function im = preprocess_frame(im)
% preprocess frame to make HTK use it more happy

% im = imcomplement(im);
im = im2double(imadjust(im));
