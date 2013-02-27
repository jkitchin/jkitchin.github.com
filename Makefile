build:
	blogofile build

serve:
	blogofile serve 

deploy:
	rm -fr _deploy/*
	cd _site
	cp -R * ../_deploy
	cd ../_deploy
	git add .
	git add -u # update any tracked files
	git commit -m "`deployment on `date`"
	git push origin master --force
	cd ..


