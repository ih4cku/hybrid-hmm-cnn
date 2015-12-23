function gen_word_prompts(vars, str_switch)
% gen_word_prompts(prompts, n_prompts, dict, gram, wdnet)
%   Generate prompts given grammar definition

switch str_switch
    case 'train'
        ds = vars.tr;
    case 'test'
        ds = vars.te;
    otherwise
        error('Switch string not valid, must be [train/test].');
end

% wdnet -> prompts 
cmd = strjoin({'HSGen -n' int2str(ds.n_samp) vars.wdnet_path vars.dict_path '>' ds.prompts});
htk_run(cmd, mfilename('fullpath'));