from data import *
import numpy as n

class SVHNDataProvider(LabeledDataProvider):
    def __init__(self, data_dir, batch_range, init_epoch=1, init_batchnum=None, dp_params={}, test=False):
        LabeledDataProvider.__init__(self, data_dir, batch_range, init_epoch, init_batchnum, dp_params, test)
        self.data_mean = self.batch_meta['data_mean']
        self.num_colors = 3
        self.img_size = 32

    def get_next_batch(self):
        epoch, batchnum, datadic = LabeledDataProvider.get_next_batch(self)
        datadic['data'] = n.require((datadic['data'] - self.data_mean), dtype=n.single, requirements='C')
        datadic['labels'] = n.require(n.array(datadic['labels']).reshape((1, datadic['data'].shape[1])), dtype=n.single, requirements='C')
 
        return epoch, batchnum, [datadic['data'], datadic['labels']]

    # Returns the dimensionality of the two data matrices returned by get_next_batch
    # idx is the index of the matrix. 
    def get_data_dims(self, idx=0):
        return self.img_size**2 * self.num_colors if idx == 0 else 1
    
    # Takes as input an array returned by get_next_batch
    # Returns a (numCases, imgSize, imgSize, 3) array which can be
    # fed to pylab for plotting.
    # This is used by shownet.py to plot test case predictions.
    def get_plottable_data(self, data):
        return n.require((data + self.data_mean).T.reshape(data.shape[1], 3, self.img_size, self.img_size).swapaxes(1,3) / 255.0, dtype=n.single)
        # original
        # return n.require((data + self.data_mean).T.reshape(data.shape[1], 3, self.img_size, self.img_size).swapaxes(1,3).swapaxes(1,2) / 255.0, dtype=n.single)


# register data provider
DataProvider.register_data_provider('svhn', 'SVHN', SVHNDataProvider)
