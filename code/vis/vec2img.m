function img_mat = vec2img(vec_mat, im_shape, mode)
% each row of VEC_MAT is a sample
% IMG_MAT is sort first on column then on row
if nargin<3
    mode = 'row';
end

n_images = size(vec_mat, 1);
[n_row, n_col] = get_subplot_layout(n_images, im_shape(2)/im_shape(1));
n_plot = n_row*n_col;
all_img = cell(n_row, n_col);
for i_im = 1:n_plot
    switch mode
        case 'row'
            i = ceil(i_im/n_col);
            j = i_im-(i-1)*n_col;
        case 'col'
            [i,j] = ind2sub([n_row, n_col], i_im);
        otherwise
            error('Not supported mode.');
    end

    if i_im>n_images
        all_img{i,j} = draw_bbox(zeros(im_shape));
    else
        all_img{i,j} = draw_bbox(reshape(vec_mat(i_im, :), im_shape));
    end
end

img_mat = im2uint8(cell2mat(all_img));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function im = draw_bbox(im)
% draw a boundary around each image
if max(im(:)) > 1
    im = im2double(uint8(im));
end
pix = 0.7;
if ismatrix(im)
    im(end, :)=pix;
    im(:, end)=pix;
else
    im(end, :, 1)=pix;
    im(end, :, 2)=pix;
    im(end, :, 3)=pix;
    im(:, end, 1)=pix;
    im(:, end, 2)=pix;
    im(:, end, 3)=pix;
end