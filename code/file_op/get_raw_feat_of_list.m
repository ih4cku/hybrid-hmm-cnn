function data_mat = get_raw_feat_of_list(frm_list, im_size)
% Get data matrix of all images in FRM_LIST.
% Each image is format as a row vector of IMG_SIZE.
%   
% DATA_MAT format: (n_frames, n_dim)

n_frames = length(frm_list);
vec_size = im_size(1)*im_size(2);
data_mat = single((zeros(n_frames, vec_size)));   % pre allocation

parfor i_frm = 1:n_frames
    disp(frm_list{i_frm});
    im = imread(frm_list{i_frm});
    if ~(size(im, 1)==im_size(1) && size(im, 2)==im_size(2))
        im = imresize(im, im_size);
    end
    data_mat(i_frm, :) = single(img2row(im));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = img2row(im)
% convert image to grayscale then make it a row vector
% normalized to [0,1], return a row vector
if ndims(im)==3
    im = rgb2gray(im);
end
im = preprocess_frame(im);
r = im(:)';