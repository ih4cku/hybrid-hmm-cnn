clear;clc

matfn = 'digitStruct.mat';

%% test
src_dir = 'E:\Datasets\SVHN\original\test';
dst_dir = 'E:\Datasets\SVHN\small\test';

matpath = fullfile(src_dir, matfn);
new_matpath = fullfile(dst_dir, matfn);

load(matpath);

% test image number
n_images = 100;
% make new .mat and copy files
digitStruct = digitStruct(1:n_images);

parfor i = 1:n_images
    src_fpath = fullfile(src_dir, digitStruct(i).name);
    dst_fpath = fullfile(dst_dir, digitStruct(i).name);
    copyfile(src_fpath, dst_fpath);
    fprintf('%s -> %s\n', src_fpath, dst_fpath);
end
save(new_matpath, 'digitStruct');
disp('Test dataset done.');

clear digitStruct;

%% train 
src_dir = 'E:\Datasets\SVHN\original\train';
dst_dir = 'E:\Datasets\SVHN\small\train';

matpath = fullfile(src_dir, matfn);
new_matpath = fullfile(dst_dir, matfn);

load(matpath);

% train images number
n_images = 1000;
% make new .mat and copy files
digitStruct = digitStruct(1:n_images);

parfor i = 1:n_images
    src_fpath = fullfile(src_dir, digitStruct(i).name);
    dst_fpath = fullfile(dst_dir, digitStruct(i).name);
    copyfile(src_fpath, dst_fpath);
    fprintf('%s -> %s\n', src_fpath, dst_fpath);
end
save(new_matpath, 'digitStruct');
disp('Train dataset done.');
