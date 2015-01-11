from __future__ import division
import numpy as np

class IncompatibleUnits(Exception):
    def __init__(self, msg=None):
        self.msg = msg
    def __str__(self):
        return repr(self.msg)

class Unit(np.ndarray):

    BASE_UNITS = ['m', 's', 'kg', 'K', 'mol', 'coul', 'candela']

    def __new__(cls, input_array, exponents=None, label=None):
        # Input array is an already formed ndarray instance
        # We first cast to be our class type
        obj = np.asarray(input_array).view(cls)
        # add the new attribute to the created instance
        obj.exponents = np.array(exponents)
        obj.label = label
        # Finally, we must return the newly created object:
        return obj

    def __eq__(self, other):
        'implement a==b for units'
        if not isinstance(other, Unit):
            raise IncompatibleUnits(['you should not compare objects'
                                     ' with different units.'
                                     ' {0} == {1}'.format(self, other)])

        return (np.all(self.exponents == other.exponents)
                and np.all(np.array(self) == np.array(other)))

print np.float64(2) == Unit(2, [1, 0, 0, 0, 0, 0, 0])
