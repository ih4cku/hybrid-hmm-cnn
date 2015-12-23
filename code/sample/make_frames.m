function make_frames(vars)
% Generate frames with sliding window.

% each item in IMG_SETS should be full path
vars_ds = {vars.tr, vars.te};

% process to generate train and test
for i_sub = 1:2
    % sub dataset
    ds = vars_ds{i_sub};

    if ~echek_dir_empty(ds.frms_dir)
        fprintf('Frames dir in [%s] already exist, skip.\n', ds.frms_dir);
        continue;
    end

    fprintf('Writing frames to "%s"...\n', ds.frms_dir);

    % load SAMPNAME_LIST
    load(ds.sampname_path);
    % format image name list
    im_list = strcat(sampname_list, ['.' vars.im_ext]);
    im_list = fullfile(ds.image_dir, im_list);

    % loop to process each sample
    n_img = length(im_list);
    parfor i_im = 1:n_img
        im_path = im_list{i_im};
        frms_img_dir = fullfile(ds.frms_dir, sampname_list{i_im});
        
        fprintf('%d: %s\n', i_im, im_path);
        write_frames(im_path, frms_img_dir, vars);
    end
    disp('done.');
end

function b_empty = echek_dir_empty(folder)
items = dir(folder);
b_empty = length(items)==2;