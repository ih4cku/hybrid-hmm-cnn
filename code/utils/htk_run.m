function cmdout = htk_run(cmd, fn)
fprintf('[HTK_CMD]$ ');
[stats, cmdout] = system(cmd, '-echo');
assert(stats==0, 'Command error @ %s.m', fn);