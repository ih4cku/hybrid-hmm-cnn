function hybrid_assign_senone_ids(opt_fn)
    cmd = strjoin({'state2id.exe' opt_fn})
    system(cmd);