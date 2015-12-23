function prompts2wlist(prompt_path, wlist_path)
% prompts2wlist(prompt_path, wlist_path, sil_str)
% Extract unique words from prompts to make the word list 
%   Input:
%       prompt_path - prompt file path
%       sil_str     - sil symbol string
%   Output:
%       wlist_path  - path to save word list
    
	fid = safefopen(prompt_path);
	pmts = textscan(fid, '%s');

	pmts = pmts{1};
	unique_pmts = unique(pmts);

	fid = safefopen(wlist_path, 'w');
    unique_pmts = add_word_pre_sym(unique_pmts);   % 0 -> H0
    fprintf(fid, '%s\n', unique_pmts{:});
    fprintf(fid, 'SIL\n');

    % sort word list
    sort_lines(wlist_path);