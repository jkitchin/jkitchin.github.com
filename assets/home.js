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

  function show(dot) {
    tip.textContent = "";
    var t = document.createElement("strong");
    t.textContent = dot.dataset.title;
    var m = document.createElement("span");
    m.textContent = dot.dataset.meta;
    tip.appendChild(t);
    tip.appendChild(m);
    tip.hidden = false;
    var r = dot.getBoundingClientRect();
    var tw = tip.offsetWidth;
    var left = Math.min(Math.max(8, r.left + r.width / 2 - tw / 2), window.innerWidth - tw - 8);
    tip.style.left = left + window.scrollX + "px";
    tip.style.top = r.top + window.scrollY - tip.offsetHeight - 10 + "px";
  }

  function hide() { tip.hidden = true; }

  chart.addEventListener("mouseover", function (e) {
    if (e.target.classList.contains("tl-dot")) show(e.target);
  });
  chart.addEventListener("mouseleave", hide);
  chart.addEventListener("focusin", function (e) {
    if (e.target.classList.contains("tl-dot")) show(e.target);
  });
  chart.addEventListener("focusout", hide);
})();
