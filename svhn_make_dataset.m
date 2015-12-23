%%
clear;clc;close all
% vl_setup();
root_dir = '/home/paile/research/svhn_numbers';
feat_name = 'cnn';
mix_num = 100;

vars = all_vars_func(root_dir, feat_name, mix_num);

%% generate image and label lists
make_sample_label_lists(vars);

%% generate sliding window frames
make_frames(vars);

%% PCA training
% train_pca(vars);

%% make samples
% make_samples(vars);
