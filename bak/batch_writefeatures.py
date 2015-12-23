import os

if __name__ == '__main__':
    for i_exp in range(2, 6):
        model_dir = r'data\htk\experiments\exp{0}'.format(str(i_exp))
        model_dir = os.path.join(model_dir, os.listdir(model_dir)[0])
        res_dir = r'data/htk/test/exp{0}/'.format(str(i_exp))
        if not os.path.exists(res_dir):
            os.makedirs(res_dir)
        cmd = r'python.exe cuda-convnet/shownet.py -f {0} --write-features=probs --feature-path={1} --test-data-path=data/htk/test'.format(model_dir, res_dir)
        os.system(cmd)
