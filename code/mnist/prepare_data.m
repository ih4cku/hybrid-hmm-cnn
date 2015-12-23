function prepare_data(vars)

% generate train samples
gen_word_prompts(vars, 'train');
gen_samples(vars, 'train');

% generate test samples
gen_word_prompts(vars, 'test');
gen_samples(vars, 'test');

% generate word list
prompts2wlist(vars.tr.prompts, vars.word_list);

% generate phone list
cmd = strjoin({'HDMan' vars.global_opt ...
               '-w' vars.word_list ...
               '-n' vars.phone_list ...
               vars.tmp_wlist ...
               vars.dict_path});
htk_run(cmd, mfilename('fullpath'));
sort_lines(vars.phone_list);

% convert word level MLF to phone level MLF, save to tr_phone_mlf
cmd = strjoin({'HLEd' vars.global_opt ...
               '-i' vars.tr.phone_mlf ...
               '-d' vars.dict_path ...
               vars.mlf_edit_script ...
               vars.tr.word_mlf});
htk_run(cmd, mfilename('fullpath'));
