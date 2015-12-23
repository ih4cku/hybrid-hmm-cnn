function normalize_image_height(im_path, norm_height)
% NORMALIZE_IMAGE_HEIGHT(IM_PATH, NORM_HEIGHT) Read image, normalize its height 
% while preserving scale ratio. Normalized image will overwrite the original 
% image.

im = imread(im_path);
im = im2double(im);
[im_hei, im_wid, ~] = size(im);

% normalize image height to norm_height
s = norm_height/im_hei;
if s~=1
    im_wid = ceil(im_wid*s);
    im_hei = norm_height;
    im = imresize(im, [im_hei, im_wid]);
    imwrite(im, im_path);
end

