function svhn_crop_frames(in_images_dir, out_root_dir, vars)
% crop frames of all images using sliding window
% Params:
%   in_images_dir   - input dir containing images to process
%   out_root_dir    - output dir to save frames

norm_height = vars.norm_height;         % normalize image height
win_wid     = vars.win_wid;             % sliding window width
n_overlap   = vars.n_overlap;           % sliding window overlap

im_list = dir(fullfile(in_images_dir, ['*.' vars.im_ext]));
im_list = {im_list.name};
n_images = length(im_list);

parfor i_im = 1:n_images

    im_name = im_list{i_im};
    im_path = fullfile(in_images_dir, im_name);
    
    frms_img_dir = fullfile(out_root_dir, im_name(1:end-4));
    if ~exist(frms_img_dir, 'dir')
        mkdir(frms_img_dir)
    end
    
    fprintf('%d: %s\n', i_im, im_path);
    im = normalize_image(im_path, norm_height, win_wid, n_overlap);
    [im_hei, im_wid, ~] = size(im);
    
    % construct windows
    slide_wins = sliding_window(im_wid, im_hei, win_wid, n_overlap);

    % extract frames
    n_win = length(slide_wins);
    for i_win = 1:n_win
        win = slide_wins(i_win);
        im_win = im(win.y:win.hei, win.x:win.x+win.wid-1, :);

        frm_img_path = fullfile(frms_img_dir, [num2str(i_win), '.', vars.im_ext]);
        imwrite(im_win, frm_img_path);
    end
    
end
