"""Fetch each publication's OpenAlex primary topic into data/publication-fields.json.

The home page timeline colors papers by research area, grouped from the
OpenAlex field of each paper's primary topic (see AREAS in prerender.py).
Run after update_publications.py adds papers:

    python3 scripts/update_publication_fields.py

Set OPENALEX_API_KEY for higher rate limits.
"""

import json
import os
import urllib.parse
import urllib.request
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "data" / "publication-fields.json"
MAILTO = "jkitchin@andrew.cmu.edu"


def main():
    pubs = yaml.safe_load((ROOT / "data" / "publications.yml").read_text())
    dois = [p["doi"].lower() for p in pubs if p.get("doi")]
    out = json.loads(OUT.read_text()) if OUT.exists() else {}
    for i in range(0, len(dois), 50):  # OpenAlex allows 50 DOIs per filter
        q = {"filter": "doi:" + "|".join(dois[i:i + 50]), "per-page": 50,
             "select": "doi,primary_topic", "mailto": MAILTO}
        if os.environ.get("OPENALEX_API_KEY"):
            q["api_key"] = os.environ["OPENALEX_API_KEY"]
        with urllib.request.urlopen("https://api.openalex.org/works?" + urllib.parse.urlencode(q), timeout=60) as r:
            for w in json.load(r)["results"]:
                t = w.get("primary_topic") or {}
                out[w["doi"].replace("https://doi.org/", "").lower()] = {
                    "field": (t.get("field") or {}).get("display_name"),
                    "subfield": (t.get("subfield") or {}).get("display_name"),
                    "topic": t.get("display_name"),
                }
    OUT.write_text(json.dumps(out, indent=1, sort_keys=True, ensure_ascii=False) + "\n")
    print(f"{len(out)} of {len(dois)} publications have a field -> {OUT}")


if __name__ == "__main__":
    main()
