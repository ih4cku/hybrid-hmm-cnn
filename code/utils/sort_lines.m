function sort_lines(file_path)
% sort_lines(file_path)
% sort lines in file alphabetically

fprintf('Sorting lines of [%s] ...', file_path);
fid = safefopen(file_path);

text = textscan(fid, '%s', 'Delimiter', '\n');

% sort each line
text = text{1};
text = sort(text);

% save sorted lines
fid = safefopen(file_path, 'w');
fprintf(fid, '%s\n', text{:});

disp('done.');