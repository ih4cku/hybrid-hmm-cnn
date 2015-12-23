function avg_logprob = emb_training(last_dir, new_dir, vars)
% Embedded training with HERest

hmm_defs_path = fullfile(last_dir, vars.hmm_defs);
floor_path = fullfile(last_dir, vars.hmm_vfloors);

if ~exist(new_dir, 'dir')
    mkdir(new_dir);
end

% log_path = fullfile(new_dir, 'emb.log');

cmd = strjoin({'HERest' ...
               '-C' vars.htk_cfg_file...
               '-H' hmm_defs_path ...
               '-H' floor_path ...
               '-S' vars.tr.samp_list ...
               '-I' vars.tr.phone_mlf...
               '-M' new_dir ...
               vars.phone_list});
               % ['>' log_path]});
cmdout = htk_run(cmd, mfilename('fullpath'));
disp('done');

fprintf('Getting training log-likelihood...');
cmdout = cmdout(end-200:end);
avg_logprob = get_emb_res(cmdout);
disp('done.');