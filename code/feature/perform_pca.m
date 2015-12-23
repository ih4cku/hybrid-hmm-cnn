function perform_pca(data, vars)
% PERFORM_PCA(DATA, VARS) Training PCA with DATA matrix, each *row* is an 
% observation. Trained PC and SAMPLE_MEAN are saved to VARS.PCA_PATH.

% transform data to GPU
if vars.use_gpu
    fprintf('Transforming data to GPU...');
    data = gpuArray(double(data));
    disp('done.');
end

% training GPU to get vars.feat_dim principal components
fprintf('Training PCA...');
% n_comp = prod(vars.feat_dim);
% [PC, ~, ~, ~, explained, sample_mean] = pca(data, 'NumComponents', n_comp);
[PC, ~, ~, ~, explained, sample_mean] = pca(data);
disp('done.');


% saveing PC and sample_mean to disk
fprintf('Saving PCA to [%s]...', vars.pca_data_path);
if vars.use_gpu
    fprintf('\n\tTransforming GPU data to CPU...');
    PC = gather(PC);
    sample_mean = gather(sample_mean);
    explained = gather(explained);
    disp('done.');
end

% select components contain VARS.PCA_PCENT infomation
pcent = cumsum(explained);
n_comp = find(pcent>vars.pca_pcent, 1);
PC = PC(:, 1:n_comp);

save(vars.pca_data_path, 'sample_mean', 'PC', 'explained', 'n_comp');
disp('done.')