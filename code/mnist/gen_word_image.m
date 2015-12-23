function gen_word_image(word_label, word_path, char_root_dir, b_crop, b_addsil)
% Generate a multiple character sample 
% Input : 
% 	word_label	: label of the word	
% 	word_path	: path to save the word image, note: with the image filename
% 	char_root_dir : the root dir in which the character images are saved
% 
% Output:
% 	no output, the image are saved at word_path

	n_char = length(word_label);
	im_word = [];

	for i = 1:n_char
		ch = word_label(i);

		% get a random char image
		im_char = get_char_image(ch, char_root_dir, b_crop, b_addsil);

		% put the image to image
		im_word = [im_word, im_char];
	end

    % pad SIL to im_word's head and tail
    im_word = padarray(im_word, [0, 8], false, 'both');
	
    % save sample
    imwrite(logical(im_word), word_path);



function im_char = get_char_image(ch, char_root_dir, b_crop, b_addsil)
	im_list = dir(fullfile(char_root_dir, ch, '*.bmp'));
	im_list = {im_list.name};
	i_ch = randperm(length(im_list), 1);
	im_char = imread(fullfile(char_root_dir, ch, im_list{i_ch}));

    % crop only character
    if b_crop
        [~, c] = find(im_char);
        im_char = im_char(:, min(c):max(c));
    end

    % add sil space around im_char
    if b_addsil
        im_char = rand_add_sil(im_char);
    end

    

function im_char = rand_add_sil(im_char)
    % randomly add to sil to head and tail of im_char
    pad_head = rand_sil_width();
    im_char = padarray(im_char, [0, pad_head], false, 'pre');

    pad_tail = rand_sil_width();
    im_char = padarray(im_char, [0, pad_tail], false, 'post');


function sil_wid = rand_sil_width()
    if rand(1)>0.5
        sil_wid = 3+randi(3);
    else
        sil_wid = 0;
    end

% generate only touching chars 
% sil_wid = 0;
