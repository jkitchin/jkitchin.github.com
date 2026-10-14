"""One-time seed of data/publications.yml from the old site.

Merges the Scopus-generated legacy/publications.html (2014 onward) with the
older entries in legacy/publications/kitchingroup.bib, de-duplicated by DOI.
After this, keep the YAML current with update_publications.py.

    python3 scripts/seed_publications.py
"""

import html
import re
from pathlib import Path

import bibtexparser  # pip install "bibtexparser>=2"
import yaml

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "data" / "publications.yml"
HEADER = (
    "# Publications list rendered on /publications.html.\n"
    "# Seeded from the legacy Scopus page and publications/kitchingroup.bib.\n"
    "# scripts/update_publications.py adds new works from OpenAlex by ORCID and never deletes entries.\n"
)


def clean(x):
    return html.unescape(re.sub(r"<[^>]+>", "", x)).strip().rstrip("'").strip()


def fix_escapes(s):
    """The Scopus page has literal \\xe2\\x80\\x93-style byte escapes; decode them."""
    def rep(m):
        b = bytes(int(h, 16) for h in re.findall(r"\\x([0-9a-fA-F]{2})", m.group(0)))
        return b.decode("utf-8", "replace")
    return re.sub(r"(?:\\x[0-9a-fA-F]{2})+", rep, s)


def from_scopus_page():
    s = (ROOT / "legacy" / "publications.html").read_text(encoding="utf-8")
    ol = s[s.find("<ol reversed"):]
    ol = ol[:ol.find("</ol>")]
    out = []
    for it in re.findall(r"<li>(.*?)</li>", ol, re.S):
        it = re.sub(r"<div data-badge.*?</div>", "", it, flags=re.S)
        it = re.sub(r"<img[^>]*>(</img>)?", "", it)
        m = re.search(r"<i>(.*?)</i>", it, re.S)
        if not m:
            continue
        rest = it[m.end():]
        j = re.search(r"sourceInfo[^>]*>(.*?)</a>", rest)
        vol = re.search(r"<b>(.*?)</b>", rest)
        date = re.search(r"\((\d{4}-\d{2}-\d{2})\)", rest)
        doi = re.search(r"doi:([^<]+)</a>", rest)
        pages = re.search(r"</b>,\s*([^,]+),\s*\(", rest) if vol else None
        out.append({
            "title": fix_escapes(clean(m.group(1))),
            "authors": [fix_escapes(clean(a)) for a in
                        re.findall(r"<a [^>]*authorId=[^>]*>(.*?)</a>", it[:m.start()])],
            "journal": fix_escapes(clean(j.group(1))) if j else "",
            "volume": clean(vol.group(1)) if vol else "",
            "pages": re.sub(r"^p\.\s*", "", clean(pages.group(1))) if pages else "",
            "date": date.group(1) if date else "",
            "doi": doi.group(1).strip() if doi else "",
        })
    return out


def short_name(a):
    a = ws(a)
    if "," in a:
        last, first = [x.strip() for x in a.split(",", 1)]
    else:
        parts = a.split()
        last, first = parts[-1], " ".join(parts[:-1])
    ini = "".join(p[0] + "." for p in re.split(r"[\s.-]+", first) if p)
    return f"{last} {ini}".strip()


def ws(s):
    return re.sub(r"\s+", " ", re.sub(r"[{}\\]", "", s)).strip()


def from_bib(have):
    lib = bibtexparser.parse_file(str(ROOT / "legacy" / "publications" / "kitchingroup.bib"))
    out = []
    for e in lib.entries:
        f = {k.lower(): v.value for k, v in e.fields_dict.items()}
        doi = f.get("doi", "").strip().lower()
        if e.entry_type.lower() != "article" or not doi or doi in have:
            continue
        out.append({
            "title": ws(f.get("title", "")),
            "authors": [short_name(a) for a in re.split(r"\s+and\s+", f.get("author", ""))],
            "journal": ws(f.get("journal", "")),
            "volume": ws(f.get("volume", "")),
            "pages": ws(f.get("pages", "")).replace("--", "-"),
            "date": ws(f.get("year", "")),
            "doi": doi,
        })
        have.add(doi)
    return out


if __name__ == "__main__":
    pubs = from_scopus_page()
    have = {p["doi"].lower() for p in pubs}
    pubs += from_bib(have)
    pubs.sort(key=lambda p: p["date"], reverse=True)
    OUT.parent.mkdir(exist_ok=True)
    OUT.write_text(HEADER + yaml.safe_dump(pubs, allow_unicode=True, sort_keys=False, width=1000))
    print(f"wrote {len(pubs)} entries to {OUT}")
