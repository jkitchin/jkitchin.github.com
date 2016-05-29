
import io
import os
import matplotlib.pyplot
original_savefig = matplotlib.pyplot.savefig

# patch to capture savefig
def mysave(fname, *args, **kwargs):
    """wrap savefig for org-mode."""

    original_savefig(fname, *args, **kwargs)
    print('[[file:{}]]'.format(fname))

matplotlib.pyplot.savefig = mysave

from hashlib import sha1
def git_hash(string):
    """Return a git has of string."""

    s = sha1()
    g = "blob {0:d}\0".format(len(string))
    s.update(g.encode('utf-8'))
    s.update(string)
    return s.hexdigest()

def myshow():
    format = "png"
    sio = io.BytesIO()
    original_savefig(sio, format=format)
    fig_contents = sio.getvalue()

    hash = git_hash(fig_contents)

    if not os.path.isdir('pyshow'):
        os.mkdir('pyshow')

    png = os.path.join('pyshow', hash + '.png')

    with open(png, 'wb') as f:
        f.write(fig_contents)

    print('[[file:{}]]'.format(png))

matplotlib.pyplot.show = myshow

# Tables
def table(data, name=None, caption=None, label=None, attributes=None):
    """Return a formatted table.

    attributes: [(backend, 'attributes')]
    """
    s = []
    if name is not None:
        s += ['#+TBLNAME: {}'.format(name)]

    if caption is not None:
        s += ['#+CAPTION: {}'.format(caption)]

    if label is not None:
        s += ['#+LABEL: {}'.format(label)]

    if attributes is not None:
        for backend, attrs in attributes:
            s += ['#+ATTR_{}: {}'.format(backend, attrs)]

    for row in data:
        if row is None:
            s += ['|-']
        else:
            s += ['| ' + ' | '.join([str(x) for x in row]) + '|']

    return '\n'.join(s)


def figure(fname, caption=None, label=None, attributes=None):
    """Return a formatted figure.

    attributes: [(backend, 'attributes')]
    """
    s = []

    if caption is not None:
        s += ['#+CAPTION: {}'.format(caption)]

    if label is not None:
        s += ['#+LABEL: {}'.format(label)]

    if attributes is not None:
        for backend, attrs in attributes:
            s += ['#+ATTR_{}: {}'.format(backend, attrs)]

    s += ['[[file:{}]]'.format(fname)]

    return '\n'.join(s)
