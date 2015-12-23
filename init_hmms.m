%%
clear;clc

%! Prepare GRAM and ORIGINAL folders first !%
root_dir = 'E:\Datasets\SVHN\all';
feat_name_list = {'cnn'};
mix_num_list = [100, 500, 800];

combs = {};
for i = 1:length(feat_name_list)
    for j = 1:length(mix_num_list)
        combs{end+1, 1} = {feat_name_list{i}, mix_num_list(j)};
    end
end

n_combs = length(combs);
parfor i_comb = 1:n_combs
    item = combs{i_comb};
    feat_name = item{1};
    mix_num = item{2};
    
    vars = all_vars_func(root_dir, feat_name, mix_num);
    write_config(vars);
    
    % prepare wdnet
    prepare_gram(vars);
    
    % generate word list
    generate_lists(vars);
    
    % init HMM models
    init_hmm_model(vars);
end
