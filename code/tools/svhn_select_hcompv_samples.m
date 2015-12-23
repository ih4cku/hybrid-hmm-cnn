clear;clc

tr_list = 'D:\dataset\SVHN\crop\data\tr_list.txt';
all_lines = {};

f_tr = fopen(tr_list);
l = fgetl(f_tr);
while ischar(l)
    all_lines{end+1} = l;
    l = fgetl(f_tr);
end

