import os
import time

if __name__ == '__main__':
    try:
        f = open('convnet_log.txt', 'w')
        f.write('start - %s\n' % time.strftime('%X'))

        # embedded training
        for i_exp in range(1, 6):
            # original train
            # cmd = r'python.exe cuda-convnet/convnet.py --data-path=data/htk/train --save-path=data/htk/exp{0}/ --layer-def=layer/exp{0}/layer.cfg --layer-params=layer/exp{0}/param.cfg --data-provider=cifar --test-freq=20 --train-range=1-110 --test-range=111-123 --epochs=15'.format(str(i_exp))
            
            # continuous train
            model_dir = r'data\htk\experiments\exp{0}'.format(str(i_exp))
            model_dir = os.path.join(model_dir, os.listdir(model_dir)[0])
            cmd = r'python.exe cuda-convnet/convnet.py --save-path= -f {0} --epochs=18'.format(model_dir)
            print cmd
            os.system(cmd)
            f.write('%d - %s\n' % ( i_exp, time.strftime('%X') ))
    finally:
        f.close()

