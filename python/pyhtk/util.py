from .matlab import MatlabServer

matlab_root_dir = 'E:/Codes/htk_matlab'

def get_config_path():
    with MatlabServer() as mlab:
        mlab.run_code('cd %s;' % matlab_root_dir)
        mlab.run_code('all_vars;')
        mlab.run_code('cfg_path = vars.convnet.cfg_file;')
        cfg_path = mlab.get_variable('cfg_path')
        print 'ConvNet config file [%s]' % cfg_path
    return cfg_path

