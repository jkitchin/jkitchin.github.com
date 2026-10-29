"""Build each Marp deck in talks/<slug>/deck.md into the files the site serves.

    python3 scripts/build_talks.py          # decks whose source is newer than the build
    python3 scripts/build_talks.py --all    # every deck

For each deck this writes index.html (one self-contained file with the
scimax presenter tools, via `scimax marp build`) and thumb.webp (the title
slide, for the listing on talks.qmd). The outputs are committed, because CI
does not have Marp; prerender.py only builds the listing from data/talks.yml.
"""

import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
MARP = ["npx", "--yes", "@marp-team/marp-cli@4"]  # same Marp CLI scimax uses
THUMB_W = 640


def stale(d):
    out = d / "index.html"
    if not out.exists():
        return True
    newest = max(f.stat().st_mtime for f in d.rglob("*")
                 if f.is_file() and f.name not in {"index.html", "thumb.webp"})
    return newest > out.stat().st_mtime


def build(d):
    print(f"building {d.relative_to(ROOT)}", flush=True)
    subprocess.run(["scimax", "marp", "build", "deck.md", "-o", "index.html"], cwd=d, check=True)
    with tempfile.TemporaryDirectory() as tmp:
        png = Path(tmp) / "title.png"
        subprocess.run(MARP + ["deck.md", "--image", "png", "--allow-local-files", "--html", "-o", str(png)],
                       cwd=d, check=True, capture_output=True)
        im = Image.open(png)
        im.thumbnail((THUMB_W, THUMB_W))
        im.save(d / "thumb.webp", "WEBP", quality=85)


if __name__ == "__main__":
    decks = sorted(p.parent for p in (ROOT / "talks").glob("*/deck.md"))
    for d in decks:
        if "--all" in sys.argv or stale(d):
            build(d)
    for d in decks:
        print(f"{d.name:32} {(d / 'index.html').stat().st_size / 1e6:5.1f} MB")
