clear;clc;close all

src_dir = 'E:\Datasets\SVHN\all\images\train_bak';
dst_dir = 'E:\Datasets\SVHN\all\images\train';

samp_range = [202354:235755];
n_samp = length(samp_range);

parfor i = 1:n_samp
    src_file = fullfile(src_dir, sprintf('%d.png', samp_range(i)));
    dst_file = fullfile(dst_dir, sprintf('%d.png', i));
    copyfile(src_file, dst_file);
    fprintf('%s -> %s\n', src_file, dst_file);
end
disp('done.');
