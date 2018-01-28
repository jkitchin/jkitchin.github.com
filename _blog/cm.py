import os

class current_directory:
    def __init__(self, newdir, handler=None):
        """newdir is where we change to.
        handler is a function that will handle exceptions.
        It has a signature of handler(exception_type, exception_value, traceback).
        It should return True if the exception was handled, and False otherwise.

        """
        self.cwd = os.getcwd()
        self.newdir = newdir
        self.handler = handler
        print('init: ', os.getcwd())

    def __str__(self):
        s = 'current_directory CM (dir: {0} contextdir: {1} handler: {2})'
        return s.format(self.cwd, self.newdir, self.handler)

    def __enter__(self):
        # Enter the directory
        os.chdir(self.newdir)
        print('entered: ', os.getcwd())

    def __exit__(self, type, value, traceback):
        # return to where we came from first.
        os.chdir(self.cwd)
        print('exited: ', os.getcwd())
        if type is not None:
            if self.handler is not None:
                return self.handler(self, type, value, traceback)
            else:
                return False
        else:
            return True
