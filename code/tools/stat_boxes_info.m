clear;clc

% get all text in mlf
mlf_path = 'D:/dataset/SVHN/small/label/te_rec_state_mlf.txt';
f_mlf = fopen(mlf_path);

line = fgetl(f_mlf);
all_lines = {};
while ischar(line)
    all_lines{end+1,1} = line;
    line = fgetl(f_mlf);
end

fclose(f_mlf);

% count frames in mlf
last_frm_line = cellfun(@(line) strcmp(line, '.'), all_lines);
last_frm_line = find(last_frm_line)-1;

frm_nums = cellfun(@(l) regexp(l, '\d+\s+(\d+)', 'tokens'), all_lines(last_frm_line));
frm_nums_mlf = cellfun(@(n) str2double(n), frm_nums);
frm_nums_mlf = sum(frm_nums_mlf);

% count frames in folder
rec_lines = cellfun(@(l) ~isempty(strfind(l, '"D:/dataset')), all_lines);
samp_dirs = cellfun(@(p) fullfile('D:/dataset/SVHN/small/data/frames/test', p(41:end-5)), all_lines(rec_lines), 'UniformOutput', false);
frm_nums_dir  = cellfun(@(d) length(dir(fullfile(d, '*.png'))), samp_dirs);
frm_nums_dir  = sum(frm_nums_dir);