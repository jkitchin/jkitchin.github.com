SOURCES = $(wildcard _posts/* _templates/*)

env:
	source .venv/bin/activate

build:
	uv run blogofile build

serve:
	uv run blogofile build
	uv run blogofile serve

status:
	git -C _deploy status --short | head -50

publications: publications.py
	python publications.py

dept:
	emacs -q --batch --eval '(progn (setq org-confirm-babel-evaluate nil) (find-file "department.org") (org-html-export-to-html nil nil nil t nil))'
	mv department.html department.html.mako
	python dept_publications.py

# _deploy must be a git clone of this repo checked out on master (the
# published-site branch). Without its .git, the commands below would run
# against the source repo instead, so refuse to proceed rather than guess.
deploy:
	@test -d _deploy/.git || { \
	  echo "ERROR: _deploy is not a git repo."; \
	  echo "Recreate it with: git clone -b master $$(git config remote.origin.url) _deploy"; \
	  exit 1; }
	rsync -avz --delete --exclude=.git --exclude=.venv _site/ _deploy
	git -C _deploy add -A && git -C _deploy commit -m "deployment" && git -C _deploy push origin master --force
	git add -A && git commit -m "source-commit" && git push --force

all:
	make publications
	make dept
	make build
	make deploy
