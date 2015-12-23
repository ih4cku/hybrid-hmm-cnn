clear; clc;

%% htk configuration
n_all_mix    = 200;
separate_dir = ['mix' num2str(n_all_mix)];

svhn_vars_mix;
hmm_dir  = fullfile(vars.hmm_dir, 'flat');      % start with flat hmms

%% decoding 
hmm_defs_path = fullfile(hmm_dir, vars.hmm_defs);
floor_path    = fullfile(hmm_dir, vars.hmm_vfloors);

cmd_decode = strjoin({'HVite.exe' vars.global_opt ...
    '-C' vars.htk_cfg_file...
    '-o SWC' ...
    '-H' hmm_defs_path ...
    '-H' floor_path ...
    '-S' vars.te.samp_list ...
    '-i' vars.te.rec_w_mlf ...
    '-w' vars.wdnet_path ...
    vars.dict_path ...
    vars.phone_list})

% evaluation
cmd_eval = strjoin({'HResults.exe' vars.global_opt ...
    '-f' ...
    '-t' ...
    '-I' vars.te.word_mlf ...
    vars.phone_list ...
    vars.te.rec_w_mlf})