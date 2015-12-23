function gen_dir_features(image_dir)
	% Generate image feature of a specific folder, save as HTK format in the same folder
	% Input:
	% 	image_dir - dir of data to process

	HTKCode = 9;

	im_list = dir(fullfile(image_dir, '*.bmp'));
	im_list = {im_list.name};
    n_images = length(im_list);

	for i_im = 1:n_images
		im_path = fullfile(image_dir, im_list{i_im});
		im = imread(im_path);

		feat = extr_image_feats(im);

		feat_path = strrep(im_path, 'bmp', 'htk');
		htkwrite(feat, feat_path, HTKCode);

		fprintf('%s -> %s\n', im_path, feat_path);
	end