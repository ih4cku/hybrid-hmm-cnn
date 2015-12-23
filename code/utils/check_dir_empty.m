function b_empty = check_dir_empty(d)
im_list = dir(fullfile(d, '*.png'));
b_empty = isempty(im_list);