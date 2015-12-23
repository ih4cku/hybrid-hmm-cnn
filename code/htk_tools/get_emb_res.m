function avg_logprob = get_emb_res(cmdout)
% get frame average log prob from command output
cmdout = textscan(cmdout, '%s', 'Delimiter', '\n');
cmdout = cmdout{1};
re = regexp(cmdout, '^Reestimation complete - ');
line = cmdout(~cellfun(@isempty, re));
line = line{1};
avg_logprob = textscan(line, '%[^=]%c%f');
avg_logprob = avg_logprob{3};
