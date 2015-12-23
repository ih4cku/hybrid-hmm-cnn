import subprocess
from pprint import pprint
import sys
import re
import os
import shutil
import cPickle
import time

# NOTICE: no succeding '/'
ROOT_DIR = 'E:/Datasets/SVHN/all'

def print_lines(lines):
    print '----- Parsing Lines -----'
    pprint(lines)

def check_line(lines):
    # assert len(lines)==1, 'Filter find multiple lines.'
    assert len(lines)!=0, 'Filter find no line.'

def check_command(lines):
    flat_str = ''.join(lines)
    assert flat_str.lower().find('error') == -1, 'Error occured in command.'


def run_command(cmd, trunc=True):
    """
    Run command and get stdout as string list.
    """
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
    output = []
    while True:
        line = p.stdout.readline()
        output.append(line)
        print line,
        if line=='' and p.poll()!= None:
            break

    check_command(output)

    # return last 20 lines
    if trunc:
        output = output[-30:]
    return output

def parse_hemest(lines):
    """
    Parse stdout of HERest.exe and get average log prob per frame.
    """
    print_lines(lines)

    head = 'Reestimation complete - average log prob per frame'

    line = filter(lambda x: x.startswith(head), lines)
    check_line(line)

    _, s = line[0].split('=', 1)
    prob = float(s)
    return prob

def parse_hvite(lines):
    """
    Parse stdout of HVite.exe and get sentence and word accuracy.
    """
    print_lines(lines)
    
    sent_head = 'SENT: %Correct'
    sent_line = filter(lambda x: x.startswith(sent_head), lines)
    check_line(sent_line)
    sent_acc = float(re.match(r'.+?=(\d+\.\d+).+', sent_line[0]).group(1))/100

    word_head = 'WORD: %Corr'
    word_line = filter(lambda x: x.startswith(word_head), lines)
    check_line(word_line)
    word_acc = float(re.match(r'.+?=(\d+\.\d+).+', word_line[0]).group(1))/100
    return sent_acc, word_acc

# -------------------------------
def foramt_hemest_cmd(feat_name, mix_num, src_dir, dst_dir):
    src_hmm_dir = '{0}/htk/{1}/mix_{2}/hmms/{3}'.format(ROOT_DIR, feat_name, mix_num, src_dir)
    dst_hmm_dir = '{0}/htk/{1}/mix_{2}/hmms/{3}'.format(ROOT_DIR, feat_name, mix_num, dst_dir)
    if os.path.exists(dst_hmm_dir):
        shutil.rmtree(dst_hmm_dir)
    os.makedirs(dst_hmm_dir)

    hmmdefs_path = '{0}/hmmdefs.txt'.format(src_hmm_dir)
    vFloors_path = '{0}/vFloors'.format(src_hmm_dir)

    list_dir        = '{0}/data/win_12_6/{1}'.format(ROOT_DIR, feat_name)
    list_file_path  = '{0}/tr_list.txt'.format(list_dir)
    phone_mlf_path  = '{0}/tr_phone_mlf.txt'.format(list_dir)
    phones_path     = '{0}/gram/phones.txt'.format(ROOT_DIR)

    herest_cmd = 'HERest.exe -C htkconf.ini -H {0} -H {1} -S {2} -I {3} -M {4} {5}'.format(hmmdefs_path, vFloors_path, list_file_path, phone_mlf_path, dst_hmm_dir, phones_path)
    return herest_cmd

def format_hvite_cmd(feat_name, mix_num, src_hmm_dir):
    src_hmm_dir = '{0}/htk/{1}/mix_{2}/hmms/{3}'.format(ROOT_DIR, feat_name, mix_num, src_hmm_dir)
    hmmdefs_path = '{0}/hmmdefs.txt'.format(src_hmm_dir)
    vFloors_path = '{0}/vFloors'.format(src_hmm_dir)

    list_dir        = '{0}/data/win_12_6/{1}'.format(ROOT_DIR, feat_name)
    list_file_path  = '{0}/te_list.txt'.format(list_dir)
    rec_label_path  = '{0}/htk/{1}/mix_{2}/label/te_rec_mlf.txt'.format(ROOT_DIR, feat_name, mix_num)
    wdnet_path      = '{0}/gram/wdnet.txt '.format(ROOT_DIR)
    dic_path        = '{0}/gram/dict.txt '.format(ROOT_DIR)
    phones_path     = '{0}/gram/phones.txt'.format(ROOT_DIR)

    hvite_cmd = 'HVite.exe -A -T 1 -C htkconf.ini -o SWC -H {0} -H {1} -S {2} -i {3} -w {4} {5} {6}'.format(hmmdefs_path, vFloors_path, list_file_path, rec_label_path, wdnet_path, dic_path, phones_path)
    return hvite_cmd

def format_hresults_cmd(feat_name, mix_num):
    label_path = '{0}/data/win_12_6/{1}/te_word_mlf.txt'.format(ROOT_DIR, feat_name)
    phones_path = '{0}/gram/phones.txt'.format(ROOT_DIR)
    rec_path = '{0}/htk/{1}/mix_{2}/label/te_rec_mlf.txt'.format(ROOT_DIR, feat_name, mix_num)
    hresults_cmd = 'HResults.exe -A -T 1 -f -t -I {0} {1} {2}'.format(label_path, phones_path, rec_path)
    return hresults_cmd

# -------------------------------

def format_commands(feat_name, mix_num, src_dir, dst_dir):

    train_cmd = foramt_hemest_cmd(feat_name, mix_num, src_dir, dst_dir)
    cmd1 = format_hvite_cmd(feat_name, mix_num, dst_hmm_dir)
    cmd2 = format_hresults_cmd(feat_name, mix_num)
    test_cmd = '{0} & {1}'.format(cmd1, cmd2)

    return train_cmd, test_cmd

def train_test(train_cmd, test_cmd):
    t = time.time()
    train_out = run_command(train_cmd)
    train_time = time.time()-t
    prob = parse_hemest(train_out)
    
    t = time.time()
    test_out = run_command(test_cmd)
    test_time = time.time()-t
    accs = parse_hvite(test_out)

    return prob, accs, train_time, test_time

if __name__ == '__main__':
    # feat_name = sys.argv[1]
    # mix_num = int(sys.argv[2])
    feat_name_list = ['cnn']
    mix_num_list = [100, 500, 800]

    for feat_name in feat_name_list:
        for mix_num in mix_num_list:
            src_hmm_dir = 'flat'

            prob_list = []
            accs_list = []
            train_time_list = []
            test_time_list = []
            # train 5 iters
            for it in range(1, 5):
                iter_num = it
                dst_hmm_dir = 'iter%d' % iter_num
                train_cmd, test_cmd = format_commands(feat_name, mix_num, src_hmm_dir, dst_hmm_dir)
                prob, accs, train_time, test_time = train_test(train_cmd, test_cmd)
                prob_list.append(prob)
                accs_list.append(accs)
                train_time_list.append(train_time)
                test_time_list.append(test_time)
                src_hmm_dir = dst_hmm_dir
                
            pk_path = '{0}/htk/{1}/mix_{2}/hmms/results.pk'.format(ROOT_DIR, feat_name, mix_num)
            with open(pk_path, 'wb') as f:
                cPickle.dump([prob_list, accs_list, train_time_list, test_time_list], f, -1)
            print '-------->', feat_name, mix_num, ' done.'
