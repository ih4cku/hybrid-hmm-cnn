# htkwritefeatures.py 
# --f=E:\Datasets\SVHN\small\data\win_16_8\convnet\model\ConvNet__2015-01-15_16.17.50 
# --write-features=probs 
# --feature-path=E:\Datasets\SVHN\small\data\win_16_8\convnet\train\results 
# --test-data-path=E:\Datasets\SVHN\small\data\win_16_8\convnet\train\batches

from shownet import *
from data import DataProvider
from util import *
import getopt as opt
import svhndata

class PredictNet(ShowConvNet):
    def __init__(self, op, load_dic):
        ShowConvNet.__init__(self, op, load_dic)

    def init_data_providers(self):
        batch_range = DataProvider.get_batch_nums(self.test_data_path)
        self.test_data_provider = DataProvider.get_instance(self.test_data_path, 
                                                            batch_range,
                                                            type=self.dp_type, 
                                                            dp_params=self.dp_params, 
                                                            test=True)
        self.train_data_provider = DataProvider.get_instance(self.data_path, 
                                                            self.train_batch_range,
                                                            self.model_state["epoch"], 
                                                            self.model_state["batchnum"],
                                                            type=self.dp_type, 
                                                            dp_params=self.dp_params, 
                                                            test=False)
    @classmethod
    def get_options_parser(cls):
        op = ShowConvNet.get_options_parser()
        op.add_option('test-data-path', 'test_data_path', StringOptionParser, 'Path where data to predict.')
        return op

if __name__ == '__main__':
    try:
        op = PredictNet.get_options_parser()
        op, load_dic = IGPUModel.parse_options(op)
        model = PredictNet(op, load_dic)

        model.op.print_values()
        print 'Start writing features...'
        model.do_write_features()
        print 'done.'
    except (UnpickleError, ShowNetError, opt.GetoptError), e:
        print "----------------"
        print "Error:"
        print e