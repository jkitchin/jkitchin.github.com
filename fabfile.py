from fabric.api import *
import os, shutil

    
def build():
    """
    Build blog, and run locally on port 9000
    """
    local("blogofile build")
    local("blogofile serve 9000")


def deploy():
    'copy _site to _deploy amd push to github'
    os.chdir('_deploy')
    # delete contents
    import glob
    for fd in glob.glob('*'):
        if os.path.isdir(fd):
            shutil.rmtree(fd)
        else:
            os.unlink(fd)

    # now copy _site here and commit the results
    local('cp -R ../_site/* .')
    local('git add .')
    local('git add -u')
    local('git commit -m "deploy"')
    local('git push origin master')

def commit():
    local('git add -u')
    local('git add _posts _blog org img')
    local('git commit -m "src"')
    local('git push origin source')
