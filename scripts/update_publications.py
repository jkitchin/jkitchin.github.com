"""Add new journal articles to data/publications.yml from OpenAlex.

Run it on your machine when you want the list refreshed, then commit the change:

    python3 scripts/update_publications.py            # show what would be added
    python3 scripts/update_publications.py --write    # add them to the YAML

It looks up works by ORCID, keeps journal articles and reviews, and adds any
whose DOI is not already listed. It never edits or deletes existing entries, so
corrections you make by hand stick. Uses only the standard library and PyYAML.

Each new entry gets a permanent key, first author's surname + year with a
letter suffix if needed (smith2026, smith2026a, ...). Keys already in the file
or under papers/ are never reused. Name the paper's crucible summary the same
way; the export matches by DOI, so the page lands at this key regardless.

OpenAlex requires a free API key to page past the first 200 results; set
OPENALEX_API_KEY in the environment (https://openalex.org/settings/api).
"""

import argparse
import json
import os
import re
import sys
import time
import unicodedata
import urllib.parse
import urllib.request
from pathlib import Path

import yaml

ORCID = "0000-0003-2625-9232"
MAILTO = "jkitchin@andrew.cmu.edu"  # OpenAlex "polite pool"
DATA = Path(__file__).resolve().parent.parent / "data" / "publications.yml"
KEEP_TYPES = {"article", "review", "letter"}
EXCLUDE = DATA.parent / "publications-exclude.txt"
# Abstract-service duplicates and journal covers, not articles.
SKIP_DOI = ("10.1002/chin.",)
SKIP_TITLE = re.compile(r"^(ChemInform Abstract|Cover Picture)", re.I)


def excluded():
    if not EXCLUDE.exists():
        return set()
    return {line.split("#")[0].strip().lower() for line in EXCLUDE.read_text().splitlines()} - {""}


def fetch_works():
    works, cursor = [], "*"
    while cursor:
        q = urllib.parse.urlencode({
            "filter": f"author.orcid:{ORCID}",
            "per-page": 200,
            "cursor": cursor,
            "mailto": MAILTO,
        })
        if os.environ.get("OPENALEX_API_KEY"):
            q += "&api_key=" + urllib.parse.quote(os.environ["OPENALEX_API_KEY"])
        with urllib.request.urlopen(f"https://api.openalex.org/works?{q}", timeout=60) as r:
            page = json.load(r)
        works += page["results"]
        cursor = page["meta"].get("next_cursor")
        if not page["results"]:
            break
        time.sleep(0.2)
    return works


def short_name(display):
    """'John R. Kitchin' -> 'Kitchin J.R.' to match the existing entries."""
    parts = display.replace(",", " ").split()
    if len(parts) < 2:
        return display
    last, first = parts[-1], parts[:-1]
    initials = "".join(p[0] + "." for p in re.split(r"[\s.\-]+", " ".join(first)) if p)
    return f"{last} {initials}"


def new_key(entry, taken):
    """'Nunes-Alves A.', 2026 -> 'nunesalves2026', or the next free suffix."""
    surname = (entry["authors"] or ["x"])[0].split()[0]
    surname = unicodedata.normalize("NFKD", surname).encode("ascii", "ignore").decode()
    base = re.sub(r"[^a-z]", "", surname.lower()) + str(entry["date"])[:4]
    for suffix in [""] + [chr(c) for c in range(ord("a"), ord("z") + 1)]:
        if base + suffix not in taken:
            taken.add(base + suffix)
            return base + suffix
    raise ValueError(f"no free key for {base}")


def to_entry(w):
    loc = w.get("primary_location") or {}
    src = loc.get("source") or {}
    if w.get("type") not in KEEP_TYPES or src.get("type") != "journal" or not w.get("doi"):
        return None
    b = w.get("biblio") or {}
    vol = b.get("volume") or ""
    if b.get("issue"):
        vol = f"{vol}({b['issue']})"
    pages = "-".join(x for x in (b.get("first_page"), b.get("last_page")) if x)
    if b.get("first_page") and b.get("first_page") == b.get("last_page"):
        pages = b["first_page"]
    return {
        "key": "",
        "title": re.sub(r"<[^>]+>", "", w.get("title") or "").strip(),
        "authors": [short_name(a["author"]["display_name"]) for a in w.get("authorships", [])],
        "journal": src.get("display_name", ""),
        "volume": vol,
        "pages": pages,
        "date": w.get("publication_date") or str(w.get("publication_year", "")),
        "doi": w["doi"].replace("https://doi.org/", "").lower(),
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--write", action="store_true", help="update data/publications.yml")
    args = ap.parse_args()

    text = DATA.read_text()
    header = "".join(line for line in text.splitlines(True) if line.startswith("#"))
    pubs = yaml.safe_load(text)
    have = {p["doi"].lower() for p in pubs} | excluded()
    taken = {p["key"] for p in pubs} | {d.name for d in (DATA.parent.parent / "papers").iterdir()}

    new = []
    for w in fetch_works():
        e = to_entry(w)
        if not e or e["doi"].startswith(SKIP_DOI) or SKIP_TITLE.match(e["title"]):
            continue
        if e["doi"] not in have:
            e["key"] = new_key(e, taken)
            new.append(e)
            have.add(e["doi"])

    for e in sorted(new, key=lambda e: e["date"], reverse=True):
        print(f"+ {e['key']:<20} {e['title'][:90]}  ({e['doi']})")
    print(f"{len(new)} new of {len(pubs) + len(new)} total", file=sys.stderr)

    if args.write and new:
        pubs = sorted(pubs + new, key=lambda p: str(p.get("date", "")), reverse=True)
        DATA.write_text(header + yaml.safe_dump(pubs, allow_unicode=True, sort_keys=False, width=1000))
        print(f"wrote {DATA}", file=sys.stderr)


if __name__ == "__main__":
    main()
