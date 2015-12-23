import os
import time
import sys

N_BATCH = 5

if __name__ == '__main__':
    mix_dir = sys.argv[1]
    emb_cmd = r'HERest.exe -C htkconf.ini -H D:\dataset\SVHN\crop\{0}\hmms\flat\hmmdefs.txt -H D:\dataset\SVHN\crop\{0}\hmms\flat\vFloors -S D:\dataset\SVHN\crop\data\tr_list.txt -I D:\dataset\SVHN\crop\data\tr_phone_mlf.txt -M D:\dataset\SVHN\crop\{0}\hmms\flat D:\dataset\SVHN\crop\gram\phones.txt'.format(mix_dir)
    dec_cmd = r'HVite.exe -A -T 1 -C htkconf.ini -o SWC -H D:\dataset\SVHN\crop\{0}\hmms\flat\hmmdefs.txt -H D:\dataset\SVHN\crop\{0}\hmms\flat\vFloors -S D:\dataset\SVHN\crop\data\te_list.txt -i D:\dataset\SVHN\crop\{0}\label\te_rec_mlf.txt -w D:\dataset\SVHN\crop\gram\wdnet.txt D:\dataset\SVHN\crop\gram\dict.txt D:\dataset\SVHN\crop\gram\phones.txt & HResults.exe -A -T 1 -f -t -I D:\dataset\SVHN\crop\data\te_word_mlf.txt D:\dataset\SVHN\crop\gram\phones.txt D:\dataset\SVHN\crop\{0}\label\te_rec_mlf.txt'.format(mix_dir)

    try:
        f = open('{0}_log.txt'.format(mix_dir), 'w')
        f.write('%s\n' % time.strftime('%X'))

        # embedded training
        for i in range(N_BATCH):
            os.system(emb_cmd)
            f.write('%d - %s\n' % ( i, time.strftime('%X') ))
            f.flush()

        # decoding
        os.system(dec_cmd)
        f.write('%s\n' % time.strftime('%X'))
    finally:
        f.close()
