from pymatbridge import Matlab

class MatlabServer(Matlab):
    def __enter__(self):
        self.start()
        return self

    def __exit__(self, exc_type, exc_value, exc_tb):
        self.stop()
        if not exc_type:
            return False
