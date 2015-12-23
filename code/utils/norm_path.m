function p = norm_path(p)
% P = NORM_PATH(P) Normalize path P to unix style. '\' are replaced to '/'.
% This is a need of HTK.

p = strrep(p, '\', '/');