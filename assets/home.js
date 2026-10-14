// Home page: the header Ask box and the publication timeline tooltip.
(function () {
  // ---- header Ask box: hand the question to the Ask widget ----
  var form = document.querySelector(".hero-ask");
  if (form) {
    form.addEventListener("submit", function (e) {
      var q = form.querySelector("input").value.trim();
      if (!window.KGAsk) return; // widget not loaded: fall through to ask.html?q=
      e.preventDefault();
      window.KGAsk.open(q);
    });
  }

  // ---- timeline tooltip ----
  var tip = document.querySelector(".tl-tip");
  var chart = document.querySelector(".tl");
  if (!tip || !chart) return;

  function place(el) {
    tip.hidden = false;
    var r = el.getBoundingClientRect();
    var tw = tip.offsetWidth;
    var left = Math.min(Math.max(8, r.left + r.width / 2 - tw / 2), window.innerWidth - tw - 8);
    tip.style.left = left + window.scrollX + "px";
    tip.style.top = r.top + window.scrollY - tip.offsetHeight - 10 + "px";
  }

  function fill(title, meta) {
    tip.textContent = "";
    var t = document.createElement("strong");
    t.textContent = title;
    tip.appendChild(t);
    if (meta) {
      var m = document.createElement("span");
      m.textContent = meta;
      tip.appendChild(m);
    }
  }

  function hide() { tip.hidden = true; }

  // pointer: one paper per dot
  chart.addEventListener("mouseover", function (e) {
    if (e.target.classList.contains("tl-dot")) {
      fill(e.target.dataset.title, e.target.dataset.meta);
      place(e.target);
    }
  });
  chart.addEventListener("mouseleave", hide);
  // keyboard: one year per column
  chart.addEventListener("focusin", function (e) {
    var col = e.target.closest(".tl-col");
    if (col && col.dataset.summary) {
      fill(col.dataset.summary, "Press Enter to see them");
      place(col);
    }
  });
  chart.addEventListener("focusout", hide);
  document.addEventListener("keydown", function (e) { if (e.key === "Escape") hide(); });
})();
