"""Fetch current numbers for the software page into data/software-stats.json.

For each package in data/software.yml: GitHub stars, forks, open issues, last
push and latest release, plus the current PyPI and crates.io versions. The JSON
is baked into software.html by prerender.py so the page shows numbers without
JavaScript; assets/software.js then refreshes them in the browser.

    python3 scripts/update_software_stats.py

Set GITHUB_TOKEN (or GH_TOKEN) to avoid GitHub's 60 requests/hour anonymous
limit. A package whose lookup fails keeps its previous numbers.
"""

import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "data" / "software-stats.json"
UA = "kitchingroup-site (https://kitchingroup.cheme.cmu.edu)"


def get(url, token=None):
    headers = {"User-Agent": UA, "Accept": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=headers), timeout=30) as r:
            return json.load(r)
    except urllib.error.HTTPError as e:
        if e.code != 404:
            print(f"  {url}: HTTP {e.code}", file=sys.stderr)
        return None


def github(repo, token):
    r = get(f"https://api.github.com/repos/{repo}", token)
    if not r:
        return None
    out = {
        "stars": r["stargazers_count"],
        "forks": r["forks_count"],
        "issues": r["open_issues_count"],
        "pushed": r["pushed_at"],
        "license": (r.get("license") or {}).get("spdx_id"),
    }
    rel = get(f"https://api.github.com/repos/{repo}/releases/latest", token)
    if rel:
        out["release"] = rel["tag_name"]
    return out


def main():
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    groups = yaml.safe_load((ROOT / "data" / "software.yml").read_text())
    stats = json.loads(OUT.read_text()) if OUT.exists() else {}
    for g in groups:
        for p in g["packages"]:
            s = stats.get(p["repo"], {})
            gh = github(p["repo"], token)
            if gh:
                s.update(gh)
            if p.get("pypi"):
                r = get(f"https://pypi.org/pypi/{p['pypi']}/json")
                if r:
                    s["pypi"] = r["info"]["version"]
            if p.get("crate"):
                r = get(f"https://crates.io/api/v1/crates/{p['crate']}")
                if r:
                    s["crate"] = r["crate"]["max_stable_version"] or r["crate"]["max_version"]
            stats[p["repo"]] = s
            print(f"{p['name']:14} {s.get('stars', '?'):>5} stars  "
                  f"release {s.get('release', '-'):10} pypi {s.get('pypi', '-'):8} crate {s.get('crate', '-')}")
    OUT.write_text(json.dumps(stats, indent=1, sort_keys=True) + "\n")


if __name__ == "__main__":
    main()
