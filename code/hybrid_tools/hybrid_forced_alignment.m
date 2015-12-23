function hybrid_forced_alignment(new_hmm_dir, vars, ds_flag)

hmm_defs_path = fullfile(new_hmm_dir, vars.hmm_defs);
floor_path    = fullfile(new_hmm_dir, vars.hmm_vfloors);

switch ds_flag
case 'train'
    ds = vars.tr;
case 'test'
    ds = vars.te;
otherwise
    error('wrong parameter.')
end

% for state alignment, -o not use C
log_path = fullfile(new_hmm_dir, ['hybrid_align_' ds_flag '_state.log']);
cmd = strjoin({'hvite_dnn_train.exe' vars.global_opt ...
               '-C' vars.htk_cfg_file...
               '-a' ...
               '-f' ...
               '-o SW' ...
               '-b SIL' ...
               '-H' hmm_defs_path...
               '-H' floor_path ...
               '-S' vars.tr.samp_list ...
               '-I' vars.tr.word_mlf...
               '-i' vars.tr.rec_s_mlf ...
               vars.dict_path ...
               vars.phone_list ...
               ['>' log_path]});
htk_run(cmd, mfilename('fullpath'));
fprintf('log: %s\n', log_path);

% for visualization, -o use C
log_path = fullfile(new_hmm_dir, ['hybrid_align_' ds_flag '_word.log']);
cmd = strjoin({'hvite_dnn_train.exe' vars.global_opt ...
    '-C' vars.htk_cfg_file...
    '-a' ...
    '-o SWC' ...
    '-b SIL' ...
    '-H' hmm_defs_path ...
    '-H' floor_path ...
    '-S' ds.samp_list ...
    '-I' ds.word_mlf ...
    '-i' ds.rec_w_mlf ...
    vars.dict_path ...
    vars.phone_list...
    ['>' log_path]});
htk_run(cmd, mfilename('fullpath'));
fprintf('log: %s\n', log_path);
