from array import array
import os
import numpy as np 

if __name__ == '__main__':
    htkcode = 9
    nsamp = 5
    ndim  = 10
    samp_period = 1
    samp_size = 4*ndim
    data_vec  = np.zeros(ndim).tolist()

    try:
        f = open('test.htk', 'wb')
        # write head
        be_arr = array('L', [nsamp])
        be_arr.byteswap()
        be_arr.tofile(f)
        be_arr = array('L', [samp_period])
        be_arr.byteswap()
        be_arr.tofile(f)
        be_arr = array('H', [samp_size])
        be_arr.byteswap()
        be_arr.tofile(f)
        be_arr = array('H', [htkcode])
        be_arr.byteswap()
        be_arr.tofile(f)

        # write body 
        data = array('f', data_vec)
        for i_samp in range(5):
            be_arr = data
            be_arr.byteswap()
            be_arr.tofile(f)

    finally:
        f.close()

    os.system('HList -h test.htk')