function im_cat = cat_images(im_cell)
	n_im = length(im_cell);
	im_cat = im_cell{1};
	[hei, wid, ~] = size(im_cat);
	split_wid = 4;
	im_split = 0.3 * ones(hei, split_wid);
	
	for i = 2:n_im
		im_cell{i} = im2double(im_cell{i});
		im_cat = [im_cat, im_split, im_cell{i}];
	end
