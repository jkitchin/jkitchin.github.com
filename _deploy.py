#

import commands, os, shutil

print commands.getstatusoutput('rm -fr _deploy/*')
print commands.getstatusoutput('cp -R _site/* _deploy')
os.chdir('_deploy')
print commands.getstatusoutput('git add .')
print commands.getstatusoutput('git add u')
print commands.getstatusoutput('git commit -m "deploy"')
print commands.getstatusoutput('git push origin master')
