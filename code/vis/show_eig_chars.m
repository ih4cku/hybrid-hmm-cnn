% show learned eigen vectors 
function show_eig_chars(vars)
% show eigen vectors
load(vars.pca_data_path);

n_comp = prod(vars.feat_dim);
[n_row, n_col] = get_subplot_layout(n_comp, 0.5);
h = figure;
for i = 1:vars.feat_dim
    m = PC(:, i);
    m = reshape(m, vars.frame_shape);
    im = mat2gray(m);
    subplot(n_row, n_col, i); imshow(im); title(sprintf('%d\n%.2f',i,explained(i)));
end