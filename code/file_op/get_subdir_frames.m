function frame_list = get_subdir_frames(data_dir, im_ext)
% FRAME_LIST = GET_SUBDIR_FRAMES(DATA_DIR, IM_EXT) Get all frames images full 
% path in DATA_DIR's all sub directories.

% % parfor version
% assert(~isempty(gcp('nocreate')), 'Parallel pool not created yet.');

sub_dirs  = dir(data_dir);
sub_dirs  = {sub_dirs(3:end).name}';
n_subdirs = length(sub_dirs);
frame_list = cell(n_subdirs, 1);    % pre allocation
parfor i_d = 1:n_subdirs
    frame_list{i_d} = get_image_list(fullfile(data_dir, sub_dirs{i_d}), im_ext);
end
frame_list = cat(1, frame_list{:});
