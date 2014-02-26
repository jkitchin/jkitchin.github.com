#!/usr/bin/env python
'''
module to create archive-contents from the contents of this directory
'''

import glob
import os, tarfile
from contextlib import closing

root = os.path.expanduser('~/Dropbox/blogofile-jkitchin.github.com/elpa/')

# get the tar-files
tfs = glob.glob(root + '*.tar')

def get_archive_contents_entry(tfile):

    basedir,tf = os.path.split(tfile)

    base, ext  = os.path.splitext(tf)

    splits = base.split('-')

    pkgname = '-'.join(splits[0:-1])
    version = splits[-1]

    with closing(tarfile.open(tfile)) as t:
        f = t.extractfile(pkgname + '/docstring.txt')
        DOCSTRING = f.read().strip()

        f = t.extractfile(pkgname + '/requirements.txt')
        REQUIREMENTS = f.read().strip()

        return '({pkgname} . [({version}) ({REQUIREMENTS}) "{DOCSTRING}" tar])'.format(**locals())

# build up a dictionary 
mostrecent = {}

for tf in tfs:
    basedir, tf = os.path.split(tf)
    base, ext = os.path.splitext(tf)
    splits = base.split('-')
    pkgname = '-'.join(splits[0:-1])
    version = float(splits[-1])

    if pkgname in mostrecent:
        if mostrecent[pkgname] < version:
            mostrecent[pkgname] = version
    else:
        mostrecent[pkgname] = version

ARCHIVE_CONTENTS = '(1\n'
    
for pkg in mostrecent:
    tfile = '{0}{1}-{2}.tar'.format(root, pkg, mostrecent[pkg])
    ARCHIVE_CONTENTS += '   ' + get_archive_contents_entry(tfile) + '\n'

ARCHIVE_CONTENTS += ')'

