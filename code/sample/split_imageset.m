function img_set_split = split_imageset(im_all_list, train_rate)
% split IM_ALL_LIST to train and test set
% TRAIN_RATE is portion of training images

n_images    = length(im_all_list);
n_train     = ceil(n_images*train_rate);
idx_train   = randperm(n_images, n_train);
idx_test    = setdiff(1:n_images, idx_train);
img_set_split = {im_all_list(idx_train), im_all_list(idx_test)};