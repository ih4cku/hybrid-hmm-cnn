% crop  im_wid digital patch
clear;clc;close all

im_wid = 12;

src_dir = 'E:\Datasets\digits\original';
dst_dir = 'E:\Datasets\digits\crop';
if ~exist(dst_dir ,'dir')
    mkdir(dst_dir);
end

list_path = fullfile(src_dir,'frame_list.mat');

load(list_path);

digits_num = size(img_list,1);
parfor i = 1:digits_num;
    im = imread(img_list{i});
    width = size(im,2);
    crop_im = im(:,(width - im_wid)/2+1:(width + im_wid)/2,:);
    [im_path,im_name,im_ext] = fileparts(img_list{i});
    [first_dir,first_dir_name,ext] = fileparts(im_path);
    crop_im_dir = fullfile(dst_dir,first_dir_name);
    crop_im_path = fullfile(crop_im_dir, [im_name,im_ext]);
    if ~exist(crop_im_dir ,'dir')
        mkdir(crop_im_dir);
    end
    imwrite(crop_im,crop_im_path);
    img_list{i} = crop_im_path;
end

save(fullfile(dst_dir,'frame_list.mat') ,'img_list');