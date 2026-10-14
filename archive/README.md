# archive/

Sources of the old site, kept for reference. Nothing here is rendered or
deployed; the build ignores this folder.

## blogofile-source/

The blogofile sources that produced the 2009-2025 site, copied from the
`source` branch (commit 42e427fbbdb). The built output of these files is in
`../legacy/` and is what the site serves.

- `org/` the original org-mode files for posts, by date
- `_posts/` the HTML post bodies with YAML headers that blogofile rendered
- `_templates/`, `_controllers/`, `_filters/`, `_config.py`, `*.mako` the
  blogofile templates, plugins, configuration and top-level pages
- `publications/`, `publications.py`, `dept_publications.py` the old
  Scopus-based publication pages and the bibliography they used
- `make-org/` notes on the old org-to-blog workflow

Left out because they are already in `../legacy/` as served files, or were
build output or editor state: `_blog/`, `img/`, `css/`, `js/`, `media/`,
`aiche-2018/`, `elpa/`, `TAGS`, `*.pyc`, `.jupyter_ystore.db`.

The full history stays on the `source` branch in git.

The `dept-publications-*.html.mako` files contain an Elsevier API key in image
URLs. It is the same key that is public in `../legacy/` and on the live site;
rotate it.
