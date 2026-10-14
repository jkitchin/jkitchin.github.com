# kitchingroup.cheme.cmu.edu

The group website. It has two parts:

- **`legacy/`** is the frozen blogofile site, 2009-2025: 623 posts, category and
  archive pages, and the old top-level pages. These files are never rebuilt or
  edited. Every old URL keeps working with its original look.
- **Everything else** is a [Quarto](https://quarto.org) website with a new
  look: the home page, Research, Publications, Software, Teaching, and new posts
  under `/posts/<slug>/`.

A GitHub Action renders the Quarto site, copies `legacy/` in, and deploys to
GitHub Pages.

## Layout

```
_quarto.yml               site config and navbar
theme/                    SCSS theme (light and dark)
index.qmd research.qmd teaching.qmd 404.qmd
publications.qmd          includes _generated/publications.md
software.qmd              includes _generated/software.md
data/publications.yml     publication list (edit by hand or update from OpenAlex)
data/software.yml         software cards (logos in assets/software/)
data/software-stats.json  stars/versions baked into the page (update_software_stats.py)
data/publications-exclude.txt  DOIs update_publications.py must never add
assets/ask/               Ask widget: BM25 search + optional in-browser WebLLM answers
posts/<slug>/index.qmd    a post (or index.ipynb)
_freeze/                  stored results of executed code (commit this)
_generated/               built from data/ by scripts/prerender.py (commit this)
legacy/                   the frozen old site
scripts/
  prerender.py            data/*.yml -> _generated/*.md (runs before render)
  merge_legacy.py         copies legacy/ into _site (runs after render)
  feeds.py                puts new posts into the old feed URLs
  update_publications.py  adds new articles from OpenAlex by ORCID
  seed_publications.py    one-time seed of data/publications.yml from legacy/
  verify_legacy.py        checks _site/ against the old site's master branch
  update_software_stats.py  GitHub/PyPI/crates.io numbers -> data/software-stats.json
  build_ask_index.py      _site/ask-index.json for the Ask widget (runs after render)
```

## Writing a post

1. Make a folder `posts/<slug>/` and put `index.qmd` (or `index.ipynb`) in it.
   The folder name is the URL: `/posts/<slug>/`. Slugs must be unique.
2. Start the file with front matter:

   ```yaml
   ---
   title: "Title"
   description: "One sentence for listings and feeds."
   date: 2026-10-20
   categories: [python, emacs]
   ---
   ```

   Use the same category names as the old blog (`emacs`, `org-mode`, `python`,
   ...) and the post also appears in that category's old feed, e.g.
   `/blog/category/emacs/feed/`.
3. Preview with `quarto preview`, then `quarto render`.
4. Commit the post **and** `_freeze/`. CI does not execute code; it uses the
   stored results. If you change a `.qmd` post and don't render it locally, CI
   will try to run it and fail.

**From org-mode:** export with `ox-ipynb` to `posts/<slug>/index.ipynb`, with
the front matter in a raw cell at the top. Notebooks are rendered from their
saved outputs and never executed, so code that needs a GPU, VASP or a license
is fine. Run the notebook before exporting so outputs are present.

## Updating pages

- **Publications:** `python3 scripts/update_publications.py` lists articles on
  OpenAlex that are not in `data/publications.yml`; add `--write` to add them.
  It never changes existing entries, so hand corrections stick.
- **Software:** edit `data/software.yml`, then `GH_TOKEN=$(gh auth token)
  python3 scripts/update_software_stats.py` to refresh the numbers shown
  before the page's own live update.
- **Ask widget:** the index is rebuilt on every render from the site pages,
  posts, `legacy/blog/`, `data/publications.yml` and, when present,
  `data/papers.json` (paper summaries from the crucible). Nothing to do by hand.
- **Research / Teaching:** edit the `.qmd` files.

## Old URLs and feeds

- `scripts/merge_legacy.py` copies `legacy/` into `_site/`. If the new site
  writes a file at a legacy path, the build fails, except for the pages it
  deliberately replaces (`REPLACED`: `index.html`, `research.html`,
  `publications.html`, `404.html`, `robots.txt`).
- `/blog/feed/`, `/blog/feed/atom/` and each `/blog/category/<name>/feed/`
  that a new post uses are rebuilt to hold the 10 newest items across old and
  new posts. Old items keep their original IDs, so readers don't see them
  twice. New posts also have their own feed at `/posts/index.xml`.
- `/pycse/` and `/dft-book/` are served from their own repositories and are
  not part of this build.

## Local build

```sh
pip install pyyaml lxml jupyter   # plus whatever your posts import
quarto render                     # output in _site/
python3 scripts/verify_legacy.py  # every old URL present and unchanged
```
