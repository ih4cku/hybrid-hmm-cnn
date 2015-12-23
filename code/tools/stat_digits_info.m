clear;clc

mat_path = 'D:/dataset/SVHN/crop/original/test/digitStruct.mat';
load(mat_path);

n_digits = arrayfun(@(x) length(x.bbox), digitStruct);
[n, c] = hist(n_digits, [1:6]);