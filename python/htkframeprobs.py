import cPickle
import re
import os
import sys
import argparse
from os import path
from noccn.script import get_options

class FrameProbsMapper(object):
    def __init__(self, args, cfg, rebuild=False):
        self.state_priors_path = cfg['state-prior-probs-path']

        if args.train:
            self.data_batch_dir = cfg['train-output-dir']
            self.res_batch_dir = cfg['train-result-dir']
            self.frame_probs_path = cfg['train-frame-probs-path']
        elif args.test:
            self.data_batch_dir = cfg['test-output-dir']
            self.res_batch_dir = cfg['test-result-dir']
            self.frame_probs_path = cfg['test-frame-probs-path']

        # toggle scaled likelihood
        self.scaled = args.scaled

        # force to rebuild
        if rebuild:
            # build scaled likelihood
            if self.scaled:
                if args.train:
                    self.compute_state_priors(cfg['train-output-dir'])
                if args.test:
                    print 'Loading state priors...',
                    with open(self.state_priors_path, 'rb') as f:
                        self.state_priors = cPickle.load(f)
                    print 'done.'
            # build frame probs
            self.get_frame_probs_table()
        else:
            # load scale likelihood
            if self.scaled:
                print 'Loading state priors...',
                with open(self.state_priors_path, 'rb') as f:
                    self.state_priors = cPickle.load(f)
                print 'done.'
            # load frame probs
            with open(self.frame_probs_path, 'rb') as f:
                self.frames_info = cPickle.load(f)


    def compute_state_priors(self, tr_data_batch_dir):
        '''
        compute and dump states priors
        '''
        print 'Computing state priors...'

        # get data_batch_i pickle files
        pickle_files = filter(lambda item: path.isfile(path.join(tr_data_batch_dir, item)) and re.match(r'data_batch_\d', item), \
                              os.listdir(tr_data_batch_dir))

        batch_paths = [path.normpath(path.join(tr_data_batch_dir, pk_file)) for pk_file in pickle_files]

        # get meta data pickle file
        datameta_path = path.normpath(path.join(tr_data_batch_dir, 'batches.meta'))
        with open(datameta_path, 'rb') as f:
            data_meta = cPickle.load(f)

        all_labels = []
        for data_bch_path in batch_paths:
            print '\t', data_bch_path
            with open(data_bch_path, 'rb') as f:
                data_batch = cPickle.load(f)
            all_labels.extend(data_batch['labels'])

        # compute and dump state priors
        n_labels = len(data_meta['label_names'])
        state_priors = [float(all_labels.count(si)) / float(len(all_labels)) for si in range(n_labels)]
        #for si in range(n_labels):
        #    p_si = float(all_labels.count(si))/float(len(all_labels))
        #    state_priors.append(p_si)
        with open(self.state_priors_path, 'wb') as f:
            cPickle.dump(state_priors, f, -1)

        self.state_priors = state_priors

    def get_frame_probs_table(self):
        '''
        compute and dump frame scaled likehood probs
        '''
        print 'Building frame probs...'
        # load all probs and indexs

        # load batches
        pickle_files = filter(lambda item: path.isfile(path.join(self.res_batch_dir, item)) and re.match(r'data_batch_\d+', item), \
                              os.listdir(self.res_batch_dir))

        batch_paths = [(path.join(self.data_batch_dir, pk_file), path.join(self.res_batch_dir, pk_file)) for pk_file in pickle_files]
        data_meta_path = path.join(self.data_batch_dir, 'batches.meta')

        frame_probs = {}
        print 'Loading data batches...'
        for data_bch_path, res_bch_path in batch_paths:
            print 'Loading [%s]...' % data_bch_path,
            with open(data_bch_path, 'rb') as f:
                data_batch = cPickle.load(f)
            with open(res_bch_path, 'rb') as f:
                res_batch = cPickle.load(f)
            frame_probs.update(dict(zip(data_batch['ids'], res_batch['data'])))
            print 'done.'


        # get meta info of data
        print 'Loading metadata [%s]' % data_meta_path,
        with open(data_meta_path, 'rb') as f:
            data_meta = cPickle.load(f)
        frame_paths = data_meta['metadata']
        print 'done.'

        assert len(frame_probs.keys()) == len(frame_paths), 'len(frame_probs.keys()) != len(frame_paths).'

        # build all frames info, format : [file_name, frame_name, frame_probs]
        frames_info = {}
        for key in frame_probs:
            frm_path = frame_paths[key]
            file_name = path.basename(path.dirname(frm_path))
            frame_name = path.basename(frm_path)[:-4]

            if file_name in frames_info:
                frames_info[file_name][frame_name] = frame_probs[key]
            else:
                frames_info[file_name] = {frame_name : frame_probs[key]}

        # sort to make dict to list
        for key in frames_info:
            tmp_l = frames_info[key].items()
            for k, val in tmp_l:
                frames_info[key][int(k)] = frames_info[key].pop(k).tolist()
            #tmp_l.sort(key = lambda x: int(x[0]))
            #frames_info[key] = [item[1].tolist() for item in tmp_l]

            # convert output probs to scaled likelihood
            if self.scaled:
                for i_frm in frames_info[key]:
                    scaled_likelihood = frames_info[key][i_frm]
                    for i, p_si in enumerate(self.state_priors):
                        scaled_likelihood[i] = scaled_likelihood[i] / p_si

        with open(self.frame_probs_path, 'wb') as f:
            cPickle.dump(frames_info, f, -1)
        print 'Frame probs of %d images dumped to [%s].' % (len(frames_info), self.frame_probs_path)

        # assign object attributes
        self.frames_info = frames_info


    def __call__(self, f_path):
        '''
        return matrix of frame probs corresponding to the supplied sample file
        '''
        key = path.basename(path.splitext(f_path)[0])

        return self.frames_info[key]


def _get_arguments(arg_str):
    '''
    _get_arguments(arg_str) is used in helper.cpp
    '''
    parser = argparse.ArgumentParser(description='Create frame probs matrix dict and get a matrix corresponding to the sample file.')
    mu_group = parser.add_mutually_exclusive_group(required=True)
    mu_group.add_argument('-tr', '--train', help='process training data', action='store_true')
    mu_group.add_argument('-te', '--test',  help='process testing data',  action='store_true')
    mu_group.add_argument
    parser.add_argument('-s', '--scaled', action='store_true', help='use scaled likelihood instead of CNN posteriors')
    return parser.parse_args(arg_str)


def main():
    from pyhtk.util import get_config_path
    args = _get_arguments(sys.argv[1:])
    cfg_path = get_config_path()
    cfg = get_options(cfg_path, 'dataset')

    frm_probs = FrameProbsMapper(args, cfg, True)
    # use 
    # probs = frm_probs('E:/Research/PhD_thesis/codes/htk_matlab/data/htk/1.htk')

if __name__ == '__main__':
    main()
