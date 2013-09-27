rm -fr _deploy/*

cd _deploy

cp -R ../_site/* .

git add .
git add -u
git commit -m "deploy"
git push origin master 