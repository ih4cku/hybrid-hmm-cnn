function gen_hmm_def(hmm_name, hmm_path, vecsize, n_state, n_mixture)
% gen_hmm_def(hmm_name, hmm_path, vecsize, n_state, n_mixture)
% Generate HMM defination
%   Output:
%       hmm_path - path to save the hmm prototype 

%!!! modified to fit large dataset!!!
% load('feat_data.mat'); 

%% HMM parameters
means    = zeros(1, vecsize);
covars   = ones(1, vecsize);
% means = feat_mean;
% covars= feat_var;
transmat = gen_hmm_transmat(n_state);
mix_coef = 1/n_mixture;

%% write data to HMM definition file
fid = safefopen(hmm_path, 'w');

% global option
fprintf(fid, '~o\n');
fprintf(fid, '<VecSize> %d %s\n', vecsize, '<USER>');
fprintf(fid, '\n');

% start HMM
fprintf(fid, '~h "%s"\n', hmm_name);
fprintf(fid, '<BeginHMM>\n');
fprintf(fid, '<NumStates> %d\n', n_state+2);

% states
for i_ste = 1:n_state
    fprintf(fid, '<State> %d\n', i_ste+1);
    if n_mixture>1
        fprintf(fid, '<NumMixes> %d\n', n_mixture);
    end
    
    % mixtures
    for i_mix = 1:n_mixture
        if n_mixture>1
            fprintf(fid, '<Mixture> %d %f\n', i_mix, mix_coef)
        end

        fprintf(fid, '<Mean> %d\n\t', vecsize);
        fprintf(fid, '%f ', means);
        fprintf(fid, '\n');

        fprintf(fid, '<Variance> %d\n\t', vecsize);
        fprintf(fid, '%f ', covars);
        fprintf(fid, '\n');
    end
end
fprintf(fid, '\n');

% transmat
fprintf(fid, '<TransP> %d\n\t', n_state+2);
for n = 1:n_state+2
    fprintf(fid, '%f ', transmat(n,:));
    fprintf(fid, '\n\t');
end

% end HMM
fprintf(fid, '\n<EndHMM>\n');
