"""Generate the data-driven partials included by publications.qmd and software.qmd.

Quarto runs this before every render (project.pre-render in _quarto.yml).
Outputs go to _generated/, which Quarto does not render on its own.
"""

import html
import json
import re
import urllib.parse
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "_generated"
ME = re.compile(r"^Kitchin,? J(\.|ohn)?\s*(R\.?)?$")
SCHOLAR_PROFILE = "https://scholar.google.com/citations?user=jD_4h7sAAAAJ"
ORCID = "https://orcid.org/0000-0003-2625-9232"


def esc(s):
    return html.escape(str(s or ""), quote=True)


def fmt_authors(authors, limit=12):
    names = [f"<b>{esc(a)}</b>" if ME.match(a.strip()) else esc(a) for a in authors]
    if len(names) > limit:
        mine = [n for n in names[limit:] if n.startswith("<b>")]
        names = names[:limit] + ["…"] + mine
    return ", ".join(names)


def scholar_url(title):
    return "https://scholar.google.com/scholar?" + urllib.parse.urlencode({"q": f'"{title}"'})


def publications():
    pubs = yaml.safe_load((ROOT / "data/publications.yml").read_text())
    idx = ROOT / "data" / "papers-index.json"  # written by export_crucible.py
    summaries = json.loads(idx.read_text()) if idx.exists() else {}
    pubs.sort(key=lambda p: str(p.get("date", "")), reverse=True)
    by_year = defaultdict(list)
    for p in pubs:
        by_year[str(p.get("date", ""))[:4] or "Undated"].append(p)
    years = sorted(by_year, reverse=True)

    out = ["```{=html}",
           '<div class="pub-header">',
           f'<p class="pub-count">{len(pubs)} journal articles</p>',
           '<div class="badges">'
           f'<a class="badge-link" href="{SCHOLAR_PROFILE}"><i class="bi bi-mortarboard"></i> Google Scholar</a>'
           f'<a class="badge-link" href="{ORCID}"><i class="bi bi-person-badge"></i> ORCID</a>'
           '<a class="badge-link" href="papers/"><i class="bi bi-card-text"></i> Paper summaries</a>'
           '</div></div>',
           '<input type="search" id="pub-filter" class="form-control pub-filter" '
           'placeholder="Filter by title, author, journal or year" aria-label="Filter publications">',
           '<nav class="year-nav">' + " ".join(f'<a href="#y{y}">{y}</a>' for y in years) + "</nav>"]
    for y in years:
        out.append(f'<section class="pub-year-group" data-year="{y}">')
        out.append(f'<h2 class="pub-year" id="y{y}">{y}</h2>')
        for p in by_year[y]:
            ref = f"<em>{esc(p.get('journal'))}</em>"
            if p.get("volume"):
                ref += f", {esc(p['volume'])}"
            if p.get("pages"):
                ref += f", {esc(p['pages'])}"
            doi = p.get("doi", "")
            au = fmt_authors(p.get("authors", []))
            sep = " " if re.search(r"[.…](</b>)?$", au) else ". "
            links = []
            if doi:
                links.append(f'<a href="https://doi.org/{esc(doi)}"><i class="bi bi-journal-text"></i> Journal</a>')
            links.append(f'<a href="{esc(scholar_url(p.get("title", "")))}"><i class="bi bi-mortarboard"></i> Scholar</a>')
            if doi.lower() in summaries:
                links.append(f'<a class="summary-link" href="{esc(summaries[doi.lower()])}">'
                             '<i class="bi bi-card-text"></i> Summary</a>')
            badge = (f'<div class="altmetric-lazy" data-badge-type="donut" data-badge-popover="left" '
                     f'data-hide-no-mentions="true" data-doi="{esc(doi)}"></div>') if doi else ""
            out.append(
                f'<article class="pub">'
                f'<div class="pub-body"><span class="ti">{esc(p.get("title"))}</span>'
                f'<span class="au">{au}</span>{sep.strip()} '
                f'<span class="ref">{ref}{" (" + y + ")" if y != "Undated" else ""}.</span>'
                f'<span class="links">{" ".join(links)}</span></div>'
                f'<div class="pub-badge">{badge}</div></article>')
        out.append("</section>")
    out.append('<p class="pub-none" hidden>No publications match.</p>')
    out.append("```")
    return "\n".join(out) + "\n"


def mono(name):
    """Lettered tile for packages without a logo."""
    return f'<div class="pkg-icon pkg-mono" aria-hidden="true">{esc(name[:1].upper())}</div>'


def relative(iso):
    if not iso:
        return ""
    days = (datetime.now(timezone.utc) - datetime.fromisoformat(iso.replace("Z", "+00:00"))).days
    if days < 1:
        return "today"
    if days < 60:
        return f"{days} day{'s' if days != 1 else ''} ago"
    if days < 730:
        return f"{days // 30} months ago"
    return f"{days // 365} years ago"


def card(p, s):
    """One package card. s is the package's entry in software-stats.json."""
    gh = f"https://github.com/{p['repo']}"
    status = p.get("status")
    badge = f'<span class="status">{esc(status)}</span>' if status else ""
    icon = (f'<img class="pkg-icon" src="{esc(p["icon"])}" alt="" loading="lazy">'
            if p.get("icon") else mono(p["name"]))
    versions = []
    if p.get("pypi"):
        versions.append(f'<a class="ver" href="https://pypi.org/project/{esc(p["pypi"])}/" '
                        f'title="PyPI: {esc(p["pypi"])}"><span>PyPI</span>'
                        f'<b data-k="pypi">{esc(s.get("pypi", "?"))}</b></a>')
    if p.get("crate"):
        versions.append(f'<a class="ver" href="https://crates.io/crates/{esc(p["crate"])}" '
                        f'title="crates.io: {esc(p["crate"])}"><span>crates.io</span>'
                        f'<b data-k="crate">{esc(s.get("crate", "?"))}</b></a>')
    if not versions and s.get("release"):
        versions.append(f'<a class="ver" href="{gh}/releases/latest"><span>release</span>'
                        f'<b data-k="release">{esc(s["release"])}</b></a>')
    links = [f'<a href="{gh}"><i class="bi bi-github"></i> GitHub</a>']
    if p.get("docs"):
        links.append(f'<a href="{esc(p["docs"])}"><i class="bi bi-book"></i> Docs</a>')
    attrs = f'data-repo="{esc(p["repo"])}"'
    if p.get("pypi"):
        attrs += f' data-pypi="{esc(p["pypi"])}"'
    if p.get("crate"):
        attrs += f' data-crate="{esc(p["crate"])}"'
    cls = "pkg" + (" pkg-deprecated" if status == "deprecated" else "") + (" pkg-featured" if p.get("featured") else "")
    return (
        f'<article class="{cls}" {attrs}>'
        f'<div class="pkg-head">{icon}<div><h3>{esc(p["name"])}{badge}</h3>'
        f'<div class="pkg-vers">{"".join(versions)}</div></div></div>'
        f'<p>{esc(p["description"])}</p>'
        f'<div class="pkg-stats">'
        f'<span title="GitHub stars"><i class="bi bi-star-fill"></i> <b data-k="stars">{s.get("stars", "")}</b></span>'
        f'<span title="Forks"><i class="bi bi-diagram-2"></i> <b data-k="forks">{s.get("forks", "")}</b></span>'
        f'<span title="Last commit"><i class="bi bi-clock-history"></i> '
        f'<b data-k="pushed" data-iso="{esc(s.get("pushed", ""))}">{relative(s.get("pushed"))}</b></span>'
        f'</div>'
        f'<div class="pkg-links">{" ".join(links)}</div></article>')


def software():
    groups = yaml.safe_load((ROOT / "data/software.yml").read_text())
    path = ROOT / "data" / "software-stats.json"
    stats = json.loads(path.read_text()) if path.exists() else {}

    # Featured packages go first, in one large card each, without a heading.
    # Deprecated packages are pulled out of their groups into a final section.
    featured = [p for g in groups for p in g["packages"] if p.get("featured")]
    deprecated = [p for g in groups for p in g["packages"] if p.get("status") == "deprecated"]
    sections = []
    for g in groups:
        pkgs = [p for p in g["packages"] if not p.get("featured") and p.get("status") != "deprecated"]
        if pkgs:
            sections.append({**g, "packages": pkgs})
    if deprecated:
        sections.append({"group": "Deprecated", "intro": "Superseded packages, kept here for reference.",
                         "packages": deprecated})

    current = featured + [p for g in sections if g["group"] != "Deprecated" for p in g["packages"]]
    total = sum(stats.get(p["repo"], {}).get("stars", 0) for p in current)
    out = ["```{=html}",
           f'<p class="sw-summary"><i class="bi bi-star-fill"></i> <b id="sw-total">{total:,}</b> '
           'GitHub stars across these packages. Numbers update live from GitHub, PyPI and crates.io.</p>']
    if featured:
        out.append('<div class="pkg-featured-row">')
        out += [card(p, stats.get(p["repo"], {})) for p in featured]
        out.append("</div>")
    out.append("```\n")
    for g in sections:
        out.append(f"## {g['group']}\n")
        if g.get("intro"):
            out.append(f"{g['intro']}\n")
        out.append("```{=html}")
        out.append('<div class="pkg-grid">')
        out += [card(p, stats.get(p["repo"], {})) for p in g["packages"]]
        out.append("</div>")
        out.append("```\n")
    return "\n".join(out)


def write_if_changed(path, text):
    # Avoid touching unchanged files so `quarto preview` does not loop.
    if not path.exists() or path.read_text() != text:
        path.write_text(text)


if __name__ == "__main__":
    OUT.mkdir(exist_ok=True)
    write_if_changed(OUT / "publications.md", publications())
    write_if_changed(OUT / "software.md", software())
