function cleanhtk(vars)

% clean grammer files
delete(vars.wdnet_path);
delete(vars.phone_list);
delete(vars.word_list);
delete(vars.tmp_wlist);

% clean phone mlf
delete(vars.tr.phone_mlf);

% clean recognition result
delete(vars.tr.rec_w_mlf);
delete(vars.tr.rec_s_mlf);
delete(vars.te.rec_w_mlf);
delete(vars.te.rec_s_mlf);

% clean hmms
rmdir(vars.hmm_dir, 's');
