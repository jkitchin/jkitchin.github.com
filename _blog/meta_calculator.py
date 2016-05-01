
import os
import types

class WithCurrentDirectory(type):
   """Metaclass that decorates all of its methods except __init__."""
   def __new__(cls, name, bases, attrs):
      return super(WithCurrentDirectory, cls).__new__(cls, name, bases, attrs)

   def __init__(cls, name, bases, attrs):
      """Decorate all the methods of the class instance with the classmethod cd.

      We skip __init__ because that is where the attributes are actually set.
      It is an error to access them before they are set.
      """
      for attr_name, attr_value in attrs.iteritems():
         if attr_name != '__init__' and isinstance(attr_value, types.FunctionType):
            setattr(cls, attr_name, cls.cd(attr_value))


   @classmethod
   def cd(cls, func):
      """Decorator to temporarily run cls.func in the directory stored in cls.wd.

      The working directory is restored to the original directory afterwards.
      """
      def wrapper(self, *args, **kwargs):
         if self.verbose:
            print('\nRunning {}'.format(func.__name__))
            print("Started in {}".format(os.getcwd()))
         os.chdir(self.wd)
         if self.verbose:
            print("  Entered {}".format(os.getcwd()))
         try:
            result = func(self, *args, **kwargs)
            if self.verbose:
               print('  {}'.format(result))
            return result
         except Exception, e:
            # this is where you would use an exception handling function
            print('  Caught {}'.format(e))
            pass
         finally:
            os.chdir(self.owd)
            if self.verbose:
               print("  Exited to {}\n".format(os.getcwd()))

      wrapper.__name__ = func.__name__
      wrapper.__doc__ = func.__doc__
      return wrapper


class Calculator(object):
   """Class we use for a calculator.

   Every method is decorated by the metaclass so it runs in the working
   directory defined by the class instance.

   """

   __metaclass__ = WithCurrentDirectory

   def __init__(self, wd, verbose=False):
      self.owd = os.getcwd()
      self.wd = wd
      self.verbose = verbose
      if not os.path.isdir(wd):
         os.makedirs(wd)


   def create_input(self, **kwargs):
      with open('INCAR', 'w') as f:
         for key, val in kwargs.iteritems():
            f.write('{} = {}\n'.format(key, val))


   def exc(self):
      "This raises an exception to see what happens"
      1 / 0

   def read_input(self):
      with open('INCAR', 'r') as f:
         return f.read()

   def __str__(self):
      return 'In {}. Contains: {}'.format(os.getcwd(),
                                          os.listdir('.'))
