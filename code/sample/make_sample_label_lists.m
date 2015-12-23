function make_sample_label_lists(vars)
% MAKE_SAMPLE_LABEL_LISTS(VARS) 
% Generate file paths list and label list for VARS.TR and VARS.TE. 
% Images are stored in DS.IMAGE_DIR. 
% 
% Generate for both VARS.TR and VARS.TE.
% 
% The results are saved as:
%   DS.SAMPNAME_PATH : sample file paths list
%   DS.SAMPLABEL_PATH: sample labels list

vars_ds = {vars.tr, vars.te};
for i_ds = 1:length(vars_ds)
    ds = vars_ds{i_ds};
    
    % image list
    if exist(ds.sampname_path, 'file')
        fprintf('[%s] already exist, skip.\n', ds.sampname_path);
    else
        img_list = get_image_list(ds.image_dir, vars.im_ext);
        n_img = length(img_list);
        sampname_list = cell(n_img, 1);
        name_list = cell(n_img, 1);
        parfor i = 1:n_img
            sampname_list{i} = get_main_name(img_list{i});
            name_list{i} = get_full_name(img_list{i});
        end
        fprintf('Writing sampname_list to [%s]...', ds.sampname_path);
        save(ds.sampname_path, 'sampname_list');
        disp('done.');
    end
    
    % label list
    if exist(ds.samplabel_path, 'file')
        fprintf('[%s] already exist, skip.\n', ds.samplabel_path);
    else
        label_mat_path = fullfile(ds.image_dir, 'digitStruct.mat');
        fprintf('Loading labels [%s]...', label_mat_path);
        load(label_mat_path);
        disp('done.');
        
        [~, idx_samp] = ismember(name_list, {digitStruct.name});
        idx_not_found = find(idx_samp==0);
        assert(isempty(idx_not_found), sprintf('Some files not found: %s\n', strjoin(name_list(idx_not_found)')));
        
        samplabel_list = arrayfun(@(samp) labnum2chars([samp.bbox.label]), digitStruct(idx_samp), 'UniformOutput', false);
        samplabel_list = samplabel_list(:); % convert to shape (n, 1)
        fprintf('Writing samplabel_path to [%s]...', ds.samplabel_path);
        save(ds.samplabel_path, 'samplabel_list');
        disp('done.');
    end
end
