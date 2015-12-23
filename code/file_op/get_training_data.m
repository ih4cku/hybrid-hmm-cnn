function frames_data = get_training_data(frm_root_dir, vars)
% FRAMES_DATA = GET_TRAINING_DATA(FRM_ROOT_DIR, VARS) Get feature matrix of all 
% frames in FRM_ROOT_DIR's sub directories.

frame_data_path = fullfile(frm_root_dir, vars.f_frame_data);
if exist(frame_data_path, 'file')
    % load frames data directly
    fprintf('Loading frames data matrix [%s]...', frame_data_path);
    load(frame_data_path);
    disp('done.')
else
    % get all frame list in training dir
    frame_list_path = fullfile(frm_root_dir, vars.f_frame_list);
    if exist(frame_list_path, 'file')
        % load frame list directly
        fprintf('loading frames list [%s]...', frame_list_path);
        load(frame_list_path);
        disp('done.');
    else
        fprintf('getting image list in [%s]...', frm_root_dir);
        img_list = get_subdir_frames(frm_root_dir, vars.im_ext);
        disp('done.');
        fprintf('saveing img_list to [%s]...', frame_list_path);
        save(frame_list_path, 'img_list');
        disp('done.');
    end

    % load frames feature data and save to mat
    fprintf('Reading frames data...');
    frames_data = vars.func_get_feat_data(img_list, vars.frame_shape);
    if vars.vars.rescale
        val_min = min(frames_data(:));
        val_max = max(frames_data(:));
        frames_data = zero_one_scale(frames_data, val_max, val_min);
        save(vars.rescale_param_file, 'val_max', 'val_min');
    end
    disp('done.')
    
    fprintf('Saving frames data [%s]...', frame_data_path);
    save(frame_data_path, 'frames_data');
    disp('done.')
end

