function prepare_gram(vars)

disp('====== Preparing Gram Files ======');

% sort dict as HTK required
sort_lines(vars.dict_path);

% gram -> wdnet
cmd = strjoin({'HParse' vars.global_opt vars.gram_path vars.wdnet_path});
htk_run(cmd, mfilename('fullpath'));
