function sample_data = extract_pca_feats_batch(sample_list, ds, vars)
% Construct samples of DS.
% VARS.USE_PCA controls use PCA or original features.
% 
% Parameters:
%   SAMPLE_LIST - {sample_name, sample_label}
%   DS          - data set variables with the sample list.
% 
% Return:
%   SAMPLE_DATA - {feat_path, mlf_str, feats, sample_label};

n_samples = length(sample_list);

all_frm_counts  = zeros(n_samples, 1);
all_frm_list    = cell(n_samples, 1);
feat_path_list  = cell(n_samples, 1);
mlf_list        = cell(n_samples, 1);

parfor i_im = 1:n_samples
    sample_name = sample_list{i_im, 1};
    sample_label= sample_list{i_im, 2};
    
    % Get sample dir
    frm_dir = fullfile(ds.frms_dir, sample_name);
    assert(logical(exist(frm_dir, 'dir')), sprintf('Frame dir [%s] not exist.', frm_dir));

    % Get frame list in frame dir
    frm_list = get_image_list(frm_dir, vars.im_ext);
    all_frm_counts(i_im) = length(frm_list);
    all_frm_list{i_im} = frm_list;

    % HTK file path
    feat_path = fullfile(ds.samp_dir, [sample_name '.htk']);
    feat_path_list{i_im} = norm_path(feat_path);

    % MLF label
    hmm_names = arrayfun(@(c) ['H' c], sample_label, 'UniformOutput', false);
    lab_path = [feat_path(1:end-3), 'lab'];
    lab_path = norm_path(lab_path);
    mlf_str = [sprintf('"%s"\n', lab_path), sprintf('%s\n', hmm_names{:}), sprintf('.')];
    mlf_list{i_im} = mlf_str;
end

% Get features of frames
all_frm_list = cat(1, all_frm_list{:});
feat_mat = get_raw_feature(all_frm_list, vars);
if vars.use_pca
    feat_mat = map_frames_to_pca(feat_mat, vars);
end

%   construct SAMPLE_DATA
feat_cell = cell(n_samples, 1);
idx_end   = cumsum(all_frm_counts);
idx_beg   = [1;idx_end(1:end-1)+1];
for i = 1:n_samples
    feat_cell{i} = feat_mat(idx_beg(i):idx_end(i), :);
end

% Write smaples to disk
    % sample_data{i_im} = {feat_path, mlf_str, feats, sample_label};
sample_data = cat(2, feat_path_list, mlf_list, feat_cell, sample_list(:, 2));
save(ds.sampdata_path, 'sample_data');


function feats = map_frames_to_pca(frames_data, vars)
% Create PCA features of FRAMES_DATA using trained PC and SAMPLE_MEAN.
% 
% frames_data - N x p
%          PC - p x d
% sample_mean - 1 x p
% 
% Return:
%       feats - N x d

%   load PCA data
fprintf('loading [%s] ...', vars.pca_data_path);
pca_vars = load(vars.pca_data_path);
disp('done.');

PC = pca_vars.PC;
sample_mean = pca_vars.sample_mean;

% mean centering
frames_data = bsxfun(@minus, frames_data, sample_mean);

% PCA projection
feats = frames_data*PC;



function frames_data = get_raw_feature(frm_list, vars)
% Get feature matrix FRAMES_DATA and rescale data.

% get frame data
frames_data = vars.func_get_feat_data(frm_list, vars.frame_shape);

% rescale data
if vars.rescale
    load(vars.rescale_param_file);
    frames_data = zero_one_scale(frames_data, val_max, val_min);
end