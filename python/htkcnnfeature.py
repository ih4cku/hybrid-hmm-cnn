from pyhtk.dataset import BatchCreator
from htkwritefeatures import PredictNet
import cPickle
import numpy as np
import scipy.io
from util import *
from shownet import *
import ipdb

def get_fns_and_labs(frm_list_path):
    with open(frm_list_path) as f:
        lst = [[l.strip(), 'nul'] for l in f]

    return np.array(lst)

def create_batch(frm_list_fn, output_path):
    frm_list_path = os.path.join(output_path, frm_list_fn)
    filenames_and_labels = get_fns_and_labs(frm_list_path)
    n_samples = filenames_and_labels.shape[0]

    create = BatchCreator(
        batch_size=50000,
        channels=3,
        size=(32,32),
        output_path=output_path,
        )
    create(filenames_and_labels, shuffle=False)


if __name__ == '__main__':
    try:
        frm_list_fn = 'tmp_frm_list.txt'
    
        op = PredictNet.get_options_parser()
        op, load_dic = IGPUModel.parse_options(op)

        print '============== Creating Batches =============='
        output_path = op.options['test_data_path'].value
        create_batch(frm_list_fn, output_path)
        print 'done.'

        print '============== Writing features =============='
        model = PredictNet(op, load_dic)
        model.op.print_values()
        model.do_write_features()

        print '============== Saving to mat =============='
        feature_path = op.options['feature_path'].value
        batch_list = model.test_data_provider.get_batch_filenames(feature_path)
        feat_arr = []
        for batch_fn in batch_list:
            batch_path = os.path.join(feature_path, batch_fn)
            with open(batch_path, 'rb') as f:
                data_dic = cPickle.load(f)

            feat_arr.append(data_dic['data'])

        feat_arr = np.vstack(feat_arr)
        feat_path = os.path.join(output_path ,'feat.mat')
        scipy.io.savemat(feat_path, {'feat_arr': feat_arr})
        print 'done.'

    except (UnpickleError, ShowNetError, opt.GetoptError), e:
        print "----------------"
        print "Error:"
        print e
