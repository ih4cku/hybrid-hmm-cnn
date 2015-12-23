root_dir  = 'E:\Datasets\SVHN\all';
feat_name = 'cnn';
mix_num   = 500;

%% global params
vars.root_dir           = root_dir;
n_all_mix               = mix_num;
vars.feat_name          = feat_name;

%% sliding window params
vars.norm_height        = 32;
vars.win_wid            = 12;
vars.n_overlap          = 6;
vars.im_ext             = 'png';

%% feature extraction function
switch vars.feat_name
    case 'raw'
        vars.func_get_feat_data = @get_raw_feat_of_list;
    case 'dsift'
        vars.func_get_feat_data = @get_dsift_feat_of_list;
    case 'hog'
        vars.func_get_feat_data = @get_hog_feat_of_list;
    case 'lbp'
        vars.func_get_feat_data = @get_lbp_feat_of_list;
    case 'cnn'
        vars.func_get_feat_data = @get_cnn_feat_of_list;
    otherwise
        error('Wrong feature name in VARS.')
end

% mkdir('temp');

%% sample params
vars.image_dir          = fullfile(vars.root_dir, 'images');
vars.data_dir           = fullfile(vars.root_dir, 'data');                                                      mkdir(vars.data_dir);
vars.sliding_dir        = fullfile(vars.data_dir, sprintf('win_%d_%d', vars.win_wid, vars.n_overlap));          mkdir(vars.sliding_dir)
vars.feat_data_dir      = fullfile(vars.sliding_dir, vars.feat_name);                                           mkdir(vars.feat_data_dir);
vars.n_tr_init          = 10000;                       % number of samples used to init hmm, -1 for all
vars.tr_init_list       = fullfile(vars.feat_data_dir, 'tr_init_list.txt');
vars.rescale_param_file = fullfile(vars.feat_data_dir, 'rescale.mat');

% separate dir for different experiment
vars.htk_dir            = fullfile(vars.root_dir, 'htk', vars.feat_name, sprintf('mix_%d', n_all_mix));    mkdir(vars.htk_dir);

% samples and frames dir
vars.sample_dir         = fullfile(vars.feat_data_dir, 'features');   cellfun(@mkdir, fullfile(vars.sample_dir, {'train', 'test'}));
vars.frames_dir         = fullfile(vars.sliding_dir, 'frames');       cellfun(@mkdir, fullfile(vars.frames_dir, {'train', 'test'}));

%% PCA training params
vars.use_pca            = true;
vars.use_gpu            = false;                     % use GPU to training PCA
% vars.feat_dim         = 60;                       % number of PC, also feature dimension
vars.pca_pcent          = 95;                       % percentage of infomation hold in PCA components
vars.n_pca_sample       = 10000;                    % number of samples to compute PCA, -1 for all images
vars.frame_shape        = [vars.norm_height, vars.win_wid];                % used to vectorize image, only [height, width]


vars.f_frame_list       = 'frame_list.mat';         % file name of all frames list mat
vars.f_frame_data       = [vars.feat_name '_frame_data.mat'];         % file name of frames data matrix mat
vars.f_sampname_list    = 'sampname_list.mat';
vars.f_samplabel_list   = 'samplabel_list.mat';
vars.f_image_list       = 'image_list.mat';
vars.f_sample_data      = 'sample_data.mat';
vars.pca_data_path      = fullfile(vars.sample_dir,'PCA.mat');                % file name of PC and sample_mean mat


%% HTK params
vars.global_opt         = '-A -T 1';                % global command options
vars.htk_cfg_file       = 'htkconf.ini';

% HMM params
vars.n_char_state       = 3;                        % state number of characters
vars.n_char_mix         = n_all_mix;
vars.n_sil_state        = 1;
vars.n_sil_mix          = n_all_mix;
vars.use_tee            = false;

% htk dirs
vars.gram_dir           = fullfile(vars.root_dir, 'gram');   mkdir(vars.gram_dir);
vars.label_dir          = fullfile(vars.htk_dir, 'label');   mkdir(vars.label_dir);
vars.hmm_dir            = fullfile(vars.htk_dir, 'hmms');    mkdir(vars.hmm_dir);

% htk files
vars.senone_cfg_path    = fullfile(vars.hmm_dir, 'state2id.ini');

vars.dict_path          = fullfile(vars.gram_dir, 'dict.txt');          % dictionary
vars.gram_path          = fullfile(vars.gram_dir, 'gram.txt');          % sentence grammar
vars.wdnet_path         = fullfile(vars.gram_dir, 'wdnet.txt');         % word network 

vars.mlf_edit_script    = fullfile(vars.gram_dir, 'expand_words.led');  % for generating phone list with HDMan 
vars.hmm_tie_script     = fullfile(vars.gram_dir, 'tie.hed');           % for tie HMM states
vars.hmm_tee_script     = fullfile(vars.gram_dir, 'tee.hed');
vars.hmm_post_script    = fullfile(vars.gram_dir, 'post.hed');
vars.phone_list         = fullfile(vars.gram_dir, 'phones.txt');        % phone list
vars.word_list          = fullfile(vars.gram_dir, 'words.txt');         % train word list
vars.tmp_wlist          = fullfile(vars.gram_dir, 'tmp_wlist.txt');     % temp dict

% train parameters
vars.tr.image_dir       = fullfile(vars.image_dir, 'train');
vars.tr.samp_dir        = fullfile(vars.sample_dir, 'train');           % training sample folder
vars.tr.frms_dir        = fullfile(vars.frames_dir, 'train');
vars.tr.samp_list       = fullfile(vars.feat_data_dir, 'tr_list.txt');       % training sample list
vars.tr.word_mlf        = fullfile(vars.feat_data_dir, 'tr_word_mlf.txt');   % word level label
vars.tr.phone_mlf       = fullfile(vars.feat_data_dir, 'tr_phone_mlf.txt');  % phone level label
vars.tr.sampname_path   = fullfile(vars.tr.samp_dir, vars.f_sampname_list);
vars.tr.samplabel_path  = fullfile(vars.tr.samp_dir, vars.f_samplabel_list);
vars.tr.sampdata_path   = fullfile(vars.tr.samp_dir, vars.f_sample_data);

% test parameters
vars.te.image_dir       = fullfile(vars.image_dir, 'test');
vars.te.samp_dir        = fullfile(vars.sample_dir, 'test');            % testing sample folder 
vars.te.frms_dir        = fullfile(vars.frames_dir, 'test');
vars.te.samp_list       = fullfile(vars.feat_data_dir, 'te_list.txt');       % testing sample list
vars.te.word_mlf        = fullfile(vars.feat_data_dir, 'te_word_mlf.txt');   % word level label
vars.te.phone_mlf       = fullfile(vars.feat_data_dir, 'te_phone_mlf.txt');  % phone level label
vars.te.sampname_path   = fullfile(vars.te.samp_dir, vars.f_sampname_list);
vars.te.samplabel_path  = fullfile(vars.te.samp_dir, vars.f_samplabel_list);
vars.te.sampdata_path   = fullfile(vars.te.samp_dir, vars.f_sample_data);


% HMM model parameters
vars.flat_hmm_dir       = fullfile(vars.hmm_dir, 'flat');       mkdir(vars.flat_hmm_dir);         % Flat HMM dir
vars.tie_hmm_dir        = fullfile(vars.hmm_dir, 'tie');        mkdir(vars.tie_hmm_dir);         % Flat HMM dir
vars.senone_hmm_dir     = fullfile(vars.hmm_dir, 'senone');     mkdir(vars.senone_hmm_dir);         % Flat HMM dir

vars.proto_file         = 'proto.txt';
vars.proto_path         = fullfile(vars.hmm_dir, vars.proto_file);      % proto HMM, n_state states
vars.sil_file           = 'sil.txt';
vars.sil_path           = fullfile(vars.hmm_dir, vars.sil_file);        % single state HMM
vars.hmm_defs           = 'hmmdefs.txt';                                % HMMs definition filename
vars.hmm_vfloors        = 'vFloors';                                    % floor macro filename

% test recognition parameters
vars.te.rec_w_mlf       = fullfile(vars.label_dir, 'te_rec_mlf.txt');   % recognition result label
vars.te.rec_s_mlf       = fullfile(vars.label_dir, 'te_rec_state_mlf.txt'); % recognition result label with state information

% train recognition parameters
vars.tr.rec_w_mlf       = fullfile(vars.label_dir, 'tr_rec_mlf.txt');   % recognition result label
vars.tr.rec_s_mlf       = fullfile(vars.label_dir, 'tr_rec_state_mlf.txt'); % recognition result label with state information


%% ConvNet model
vars.convnet.root_dir        = fullfile(vars.feat_data_dir, 'convnet');       mkdir(vars.convnet.root_dir);
vars.convnet.model_dir       = fullfile(vars.convnet.root_dir, 'model');      mkdir(vars.convnet.model_dir);
vars.convnet.tr.root_dir     = fullfile(vars.convnet.root_dir, 'train');      mkdir(vars.convnet.tr.root_dir);
vars.convnet.tr.batches_dir  = fullfile(vars.convnet.tr.root_dir, 'batches'); mkdir(vars.convnet.tr.batches_dir);
vars.convnet.tr.results_dir  = fullfile(vars.convnet.tr.root_dir, 'results'); mkdir(vars.convnet.tr.results_dir);
vars.convnet.tr.snapshot_dir = fullfile(vars.convnet.tr.root_dir, 'snapshot');mkdir(vars.convnet.tr.snapshot_dir);
vars.convnet.te.root_dir     = fullfile(vars.convnet.root_dir, 'test');       mkdir(vars.convnet.te.root_dir);
vars.convnet.te.batches_dir  = fullfile(vars.convnet.te.root_dir, 'batches'); mkdir(vars.convnet.te.batches_dir);
vars.convnet.te.results_dir  = fullfile(vars.convnet.te.root_dir, 'results'); mkdir(vars.convnet.te.results_dir);
vars.convnet.te.snapshot_dir = fullfile(vars.convnet.te.root_dir, 'snapshot');mkdir(vars.convnet.te.snapshot_dir);

vars.convnet.cfg_file   = fullfile(vars.convnet.root_dir, 'options.cfg');
vars.convnet.channels   = 3;
vars.convnet.batch_size = 50000;
