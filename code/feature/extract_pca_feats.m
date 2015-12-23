function sample_data = extract_pca_feats(sample_list, ds, vars)
% Feature extraction function.
% Input: 
%   SAMPLE_LIST
%   DS
%   VARS
% Output:
%   SAMPLE_DATA : {feat_path, mlf_str, feat, label_str}

% load PCA data
fprintf('loading [%s] ...', vars.pca_data_path);
pca_vars = load(vars.pca_data_path);
disp('done.');
PC = pca_vars.PC;
sample_mean = pca_vars.sample_mean;

n_samples = length(sample_list);
sample_data = cell(n_samples, 1);
for i_im = 1:n_samples
    sample_name = sample_list{i_im, 1};
    sample_label= sample_list{i_im, 2};
    
    % get frame dir
    frm_dir = fullfile(ds.frms_dir, sample_name);
    assert(logical(exist(frm_dir, 'dir')), sprintf('Frame dir [%s] not exist.', frm_dir));
    
    % build PCA feature
    frm_list = get_image_list(frm_dir, vars.im_ext);
    feats = map_frames_to_pca(frm_list, PC, sample_mean, vars);
    
    % write PCA feature to htk file
    feat_path = fullfile(ds.samp_dir, [sample_name '.htk']);
    feat_path = norm_path(feat_path);
    
    % MLF label
    hmm_names = arrayfun(@(c) ['H' c], sample_label, 'UniformOutput', false);
    lab_path = [feat_path(1:end-3), 'lab'];
    lab_path = norm_path(lab_path);
    mlf_str = [sprintf('"%s"\n', lab_path), sprintf('%s\n', hmm_names{:}), sprintf('.')];
    
    sample_data{i_im} = {feat_path, mlf_str, feats, sample_label};
end
sample_data = cat(1, sample_data{:});
save(ds.sampdata_path, 'sample_data');


function feats = map_frames_to_pca(frm_list, PC, sample_mean, vars)
% create PCA features of frames in FRM_ROOT_DIR using trained PC and SAMPLE_MEAN
% frames_data - N x p
%          PC - p x d
% sample_mean - 1 x p
% 
%       feats - N x d

% get frame data
frames_data = vars.func_get_feat_data(frm_list, vars.frame_shape);

% rescale data
if vars.rescale
    load(vars.rescale_param_file);
    frames_data = zero_one_scale(frames_data, val_max, val_min);
end

% mean centering
frames_data = bsxfun(@minus, frames_data, sample_mean);

% PCA projection
feats = frames_data*PC;
