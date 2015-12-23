function name = get_main_name(f_path)
% NAME = GET_MAIN_NAME(F_PATH) 
%   Get file name without extension from its full path.
[~, name, ~] = fileparts(f_path);