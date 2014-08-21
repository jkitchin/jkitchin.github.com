Sources = $(wildcard _posts/* _templates/*)

build:	${SOURCES}
	blogofile build

serve:
	blogofile serve 

status:
	cd _deploy
	ls

deploy:
	cd _deploy
	rsync -avz ../_site/ .
	git add .
	git add -u
	git commit -m "deployment"
	git push origin master --force
	cd ..
	git add .
	git add -u
	git commit -m "source-commit"
	git push --force


