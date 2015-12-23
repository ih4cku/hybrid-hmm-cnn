import re
import numpy as np
import random
from os import path
import os

class HtkParser:
    '''
    Generate frames labels and frames image data, then pass to BatchCreater to build dataset batches for cuda-convnet 
    '''
    def __init__(self, model_path, label_path, frame_dir):
        self.ext = '.png'
        self.model_path = model_path
        self.label_path = label_path
        self.frame_dir  = frame_dir

    def parse_models(self):
        '''
        Parse hmmdefs file

        models_info structure: 
        { hmm_name : [senones, ...] }
        '''
        print 'parsing HMM models [%s]...' % self.model_path,
        with open(self.model_path) as f_mmf:
            lines = [line.strip() for line in f_mmf]

        # find all hmm
        hmm_regex = r'~h\s+"(\w+)"'
        hmms = [[idx, re.match(hmm_regex, line).group(1)] for idx, line in enumerate(lines) if re.match(hmm_regex, line)]

        # construct hmm-senone structure
        models_info = []
        senone_regex = r'~s\s+"(\w+)"'
        for idx in xrange(len(hmms)):
            hmm_block = lines[hmms[idx][0] : hmms[idx+1][0]] if idx < len(hmms)-1 else lines[hmms[idx][0]:]
            states = [re.match(senone_regex, line).group(1) for line in hmm_block if re.match(senone_regex, line)]
            models_info.append([hmms[idx][1], states])

        models_info = dict(models_info)
        print 'done'

        return models_info

    def parse_alignment_mlf(self):
        '''
        Parse xx_rec_state_mlf file

        frms_info structure: 
        [ [fname, frms_info], ... ]

        frms_info: 
        [ [hmm_name, i_state], ... ]
        '''
        print 'parseing MLF file [%s]...' % self.label_path,
        with open(self.label_path) as f_mlf:
            header = f_mlf.next().strip()
            assert header == '#!MLF!#', 'header not MLF'
            lines = [line.strip() for line in f_mlf]

        # TO-Re
        idx_beg = [[idx, line.strip('"')] for idx, line in enumerate(lines) if '.rec' in line]
        idx_end = [[idx] for idx, line in enumerate(lines) if line == '.']
        assert len(idx_beg) == len(idx_end), 'BLOCK_BEG and BLOCK_END not same size.'

        all_blocks = [beg+end for beg, end in zip(idx_beg, idx_end)]

        frms_info = []
        for i_beg, fname, i_end in all_blocks:
            frm_lines = lines[i_beg+1:i_end]
            frm_lines = [list(re.match(r'(\d+)\s+(\d+)\s+(\w+)\[(\d+)\]', line).groups()) for line in frm_lines]
            frm_lines = [[int(item[0]), int(item[1]), item[2], int(item[3])] for item in frm_lines]

            frm_info = []
            for item in frm_lines:
                for i_frm in xrange(item[0], item[1]):
                    frm_info.append([item[2], item[3]])

            frms_info.append([fname, frm_info])

        print 'done.'
        return frms_info

    def parse_samples(self):
        '''
        filenames and labels are retrived from MLF file
        '''
        frms_info = self.parse_alignment_mlf()
        models_info = self.parse_models()

        print 'parsing samples...',
        frm_names_labels = []
        for frms_item in frms_info:
            # get frame image file dir
            frm_dir = '/'.join([self.frame_dir, path.basename(path.splitext(frms_item[0])[0])])
            for idx, frm in enumerate(frms_item[1]):
                frm_name = '/'.join([frm_dir, str(idx+1) + self.ext])
                frm_label = models_info[frm[0]][frm[1]-2] if models_info[frm[0]] else frm[0]
                # normalize path
                frm_name = path.normcase(path.normpath(frm_name))
                frm_names_labels.append([frm_name, frm_label])

        random.shuffle(frm_names_labels)
        print 'done.'
        return np.array(frm_names_labels)

    def parse_test_samples(self):
        '''
        filenames are all images in category dirs
        labels are None
        '''
        frame_root_dir = self.frame_dir

        frame_category_dirs = os.walk(frame_root_dir).next()[1]
        frm_names_labels = []  # [frm_name, frm_label]
        for cate_dir in frame_category_dirs:
            frame_fn_list = os.walk(path.join(frame_root_dir, cate_dir)).next()[2]
            map(lambda fn: frm_names_labels.append([path.normcase(path.normpath(path.join(frame_root_dir, cate_dir, fn))), 'none']), frame_fn_list)

        random.shuffle(frm_names_labels)
        return np.array(frm_names_labels)

