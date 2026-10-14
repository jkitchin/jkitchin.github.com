"""Check that the built site still serves every file the old site served.

Compares _site/ against the tree of the old site's branch (default: master):
every old path must exist; everything except the deliberately replaced pages
and the rewritten feed files must be byte-identical. Exits 1 on any problem.

    quarto render && python3 scripts/verify_legacy.py [branch]
"""

import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from merge_legacy import FEED_PATH, REPLACED  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
SITE = ROOT / "_site"


def main(branch="master"):
    names = subprocess.run(
        ["git", "-c", "core.quotepath=off", "ls-tree", "-r", "-z", "--name-only", branch],
        cwd=ROOT, capture_output=True, text=True, check=True).stdout.split("\0")
    names = [n for n in names if n]
    missing, changed, feeds = [], [], 0
    for n in names:
        out = SITE / n
        if not out.exists():
            missing.append(n)
            continue
        if n in REPLACED:
            continue
        old = subprocess.run(["git", "show", f"{branch}:{n}"], cwd=ROOT, capture_output=True).stdout
        if out.read_bytes() != old:
            if FEED_PATH.match(n):
                feeds += 1
            else:
                changed.append(n)
    same = len(names) - len(missing) - len(changed) - feeds - len(REPLACED & set(names))
    print(f"{len(names)} old paths: {same} identical, {len(REPLACED & set(names))} replaced, "
          f"{feeds} feeds rewritten, {len(changed)} changed, {len(missing)} missing")
    for n in (missing + changed)[:20]:
        print("  problem:", n)
    sys.exit(1 if missing or changed else 0)


if __name__ == "__main__":
    main(*sys.argv[1:2])
