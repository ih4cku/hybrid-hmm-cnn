function words = add_word_pre_sym(words)
% w_cell = add_word_pre_sym(w_cell)
% Add a symbol to each element of the input string cell
% Input/Output:
%   w_cell - input string cell
word_pre_sym = '';     % symbol before number, e.g. 0 -> H0
words = strcat(word_pre_sym, words);