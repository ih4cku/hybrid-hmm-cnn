im_bad_name = {'49256', 34547, 157962, 148306,68844,97522,4013,111267,36220,4019,4029,159601,70109,52708,121930,99352,70826,84215,38033,8476,115869,55100,101879,74650,56225,74651,135928,74653,41568};
img_root_dir = 'D:\dataset\SVHN\crop\original\train';
frm_root_dir = 'D:\dataset\SVHN\crop\data\frames\train';

for i = 1:length(im_bad)
    im_name = [im_bad_name{i} '.png'];
    disp(im_name);
    
    im_path = fullfile(img_root_dir, im_name);
    frm_dir = fullfile(frm_root_dir, im_bad_name{i});
    write_frames(im_path, frm_dir, vars);
end