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
    local('rm -fr _deploy/*')
    os.chdir('_deploy')
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
