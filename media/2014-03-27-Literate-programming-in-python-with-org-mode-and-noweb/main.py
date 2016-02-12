
import sys
import numpy as np
import matplotlib.pyplot as plt

from argparse import ArgumentParser

def utility_func(arg=None):
    return 'you called a utility function with this arg: {0}'.format(arg)

class HelloWorld(object):
    def __init__(self, who):
        self.who = who

    def __call__(self):
        return 'Hello {0}'.format(self.who)

    def test(self):
        return True

def main():
    parser = ArgumentParser(description="Say hi")
    parser.add_argument("-w", "--who", 
                        type=str,
                        default="world",
                        help="Who to say hello to")
    args = parser.parse_args()
  
    who = args.who
  
    greeter = HelloWorld(who)
    greeter()

    print 'test func = ', greeter.test()
  
    print utility_func()
    print utility_func(5)

    return 0

if __name__ == '__main__':
    status = main()
    sys.exit(status)
