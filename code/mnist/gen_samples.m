function gen_samples(vars, ds_flag)
% generate_samples(vars, ds_flag)
% Generate samples with each line of WORD_PROMPTS as labels
% 	Input:
%       samp_dir        - root folder to save samples
%       word_prompts    - words to generate 
%       char_root_dir   - character image folder
%       feat_dim        - feature dimension
%   Output:
%       samp_list       - path to save the sample paths list
%       samp_mlf        - path to save the samples MLF

switch ds_flag
    case 'train'
        v = vars.tr;
    case 'test'
        v = vars.te;
    otherwise
        error('Switch string not valid, must be [train/test].');
end

% global parameters
HTKCode = 9;	% format <USER> 

% read prompts
fid = safefopen(v.prompts, 'r');
pmts = textscan(fid, '%s', 'Delimiter', '\n');
pmts = cellfun(@(x) textscan(x, '%s'), pmts{1});
% pmts = cat(2, pmts{:})';

% loop to process labels in the prompts
n_samp = size(pmts, 1);

f_list = safefopen(v.samp_list, 'w');
f_mlf = safefopen(v.word_mlf, 'w');
fprintf(f_mlf, '#!MLF!#\n');

% pmts = add_word_pre_sym(pmts);  % 0 -> H0

for i_samp = 1:n_samp
	% generate word image
	% chars = textscan(strjoin(pmts(i_samp, :)), '%*s H%c');  % modified on 2014.04.07
	% chars = chars{1};
    words = pmts(i_samp);
    words = words{1};
    chars = [];
    for i = 1:length(words)
        % if strcmpi(words{i}, 'SIL')
        %     chars = [chars, 's'];
        % else
            char = textscan(words{i}, 'H%c');
            if ~isempty(char{1})
                chars = [chars, char{1}];
            end
        % end
    end

	word_img_path = fullfile(v.samp_dir, [num2str(i_samp), '.bmp']);
    word_img_path = strrep(word_img_path, '\', '/');
	gen_word_image(chars, word_img_path, v.char_dir, vars.crop_char, vars.add_sil);

    % extract features
    im = imread(word_img_path);
    [~, word_img_name, ~] = fileparts(word_img_path);
    frms_img_dir = fullfile(v.frms_dir, word_img_name);
    feat = extr_image_feats(im, frms_img_dir, vars);
    
    % save feature with HTK format
    feat_path = [word_img_path(1:end-3), 'htk'];
    htkwrite(feat, feat_path, HTKCode); 
	
    % save word path to train_list
    fprintf(f_list, '%s\n', feat_path); 

	% write MLF label
	lab_path = [feat_path(1:end-3), 'lab'];
	fprintf(f_mlf, '"%s"\n', lab_path);
    hmm_names = pmts{i_samp};
    fprintf(f_mlf, '%s\n', hmm_names{:});
	fprintf(f_mlf, '.\n');

	disp(word_img_path);
end
