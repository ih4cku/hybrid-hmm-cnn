function pad_image_width(im_path, vars)
% !NOT FINISHED YET!
% pad small image, especially single character image
step = win_wid-n_overlap;
min_wid = 3*win_wid;   % shape after pad:[step step win_wid step step]
if im_wid < min_wid
    if im_wid < win_wid
        im = padarray(im, [0, ceil((win_wid-im_wid)/2)], pad_val, 'both');    
    end
    im = padarray(im, [0, 3*step], pad_val, 'both');

    imwrite(im, im_path);
end
