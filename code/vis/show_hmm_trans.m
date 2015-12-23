function show_hmm_trans(hmm_dir, vars)
    % show hmms transition probs
    % input:
    %   hmm_dir - dir that holds hmmdefs

    hmm_defs_path = fullfile(hmm_dir, vars.hmm_defs);

    hmms = read_htk_hmm(hmm_defs_path);
    n_hmms = length(hmms);
    for i = 1:n_hmms
        disp(['[' hmms(i).name ']----------']);
        disp(exp(hmms(i).transmat));
    end
