import cPickle
from fnmatch import fnmatch
import operator
import os
import random
import sys
import traceback

import numpy as np
from PIL import Image
from PIL import ImageOps
from joblib import Parallel
from joblib import delayed

from sklearn.utils import shuffle as skshuffle

N_JOBS = -1
SIZE = (32, 32) # (width, height)

def _process_item(creator, name):
    return creator.process_item(name)

out_len = 100

class BatchCreator(object):
    def __init__(self, batch_size=1000, channels=3, size=SIZE,
                 output_path='.', n_jobs=N_JOBS, more_meta=None, **kwargs):
        self.batch_size = batch_size
        self.channels = channels
        self.size = size
        self.output_path = output_path
        self.n_jobs = n_jobs

        if not os.path.exists(output_path):
            os.mkdir(output_path)

        self.more_meta = more_meta or {}
        self.idot = 1
        vars(self).update(**kwargs)  # O_o

    def dot(self, d='.'):
        if (self.idot % out_len)==0:
            d = '\n'
            self.idot = 1
        sys.stdout.write(d)
        sys.stdout.flush()
        self.idot += 1

    def __call__(self, names_and_labels, shuffle=True):
        batch_size = self.batch_size
        n_samples = len(names_and_labels)
        ids = range(n_samples)
        if shuffle:
            ids, names_and_labels = skshuffle(ids, names_and_labels)
        labels_sorted = sorted(set(p[1] for p in names_and_labels))
        labels = [labels_sorted.index(label) for name, label in names_and_labels]

        sub_sum = 0
        for idx_batch, batch_start in enumerate(range(0, n_samples, batch_size)):
            batch = {'data': None, 'labels': [], 'metadata': []}
            batch_end = min(n_samples, batch_start+batch_size)
            sub_ids, sub_samples = ids[batch_start:batch_end], names_and_labels[batch_start:batch_end]

            rows = Parallel(n_jobs=self.n_jobs)(
                delayed(_process_item)(self, name)
                for name, label in sub_samples
                )

            sub_data = np.vstack(rows)
            sub_labels = np.array(labels[batch_start:batch_end], dtype='float32')
            sub_ids = ids[batch_start:batch_end]
            sub_sum += sub_data.sum(axis=0)

            batch['data'] = sub_data.T
            batch['labels'] = sub_labels
            batch['ids'] = sub_ids

            batch_path = os.path.join(self.output_path, 'data_batch_%d' % (idx_batch+1))
            with open(batch_path, 'wb') as f:
                cPickle.dump(batch, f, -1)
            sys.stdout.write('Wrote to %s\n' % batch_path)
            sys.stdout.flush()

        batches_meta = {}
        batches_meta['label_names'] = labels_sorted
        batches_meta['metadata'] = [name for name, _lab in names_and_labels]
        # mean should be Dx1 for broadcasting with DxN
        data_mean = sub_sum/n_samples
        data_mean = data_mean[:, None]
        batches_meta['data_mean'] = data_mean
        meta_path = os.path.join(self.output_path, 'batches.meta')
        with open(meta_path, 'wb') as f:
            cPickle.dump(batches_meta, f, -1)
        print 'Wrote to %s' % meta_path

    def load(self, name):
        return Image.open(name)

    def preprocess(self, im):
        """Takes an instance of what self.load returned and returns an
        array.
        """
        im = im.resize(self.size, Image.ANTIALIAS)
        im_data = np.array(im)
        im_data = im_data.T.reshape(self.channels, -1).reshape(-1)
        im_data = im_data.astype(np.single)
        return im_data

    def process_item(self, name):
        try:
            data = self.load(name)
            data = self.preprocess(data)
            self.dot()
            return data
        except:
            print "Error processing %s" % name
            traceback.print_exc()
            return None

    def preprocess_data(self, data):
        return data


def _find(root, pattern):
    for path, folders, files in os.walk(root, followlinks=True):
        for fname in files:
            if fnmatch(fname, pattern):
                yield os.path.join(path, fname)


def _collect_filenames_and_labels(path, pattern):
    filenames_and_labels = []
    for fname in _find(path, pattern):
        label = os.path.basename(os.path.split(fname)[-2])
        filenames_and_labels.append((fname, label))
    random.shuffle(filenames_and_labels)
    return np.array(filenames_and_labels)


if __name__ == '__main__':
    filenames_and_labels = _collect_filenames_and_labels('D:/Dataset/MNIST/digits/test', '*.bmp')
    creator = BatchCreator(channels=1)
    creator(filenames_and_labels)
