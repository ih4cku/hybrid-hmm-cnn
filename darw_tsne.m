clear;clc;close all
vl_setup();

frm_root_dir = 'E:\Datasets\digits\crop';

%%
frame_list_path = fullfile(frm_root_dir, 'frame_list.mat');
fprintf('Loading file list [%s].\n', frame_list_path);
load(frame_list_path);
disp('done.');

n_images = length(img_list);
label_cell = cell(n_images, 1);
for i = 1:n_images
    [pathstr, ~, ~] = fileparts(img_list{i});
    [~, lab, ~] = fileparts(pathstr);
    label_cell{i} = lab;
end
labels = unique(label_cell);
data_labels = cellfun(@(x) find(strcmp(x, labels)), label_cell)-1;
idx = randperm(n_images, 6000);

root_dir = 'E:\Datasets\SVHN\all';
mix_num = 500;
for item = {'dsift', 'raw', 'lbp', 'hog'}
    feat_name = item{1};
    vars = all_vars_func(root_dir, feat_name, mix_num);
    
    %%
    frame_data_path = fullfile(frm_root_dir, vars.f_frame_data);
    if exist(frame_data_path, 'file')
        % load frames data directly
        fprintf('Loading data matrix [%s].\n', frame_data_path);
        load(frame_data_path);
        disp('done.');
    else
        % get all frame list in training dir
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
        
        % load frames data and save to disk
        fprintf('Reading frames data...');
        frames_data = vars.func_get_feat_data(img_list, vars.frame_shape);
        if vars.rescale
            val_min = min(frames_data(:)); 
            val_max = max(frames_data(:));
            frames_data = zero_one_scale(frames_data, val_max, val_min);
        end
        disp('done.')
        
        fprintf('Saving frames data [%s]...', frame_data_path);
        save(frame_data_path, 'frames_data');
        % save rescale params
        save(vars.rescale_param_file, 'val_max', 'val_min');
        disp('done.')
    end
    
    %%
    data = frames_data(idx, :);
    label = data_labels(idx);
    mappedX = tsne(double(data), []);
    figure();
    gscatter(mappedX(:,1), mappedX(:,2), label);
    title(feat_name);
end