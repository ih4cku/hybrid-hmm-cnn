clear;clc;close all

% params
htk_ext     = 'htk';
mnist_file  = 'mnist_all.mat';
label_set   = num2cell('0' : '9');

% load MNIST
ds = load(mnist_file);

char_set_names = fieldnames(ds);
disp('Extracting features...');
cellfun(@(f_name) proc_mnist_set(f_name, ds), char_set_names);

disp('Done.');