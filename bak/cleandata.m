function cleandata(vars)

% delete frames and samples
fprintf('Want to DELETE all files in \n[%s]\n[%s]\n[%s]\n?', ...
    vars.data_dir, vars.label_dir);
c = input('(y/n):', 's');
folders = {vars.data_dir, vars.label_dir};
switch c
    case 'y'
        parfor i = 1:3
            fprintf('deleting [%s]...\n', folders{i});
            rmdir(folders{i}, 's');
        end
        disp('done.');
    case 'n'
        disp('Nothing is done.');
    otherwise
        disp('Invalid choice.');
end
