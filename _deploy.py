#

import commands, shutil

commands.getstatusoutput('rm -fr _deploy/*')
commands.getstatusoutput('cp -R _site/* _deploy')
os.chdir('_deploy')
commands.getstatusoutput('git add .')
commands.getstatusoutput('git add u')
commands.getstatusoutput('git commit -m "deploy"')
commands.getstatusoutput('git push origin master')
