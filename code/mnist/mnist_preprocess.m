function im = mnist_preprocess(im_vec, im_size)
% do normalization
im = reshape(im_vec, im_size);

im = permute(im,[2 1]);
im = im2bw(im);
