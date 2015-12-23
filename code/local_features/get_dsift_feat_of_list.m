function data_mat = get_dsift_feat_of_list(frm_list, im_size)
% Get data matrix of all images in FRM_LIST.
% Each image is format as a row vector of IMG_SIZE.
%   
% DATA_MAT format: (n_frames, n_dim)


dsift_feat = get_dsift_feat(frm_list{1}, im_size);
vec_size = size(dsift_feat(:),1);

n_frames = length(frm_list);
data_mat = single((zeros(n_frames, vec_size)));   % pre allocation
data_mat(1, :) = dsift_feat(:)';

parfor i_frm = 2:n_frames
    disp(frm_list{i_frm});
    dsift_feat = get_dsift_feat(frm_list{i_frm}, im_size);
    data_mat(i_frm, :) = dsift_feat(:)';
end


%
function dsift_feat = get_dsift_feat(frm_path, im_size)
im = imread(frm_path);
if ~(size(im, 1)==im_size(1) && size(im, 2)==im_size(2))
    im = imresize(im, im_size);
end
gray_im = single(rgb2gray(im));
[~, dsift_feat] = vl_dsift(gray_im, 'Step', 3, 'FloatDescriptors');
% Why max(dsift_feat(:)) is 255?
dsift_feat = dsift_feat/255;
