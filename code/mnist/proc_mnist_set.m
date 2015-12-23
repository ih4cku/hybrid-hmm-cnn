function proc_mnist_set(field, ds)
% Generate feature and write to HTK format file
% Input:
%   field - a set name of MNIST dataset 
%   ds    - MNIST data
im_size     = [28, 28];
HTKCode     = 9;

char_data   = ds.(field);

% create folders
data_dir = fullfile('data', field(1:end-1), field(end));
if ~exist(data_dir, 'dir')
    mkdir(data_dir);
end
feat_dir = fullfile('feat', field(1:end-1), field(end));
if ~exist(feat_dir, 'dir')
    mkdir(feat_dir);
end

n_data = size(char_data, 1);
for i = 1 : n_data
    main_name = sprintf('%d', i);
    data_path = fullfile(data_dir, [main_name, '.bmp']);
    feat_path = fullfile(feat_dir, [main_name, '.htk']);
    
    % extract features
    im_vec = char_data(i, :);
    
    im = mnist_preprocess(im_vec, im_size);
    imwrite(im, data_path);
    
    feats = extr_image_feats(im);
    
    % write to HTK param file
    htkwrite(feats, feat_path, HTKCode);
end
