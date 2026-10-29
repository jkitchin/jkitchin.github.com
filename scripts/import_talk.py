"""Copy a Marp deck into talks/<slug>/, shrinking its images for the web.

    python3 scripts/import_talk.py ~/journal/.../argonne-talk/slides.md 2026-argonne-lans

The deck's folder is copied (its .md becomes deck.md, built and generated
files are left behind) and every PNG or JPEG larger than MAX_PX or MAX_BYTES
is rewritten as WebP, with references to it updated in the copied text
files. The original deck is not touched. Then add the talk to
data/talks.yml and run `make talks`.
"""

import os
import re
import shutil
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
MAX_PX = 1600          # longest side after resizing
MAX_BYTES = 300_000    # smaller images are copied as they are
QUALITY = 82
TEXT = {".md", ".css", ".html", ".js", ".svg", ".yml", ".yaml"}
SKIP = {".pdf", ".py"}  # exports and build scripts stay with the original


def main(deck, slug):
    deck = Path(deck).expanduser().resolve()
    src, dest = deck.parent, ROOT / "talks" / slug
    if dest.exists():
        sys.exit(f"{dest} exists; remove it first to re-import")
    built = {deck.with_suffix(".html").name, deck.with_suffix(".pdf").name}
    renamed = {}
    for f in sorted(src.rglob("*")):
        rel = f.relative_to(src)
        if f.is_dir() or f.name in built or f.suffix in SKIP or rel.parts[0].startswith(".") and f.name != ".marprc.yml":
            continue
        if f.suffix == ".md" and f != deck:
            continue  # e.g. a slides.src.md the deck was assembled from
        out = dest / ("deck.md" if f == deck else rel)
        out.parent.mkdir(parents=True, exist_ok=True)
        if f.suffix.lower() in {".png", ".jpg", ".jpeg"}:
            im = Image.open(f)
            if max(im.size) > MAX_PX or f.stat().st_size > MAX_BYTES:
                im.thumbnail((MAX_PX, MAX_PX))
                out = out.with_suffix(".webp")
                im.save(out, "WEBP", quality=QUALITY, method=6)
                renamed[rel] = rel.with_suffix(".webp")
                continue
        shutil.copy2(f, out)
    # Point the text files at the WebP copies, by paths relative to each file.
    for f in dest.rglob("*"):
        if not renamed or f.suffix not in TEXT:
            continue
        here = f.parent.relative_to(dest)
        subs = {Path(os.path.relpath(old, here)).as_posix(): Path(os.path.relpath(new, here)).as_posix()
                for old, new in renamed.items()}
        pattern = re.compile(r"(?<![\w./-])(" + "|".join(re.escape(k) for k in sorted(subs, key=len, reverse=True)) + ")")
        text = f.read_text()
        new = pattern.sub(lambda m: subs[m.group(1)], text)
        if new != text:
            f.write_text(new)
    before = sum(f.stat().st_size for f in src.rglob("*") if f.is_file() and f.suffix.lower() in {".png", ".jpg", ".jpeg"})
    after = sum(f.stat().st_size for f in dest.rglob("*") if f.is_file() and f.suffix.lower() in {".png", ".jpg", ".jpeg", ".webp"})
    print(f"{dest.relative_to(ROOT)}: {len(renamed)} images converted, "
          f"images {before / 1e6:.1f} MB -> {after / 1e6:.1f} MB")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(*sys.argv[1:])
