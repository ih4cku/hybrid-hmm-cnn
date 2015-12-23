function state_tying(last_dir, new_dir, vars)
disp('====== State Tying ======');

hmm_defs_path = fullfile(last_dir, vars.hmm_defs);
floor_path = fullfile(last_dir, vars.hmm_vfloors);

if ~exist(new_dir, 'dir')
    mkdir(new_dir);
end

log_path = fullfile(new_dir, 'tying.log');

cmd = strjoin({'HHed -A -D -T 7' ...
               '-H' hmm_defs_path ...
               '-H' floor_path ...
               '-M' new_dir ...
               vars.hmm_tie_script ...
               vars.phone_list ...
               ['>' log_path]});
htk_run(cmd, mfilename('fullpath'));

fprintf('log: %s\n', log_path);