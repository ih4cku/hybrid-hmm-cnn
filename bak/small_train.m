% test on a small dataset

%% vars
clear;clc

n_all_mix    = 150;
separate_dir = 'mix_init';
root_dir     = 'D:/dataset/SVHN/small';

mix_vars;

% read convnet options
net_options = IniConfig();
net_options.ReadFile(vars.convnet_cfg_file);
train_res_dir    = net_options.GetValues('dataset', 'train-result-dir'); % train recognition probs dir
test_res_dir     = net_options.GetValues('dataset', 'test-result-dir');  % test recognition probs dir
train_output_dir = net_options.GetValues('dataset', 'train-output-dir');
test_output_dir  = net_options.GetValues('dataset', 'test-output-dir');

%% ----------------- GMM/HMM Training -----------------------------

%% State Tying
last_hmm_dir = fullfile(vars.hmm_dir, 'flat');
new_hmm_dir  = fullfile(vars.hmm_dir, 'hmm_tie');

% state tying
state_tying(last_hmm_dir, new_hmm_dir, vars);

% embedded training
hmm_defs_path = fullfile(new_hmm_dir, vars.hmm_defs);
floor_path = fullfile(new_hmm_dir, vars.hmm_vfloors);
cmd_train = strjoin({'HERest.exe' ...
               '-C' vars.htk_cfg_file...
               '-H' hmm_defs_path ...
               '-H' floor_path ...
               '-S' vars.tr.samp_list ...
               '-I' vars.tr.phone_mlf...
               '-M' new_hmm_dir ...
               vars.phone_list})

% decoding
cmd_decode = strjoin({'HVite.exe' vars.global_opt ...
    '-C' vars.htk_cfg_file...
    '-o SWC' ...
    '-H' hmm_defs_path ...
    '-H' floor_path ...
    '-S' vars.te.samp_list ...
    '-i' vars.te.rec_w_mlf ...
    '-w' vars.wdnet_path ...
    vars.dict_path ...
    vars.phone_list});

% evaluation
cmd_eval = strjoin({'HResults.exe' vars.global_opt ...
    '-f' ...
    '-t' ...
    '-I' vars.te.word_mlf ...
    vars.phone_list ...
    vars.te.rec_w_mlf});

cmd_rec = sprintf('%s & %s', cmd_decode, cmd_eval)

%% Forced alignment
hmm_defs_path = fullfile(new_hmm_dir, vars.hmm_defs);
floor_path    = fullfile(new_hmm_dir, vars.hmm_vfloors);

% align train set
ds = vars.tr;
cmd_align_s = strjoin({'HVite.exe' vars.global_opt ...
    '-C' vars.htk_cfg_file...
    '-a' ...
    '-f' ... 
    '-o SW' ...
    '-b SIL' ...
    '-H' hmm_defs_path ...
    '-H' floor_path ...
    '-S' ds.samp_list ...
    '-I' ds.word_mlf ...
    '-i' ds.rec_s_mlf ...
    vars.dict_path ...
    vars.phone_list})

cmd_align_w = strjoin({'HVite.exe' vars.global_opt ...
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
    vars.phone_list})

% align test set
ds = vars.te;
cmd_align_s = strjoin({'HVite.exe' vars.global_opt ...
    '-C' vars.htk_cfg_file...
    '-a' ...
    '-f' ... 
    '-o SW' ...
    '-b SIL' ...
    '-H' hmm_defs_path ...
    '-H' floor_path ...
    '-S' ds.samp_list ...
    '-I' ds.word_mlf ...
    '-i' ds.rec_s_mlf ...
    vars.dict_path ...
    vars.phone_list})

cmd_align_w = strjoin({'HVite.exe' vars.global_opt ...
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
    vars.phone_list})


%% ----------------- ConvNet Training -----------------------------
% change OPTIONS.CFG and STATE2ID_OPTIONS.INI

%% make dataset, need 'tr_rec_state_mlf'
% first time '-make-train', '-make-test'
cmd = strjoin({'python.exe' 'cuda-convnet/htkdata.py' '--make-train'})

cmd = strjoin({'python.exe' 'cuda-convnet/htkdata.py' '--make-test'})


%% save sample snapshot
% training samples
cmd = strjoin({'python.exe' 'cuda-convnet/htkshowsamples.py' ...
    '--train --save' fullfile(train_output_dir, 'snapshot')})

% test samples
cmd = strjoin({'python.exe' 'cuda-convnet/htkshowsamples.py' ...
    '--test --save' fullfile(test_output_dir, 'snapshot')})

%% Convnet Training
%   !! before training, modify layers-htk.cfg->layer.output, test-range, train-range
cmd = strjoin({'python.exe' 'cuda-convnet/convnet.py' ...
    ['--data-path=' train_output_dir]...
    ['--save-path=' vars.convnet.model_dir]...
    '--layer-def=layer/layers-conv-local-11pct.cfg' ...
    '--layer-params=layer/layer-params-conv-local-11pct.cfg' ...
    '--data-provider=cifar' ...
    '--test-freq=20'...
    '--train-range=1-3' ...
    '--test-range=4'})


%% -------- then use '-change-labels'
cmd = strjoin({'python.exe' 'cuda-convnet/htkdata.py' '--change-labels'})

%------------------------------------------------------ continuous training
% get model file pathlast_hmm_dir
model_path = get_model_path(vars.convnet.model_dir)

cmd = strjoin({'python.exe' 'cuda-convnet/convnet.py' ...
            ['--save-path=' '']...    
            '-f' model_path})

%% Show train data Prediction
cmd = strjoin({'python.exe' 'cuda-convnet/shownet.py' '-f' model_path '--show-cost=logprob --cost-idx=1'})

cmd = strjoin({'python.exe' 'cuda-convnet/shownet.py' '-f' model_path '--show-filters=conv1'})


%% ----------------- Hybrid Training ------------------------------

% Change GMM mean to SenoneID
%   Note: use ONLY ONCE
hybrid_assign_senone_ids('state2id_options.ini');

%% Write TRAIN data Prediction probs
cmd = strjoin({'python.exe' 'cuda-convnet/shownet.py' ...
    '-f' model_path ...
    '--write-features=probs' ...
    ['--feature-path=' train_res_dir]...
    ['--test-data-path=' train_output_dir]})

% write recognition frame probs for training data
cmd = strjoin({'python.exe' 'cuda-convnet/htkframeprobs.py' '-tr -s'})

%% Write TEST data Prediction probs
cmd = strjoin({'python.exe' 'cuda-convnet/shownet.py' ...
    '-f' model_path ...
    '--write-features=probs' ...
    ['--feature-path=' test_res_dir] ...
    ['--test-data-path=' test_output_dir]})

% write recognition frame probs for testing data
cmd = strjoin({'python.exe' 'cuda-convnet/htkframeprobs.py' '-te -s'})

%% Hybrid embedded training 
new_hmm_dir     = fullfile(vars.hmm_dir, 'hmm_senone');

% embedded training
hmm_defs_path = fullfile(new_hmm_dir, vars.hmm_defs);
floor_path = fullfile(new_hmm_dir, vars.hmm_vfloors);
cmd_train = strjoin({'emb_dnn_train.exe' ...
               '-C' vars.htk_cfg_file...
               '-H' hmm_defs_path ...
               '-H' floor_path ...
               '-S' vars.tr.samp_list ...
               '-I' vars.tr.phone_mlf...
               '-M' new_hmm_dir ...
               vars.phone_list})

% decoding
cmd_decode = strjoin({'hvite_dnn_test.exe' vars.global_opt ...
    '-C' vars.htk_cfg_file...
    '-o SWC' ...
    '-H' hmm_defs_path ...
    '-H' floor_path ...
    '-S' vars.te.samp_list ...
    '-i' vars.te.rec_w_mlf ...
    '-w' vars.wdnet_path ...
    vars.dict_path ...
    vars.phone_list});

% evaluation
cmd_eval = strjoin({'HResults.exe' vars.global_opt ...
    '-f' ...
    '-t' ...
    '-I' vars.te.word_mlf ...
    vars.phone_list ...
    vars.te.rec_w_mlf});

cmd_rec = sprintf('%s & %s', cmd_decode, cmd_eval)



%% Hybrid forced alignment
hmm_defs_path = fullfile(new_hmm_dir, vars.hmm_defs);
floor_path    = fullfile(new_hmm_dir, vars.hmm_vfloors);

% align train set
ds = vars.tr;
cmd_align_s = strjoin({'hvite_dnn_train.exe' vars.global_opt ...
    '-C' vars.htk_cfg_file...
    '-a' ...
    '-f' ... 
    '-o SW' ...
    '-b SIL' ...
    '-H' hmm_defs_path ...
    '-H' floor_path ...
    '-S' ds.samp_list ...
    '-I' ds.word_mlf ...
    '-i' ds.rec_s_mlf ...
    vars.dict_path ...
    vars.phone_list})

cmd_align_w = strjoin({'hvite_dnn_train.exe' vars.global_opt ...
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
    vars.phone_list})
