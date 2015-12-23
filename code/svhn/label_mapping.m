function hmm_names = label_mapping(label)
len = length(label);
hmm_names = cell(len, 1);
for i = 1:len
    if label(i)==10
        hmm_names{i} = 'H0';
    else
        hmm_names{i} = ['H' num2str(label(i))];
    end
end
