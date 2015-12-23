import os
import sys

if __name__ == '__main__':
    model_dir = r'data\htk\experiments\exp{0}'.format(sys.argv[1])
    model_dir = os.path.join(model_dir, os.listdir(model_dir)[0])
    cmd = r'python.exe cuda-convnet/shownet.py -f {0} --show-cost=logprob --cost-idx=1'.format(model_dir)
    os.system(cmd)