function write_config(vars)
% write convnet options
convnet_cfg_path = vars.convnet.cfg_file;
write_convnet_config(convnet_cfg_path, vars);

% write senone mapping config file
senone_cfg_path = vars.senone_cfg_path;
write_senonne_config(senone_cfg_path, vars);



function write_convnet_config(cfg_path, vars)

fprintf('Creating ConvNet config file [%s]...', cfg_path);

f = fopen(cfg_path, 'w');
fprintf(f, '[dataset]\n');

fprintf(f, 'hmmdefs-path=%s\n', fullfile(vars.tie_hmm_dir, vars.hmm_defs));
fprintf(f, 'train-label-path=%s\n', vars.tr.rec_s_mlf);
fprintf(f, 'test-label-path=%s\n', vars.te.rec_s_mlf);

fprintf(f, 'train-frame-dir=%s\n', fullfile(vars.tr.frms_dir));
fprintf(f, 'test-frame-dir=%s\n', fullfile(vars.te.frms_dir));

fprintf(f, 'train-output-dir=%s\n', vars.convnet.tr.batches_dir);
fprintf(f, 'test-output-dir=%s\n', vars.convnet.te.batches_dir);

fprintf(f, 'filenames-and-labels=%s\n', 'filenames_and_labels.pickle');

fprintf(f, 'train-result-dir=%s\n', vars.convnet.tr.results_dir);
fprintf(f, 'test-result-dir=%s\n', vars.convnet.te.results_dir);

fprintf(f, 'state-prior-probs-path =%s\n', fullfile(vars.convnet.tr.root_dir, 'state_priors.pickle'));
fprintf(f, 'train-frame-probs-path =%s\n', fullfile(vars.convnet.tr.root_dir, 'frame_probs.pickle'));
fprintf(f, 'test-frame-probs-path  =%s\n', fullfile(vars.convnet.te.root_dir, 'frame_probs.pickle'));

fprintf(f, 'pattern=*.%s\n', vars.im_ext);
fprintf(f, 'channels=%d\n', vars.convnet.channels);
fprintf(f, 'batch-size=%d\n', vars.convnet.batch_size);
fprintf(f, 'size=(32, 32)\n');

fclose(f);
disp('done.');


function write_senonne_config(cfg_path, vars)

fprintf('Creating senone mapping config file [%s]...', cfg_path);
f = fopen(cfg_path, 'w');

fprintf(f, 'convnet-config-file=%s\n', norm_path(vars.convnet.cfg_file));
fprintf(f, 'input-hmms-dir  = %s\n', vars.tie_hmm_dir);
fprintf(f, 'output-hmms-dir = %s\n', vars.senone_hmm_dir);
fprintf(f, 'hmm-list        = %s\n', vars.phone_list);

fclose(f);
disp('done.');
