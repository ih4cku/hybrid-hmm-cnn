% FUNC_GET_FEAT_DATA is a function handle used for morpholism. This makes a 
% simple way to use different feature extraction algorithms.
% 
% The function prototype is :
% DATA_MAT = FUNC_GET_FEAT_DATA(FRM_LIST [, FRAME_SHAPE])
% 
% The pointed function gets the data matrix of all images in FRM_LIST. The 
% resulted DATA_MAT shape: (n_frames, n_dim).