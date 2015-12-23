function emb_train_loop(hmm_dir, vars)
avg_prob        = emb_training(hmm_dir, hmm_dir, vars);

% plot result
delt_prob       = Inf;
n_max_iter      = 30;
emb_stop_thresh = 0.03;

figure;
set(gca, 'XLim', [0, n_max_iter]);
hold on; plot(avg_prob, 'r-s');
while delt_prob > emb_stop_thresh
    frm_prob        = emb_training(hmm_dir, hmm_dir, vars);

    delt_prob       = abs(frm_prob-avg_prob(end));
    avg_prob        = [avg_prob; frm_prob];
    if length(avg_prob)>n_max_iter
        set(gca, 'XLim', [0, length(avg_prob)+1]);
    end
    hold on; plot(avg_prob, 'r-s');
end

save(fullfile(hmm_dir, 'avg_prob.mat'), 'avg_prob');