
import ctypes as c

class PyObject_HEAD(c.Structure):
    _fields_ = [('HEAD', c.c_ubyte * (object.__basicsize__ -
                                      c.sizeof(c.c_void_p))),
                ('ob_type', c.c_void_p)]

_get_dict = c.pythonapi._PyObject_GetDictPtr
_get_dict.restype = c.POINTER(c.py_object)
_get_dict.argtypes = [c.py_object]

def get_dict(object):
    return _get_dict(object).contents.value

import collections
import numpy as np

def lispify(L):
    "Convert a Python object L to a lisp representation."
    if (isinstance(L, str)
        or isinstance(L, float)
        or isinstance(L, int)):
        return L.lisp()
    elif (isinstance(L, list)
          or isinstance(L, tuple)
          or isinstance(L, np.ndarray)):
        s = []
        for element in L:
            s += [element.lisp]
        return '(' + ' '.join(s) + ')'
    elif isinstance(L, dict):
        s = []
        for key in L:
            # alist format
            # s += ["({0} . {1})".format(key, L[key].lisp())]
            # plist
            s += [":{0} {1}".format(key, L[key].lisp)]
        return '(' + ' '.join(s) + ')'

get_dict(str)['lisp'] = property(lambda s:'"{}"'.format(str(s)))
get_dict(float)['lisp'] = property(lambda f:'{}'.format(str(f)))
get_dict(int)['lisp'] = property(lambda f:'{}'.format(str(f)))


get_dict(list)['lisp'] = property(lispify)
get_dict(tuple)['lisp'] = property(lispify)
get_dict(dict)['lisp'] = property(lispify)
get_dict(np.ndarray)['lisp'] = property(lispify)
