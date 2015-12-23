function model_file_path = get_model_path(model_saved_root)
    % get the last dir as model dir
    model_dir = dir(model_saved_root);
    model_dir = model_dir([model_dir.isdir]);
    model_dir = model_dir(end).name;
%     model_file = dir(fullfile(model_saved_root, model_dir));
%     model_file = model_file(~[model_file.isdir]);
%     model_file = model_file(1).name;

    model_file_path = fullfile(model_saved_root,model_dir); % ,model_file