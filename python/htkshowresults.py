import re 
import sys
import cPickle
import argparse 
import os
from os import path
import numpy as np

from pprint import pprint
from noccn.script import get_options

def build_label_path_dict(filenames_and_labels):
    # build {label: [paths]} dict
    name_and_path = {}
    for file_path, label in filenames_and_labels:
        if label in name_and_path.keys():
            name_and_path[label].append(file_path)
        else:
            name_and_path[label] = [file_path]
    return name_and_path

def get_filenames_and_labels(output_dir, res_dir):
    # get meta filepath and batch file paths
    meta_path = path.join(output_dir, 'batches.meta')
    batch_filenames = filter(lambda item: re.match(r'data_batch_\d', item), os.listdir(output_dir))
    batch_paths = [path.normpath(path.join(output_dir, pk_file)) for pk_file in batch_filenames]
    res_batch_paths = [path.normpath(path.join(res_dir, pk_file)) for pk_file in batch_filenames]

    # load data
    meta = cPickle.load(open(meta_path, 'rb'))
    batch_ids = []
    for bch in batch_paths:
        batch_ids.extend(cPickle.load(open(bch, 'rb'))['ids'])
    batch_probs = []
    for bch in res_batch_paths:
        batch_probs.extend(cPickle.load(open(bch, 'rb'))['data'])

    batch_ids   = np.asarray(batch_ids)
    batch_probs = np.asarray(batch_probs)
    labels      = np.asarray(zip(batch_ids, list(batch_probs.argmax(axis=1))))

    filenames_and_labels = []
    for idx, lab_idx in labels:
        filenames_and_labels.append([meta['metadata'][idx]['name'], meta['label_names'][lab_idx]])

    return filenames_and_labels


    
def parse_args():
    parser = argparse.ArgumentParser()
    group  = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('-tr', '--train', action='store_true', help='show train samples')
    group.add_argument('-te', '--test',  action='store_true', help='show test samples')

    parser.add_argument('-l', '--labs', nargs='+', default=[], help='show only samples of supplied labels')
    parser.add_argument('-s', '--save', nargs='?', const='', metavar='SAVE_PATH', help='save samples to image, default current dir')
    parser.add_argument('-v', '--show', action='store_true', help='show sample images')

    args = parser.parse_args()
    return args

def main():
    cfg = get_options('options.cfg', 'dataset')
    args = parse_args()

    if args.train:
        output_dir = cfg['train-output-dir']
        res_dir    = cfg['train-result-dir']

    if args.test:
        output_dir = cfg['test-output-dir']
        res_dir    = cfg['test-result-dir']

    filenames_and_labels = get_filenames_and_labels(output_dir, res_dir)
    d = build_label_path_dict(filenames_and_labels)
    pprint(d)

if __name__ == '__main__':
    main()