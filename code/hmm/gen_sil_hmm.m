function gen_sil_hmm(hmm_path, vecsize)
% gen_proto_hmm(hmm_path, vecsize)
% Generate prototype HMM 
%   Input:
%       vecsize  - length of parameter vector
%   Output:
%       hmm_path - path to save the hmm prototype 

%% parameter definition
name    = 'sil';
nstates = 1;

means    = zeros(1, vecsize);
covars   = ones(1, vecsize);
transmat = [0.0     1.0     0.0
            0.0     0.5     0.5
            0.0     0.0     0.0];

%% write data to HMM definition file
fid = safefopen(hmm_path, 'w');

fprintf(fid, '~o\n');
fprintf(fid, '<VecSize> %d %s\n', vecsize, '<USER>');

fprintf(fid, '~h "%s"\n', name);
fprintf(fid, '<BeginHMM>\n\n');

% mean, covariance
fprintf(fid, '\t<NumStates> %d\n', nstates+2);

for n = 1:nstates
    fprintf(fid, '\t<State> %d\n\t\t<Mean> %d\n\t\t\t', n+1, vecsize);
    fprintf(fid, '%f ', means);
    fprintf(fid, '\n\t\t<Variance> %d\n\t\t\t', vecsize);
    fprintf(fid, '%f ', covars);
    fprintf(fid, '\n');
end

% transmat
fprintf(fid, '\t<TransP> %d\n\t\t\t', nstates+2);

for n = 1:nstates+2
    fprintf(fid, '%f ', transmat(n,:));
    fprintf(fid, '\n\t\t\t');
end

fprintf(fid, '\n<EndHMM>\n');
