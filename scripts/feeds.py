"""Bridge new posts into the old blogofile feed URLs.

Subscribers and aggregators (Planet Emacslife, feed readers) follow
/blog/feed/, /blog/feed/atom/ and /blog/category/<name>/feed[/atom]/. This
module rewrites those files so they contain the newest posts across the
frozen archive and the new /posts/ section.

Old items are kept exactly as blogofile wrote them (same guid/id), so readers
do not see them again as new. New items come from Quarto's own feed at
_site/posts/index.xml. A category feed is only rewritten when a new post uses
that category and the old site already had a feed for it.
"""

import copy
import re
from datetime import datetime, timezone
from email.utils import format_datetime, parsedate_to_datetime
from pathlib import Path
from urllib.parse import urljoin

from lxml import etree as ET

MAX_ITEMS = 10  # blogofile's feeds held 10 items

NS = {
    "content": "http://purl.org/rss/1.0/modules/content/",
    "sy": "http://purl.org/rss/1.0/modules/syndication/",
    "atom": "http://www.w3.org/2005/Atom",
    "dc": "http://purl.org/dc/elements/1.1/",
    "wfw": "http://wellformedweb.org/CommentAPI/",
    "thr": "http://purl.org/syndication/thread/1.0",
    "media": "http://search.yahoo.com/mrss/",
}
A = "{%s}" % NS["atom"]
XML_BASE = "{http://www.w3.org/XML/1998/namespace}base"
# Keep CDATA sections and whitespace from the frozen feeds as they are.
PARSER = ET.XMLParser(strip_cdata=False)


def parse(path):
    return ET.parse(str(path), PARSER)


def html_text(html):
    """Raw HTML as a CDATA section, like blogofile wrote it."""
    return ET.CDATA(html) if "]]>" not in html else html


def write(tree, path):
    path.parent.mkdir(parents=True, exist_ok=True)
    ET.cleanup_namespaces(tree)  # drop declarations repeated on new items
    tree.write(str(path), encoding="UTF-8", xml_declaration=True)


def slugify(name):
    """Category slug as blogofile built it: punctuation and spaces become '-'."""
    words = re.split(r'[\t !"#$%&\'()*\-/<=>?@\[\\\]^_`{|},.]+', name.strip())
    return "-".join(w for w in words if w).lower()


def absolutize(html, base):
    """Make relative href/src URLs absolute so content works at any feed path."""
    def fix(m):
        attr, quote, url = m.group(1), m.group(2), m.group(3)
        if re.match(r"^([a-z][a-z0-9+.-]*:|#|//)", url, re.I):
            return m.group(0)
        return f"{attr}={quote}{urljoin(base, url)}{quote}"
    return re.sub(r'\b(href|src)=(["\'])(.*?)\2', fix, html)


def new_posts(site):
    """Read new posts from Quarto's RSS feed for /posts/."""
    path = site / "posts" / "index.xml"
    if not path.exists():
        return []
    posts = []
    for item in parse(path).getroot().iter("item"):
        link = item.findtext("link").strip()
        posts.append({
            "title": item.findtext("title", "").strip(),
            "link": link,
            "date": parsedate_to_datetime(item.findtext("pubDate")),
            "categories": [c.text.strip() for c in item.findall("category") if c.text],
            "content": absolutize(item.findtext("description", ""), link),
        })
    return posts


# ---------- RSS 2.0 ----------

def rss_item(post):
    item = ET.Element("item", nsmap={"content": NS["content"]})
    ET.SubElement(item, "title").text = post["title"]
    ET.SubElement(item, "link").text = post["link"]
    ET.SubElement(item, "pubDate").text = format_datetime(post["date"])
    for c in post["categories"]:
        ET.SubElement(item, "category").text = c
    ET.SubElement(item, "guid", isPermaLink="true").text = post["link"]
    ET.SubElement(item, "description").text = post["title"]
    ET.SubElement(item, "{%s}encoded" % NS["content"]).text = html_text(post["content"])
    return item


def rewrite_rss(legacy_file, out_file, posts):
    tree = parse(legacy_file)
    channel = tree.getroot().find("channel")
    old = channel.findall("item")
    for it in old:
        channel.remove(it)
    dated = [(parsedate_to_datetime(it.findtext("pubDate")), it) for it in old]
    dated += [(p["date"], rss_item(p)) for p in posts]
    dated.sort(key=lambda d: d[0], reverse=True)
    for _, it in dated[:MAX_ITEMS]:
        channel.append(copy.deepcopy(it))
    pub = channel.find("pubDate")
    if pub is not None:
        pub.text = format_datetime(datetime.now(timezone.utc), usegmt=True)
    gen = channel.find("generator")
    if gen is not None:
        gen.text = "Quarto + legacy Blogofile feed bridge"
    write(tree, out_file)


# ---------- Atom ----------

def iso(dt):
    return dt.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def atom_entry(post):
    e = ET.Element(A + "entry", nsmap={None: NS["atom"]})
    author = ET.SubElement(e, A + "author")
    ET.SubElement(author, A + "name").text = "John Kitchin"
    ET.SubElement(e, A + "title", type="html").text = post["title"]
    ET.SubElement(e, A + "link", rel="alternate", type="text/html", href=post["link"])
    ET.SubElement(e, A + "id").text = post["link"]
    ET.SubElement(e, A + "updated").text = iso(post["date"])
    ET.SubElement(e, A + "published").text = iso(post["date"])
    for c in post["categories"]:
        ET.SubElement(e, A + "category", term=c)
    ET.SubElement(e, A + "summary", type="html").text = post["title"]
    content = ET.SubElement(e, A + "content", type="html")
    content.set(XML_BASE, post["link"])
    content.text = html_text(post["content"])
    return e


def atom_date(entry):
    s = entry.findtext(A + "published") or entry.findtext(A + "updated")
    return datetime.fromisoformat(s.replace("Z", "+00:00"))


def rewrite_atom(legacy_file, out_file, posts):
    tree = parse(legacy_file)
    feed = tree.getroot()
    old = feed.findall(A + "entry")
    for e in old:
        feed.remove(e)
    dated = [(atom_date(e), e) for e in old] + [(p["date"], atom_entry(p)) for p in posts]
    dated.sort(key=lambda d: d[0], reverse=True)
    for _, e in dated[:MAX_ITEMS]:
        feed.append(copy.deepcopy(e))
    upd = feed.find(A + "updated")
    if upd is not None:
        upd.text = iso(datetime.now(timezone.utc))
    write(tree, out_file)


# ---------- entry point ----------

def bridge(legacy, site):
    """Rewrite the legacy feed files in site/ to include new posts. Returns paths written."""
    posts = new_posts(site)
    if not posts:
        return []
    written = []

    def both(feed_dir, selected):
        rss, atom = feed_dir / "index.xml", feed_dir / "atom" / "index.xml"
        rel = feed_dir.relative_to(legacy)
        if rss.exists():
            rewrite_rss(rss, site / rel / "index.xml", selected)
            written.append(rel / "index.xml")
        if atom.exists():
            rewrite_atom(atom, site / rel / "atom" / "index.xml", selected)
            written.append(rel / "atom" / "index.xml")

    both(legacy / "blog" / "feed", posts)

    by_cat = {}
    for p in posts:
        for c in p["categories"]:
            by_cat.setdefault(slugify(c), []).append(p)
    for slug, selected in sorted(by_cat.items()):
        feed_dir = legacy / "blog" / "category" / slug / "feed"
        if feed_dir.exists():
            both(feed_dir, selected)
    return written
