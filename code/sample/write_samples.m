function write_samples(sample_data, list_path, mlf_path)
% write feature to htk file
% Input:
%   sample_data - {feat_path, label, feat}

% write sample path list
fprintf('Writing to file [%s]...', list_path);
f_list = safefopen(list_path, 'w');
cellfun(@(p) fprintf(f_list, '%s\n', p), sample_data(:, 1));
disp('done.');

% write sampel label list
fprintf('Writing to file [%s]...', mlf_path);
f_mlf  = safefopen(mlf_path, 'w');
fprintf(f_mlf, '#!MLF!#\n');
cellfun(@(p) fprintf(f_mlf, '%s\n', p), sample_data(:, 2));
disp('done.');

% write feature
% TODO: optimize to parfor
HTKCode = 9;    % USER
n_sample = length(sample_data);
fprintf('Writing htk files...');
parfor i_samp = 1:n_sample
    htkwrite(sample_data{i_samp, 3}, sample_data{i_samp, 1}, HTKCode); 
end
disp('done');
