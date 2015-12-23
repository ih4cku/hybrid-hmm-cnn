function [feats, im_cat] = extr_image_feats(im, frms_img_dir, vars)
% Main variables:
% 
% 	sliding window:
% 	  x_1 = 1
% 	  x_n = x_{n-1} + (win_wid - n_overlap)
% 
% 	window parameters:
% 	  x
% 	  y
% 	  wid
% 	  hei
% 	  n_olp
% 
% 	grid parameters:
% 	  n_grid_row
% 	  n_grid_col
% 
% 	FEATS format: N_sample x n_dim
%                 n_dim = n_grid_row * n_grid_col
% 
% by Guo @ 2013.12.02

feat_dim    = vars.feat_dim;
win_wid     = vars.win_wid;
n_overlap   = vars.n_overlap;

im = im2double(im);
[im_hei, im_wid] = size(im);

% construct windows
% win_wid     = 4;
% n_overlap   = 1;
n_grid_row  = feat_dim(1);
n_grid_col  = feat_dim(2);

step  = win_wid - n_overlap;
win_x = 1: step :im_wid;

slide_wins = struct('x', num2cell(win_x)', 'y', 1, ...
                    'wid', win_wid, 'hei', im_hei, 'n_olp', n_overlap, ...
                    'n_grid_row', n_grid_row, 'n_grid_col', n_grid_col);

% pad image
padsize = [0, (win_x(end)+win_wid-1)-im_wid];
im_pad = padarray(im, padsize, 0, 'post');

% extract feature of each window
assert(n_grid_row<=im_hei && n_grid_col<=win_wid, 'Grid partition to window too much.');

n_win = length(slide_wins);
feats = [];
im_win = {};

if ~exist(frms_img_dir, 'dir')
    mkdir(frms_img_dir)
end

for i_win = 1:n_win
	[fea, im_win{i_win}] = extr_win_feats(slide_wins(i_win), im_pad);
	feats = [feats; fea];       % feature of each window image

    frm_img_path = fullfile(frms_img_dir, [num2str(i_win), '.bmp']);
    imwrite(im_win{i_win}, frm_img_path);
end

% cat the sliding window images for visualization
im_cat = cat_images(im_win);


function [feat, im_win] = extr_win_feats(win, im)
blk_size = [ceil(win.hei/win.n_grid_row), ceil(win.wid/win.n_grid_col)];

% window image
im_win = im(win.y:win.hei, win.x:win.x+win.wid-1);
im_win = padarray(im_win, [win.n_grid_row*blk_size(1), win.n_grid_col*blk_size(2)]-[win.hei, win.wid], 0, 'post');

% block processing
feat = blockproc(im_win, blk_size, @(blk) sum(blk.data(:)));
feat = feat(:)';
