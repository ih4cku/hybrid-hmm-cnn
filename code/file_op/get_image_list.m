function img_paths = get_image_list(img_dir, im_ext)
% IMG_PATH = GET_IMAGE_LIST(IMG_DIR, IM_EXT) Get all files path in IMG_DIR with 
% extension name IM_EXT. If all the image file names are numbers, then the files 
% are sorted as the number.
% 
% This function also save a snapshot of the result in the folder as 
% 'image_list.mat'.
% 
% Return:
%   IMG_PATHS - a cell contains the paths of all files.

file_list = fullfile(img_dir, 'image_list.mat');
if exist(file_list, 'file')
    fprintf('Loading images from [%s]...', file_list);
    load(file_list);
else
    % get files' path list in IMG_DIR
    disp(['Loading images from ' img_dir '...']);
    img_list = dir(fullfile(img_dir, ['*.' im_ext]));
    n_img = length(img_list);
    img_paths = cell(n_img, 1);
    img_num = zeros(n_img, 1);
    
    parfor i = 1:n_img
        img_paths{i} = fullfile(img_dir, img_list(i).name);
        img_num(i) = str2double(get_main_name(img_paths{i}));
    end
    
    % sort images by there file names
    if ~any(isnan(img_num))
        [~, order] = sort(img_num);
        img_paths = img_paths(order);
    end
    save(file_list, 'img_paths');
end


disp('done.')