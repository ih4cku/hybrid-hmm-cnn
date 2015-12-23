function im_cuts = overlay_segment_cuts(im, frms, vars)
[im_hei, im_wid, ~] = size(im);

% begin and end cuts of each frame
beg_cuts = [frms{:,1}];
end_cuts = [frms{:,2}];

% cut axes
wins = sliding_window(im_wid, im_hei, vars.win_wid, vars.n_overlap);
axis_frms = [wins.x];
axis_beg_cuts = axis_frms(beg_cuts);
axis_end_cuts = axis_frms(end_cuts)+vars.win_wid-1;

% draw cut lines
if ndims(im) ~= 3
    im_cuts = im2uint8(cat(3, im, im, im));
else
    im_cuts = im;
end

% begin RED
for i_cut = 1:length(axis_beg_cuts)
    col = randi(255, 1, 3);
    im_cuts(:, axis_beg_cuts(i_cut), 1) = col(1);
    im_cuts(:, axis_beg_cuts(i_cut), 2) = col(2);
    im_cuts(:, axis_beg_cuts(i_cut), 3) = col(3);

    im_cuts(:, axis_end_cuts(i_cut), 1) = col(1);
    im_cuts(:, axis_end_cuts(i_cut), 2) = col(2);
    im_cuts(:, axis_end_cuts(i_cut), 3) = col(3);
end

