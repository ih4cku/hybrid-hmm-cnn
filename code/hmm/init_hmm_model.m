function init_hmm_model(vars)

disp('====== Initializing HMM models ======');

% generate prototype hmms
load(vars.pca_data_path, 'n_comp');
% vecsize = prod(vars.feat_dim);
vecsize = n_comp;
gen_hmm_def('proto', vars.proto_path, vecsize, vars.n_char_state, vars.n_char_mix);
gen_hmm_def('sil', vars.sil_path, vecsize, vars.n_sil_state, vars.n_sil_mix); % single state model

% flat start hmm
if ~exist(vars.flat_hmm_dir, 'dir')
    mkdir(vars.flat_hmm_dir);
    fprintf('Create folder [%s].\n', vars.flat_hmm_dir);
end

% create train init list file
if ~exist(vars.tr_init_list, 'file')
    fprintf('Creating init list file [%s]...', vars.tr_init_list);
    if vars.n_tr_init == -1
        copyfile(vars.tr.samp_list, vars.tr_init_list);
    else
        fin = fopen(vars.tr.samp_list);
        lines = textscan(fin, '%s');
        lines = lines{1};
        fclose(fin);

        n_lines = length(lines);
        shuffle = randperm(length(lines), min(n_lines, vars.n_tr_init));
        lines = lines(shuffle);
        
        fout= fopen(vars.tr_init_list, 'w');
        fprintf(fout, '%s\n', lines{:});
        fclose(fout);
    end
    disp('done.');
end

% init proto
cmd = strjoin({'HCompV' vars.global_opt ...
    '-f 0.01' ...
    '-m' ...
    '-M' vars.flat_hmm_dir ...
    '-S' vars.tr_init_list ...
    '-H' vars.proto_path ...
    vars.proto_path});
htk_run(cmd, mfilename('fullpath'));

% init sil
cmd = strjoin({'HCompV' vars.global_opt ...
               '-f 0.1' ...
               '-m' ...
               '-M' vars.flat_hmm_dir ...
               '-S' vars.tr_init_list ...
               '-H' vars.sil_path ...
               vars.sil_path});
htk_run(cmd, mfilename('fullpath'));

% prepare all phone's hmm definition
generate_all_hmms(vars);

% post-process proto: add 1->3, 3->5 transition
hmm_defs_path = fullfile(vars.flat_hmm_dir, vars.hmm_defs);
cmd = strjoin({'HHEd' vars.global_opt ...
    '-H' hmm_defs_path ...
    vars.hmm_post_script ...
    vars.phone_list});
htk_run(cmd, mfilename('fullpath'));


% modify sp to tee-model
if vars.use_tee
    assert(logical(exist(vars.hmm_tee_script, 'file')), 'Tee edit script not exist.');
    
    hmm_defs_path   = fullfile(vars.flat_hmm_dir, vars.hmm_defs);
    floor_path      = fullfile(vars.flat_hmm_dir, vars.hmm_vfloors);
    cmd = strjoin({'HHEd' vars.global_opt ...
        '-H' hmm_defs_path ...
        '-H' floor_path ...
        '-M' vars.flat_hmm_dir ...
        vars.hmm_tee_script ...
        vars.phone_list});
    htk_run(cmd, mfilename('fullpath'));
end