# Build, serve and deploy the group website.
#
#   make build     render the site into _site/
#   make serve     serve _site/ at http://localhost:4321, re-rendering on save
#   make preview   quarto preview (slower to start; watches everything)
#   make talks     build new or changed Marp decks in talks/ (commit the output)
#   make verify    check every legacy URL is present and unchanged
#   make deploy    build, commit everything, push; the Action publishes
#   make clean     remove _site/ and .quarto/
#
# Uses the project venv (.venv) when it exists, so Quarto is >= 1.10.

VENV   := .venv/bin
PYTHON := $(if $(wildcard $(VENV)/python3),$(VENV)/python3,python3)
QUARTO := $(if $(wildcard $(VENV)/quarto),$(VENV)/quarto,quarto)
PORT   ?= 4321
BRANCH := modern-site

# The pre/post-render scripts call python3 and quarto by name.
export PATH := $(abspath $(VENV)):$(PATH)

.PHONY: build serve preview talks verify deploy clean help

help:
	@sed -n '3,10s/^# *//p' Makefile

build:
	$(QUARTO) render

serve: $(if $(wildcard _site/index.html),,build)
	$(PYTHON) scripts/serve.py $(PORT)

preview:
	$(QUARTO) preview --port $(PORT)

talks:
	$(PYTHON) scripts/build_talks.py

verify: build
	$(PYTHON) scripts/verify_legacy.py

# CI does not execute post code; it uses _freeze/ and _generated/. Render
# locally first so those are current, then commit everything and push.
#   make deploy MSG="Post: new thing"
MSG ?= Update site

deploy: build
	@test "$$(git branch --show-current)" = "$(BRANCH)" || \
	  { echo "deploy: switch to $(BRANCH) first"; exit 1; }
	git add -A
	@git diff --cached --quiet && echo "Nothing new to commit." || git commit -m "$(MSG)"
	git push origin $(BRANCH)
	@echo "Pushed. Follow the publish run with: gh run watch"

clean:
	rm -rf _site .quarto
