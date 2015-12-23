function train_pca(vars)
% Train PCA with frames in VARS.TR.FRMS_DIR.
% 
% Steps:
%   1. Get all frames in subdirs of VARS.TR.FRMS_DIR;
%   2. Get all image data of frames and save in VARS.TR.FRMS_DIR, then randomly 
%      select VARS.N_PCA_SAMPLES for training;
%   3. PCA training to get PC and SAMPLE_MEAN and save to VARS.PCA_PATH.

disp('----- Generating all frames data -----');

% Generate data matrix of all frames in frm_root_dir
frames_data = get_training_data(vars.tr.frms_dir, vars);

if vars.use_pca
    disp('----- Train PCA features -----');
    % randomly select samples for PCA training
    n_frames = size(frames_data, 1);
    if vars.n_pca_sample == -1
        n_frm_used = n_frames;
    else
        n_frm_used = min(n_frames, vars.n_pca_sample);
    end
    frames_data = frames_data(randperm(n_frames, n_frm_used), :);
    
    % perform PCA training
    perform_pca(frames_data, vars);
end