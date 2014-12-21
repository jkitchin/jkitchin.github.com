#!/usr/bin/env python

# Deep, dirty, and exhaustive 'apropos' for Python. Crawls all 
# libraries in the system.path, and matches a querystring against
# all module names, as well as class, function, and method names 
# and docstrings of the top-level modules.
# Usage: ./apropos.py <keyword>
#
# This module was created due to the shortcomings of PyDoc's apropos
# method, which fails hard when one of the top level modules cannot
# be imported. The native apropos method also does not crawl
# docstrings, or deep module names, which this module does.
#
# (c) 2011 Philipp Pfeiffenberger

import sys
import re
import os
import stat
import inspect

module_hashes_ = [] # Enforce unique modules without keeping all in memory

B_START = "\033[1m"
B_RESET = "\033[0;0m"

def apropos_find(to_find):
    module_names_ = []
    matches_ = []

    for dir_ in sys.path:
        if not is_dir(dir_):
            continue
        module_names_ += find_modules(dir_)
    find_in_module_names(to_find, module_names_)

    sys.stderr = os.devnull
    sys.stdout = os.devnull
    for module_name in module_names_:
        if "." in module_name:
            continue
        try:
            module_ = __import__(module_name)
            find_in_module(to_find, module_)
            del module_
        except Exception, e:
            pass
    sys.stderr = sys.__stderr__
    sys.stdout = sys.__stdout__

def find_modules(cur_dir, parent_dirs = None):
    ''' Finds and returns all modules in the system's python paths.
    Searches for .py files in cur_dir and all subdirectories that have __init__.py.
    '''
    parent_dirs = parent_dirs or []

    if not is_dir(cur_dir):
        return []

    entries = os.listdir(cur_dir)
    
    files_ = [file_ for file_ in entries if file_[-3:] == ".py"]
    module_names_ = list(set([(file_.split(os.sep)[-1])[:-3] for file_ in files_ if file_]))
    module_names_ = [".".join(parent_dirs+[module_name_]) for module_name_ in module_names_]


    dirs_ = [dir_ for dir_ in entries if is_dir(cur_dir+os.sep+dir_)]
    for dir_ in dirs_:
        dir_path_ = cur_dir+os.sep+dir_
        if '__init__.py' in os.listdir(dir_path_):
            module_names_ += find_modules(dir_path_, parent_dirs + [dir_])
    return module_names_

def find_in_module(to_find, module):
    members = dir(module)
    matches = []
    module_hash_ = hash(module)
    
    if module_hash_ in module_hashes_:
        return []
    else:
        module_hashes_.append(module_hash_)

    for member_str in members:
        member_ = getattr(module,member_str)
        docstr_ = getattr(member_,'__doc__','')
        docstr_ = isinstance(docstr_,str) and docstr_ or ""
        if not inspect.ismodule(member_):
            if is_match(to_find, docstr_) or is_match(to_find, member_str):
                print_("="*30)
                print_("Matched in %s %s of module %s" % \
                           (type(member_).__name__,
                            member_str, module.__name__),
                       to_bold=to_find)
                print_(docstr_,to_bold=to_find)
                print_("")

def find_in_module_names(to_find, module_names):
    for module_name_ in module_names:
        if is_match(to_find, module_name_):
            print_("Matched in module name: %s" % module_name_, to_bold=to_find)

def is_match(needle, haystack):
    return re.search(needle, haystack)

def print_(to_print, to_bold=None):
    sys.stdout = sys.__stdout__
    if to_bold:
        spans_ = [i.span() for i in re.finditer(to_bold, to_print)]
        for s in spans_[::-1]:
            to_print = to_print[:s[1]]+B_RESET+to_print[s[1]:]
            to_print = to_print[:s[0]]+B_START+to_print[s[0]:]
    print to_print
    sys.stdout = os.devnull

def is_dir(dirpath):
    return os.access(dirpath, os.R_OK|os.X_OK) and \
        stat.S_ISDIR(os.stat(dirpath).st_mode)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print "Usage: %s <keyword>" % sys.argv[0]
    else:
        apropos_find(sys.argv[1])
