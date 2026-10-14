"""Build _site/ask-index.json, the search corpus for the Ask widget (assets/ask/).

Quarto runs this after merge_legacy.py (project.post-render in _quarto.yml).
The widget does BM25 over these passages in the reader's browser and, if the
reader loads a WebLLM model, writes an answer from the top few.

Sources, each a "kind" the widget can label:

  page   the new site's pages (_site/*.html), split at section headings
  post   new posts (_site/posts/<slug>/index.html)
  blog   the frozen 2009-2025 posts (legacy/blog/YYYY/MM/DD/<slug>/index.html)
  pub    one passage per article in data/publications.yml (bibliographic record)
  paper  summaries of the group's papers (papers/<key>/, from the crucible wiki
         via scripts/export_crucible.py)
  topic  research topics across those papers (papers/topics/<concept>/)

Format (short keys keep the file small; the widget depends on t, h, u, k, x):

  {"schema": 1, "counts": {kind: n, ..., "total": n},
   "chunks": [{"t": page title, "h": "Title › Section", "u": "/path#anchor",
               "k": kind, "x": text, "d": "YYYY-MM-DD" (optional),
               "c": citation (optional)}]}
"""

import json
import re
import sys
from pathlib import Path

import yaml
from lxml import html

ROOT = Path(__file__).resolve().parent.parent
SITE = ROOT / "_site"
LEGACY = ROOT / "legacy"
OUT = SITE / "ask-index.json"

MAX_CHARS = 1600   # split longer sections at block boundaries
MIN_CHARS = 40     # drop fragments shorter than this
MAX_CODE_LINES = 40
PAGES = ["index.html", "about.html", "research.html", "software.html", "teaching.html"]
BLOCKS = ("p", "li", "pre", "table", "dt", "dd", "blockquote")
HEADINGS = ("h1", "h2", "h3", "h4")
SKIP = "|".join(f"ancestor::{t}" for t in ("li", "table", "blockquote", "pre", "nav", "script", "style"))
XPATH = (" | ".join(f".//{t}[not({SKIP})]" for t in BLOCKS + HEADINGS))


def ws(s):
    return re.sub(r"\s+", " ", s or "").strip()


def block_text(el):
    if el.tag == "pre":
        lines = el.text_content().rstrip().splitlines()
        if len(lines) > MAX_CODE_LINES:
            lines = lines[:MAX_CODE_LINES] + ["..."]
        return "```\n" + "\n".join(lines) + "\n```"
    if el.tag == "li":
        return "- " + ws(el.text_content())
    return ws(el.text_content())


def sections(root, title):
    """Yield (heading trail, anchor, text) for each section of a content element."""
    trail, anchor, buf = [title], "", []
    levels = {}

    def flush():
        text = "\n\n".join(b for b in buf if b)
        if text:
            yield " › ".join(trail), anchor, text

    for el in root.xpath(XPATH):
        if el.tag in HEADINGS:
            yield from flush()
            buf = []
            level = int(el.tag[1])
            head = ws(el.text_content())
            if not head:
                continue
            levels = {k: v for k, v in levels.items() if k < level}
            levels[level] = head
            trail = [title] + [levels[k] for k in sorted(levels) if levels[k] != title]
            # Quarto puts the id on the enclosing <section>; Pandoc/org on the heading.
            parent = el.getparent()
            anchor = el.get("id") or (parent.get("id") if parent is not None and parent.tag == "section" else "") or ""
        else:
            buf.append(block_text(el))
    yield from flush()


def split(text):
    """Split long text at block boundaries into pieces of at most MAX_CHARS."""
    if len(text) <= MAX_CHARS:
        return [text]
    out, cur = [], ""
    for block in text.split("\n\n"):
        while len(block) > MAX_CHARS:  # a single huge block: cut at lines
            cut = block.rfind("\n", 0, MAX_CHARS)
            cut = cut if cut > 0 else MAX_CHARS
            if cur:
                out.append(cur)
                cur = ""
            out.append(block[:cut])
            block = block[cut:].lstrip("\n")
        if cur and len(cur) + len(block) + 2 > MAX_CHARS:
            out.append(cur)
            cur = block
        else:
            cur = f"{cur}\n\n{block}" if cur else block
    if cur:
        out.append(cur)
    return out


def add(chunks, kind, title, url, root, date=None):
    for trail, anchor, text in sections(root, title):
        for piece in split(text):
            if len(piece) < MIN_CHARS:
                continue
            c = {"t": title, "h": trail, "u": url + (f"#{anchor}" if anchor else ""), "k": kind, "x": piece}
            if date:
                c["d"] = date
            chunks.append(c)


def new_pages(chunks):
    files = [SITE / p for p in PAGES] + sorted(SITE.glob("posts/*/index.html"))
    for f in files:
        if not f.exists():
            continue
        doc = html.parse(str(f)).getroot()
        main = doc.xpath('//main[@id="quarto-document-content"]')
        if not main:
            continue
        main = main[0]
        h1 = doc.xpath('//h1[contains(@class,"title")]')
        title = ws(h1[0].text_content()) if h1 else ws(doc.findtext(".//title")).split(" – ")[0]
        for bad in main.xpath('.//header[@id="title-block-header"] | .//div[contains(@class,"quarto-listing")]'):
            bad.getparent().remove(bad)
        rel = f.relative_to(SITE).as_posix()
        url = "/" + (rel[:-len("index.html")] if rel.endswith("index.html") else rel)
        date = None
        kind = "page"
        if rel.startswith("posts/"):
            kind = "post"
            m = doc.xpath('//div[contains(@class,"quarto-title-meta")]//p[contains(@class,"date")]')
            date = ws(m[0].text_content()) if m else None
        add(chunks, kind, title, url, main, date)


def legacy_posts(chunks):
    for f in sorted(LEGACY.glob("blog/20*/*/*/*/index.html")):
        doc = html.parse(str(f)).getroot()
        prose = doc.xpath('//div[contains(concat(" ", @class, " "), " post_prose ")]')
        head = doc.xpath('//h2[contains(@class, "blog_post_title")]')
        if not prose or not head:
            continue
        rel = f.parent.relative_to(LEGACY).as_posix()
        y, m, d = rel.split("/")[1:4]
        add(chunks, "blog", ws(head[0].text_content()), f"/{rel}/", prose[0], f"{y}-{m}-{d}")


def citation(p):
    authors = p.get("authors", [])
    au = ", ".join(authors[:6]) + (", et al." if len(authors) > 6 else "")
    ref = p.get("journal", "")
    if p.get("volume"):
        ref += f" {p['volume']}"
    if p.get("pages"):
        ref += f", {p['pages']}"
    return f"{au.rstrip('.')}. {p['title']}. {ref} ({str(p.get('date', ''))[:4]}). https://doi.org/{p['doi']}"


def publications(chunks):
    pubs = yaml.safe_load((ROOT / "data" / "publications.yml").read_text())
    for p in pubs:
        if not p.get("doi"):
            continue
        cite = citation(p)
        chunks.append({"t": p["title"], "h": f"Publication › {p['title']}",
                       "u": f"https://doi.org/{p['doi']}", "k": "pub",
                       "x": cite, "d": str(p.get("date", "")), "c": cite})


def papers(chunks):
    """Paper summaries and topic pages exported from the crucible (export_crucible.py)."""
    for f in sorted(SITE.glob("papers/*/index.html")) + sorted(SITE.glob("papers/topics/*/index.html")):
        doc = html.parse(str(f)).getroot()
        main = doc.xpath('//main[@id="quarto-document-content"]')
        if not main:
            continue
        main = main[0]
        h1 = doc.xpath('//h1[contains(@class,"title")]')
        title = ws(h1[0].text_content()) if h1 else f.parent.name
        cite = main.xpath('.//div[contains(@class,"paper-citation")]')
        citation = ws(cite[0].text_content()) if cite else ""
        for bad in main.xpath('.//header[@id="title-block-header"] | .//div[contains(@class,"callout")]'
                              ' | .//div[contains(@class,"paper-citation")]'):
            bad.getparent().remove(bad)
        rel = f.parent.relative_to(SITE).as_posix()
        before = len(chunks)
        add(chunks, "topic" if "/topics/" in f"/{rel}/" else "paper", title, f"/{rel}/", main)
        for c in chunks[before:]:
            if citation:
                c["c"] = citation


def main():
    if not SITE.exists():
        sys.exit("build_ask_index: _site/ does not exist; run quarto render first")
    chunks = []
    new_pages(chunks)
    papers(chunks)
    publications(chunks)
    legacy_posts(chunks)
    counts = {}
    for c in chunks:
        counts[c["k"]] = counts.get(c["k"], 0) + 1
    counts["total"] = len(chunks)
    OUT.write_text(json.dumps({"schema": 1, "counts": counts, "chunks": chunks},
                              ensure_ascii=False, separators=(",", ":")))
    print(f"build_ask_index: {counts} -> {OUT.stat().st_size / 1e6:.1f} MB")


if __name__ == "__main__":
    main()
