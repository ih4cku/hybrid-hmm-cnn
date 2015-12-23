function data_mat = get_lbp_feat_of_list(frm_list, im_size)
% Get data matrix of all images in FRM_LIST.
% Each image is format as a row vector of IMG_SIZE.
%   
% DATA_MAT format: (n_frames, n_dim)

%para setting

%
lbp_feat = get_lbp_feat(frm_list{1}, im_size);
vec_size = size(lbp_feat(:), 1);

n_frames = length(frm_list);
data_mat = single((zeros(n_frames, vec_size)));   % pre allocation
data_mat(1, :) = lbp_feat(:)';

parfor i_frm = 2:n_frames
    disp(frm_list{i_frm});
    lbp_feat = get_lbp_feat(frm_list{i_frm}, im_size);
    data_mat(i_frm, :) = lbp_feat(:)';
end

% 
function lbp_feat = get_lbp_feat(frm_path, im_size)

im = imread(frm_path);
if ~(size(im, 1)==im_size(1) && size(im, 2)==im_size(2))
    im = imresize(im, im_size);
end
gray_im = single(rgb2gray(im)) ;
lbp_feat = lbp(gray_im);
% Why max(dsift_feat(:)) is 255?
lbp_feat = lbp_feat/255;
