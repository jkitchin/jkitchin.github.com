SOURCES = $(wildcard _posts/* _templates/*)

build:	${SOURCES}
	blogofile build

serve:
	blogofile build
	blogofile serve

status:
	cd _deploy
	ls

publications: publications.py
	python publications.py

dept:
	emacs -q --batch --eval '(progn (setq org-confirm-babel-evaluate nil) (find-file "department.org") (org-html-export-to-html nil nil nil t nil))'
	mv department.html department.html.mako
	python dept_publications.py

deploy:
	rsync -avz --delete --exclude=.git _site/ _deploy
	cd _deploy; git add . && git add -u &&	git commit -m "deployment" && git push origin master --force
	git add . && git add -u && git commit -m "source-commit" && git push --force

all:
	make build
	make deploy
