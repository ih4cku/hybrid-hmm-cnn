function name = get_full_name(f_path)
% NAME = GET_FULL_NAME(F_PATH) 
%   Get a file's full name (with extension) from its path.
[~, name, ext] = fileparts(f_path);
name = [name, ext];