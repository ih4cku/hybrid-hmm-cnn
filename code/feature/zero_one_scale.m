function data_mat = zero_one_scale(data_mat, vmax, vmin)
% recale the data matrix to [0~1]

data_mat = (data_mat-vmin)/(vmax-vmin);

