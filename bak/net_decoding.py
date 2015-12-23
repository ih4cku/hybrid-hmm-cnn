import cPickle
from util import get_gpu_lock

if __name__ == '__main__':
    # init model
    lib_name = 'pyconvnet'
    print 'Importing module...', 
    libmodel = __import__(lib_name)

    with open('layers.pk', 'rb') as f:
        layers = cPickle.load(f)
    mb_size = 10
    device_ids = get_gpu_lock()
    libmodel.initModel(layers, mb_size, device_ids)

    # load data
    with open('data.pk', 'rb') as f:
        data = cPickle.load(f)

    # decode
    layer_idx = 19
    libmodel.startFeatureWriter(data, layer_idx)
    libmodel.finishBatch()

    print data[-1]