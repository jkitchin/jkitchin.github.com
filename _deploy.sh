#!/bin/bash
# shell script to deploy new site

cd _deploy

rsync -avz ../_site/ .

git add .
git add -u
git commit -m "deploy"
git push origin master 
