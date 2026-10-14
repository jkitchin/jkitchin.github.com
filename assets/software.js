// Refresh the software cards with live numbers from GitHub, PyPI and crates.io.
// The page already shows the values from data/software-stats.json, so if a
// request fails (offline, GitHub's 60/hour anonymous limit) nothing changes.
// Results are cached in localStorage for an hour per visitor.
(function () {
  const TTL = 60 * 60 * 1000;

  function cached(key) {
    try {
      const v = JSON.parse(localStorage.getItem(key));
      if (v && Date.now() - v.t < TTL) return v.d;
    } catch (e) {}
    return null;
  }

  function store(key, d) {
    try { localStorage.setItem(key, JSON.stringify({ t: Date.now(), d: d })); } catch (e) {}
  }

  async function getJSON(url) {
    const key = "kg:" + url;
    const hit = cached(key);
    if (hit) return hit;
    const r = await fetch(url, { headers: { Accept: "application/json" } });
    if (!r.ok) throw new Error(url + ": " + r.status);
    const d = await r.json();
    store(key, d);
    return d;
  }

  function ago(iso) {
    const days = Math.floor((Date.now() - Date.parse(iso)) / 86400000);
    if (days < 1) return "today";
    if (days < 60) return days + (days === 1 ? " day ago" : " days ago");
    if (days < 730) return Math.floor(days / 30) + " months ago";
    return Math.floor(days / 365) + " years ago";
  }

  function set(card, k, v) {
    const el = card.querySelector('[data-k="' + k + '"]');
    if (el && v !== undefined && v !== null && v !== "") {
      el.textContent = v;
      el.classList.add("live");
    }
  }

  function updateTotal() {
    let total = 0;
    document.querySelectorAll('.pkg:not(.pkg-deprecated) [data-k="stars"]').forEach(function (el) {
      total += parseInt(el.textContent.replace(/,/g, ""), 10) || 0;
    });
    const t = document.getElementById("sw-total");
    if (t) t.textContent = total.toLocaleString();
  }

  document.querySelectorAll(".pkg[data-repo]").forEach(function (card) {
    const repo = card.dataset.repo;
    getJSON("https://api.github.com/repos/" + repo).then(function (r) {
      set(card, "stars", r.stargazers_count);
      set(card, "forks", r.forks_count);
      set(card, "pushed", ago(r.pushed_at));
      updateTotal();
    }).catch(function () {});
    if (card.querySelector('[data-k="release"]')) {
      getJSON("https://api.github.com/repos/" + repo + "/releases/latest")
        .then(function (r) { set(card, "release", r.tag_name); }).catch(function () {});
    }
    if (card.dataset.pypi) {
      getJSON("https://pypi.org/pypi/" + card.dataset.pypi + "/json")
        .then(function (r) { set(card, "pypi", r.info.version); }).catch(function () {});
    }
    if (card.dataset.crate) {
      getJSON("https://crates.io/api/v1/crates/" + card.dataset.crate)
        .then(function (r) { set(card, "crate", r.crate.max_stable_version || r.crate.max_version); })
        .catch(function () {});
    }
  });
})();
