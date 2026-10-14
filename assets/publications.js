// Publications page: text filter and lazily loaded Altmetric badges.
(function () {
  // ---- filter ----
  const input = document.getElementById("pub-filter");
  const none = document.querySelector(".pub-none");
  if (input) {
    input.addEventListener("input", function () {
      const words = input.value.toLowerCase().split(/\s+/).filter(Boolean);
      let shown = 0;
      document.querySelectorAll(".pub-year-group").forEach(function (group) {
        let n = 0;
        group.querySelectorAll(".pub").forEach(function (pub) {
          const text = (pub.textContent + " " + group.dataset.year).toLowerCase();
          const ok = words.every(function (w) { return text.includes(w); });
          pub.hidden = !ok;
          if (ok) n++;
        });
        group.hidden = n === 0;
        shown += n;
      });
      if (none) none.hidden = shown > 0;
    });
  }

  // ---- Altmetric badges ----
  // Badges are created only as they scroll into view, so the page does not
  // make 140 requests to Altmetric on load.
  const pending = [];
  let loading = false;

  // embed.js loads a second script that defines _altmetric_embed_init, so the
  // function can be missing for a moment after embed.js itself has loaded.
  let waits = 0;

  function flush() {
    if (!window._altmetric_embed_init) {
      if (loading && waits++ < 50) setTimeout(flush, 200);
      return;
    }
    while (pending.length) {
      const el = pending.shift();
      el.classList.remove("altmetric-lazy");
      el.classList.add("altmetric-embed");
    }
    window._altmetric_embed_init();
  }

  function loadScript() {
    if (loading) return;
    loading = true;
    const s = document.createElement("script");
    s.src = "https://d1bxh8uas1mnw7.cloudfront.net/assets/embed.js";
    s.async = true;
    s.onload = flush;
    document.head.appendChild(s);
  }

  const badges = document.querySelectorAll(".altmetric-lazy");
  if (!("IntersectionObserver" in window)) {
    badges.forEach(function (el) { pending.push(el); });
    loadScript();
    return;
  }
  const io = new IntersectionObserver(function (entries) {
    entries.forEach(function (e) {
      if (!e.isIntersecting) return;
      io.unobserve(e.target);
      pending.push(e.target);
    });
    if (pending.length) {
      loadScript();
      flush();
    }
  }, { rootMargin: "400px 0px" });
  badges.forEach(function (el) { io.observe(el); });
})();
