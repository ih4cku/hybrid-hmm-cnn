function make_samples(vars)
vars_ds = {vars.te, vars.tr};

% below:
%   |-SAMPLE_LIST : {{tr_samp_name, tr_samp_label};
%   |                {te_samp_name, te_samp_label}}
%   |-SAMP_LABEL is a char array: '013'

for i_ds = 1:2
    ds = vars_ds{i_ds};

    % SAMPNAME_LIST
    load(ds.sampname_path);
    % SAMPLABEL_LIST
    load(ds.samplabel_path);

    sample_list = cat(2, sampname_list(:), samplabel_list(:));
    clear sampname_list samplabel_list

    % Main Loop
    fprintf('Generating samples...');
    sample_data = extract_pca_feats_batch(sample_list, ds, vars);

    % write samples
    write_samples(sample_data, ds.samp_list, ds.word_mlf);
end
disp('done.');

