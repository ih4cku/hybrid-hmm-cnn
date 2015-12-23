function prepare_svhn_data(original_dir, feat_root_dir, frame_root_dir, f_samp_path, f_mlf_path, vars)
% extract PCA features for all frames in FRAME_

% load digitStructure.mat
dataset_label_path = fullfile(original_dir, 'digitStruct.mat');
fprintf('loading [%s] ...', dataset_label_path);
load(dataset_label_path);
disp('done.');

% load PCA data
fprintf('loading [%s] ...', vars.pca_data_path);
load(vars.pca_data_path);
disp('done.');

% Main Loop
fprintf('Generating features...');
[samppath_to_write, mlflabel_to_write] = main_loop(digitStruct, PC, sample_mean, feat_root_dir, frame_root_dir, vars);
disp('done.');

% write infomation to file
fprintf('Writing to file...')
f_list = safefopen(f_samp_path, 'w');
cellfun(@(p) fprintf(f_list, '%s\n', p), samppath_to_write);

f_mlf  = safefopen(f_mlf_path, 'w');
fprintf(f_mlf, '#!MLF!#\n');
cellfun(@(p) fprintf(f_mlf, '%s\n', p), mlflabel_to_write);
disp('done');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [samppath_to_write, mlflabel_to_write] = main_loop(digitStruct, PC, sample_mean, feat_root_dir, frame_root_dir, vars)
% extract PCA features for each image
HTKCode = 9;

n_images = length(digitStruct);
samppath_to_write = cell(n_images, 1);
mlflabel_to_write = cell(n_images, 1);
parfor i_im = 1:n_images
    img_name = digitStruct(i_im).name;
    img_mainname = img_name(1:end-4);

    % get frame dir
    frmd = fullfile(frame_root_dir, img_mainname);
    assert(logical(exist(frmd, 'dir')), sprintf('Frame dir [%s] not exist.', frmd));
    
    % build PCA feature
    feats = extract_pca_feats(frmd, PC, sample_mean, vars);

    % write PCA feature to htk file
    feat_path = fullfile(feat_root_dir, [img_mainname '.htk']);
    htkwrite(feats, feat_path, HTKCode); 
    feat_path = norm_path(feat_path);
    % save feature path to be written
    samppath_to_write{i_im} = feat_path;

    % label
    hmm_names = label_mapping([digitStruct(i_im).bbox.label]);

    % write MLF label
    lab_path = [feat_path(1:end-3), 'lab'];
    lab_path = norm_path(lab_path);
    mlflabel_to_write{i_im} = [sprintf('"%s"\n', lab_path), sprintf('%s\n', hmm_names{:}), sprintf('.')];
    % disp(frmd);
end



