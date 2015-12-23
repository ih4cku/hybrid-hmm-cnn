function write_frames(im_path, frms_img_dir, vars)
% WRITE_FRAMES(IM_PATH, FRMS_IMG_DIR, VARS) Sliding window to extract frames of 
% IM_PATH and save frame images to FRMS_IMG_DIR. The remaining part not enough
% for a window will be droped.

if ~exist(frms_img_dir, 'dir')
    mkdir(frms_img_dir)
end

% normalize image height
normalize_image_height(im_path, vars.norm_height);

% sliding windows
im = imread(im_path);
[im_hei, im_wid, ~] = size(im);
slide_wins = sliding_window(im_wid, im_hei, vars.win_wid, vars.n_overlap);

% extract frames
n_win = length(slide_wins);
if n_win == 0
    % image width too small to fit a window width, then resize to window width.
    im_win = imresize(im, [im_hei, vars.win_wid]);
    frm_img_path = fullfile(frms_img_dir, [num2str(1), '.', vars.im_ext]);
    imwrite(im_win, frm_img_path);
else
    for i_win = 1:n_win
        win = slide_wins(i_win);
        im_win = im(win.y:win.hei, win.x:win.x+win.wid-1, :);
        
        frm_img_path = fullfile(frms_img_dir, [num2str(i_win), '.', vars.im_ext]);
        imwrite(im_win, frm_img_path);
    end
end