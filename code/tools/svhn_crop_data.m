clear;clc;close all

root_dir    = 'D:/dataset/SVHN';
src_dir     = 'original';
dst_dir     = 'crop/original';
data_dirs   = {'extra'};
mat_file    = 'digitStruct.mat';
exp_rate    = 0.3;
norm_height = 32;
win_wid     = 10;

all_wid     = [];
all_hei     = [];
all_intval  = [];

% process each dir
for i_dir = 1:length(data_dirs)
    sub_dir = data_dirs{i_dir};
    full_src_dir = fullfile(root_dir, src_dir, sub_dir);    % src dir
    full_dst_dir = fullfile(root_dir, dst_dir, sub_dir);    % dst dir
    if ~exist(full_dst_dir, 'dir')
        mkdir(full_dst_dir);
    end
    
    mat_path = fullfile(full_src_dir, mat_file);            % digitStruct.mat
    fprintf('loading %s...', mat_path);
    load(mat_path);
    disp('done.');

    % process each image in sub_dir
    n_images = length(digitStruct);
    parfor i_im = 1:n_images
        im_src_path = fullfile(full_src_dir, digitStruct(i_im).name);   % src image path
        im_dst_path = fullfile(full_dst_dir, digitStruct(i_im).name);   % dst image path
        if exist(im_dst_path, 'file')
            continue;
        end
        
        fprintf('%d : %s\n', i_im, im_src_path);
        
        %% Cropping
        im = imread(im_src_path);
        [im_ori_hei, im_ori_wid, ~] = size(im);

        % [box]: left, top, height, width, label
        boxes = digitStruct(i_im).bbox;
        boxes = cat(1, [boxes.left], [boxes.top], [boxes.width], [boxes.height]);     % each column is a box

        n_digits = size(boxes, 2);

        % whole box: [x1, y1, x2, y2]
        whole_box = [min(boxes(1, :)), ...
                     min(boxes(2, :)), ...
                     max(boxes(1, :) + boxes(3, :)), ...
                     max(boxes(2, :) + boxes(4, :))];
        
        % show whole box
        % bbox = [whole_box(1), whole_box(2), whole_box(3)-whole_box(1)+1, whole_box(4)-whole_box(2)+1];
        
        % h = figure;
        % subplot(131); imshow(im); 
        % hold on; rectangle('Position', bbox, 'EdgeColor', 'b');

        % expansion
        whole_wid    = whole_box(3)-whole_box(1)+1;
        expansion    = ceil(exp_rate*whole_wid);
        whole_box(1) = max(1, whole_box(1)-expansion);
        whole_box(2) = max(1, whole_box(2));
        whole_box(3) = min(im_ori_wid, whole_box(3)+expansion);
        whole_box(4) = min(im_ori_hei, whole_box(4));

        % show expansion box
        bbox = [whole_box(1), whole_box(2), whole_box(3)-whole_box(1)+1, whole_box(4)-whole_box(2)+1];
        % hold on; rectangle('Position', bbox, 'EdgeColor', 'r');
        
        % im[y1:y2, x1:x2]
        im_crop = im(whole_box(2):whole_box(4), whole_box(1):whole_box(3), :);
        % subplot(132); imshow(im_crop);

        %% Post precessing
        % normalize height
        [crop_hei, crop_wid, ~] = size(im_crop);
        scale_hei= norm_height/crop_hei;
        crop_wid = round(crop_wid*scale_hei);
        crop_hei = norm_height;
        im_post  = imresize(im_crop, [crop_hei, crop_wid]);        
        
        % pad image 
        min_wid = (n_digits+2)*win_wid;
        pad_wid = max(0, ceil((min_wid-crop_wid)/2));
        im_post = padarray(im_post, [0, pad_wid], 'replicate', 'both');
        % subplot(133); imshow(im_post);

        % record width, height, space
        boxes = boxes*scale_hei;    % rescale box info
        all_wid = [all_wid, boxes(3, :)];
        all_hei = [all_hei, boxes(4, :)];
        if n_digits>1
            box_right = boxes(1, 1:end-1)+boxes(3, 1:end-1);
            box_left  = boxes(1, 2:end);
            box_interval = box_left - box_right;
            all_intval = [all_intval, box_interval];
        end

        % save image
        imwrite(im_post, im_dst_path);
        
        % close(h);
    end
    
    clear digitStruct;

end
disp('done');

