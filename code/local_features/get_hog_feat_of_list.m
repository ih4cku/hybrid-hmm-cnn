function data_mat = get_hog_feat_of_list(frm_list, im_size)
% Get data matrix of all images in FRM_LIST.
% Each image is format as a row vector of IMG_SIZE.
%   
% DATA_MAT format: (n_frames, n_dim)

cellSize = 8;

hog_feat = get_hog_feat(frm_list{1}, cellSize, im_size);
vec_size = size(hog_feat(:),1);

n_frames = length(frm_list);
data_mat = single((zeros(n_frames, vec_size)));   % pre allocation
data_mat(1, :) = hog_feat(:)';

parfor i_frm = 2:n_frames
    disp(frm_list{i_frm});
    hog_feat = get_hog_feat(frm_list{i_frm}, cellSize, im_size);

    data_mat(i_frm, :) = hog_feat(:)';
end

%
function hog_feat = get_hog_feat(frm_path, cellSize, im_size)
im = imread(frm_path);
if ~(size(im, 1)==im_size(1) && size(im, 2)==im_size(2))
    im = imresize(im, im_size);
end
gray_im = single(rgb2gray(im));
hog_feat = vl_hog(gray_im, cellSize);
% why most of the max value of a feature vector is 0.4?
hog_feat = hog_feat/0.4243;