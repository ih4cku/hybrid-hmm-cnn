import os
from os import path
import cPickle
import argparse
import re

from noccn.script import get_options
from pyhtk.dataset import BatchCreator
from pyhtk.mlfparser import HtkParser
from pyhtk.util import get_config_path

# ------------------------------------------------------------------------ #
# Tools
# ------------------------------------------------------------------------ #
def _parse_config(dataset):
    if dataset=='Train':
        hmmdef_path  = cfg['hmmdefs-path']
        label_path   = cfg['train-label-path']
        frame_dir    = cfg['train-frame-dir']
        output_path  = cfg['train-output-dir']
    elif dataset=='Test':
        hmmdef_path  = cfg['hmmdefs-path']
        label_path   = cfg['test-label-path']
        frame_dir    = cfg['test-frame-dir']
        output_path  = cfg['test-output-dir']
    else:
        raise ValueError('Wrong argument.')

    return hmmdef_path, label_path, frame_dir, output_path

def _parse_and_create(cfg, dataset):
    """
    Parse MLF file and create batches of all frames.
    """
    hmmdef_path, label_path, frame_dir, output_path = _parse_config(dataset)
    htk_parser = HtkParser(hmmdef_path, label_path, frame_dir)
    if not path.exists(output_path):
        os.makedirs(output_path)
    # get frame filenames and senone labels
    filenames_and_labels = htk_parser.parse_samples()
    dump_path = path.join(output_path, cfg['filenames-and-labels'])
    with open(dump_path, 'wb') as f:
        cPickle.dump(filenames_and_labels, f, -1)

    # create batch file
    create = BatchCreator(
        batch_size=int(cfg.get('batch-size', 1000)),
        channels=int(cfg.get('channels', 3)),
        size=eval(cfg.get('size', '(64, 64)')),
        output_path=output_path,
        )
    # filenames_and_labels = filenames_and_labels[:10]
    create(filenames_and_labels)

def make_batches(cfg, dataset):
    _parse_and_create(cfg, dataset)

def make_test_batches_no_label(cfg):
    hmmdef_path, label_path, frame_dir, output_path = _parse_config('Test')

    if not path.exists(output_path):
        os.makedirs(output_path)

    # get frame filenames and senone labels
    filenames_and_labels = htk_parser.parse_test_samples()

    # create batch file
    create = BatchCreator(
        batch_size=int(cfg.get('batch-size', 1000)),
        channels=int(cfg.get('channels', 3)),
        size=eval(cfg.get('size', '(64, 64)')),
        output_path=output_path,
        )
    create(filenames_and_labels)

def change_labels(cfg, dataset):
    hmmdef_path, label_path, frame_dir, output_path = _parse_config(dataset)
    htk_parser = HtkParser(hmmdef_path, label_path, frame_dir)

    # parse mlf to get new labels
    filenames_and_labels = htk_parser.parse_samples()

    # dump filenames and labels
    output_path = cfg['train-output-dir']
    dump_path =path.join(output_path, cfg['filenames-and-labels'])
    with open(dump_path, 'wb') as f:
        cPickle.dump(filenames_and_labels, f, -1)

    # change labels in pickle data
    filenames_and_labels = dict(filenames_and_labels)
    pickle_dir = cfg['train-output-dir']
    with open(path.join(pickle_dir, 'batches.meta'), 'rb') as f:
        meta_data = cPickle.load(f)

    batch_list = os.listdir(pickle_dir)
    
    for batch_name in batch_list:
        if not re.match(r'data_batch_\d', batch_name):
            continue
        batch_pickle_path = path.normpath(path.join(pickle_dir, batch_name))
        print 'Processing [%s]...' % batch_pickle_path,
        with open(batch_pickle_path, 'rb') as f:
            batch_data = cPickle.load(f)
        for i, idx_frame in enumerate(batch_data['ids']):
            frame_path = meta_data['metadata'][idx_frame]
            new_label = meta_data['label_names'].index(filenames_and_labels[frame_path])
            batch_data['labels'][i] = new_label

        # save pickle data
        with open(batch_pickle_path, 'wb') as f:
            cPickle.dump(batch_data, f, -1)
        print ' dumped.'

# ------------------------------------------------------------------------ #
# Parse Arguments
# ------------------------------------------------------------------------ #
def parse_args():
    parser = argparse.ArgumentParser()
    group1 = parser.add_mutually_exclusive_group()
    group1.add_argument('-tr', '--make-train', action='store_true', help='make train data batch')
    group1.add_argument('-chtr', '--change-labels', action='store_true', help='change train data batch labels')

    group2 = parser.add_mutually_exclusive_group()
    group2.add_argument('-te', '--make-test', action='store_true', help='make test data batch')
    group2.add_argument('-chte', '--change-test-labels', action='store_true', help='change test data batch labels')
    group2.add_argument('-tenl', '--make-test-no-label', action='store_true', help='make test data batch without labels')

    args = parser.parse_args()
    return args

if __name__ == '__main__':
    args = parse_args()
    cfg_path = get_config_path()
    cfg = get_options(cfg_path, 'dataset')

    if args.make_train:
        make_batches(cfg, 'Train')

    if args.change_labels:
        change_labels(cfg, 'Train')

    if args.make_test:
        make_batches(cfg, 'Test')

    if args.change_test_labels:
        change_labels(cfg, 'Test')

    if args.make_test_no_label:
        make_test_batches_no_label(cfg)
