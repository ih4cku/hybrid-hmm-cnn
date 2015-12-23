function generate_lists(vars)

disp('====== Generating List Files ======');

fprintf('Writing H0-H9 to [%s]...\n', vars.word_list);
f_wl = safefopen(vars.word_list, 'w');
for i = 0:9
    fprintf(f_wl, 'H%d\n', i);
end
fprintf(f_wl, 'SIL\n');
% fprintf(f_wl, 'SP\n');
disp('done.');


% generate phone list
fprintf('Generating phone list to [%s]...\n', vars.phone_list);
cmd = strjoin({'HDMan' vars.global_opt ...
               '-w' vars.word_list ...
               '-n' vars.phone_list ...
               vars.tmp_wlist ...
               vars.dict_path});
htk_run(cmd, mfilename('fullpath'));
sort_lines(vars.phone_list);
disp('done.');

% expand words mlf to phones mlf
fprintf('Expanding words to phones [%s]...\n', vars.tr.word_mlf);
cmd = strjoin({'HLEd' vars.global_opt ...
               '-i' vars.tr.phone_mlf ...
               '-d' vars.dict_path ...
               vars.mlf_edit_script ...
               vars.tr.word_mlf});
htk_run(cmd, mfilename('fullpath'));
disp('done.');
