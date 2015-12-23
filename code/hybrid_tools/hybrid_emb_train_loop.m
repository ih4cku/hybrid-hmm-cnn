function hybrid_emb_train_loop(hmm_dir, vars)
delt_prob = Inf;
emb_stop_thresh = 0.01;
avg_prob        = hybrid_emb_training(hmm_dir, hmm_dir, vars);
figure;
set(gca, 'XLim', [0, 20]);
hold on; plot(avg_prob);
while delt_prob > emb_stop_thresh
    frm_prob        = hybrid_emb_training(hmm_dir, hmm_dir, vars);

    delt_prob       = abs(frm_prob-avg_prob(end));
    avg_prob        = [avg_prob; frm_prob]
    if length(avg_prob)>20
        set(gca, 'XLim', [0, length(avg_prob)+1]);
    end
    hold on; plot(avg_prob, 'r-s');
end