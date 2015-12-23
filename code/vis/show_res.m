function show_res(vars, ds_flag, n_img_show)
% show_res(vars, ds_flag)
% show alignment result
%   ds_flag should be 'train' or 'test'

n_img_per_fig = 30;

if nargin<2
    ds_flag = 'test';
end

switch ds_flag
case 'train'
    ds = vars.tr;
case 'test'
    ds = vars.te;
otherwise
    error('wrong parameter.')
end

% get information of each frame from recognition label file
all_frms = get_im_frames_info(ds.rec_w_mlf, ds.image_dir, vars.im_ext);

% get subplot layout
im_tmp = imread(all_frms{1, 1});
n_im = size(all_frms, 1);
N = min(n_im, n_img_per_fig);
[n_row, n_col] = get_subplot_layout(N, size(im_tmp, 2)/size(im_tmp, 1));

% if n_img_show not supplied, show all images
if nargin<3
    n_img_show = n_im;
end
h = figure();
i_plot = 1;
for i_im = 1:n_img_show
    im = imread(all_frms{i_im, 1});
    
    if i_plot>N
        input('...');
        h = figure();
        i_plot = 1;
    end
    
    % draw cuts on original image
    im_cut = overlay_segment_cuts(im, all_frms{i_im, 2}, vars);
    
    % format title
    frm = all_frms{i_im, 1};
    [~, mainname, ~] = fileparts(frm);
    labels = all_frms{i_im, 2};
    labels = strjoin(labels(:,3)');
    labels = strrep(labels, 'H', '');
    
    % show cut image
    figure(h); 
    subplot(n_row, n_col, i_plot);
    imshow(im_cut); 
    title(sprintf('[%d] %s\n%s', i_im, mainname, labels));
    
    i_plot = i_plot+1;
end
