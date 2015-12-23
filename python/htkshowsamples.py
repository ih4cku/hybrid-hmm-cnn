import sys
import cPickle
import argparse 
import os
import re
from os import path
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm as cm

from PIL import Image
from joblib import Parallel, delayed
from multiprocessing.dummy import Pool
from pprint import pprint
from noccn.script import get_options
from pyhtk.util import get_config_path

N_JOBS = 8

def build_label_path_dict(filenames_and_labels):
    '''
    get frame paths of each category
    format: {label: [paths]} 
    '''
    name_and_path = {}
    for file_path, label in filenames_and_labels:
        if label in name_and_path.keys():
            name_and_path[label].append(file_path)
        else:
            name_and_path[label] = [file_path]
    return name_and_path

def get_filenames_and_labels(output_dir):
    '''
    get frame label from recognition result
    '''
    res_dir = path.join(output_dir, 'result')
    if not path.exists(res_dir):
        raise Exception('results not exist.')

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

def paste_images(args):
    '''
    paste im_path to im_new at ith position
    '''
    im_new, i, im_path, wid, hei, n_col, intval = args
    im = Image.open(im_path)
    if not im.size==(wid, hei):
        im = im.resize((wid, hei), Image.ANTIALIAS)
    i_row = int(np.floor(i/n_col))
    i_col = int(i % n_col)
    im_new.paste(im, (i_col*(wid+intval), i_row*(hei+intval)))

    sys.stdout.write('.')
    sys.stdout.flush()

def merge_images(im_list):
    '''
    merge images in IM_LIST to IM_NEW
    '''
    # init im_new
    im = Image.open(im_list[0])
    wid, hei = im.size
    ratio = hei/wid
    N = len(im_list)
    n_row = np.floor(np.sqrt(N/ratio))
    if n_row==0: n_row = 1
    n_col = np.ceil(N/n_row)
    intval = 2

    # make new blank image
    imshape = ([int(n_col*(wid+intval)-intval), int(n_row*(hei+intval)-intval)])
    im_new = Image.new('RGB', imshape, 'gray')

    # parallel pasting all frames into im_new
    pool = Pool(N_JOBS)
    pool.map(paste_images, ((im_new, i, im_path, wid, hei, n_col, intval) for i, im_path in enumerate(im_list)) )

    return im_new
    
def show_samples(cfg, args):
    '''
    show frames belong to each senone
    '''
    if args.train:
        output_dir = cfg['train-output-dir']
    elif args.test:
        output_dir = cfg['test-output-dir']
    save_dir = args.save

    # if not supply label, create for all
    if not args.labs:
        # load labels from metadata
        print 'Loading lab_list from batches.meta...',
        with open(path.join(output_dir, 'batches.meta'), 'rb') as f:
            metadata = cPickle.load(f)
        lab_list = metadata['label_names']
        print 'done.'
    else:
        lab_list = args.labs

    assert lab_list, 'empty lab list.'
    print lab_list

    if args.result:
        # use recognition result label
        print 'Getting filenames_and_labels from result...',
        filenames_and_labels = get_filenames_and_labels(output_dir)
        print 'done.'
    else:
        # use original label
        print 'Loading filenames_and_labels ...',
        name_label_pickle_path = path.join(output_dir, cfg['filenames-and-labels'])
        with open(name_label_pickle_path, 'rb') as f:
            filenames_and_labels = cPickle.load(f)
        print 'done.'

    # create {lab1: [frm1, frm2, ...], lab2: [frm1, frm2, ...]} 
    print 'Building label_path_dict...',
    label_path_dict = build_label_path_dict(filenames_and_labels)
    print 'done.'

    # loop to save each senone
    for lab in lab_list:
        assert lab in label_path_dict.keys(), 'wrong key %s' % lab

        print 'Merging frames of [%s]...' % lab
        im_all = merge_images(label_path_dict[lab])
        print 'done.'

        if not save_dir is None:
            if save_dir!='' and not path.exists(save_dir):
                #pwd_dir = os.getcwd()
                os.makedirs(save_dir)
            im_path = path.join(save_dir, lab+'.png')
            print '[%s] save to %s...' % (lab, im_path), 
            im_all.save(im_path)
            print 'done.'

        if args.show:
            plt.figure()
            plt.imshow(im_all, cmap=cm.Greys_r)
            plt.axis('off')
            plt.title(lab)

    if args.show:
        plt.show()
    
def parse_args():
    parser = argparse.ArgumentParser()
    group  = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('-tr', '--train', action='store_true', help='show train samples')
    group.add_argument('-te', '--test',  action='store_true', help='show test samples')

    parser.add_argument('-l', '--labs', nargs='+', default=[], help='show only samples of supplied labels')
    parser.add_argument('-s', '--save', nargs='?', const='', metavar='SAVE_PATH', help='save samples to image, default current dir')
    parser.add_argument('-v', '--show', action='store_true', help='show sample images')
    parser.add_argument('-r', '--result', action='store_true', help='show result instead of samples')

    args = parser.parse_args()
    return args

def main():
    args = parse_args()
    cfg_path = get_config_path()
    cfg = get_options(cfg_path, 'dataset')

    show_samples(cfg, args)

if __name__ == '__main__':
    main()