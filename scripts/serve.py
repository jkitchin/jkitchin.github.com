"""Serve the built site locally and re-render pages when you save them.

    python3 scripts/serve.py            # http://localhost:4321
    python3 scripts/serve.py 8000       # another port

A lighter alternative to `quarto preview`, which spends minutes watching this
project's large tree (legacy/ and _site/ hold thousands of files). This polls
only the new site's sources:

  - a changed .qmd, .ipynb or .md page   -> quarto render <that page>
  - a changed theme, data file, _quarto.yml or asset -> quarto render (all)

Refresh the browser after the "rendered" line appears. Run `quarto render`
once first so _site/ exists.
"""

import functools
import http.server
import subprocess
import sys
import threading
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SITE = ROOT / "_site"
SKIP = {"legacy", "archive", "_site", "_freeze", ".quarto", ".venv", ".git", "_generated", "node_modules"}
PAGES = {".qmd", ".ipynb", ".md"}
EVERYTHING = {".scss", ".yml", ".yaml", ".js", ".css", ".svg", ".png", ".json", ".py"}


def sources():
    for p in ROOT.rglob("*"):
        rel = p.relative_to(ROOT)
        if rel.parts[0] in SKIP or not p.is_file():
            continue
        if p.suffix in PAGES | EVERYTHING:
            yield p


def is_page(p):
    """Only files the site renders (see project.render in _quarto.yml)."""
    rel = p.relative_to(ROOT)
    if p.name.startswith("_") or p.suffix not in PAGES:
        return False
    if len(rel.parts) == 1:
        return p.suffix == ".qmd"  # top-level pages; README.md is not one
    return rel.parts[0] in ("posts", "papers")


def snapshot():
    return {p: p.stat().st_mtime for p in sources()}


def render(target=None):
    cmd = ["quarto", "render"] + ([str(target.relative_to(ROOT))] if target else [])
    print(f"rendering {target.relative_to(ROOT) if target else 'the whole site'} ...", flush=True)
    t = time.time()
    r = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
    errors = [l for l in (r.stdout + r.stderr).splitlines() if "ERROR" in l]
    print("\n".join(errors) if errors else f"rendered in {time.time() - t:.0f} s; refresh the browser", flush=True)


def watch():
    seen = snapshot()
    while True:
        time.sleep(2)
        now = snapshot()
        changed = [p for p, m in now.items() if seen.get(p) != m]
        seen = now
        if not changed:
            continue
        pages = [p for p in changed if is_page(p)]
        if any(p.suffix in EVERYTHING or p.name == "_quarto.yml" for p in changed):
            render()
        else:
            for p in pages:
                render(p)
        seen = snapshot()  # renders write _generated/ and papers/; don't loop on them


def main(port=4321):
    if not SITE.exists():
        sys.exit("serve: run `quarto render` first")
    handler = functools.partial(http.server.SimpleHTTPRequestHandler, directory=str(SITE))
    handler.log_message = lambda *a: None
    server = http.server.ThreadingHTTPServer(("", port), handler)
    threading.Thread(target=watch, daemon=True).start()
    print(f"serving {SITE} at http://localhost:{port} (Ctrl-C to stop); watching sources", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main(int(sys.argv[1]) if len(sys.argv) > 1 else 4321)
