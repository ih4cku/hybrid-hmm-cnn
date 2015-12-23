import cPickle
import scipy.io
import numpy as np 
from pprint import pprint
import os
import sys

if __name__ == '__main__':
    feat_names = ['hog', 'lbp', 'dsift', 'raw']
    mix_nums = ['100', '500', '800']

    for feat in feat_names:
        for mix in mix_nums:
            fn = os.path.join('E:/Datasets/SVHN/all/htk', feat, 'mix_%s' % mix, 'hmms', 'results.pk')              
            print 'Processing [%s]...' % fn
            with open(fn, 'rb') as f:
                res = cPickle.load(f)

            pprint(res)

            logprobs = np.array(res[0])
            accuracy = np.array(res[1])
            run_time = np.array(res[2:4])

            dst_dir, name = os.path.split(fn)
            dst_fn = os.path.join(dst_dir, 'results.mat')
            scipy.io.savemat(dst_fn, {'logprobs': logprobs,'run_time': run_time,'accuracy': accuracy})
            print 'done.'
