function generate_all_hmms(vars)
% generate all hmms according to hmm list
% 1. copy proto(sil) 
% 2. add noise to Gaussian mean

fid = safefopen(vars.phone_list);
phone_names = textscan(fid, '%s');
phone_names = phone_names{1};

% read hmms
flat_proto_path = fullfile(vars.flat_hmm_dir, vars.proto_file);
flat_sil_path   = fullfile(vars.flat_hmm_dir, vars.sil_file);
if ~exist(flat_proto_path, 'file')
    error('Flat start not done yet.')
end
hmm_flat = read_htk_hmm(flat_proto_path);
hmm_sil  = read_htk_hmm(flat_sil_path);

n_phones = length(phone_names);
all_hmms = cell(n_phones,1);
for i_phone = 1:n_phones
    if ismember(phone_names{i_phone}, {'sil', 'sp'})
        tmp_hmm = hmm_sil;
    else
        tmp_hmm = hmm_flat;
    end
    tmp_hmm.name = phone_names{i_phone};
    tmp_hmm = add_rand_noise(tmp_hmm);
    all_hmms{i_phone} = tmp_hmm;
end

hmm_defs_path = fullfile(vars.flat_hmm_dir, vars.hmm_defs);
write_htk_hmm(hmm_defs_path, all_hmms);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hmm = add_rand_noise(hmm)
switch hmm.emission_type
    case 'gaussian'
        means = hmm.means;
        cov   = hmm.covars;
        noise = randn(size(means))*0.1;         % random init
        hmm.means = hmm.means+noise.*cov;
        
    case 'GMM'
        n_ste = length(hmm.gmms);
        for i_ste = 1:n_ste
            means = hmm.gmms(i_ste).means;
            noise = randn(size(means))*0.1;     % random init
            hmm.gmms(i_ste).means=hmm.gmms(i_ste).means+noise.*hmm.gmms(i_ste).covars;
        end
        
    otherwise
        error('HMM emission type error.');
end



% training sil
% floor_path = fullfile(vars.flat_hmm_dir, vars.hmm_vfloors);
% cmd = strjoin({'HInit' '-A -T 7' ...
%               '-l' 'sil' ...
%               '-u' 'mtw' ...
%               '-H' hmm_defs_path ...
%               '-H' floor_path ...              
%               '-S' vars.tr.samp_list ...
%               '-I' vars.tr.phone_mlf...
%               '-M' 'hmms/s'...
%               'hmms/sil'});
% htk_run(cmd, mfilename('fullpath'));


