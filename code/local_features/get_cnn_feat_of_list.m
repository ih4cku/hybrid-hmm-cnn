function data_mat = get_cnn_feat_of_list(frm_list, im_size)
% Get data matrix of all images in FRM_LIST.
% Each image is format as a row vector of IMG_SIZE.
%   
% DATA_MAT format: (n_frames, n_dim)

% protocol 
%   - model is saved in 'pretrained'
%   - frames list file is in 'temp/tmp_frm_list.txt'
%   - all batche files are format 'temp/data_batch_x'
%   - features are write to the same 'temp/data_batch_x' file
%   - all features are then concatenate to one Numpy array save as Matlab
%     format file 'temp/feat.mat'


% create temp directory to hold all files
output_path = tempname('temp');
mkdir(output_path);
feature_path = fullfile(output_path, 'features');
mkdir(feature_path);

% create frame images list
frm_list_path = fullfile(output_path, 'tmp_frm_list.txt');
fid = fopen(frm_list_path, 'w');
fprintf(fid, '%s\n', frm_list{:});
fclose(fid);

% call python to use pretrained model to generate features
cmd = sprintf('python.exe python/htkcnnfeature.py -f pretrained --test-data-path=%s --feature-path=%s --write-features=fc1', output_path, feature_path);
system(cmd);

% load dumped mat file
feat_mat_path = fullfile(output_path, 'feat.mat');
feat_mat = load(feat_mat_path);
data_mat = feat_mat.feat_arr;

% remove temp directory
rmdir(output_path, 's');

