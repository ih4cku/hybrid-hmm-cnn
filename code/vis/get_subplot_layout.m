function [n_row, n_col] = get_subplot_layout(n_im, scale)
% aim to make the subplot more tight
% sclae is im_wid/im_hei

scale = scale*1/2;

n_col = ceil(sqrt(n_im/scale));
n_row = ceil(n_im/n_col);
n_col = ceil(n_im/n_row);
