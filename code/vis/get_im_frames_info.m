function all_frms = get_im_frames_info(state_mlf_path, image_dir, im_ext)
% get_im_frames_info(state_mlf_path)
% Get information of each frame coresponding to HMM models
% Input:
%   state_mlf_path  - MLF file path with state alignment info
% Outout:
%   all_frms
%         format:
%         {
%             im_path, { 
%                         frmBegIdx, frmEndIdx, hmmName
%                         ...
%                      }
%             ...
%         }

fprintf('Reading MLF file [%s]...', state_mlf_path);
f = safefopen(state_mlf_path);

mlf_header = fgetl(f);
if ~strcmp(mlf_header, '#!MLF!#')
    error('Not a valid MLF file.')
end

all_frms = {};

while(~feof(f))
    % read image path
    im_path = fgetl(f);
    [~, name, ~] = fileparts(im_path(2:end-4));
    im_path = fullfile(image_dir, [name, '.', im_ext]);

    % read frame info 
    ln = fgetl(f);
    frms = {};
    while(ln(1) ~= '.' && ~feof(f)) % read dot
%         frm_info = textscan(ln, '%d %d %[^[]', 1); % {begIdx, endIdx, name}
        frm_info = regexp(ln, '(\d+)\s+(\d+)\s+(\w+)', 'tokens');
        if ~isempty(frm_info)
            frm_info = frm_info{1};
            frm_info = {str2double(frm_info{1}), str2double(frm_info{2}), frm_info{3}};
            frms = cat(1, frms, frm_info);
        end
        ln = fgetl(f);
    end
    all_frms = cat(1, all_frms, {im_path, frms});
end

disp('done.');