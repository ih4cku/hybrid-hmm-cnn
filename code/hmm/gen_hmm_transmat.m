function transmat = gen_hmm_transmat(n_state)
% N_STATE is the number of output states, not count null states
% matrix size is (N_STATE+2)*(N_STATE+2)
% build rule:
%   - 0th diagnal [0.0 0.5 ... 0.5 0.0]
%   - 1st diagnal [1.0 0.5 ... 0.5]

M_diag0 = diag([0; 0.5*ones(n_state, 1); 0]);   % self transition
M_diag1 = diag([1; 0.5*ones(n_state, 1)], 1);   % transition to next state

transmat = M_diag1 + M_diag0;
