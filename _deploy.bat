rm -fr _deploy/*
cp -R _site/* _deploy
cd _deploy
git add .
git add -u
git commit -m "deploy"
git push origin master