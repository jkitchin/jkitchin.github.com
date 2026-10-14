"""Copy the frozen legacy site into _site and bridge the old feeds.

Quarto runs this after rendering (project.post-render in _quarto.yml).

1. Every file under legacy/ is copied to the same path in _site/, except the
   top-level pages the new site replaces (REPLACED). If Quarto produced any
   other file at a legacy path, the build fails rather than silently
   overwriting old content.
2. The old feed URLs (/blog/feed/, /blog/feed/atom/ and the per-category
   feeds) are rewritten so they also carry new posts. See feeds.py.
"""

import filecmp
import os
import re
import shutil
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import feeds  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
LEGACY = ROOT / "legacy"
SITE = ROOT / "_site"

# Legacy files the new site deliberately replaces. Paths relative to the site root.
REPLACED = {
    "index.html",
    "research.html",
    "publications.html",
    "404.html",
    "about.html",  # the new About page replaces the old one (archive/ keeps its source)
    "robots.txt",  # Quarto adds a Sitemap line; the old file allowed everything too
}


FEED_PATH = re.compile(r"^blog/(category/[^/]+/)?feed/(atom/)?index\.xml$")


def copy_legacy():
    collisions, copied = [], 0
    for src in LEGACY.rglob("*"):
        if not src.is_file():
            continue
        rel = src.relative_to(LEGACY).as_posix()
        if rel in REPLACED:
            continue
        dest = SITE / rel
        if FEED_PATH.match(rel):
            # Feed files are rebuilt by feeds.bridge after every copy, so always
            # start from the frozen original.
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dest)
            continue
        if dest.exists():
            # Identical (same size and mtime) means we copied it on an earlier
            # render. Anything else is Quarto output landing on a legacy path.
            if filecmp.cmp(src, dest, shallow=True):
                continue
            collisions.append(rel)
            continue
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dest)
        copied += 1
    return copied, collisions


def main():
    if not SITE.exists():
        sys.exit("merge_legacy: _site/ does not exist; run quarto render first")
    copied, collisions = copy_legacy()
    if collisions:
        print("merge_legacy: the new site writes to legacy paths:", file=sys.stderr)
        for c in collisions[:50]:
            print("  " + c, file=sys.stderr)
        print("Add a path to REPLACED in scripts/merge_legacy.py if replacing it is intended.",
              file=sys.stderr)
        sys.exit(1)
    written = feeds.bridge(LEGACY, SITE)
    if os.environ.get("QUARTO_PROJECT_RENDER_ALL") or copied:
        print(f"merge_legacy: copied {copied} legacy files; wrote {len(written)} feed files")


if __name__ == "__main__":
    main()
