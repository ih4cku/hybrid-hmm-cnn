from convnet import ConvNet
from gpumodel import IGPUModel

# use self-defined DataProvider
import svhndata

if __name__ == "__main__":
    #nr.seed(5)

    op = ConvNet.get_options_parser()

    op, load_dic = IGPUModel.parse_options(op)
    model = ConvNet(op, load_dic)
    model.start()
