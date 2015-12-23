%%
clear;clc;close all
vl_setup();
root_dir = 'E:\Datasets\SVHN\all';
feat_name = 'cnn';
all_vars;

%% get image and label list
make_sample_label_lists(vars);

%% make frames
make_frames(vars);

%% PCA training
train_pca(vars);

%% make samples
make_samples(vars);
