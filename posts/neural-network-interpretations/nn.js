// Interactive figures for "Interpretations of what a neural network is".
// Each <div class="nn-fig" data-nnfig="name"> is filled in by FIGS[name].
// Numbers computed in Python arrive as <script type="application/json"> blocks.
(() => {
  const NS = "http://www.w3.org/2000/svg";
  const SUB = "₀₁₂₃₄₅₆₇₈₉";
  const sub = (n) => String(n).replace(/\d/g, (d) => SUB[d]);
  const fmt = (v, d = 3) => (v < 0 ? "−" : "") + Math.abs(v).toFixed(d);
  const S = (k) => `var(--nn-s${k})`;

  function el(tag, attrs = {}, parent) {
    const e = document.createElementNS(NS, tag);
    for (const [k, v] of Object.entries(attrs)) {
      if (k === "text") e.textContent = v;
      else if (k === "style") Object.assign(e.style, v);
      else e.setAttribute(k, v);
    }
    if (parent) parent.appendChild(e);
    return e;
  }

  function html(tag, attrs = {}, parent) {
    const e = document.createElement(tag);
    for (const [k, v] of Object.entries(attrs)) {
      if (k === "text") e.textContent = v;
      else if (k === "html") e.innerHTML = v;
      else e.setAttribute(k, v);
    }
    if (parent) parent.appendChild(e);
    return e;
  }

  function svg(parent, W, H, label) {
    return el("svg", { viewBox: `0 0 ${W} ${H}`, role: "img", "aria-label": label }, parent);
  }

  const scale = (d0, d1, r0, r1) => {
    const f = (v) => r0 + ((v - d0) * (r1 - r0)) / (d1 - d0);
    f.inv = (p) => d0 + ((p - r0) * (d1 - d0)) / (r1 - r0);
    return f;
  };

  const path = (xs, ys, sx, sy) =>
    xs.map((x, i) => `${i ? "L" : "M"}${sx(x).toFixed(1)},${sy(ys[i]).toFixed(1)}`).join("");

  // A plot area with horizontal grid lines, tick labels and axis titles.
  function frame(s, W, H, m, xd, yd, xt, yt, xlab, ylab) {
    const sx = scale(xd[0], xd[1], m.l, W - m.r);
    const sy = scale(yd[0], yd[1], H - m.b, m.t);
    const g = el("g", {}, s);
    for (const t of yt) {
      el("line", { class: "nn-grid", x1: m.l, x2: W - m.r, y1: sy(t), y2: sy(t) }, g);
      el("text", { class: "nn-tick", x: m.l - 6, y: sy(t) + 4, "text-anchor": "end",
        text: String(+t.toFixed(2)).replace("-", "−") }, g);
    }
    el("line", { class: "nn-axis", x1: m.l, x2: W - m.r, y1: H - m.b, y2: H - m.b }, g);
    for (const t of xt) {
      el("text", { class: "nn-tick", x: sx(t), y: H - m.b + 16, "text-anchor": "middle",
        text: fmt(t, 0) }, g);
    }
    if (xlab) el("text", { x: (m.l + W - m.r) / 2, y: H - 4, "text-anchor": "middle",
      "font-style": "italic", text: xlab }, g);
    if (ylab) el("text", { x: 12, y: (m.t + H - m.b) / 2, "text-anchor": "middle",
      transform: `rotate(-90 12 ${(m.t + H - m.b) / 2})`, text: ylab }, g);
    return { sx, sy, g };
  }

  const ticks = (lo, hi, step) => {
    const out = [];
    for (let t = Math.ceil(lo / step) * step; t <= hi + 1e-9; t += step) out.push(+t.toFixed(6));
    return out;
  };

  const extent = (arrs, pad = 0.08) => {
    let lo = Infinity, hi = -Infinity;
    for (const a of arrs) for (const v of a) { lo = Math.min(lo, v); hi = Math.max(hi, v); }
    const p = (hi - lo || 1) * pad;
    return [lo - p, hi + p];
  };

  const niceStep = (span) => {
    const raw = span / 5, mag = 10 ** Math.floor(Math.log10(raw));
    return [1, 2, 2.5, 5, 10].map((k) => k * mag).find((s) => s >= raw);
  };

  function svgPoint(s, evt) {
    const p = s.createSVGPoint();
    p.x = evt.clientX; p.y = evt.clientY;
    return p.matrixTransform(s.getScreenCTM().inverse());
  }

  // One shared tooltip.
  let tip;
  function showTip(evt, content) {
    if (!tip) tip = html("div", { class: "nn-tip", role: "status" }, document.body);
    tip.innerHTML = content;
    tip.style.opacity = 1;
    const r = tip.getBoundingClientRect();
    let x = evt.clientX + 14, y = evt.clientY + 14;
    if (x + r.width > innerWidth - 8) x = evt.clientX - r.width - 14;
    if (y + r.height > innerHeight - 8) y = evt.clientY - r.height - 14;
    tip.style.left = `${Math.max(8, x)}px`;
    tip.style.top = `${Math.max(8, y)}px`;
  }
  const hideTip = () => tip && (tip.style.opacity = 0);

  const data = (id) => JSON.parse(document.getElementById(id).textContent);

  function slider(parent, label, min, max, value, onInput, describe) {
    const c = html("div", { class: "nn-controls" }, parent);
    const id = `nn-${Math.random().toString(36).slice(2)}`;
    html("label", { for: id, text: label }, c);
    const r = html("input", { type: "range", id, min, max, step: 1, value }, c);
    const o = html("output", { for: id }, c);
    const update = () => { o.textContent = describe(+r.value); onInput(+r.value); };
    r.addEventListener("input", update);
    return { controls: c, update };
  }

  function legendItem(g, x, y, color, text, dash, width = 2.5) {
    el("line", { x1: x, x2: x + 22, y1: y, y2: y, stroke: color, "stroke-width": width,
      "stroke-dasharray": dash || "none", "stroke-linecap": "round" }, g);
    el("text", { x: x + 28, y: y + 4, text }, g);
  }

  // Fourier partial sums with a slider over N and a chart of the coefficients.
  function fourierSeries(root) {
    const D = data("fourier-data");
    const NMAX = D.a.length - 1;
    const W = 640, H = 270, m = { l: 44, r: 16, t: 14, b: 38 };
    let N = 3;

    const sum = (n) => D.x.map((x) => {
      let y = D.a[0] / 2;
      for (let k = 1; k <= n; k++) y += D.a[k] * Math.cos(k * x) + D.b[k] * Math.sin(k * x);
      return y;
    });

    const ctl = slider(root, "Number of harmonics", 0, NMAX, N, (n) => { N = n; draw(); },
      (n) => `N = ${n} (${2 * n + 1} basis functions)`);

    const s1 = svg(root, W, H, "f(x) and its Fourier partial sum");
    const F = frame(s1, W, H, m, [-Math.PI, Math.PI], [-0.15, 1.1], ticks(-3, 3, 1),
      [0, 0.25, 0.5, 0.75, 1], "x", "");
    el("path", { d: path(D.x, D.f, F.sx, F.sy), fill: "none", stroke: "var(--nn-faint)",
      "stroke-width": 6, "stroke-linecap": "round" }, s1);
    const sp = el("path", { fill: "none", stroke: S(1), "stroke-width": 2 }, s1);
    const lg = el("g", {}, s1);
    legendItem(lg, W - 190, 26, "var(--nn-faint)", "f(x)", null, 6);
    legendItem(lg, W - 190, 46, S(1), "partial sum");
    const cross = el("line", { y1: m.t, y2: H - m.b, stroke: "var(--nn-faint)",
      visibility: "hidden" }, s1);
    const dotF = el("circle", { r: 4.5, fill: "var(--nn-muted)", visibility: "hidden" }, s1);
    const dotS = el("circle", { r: 4.5, fill: S(1), stroke: "var(--nn-bg)", "stroke-width": 2,
      visibility: "hidden" }, s1);
    let ys = [];
    const hit = el("rect", { x: m.l, y: m.t, width: W - m.l - m.r, height: H - m.t - m.b,
      fill: "transparent" }, s1);
    hit.addEventListener("pointermove", (e) => {
      const px = svgPoint(s1, e).x;
      const xv = F.sx.inv(px);
      let i = Math.round(((xv - D.x[0]) / (D.x.at(-1) - D.x[0])) * (D.x.length - 1));
      i = Math.max(0, Math.min(D.x.length - 1, i));
      const cx = F.sx(D.x[i]);
      for (const n of [cross, dotF, dotS]) n.setAttribute("visibility", "visible");
      cross.setAttribute("x1", cx); cross.setAttribute("x2", cx);
      dotF.setAttribute("cx", cx); dotF.setAttribute("cy", F.sy(D.f[i]));
      dotS.setAttribute("cx", cx); dotS.setAttribute("cy", F.sy(ys[i]));
      showTip(e, `x = ${fmt(D.x[i], 2)}<br>f(x) = ${fmt(D.f[i])}<br>` +
        `partial sum (N = ${N}) = ${fmt(ys[i])}`);
    });
    hit.addEventListener("pointerleave", () => {
      for (const n of [cross, dotF, dotS]) n.setAttribute("visibility", "hidden");
      hideTip();
    });

    // coefficient chart
    const H2 = 210, m2 = { l: 44, r: 16, t: 28, b: 38 };
    const coefs = [];
    for (let n = 0; n <= NMAX; n++) {
      coefs.push({ n, kind: "a", v: n ? D.a[n] : D.a[0] / 2 });
      if (n) coefs.push({ n, kind: "b", v: D.b[n] });
    }
    const yd = extent([coefs.map((c) => c.v), [0]], 0.12);
    const s2 = svg(root, W, H2, "Fourier coefficients");
    const C = frame(s2, W, H2, m2, [-0.6, NMAX + 0.6], yd, ticks(0, NMAX, 1),
      ticks(yd[0], yd[1], niceStep(yd[1] - yd[0])), "n", "");
    el("line", { class: "nn-axis", x1: m2.l, x2: W - m2.r, y1: C.sy(0), y2: C.sy(0),
      stroke: "var(--nn-muted)" }, s2);
    const lg2 = el("g", {}, s2);
    legendItem(lg2, m2.l + 4, 12, S(1), "aₙ (cos nx)", null, 8);
    legendItem(lg2, m2.l + 140, 12, S(2), "bₙ (sin nx)", null, 8);
    const bw = 0.34 * (C.sx(1) - C.sx(0));
    const bars = coefs.map((c) => {
      const x = C.sx(c.n) + (c.kind === "a" ? (c.n ? -bw - 1 : -bw / 2) : 1);
      const y0 = C.sy(0), y1 = C.sy(c.v);
      const r = el("rect", { x, width: bw, y: Math.min(y0, y1), height: Math.abs(y1 - y0),
        rx: 2, fill: S(c.kind === "a" ? 1 : 2), class: "nn-hot" }, s2);
      const name = c.n ? `${c.kind}${sub(c.n)}` : "a₀/2";
      r.addEventListener("pointermove", (e) => showTip(e,
        `${name} = ${fmt(c.v, 4)}<br><span style="color:var(--nn-muted)">` +
        `one integral, independent of N</span>`));
      r.addEventListener("pointerleave", hideTip);
      return { r, c };
    });

    function draw() {
      ys = sum(N);
      sp.setAttribute("d", path(D.x, ys, F.sx, F.sy));
      for (const { r, c } of bars) r.style.opacity = c.n <= N ? 1 : 0.15;
    }
    ctl.update();
  }

  // The Fourier series drawn as a network; hover a hidden unit to see what it computes.
  function fourierNetwork(root) {
    const D = data("fourier-data");
    let N = 3, active = null;
    const ctl = slider(root, "Number of harmonics", 1, 4, N, (n) => { N = n; active = null; draw(); },
      (n) => `N = ${n}`);
    const row = html("div", { class: "nn-row" }, root);
    const W = 360, H = 440;
    const sd = svg(html("div", { style: "flex:1.6 1 300px" }, row), W, H,
      "Fourier series drawn as a neural network");
    sd.classList.add("nn-big");
    const pw = 280, ph = 230, pm = { l: 40, r: 10, t: 34, b: 34 };
    const pdiv = html("div", {}, row);
    const sp = svg(pdiv, pw, ph, "output of the selected unit");
    html("div", { class: "nn-hint", text: "Hover or tap a hidden unit to see the function it computes and its weighted contribution." }, pdiv);

    const units = (n) => {
      const u = [{ name: "1", w: 0, kind: "c", n: 0, c: D.a[0] / 2, cname: "a₀/2" }];
      for (let k = 1; k <= n; k++) {
        u.push({ name: `cos ${k > 1 ? k : ""}x`, w: k, kind: "a", n: k, c: D.a[k], cname: `a${sub(k)}` });
        u.push({ name: `sin ${k > 1 ? k : ""}x`, w: k, kind: "b", n: k, c: D.b[k], cname: `b${sub(k)}` });
      }
      return u;
    };
    const h = (u, x) => (u.kind === "c" ? 1 : u.kind === "a" ? Math.cos(u.n * x) : Math.sin(u.n * x));
    const color = (u) => (u.kind === "c" ? "var(--nn-muted)" : S(u.kind === "a" ? 1 : 2));

    function plot() {
      sp.replaceChildren();
      const U = units(N);
      let series, title;
      if (active === null) {
        const yS = D.x.map((x) => U.reduce((s, u) => s + u.c * h(u, x), 0));
        series = [[D.f, "var(--nn-faint)", 6, "f(x)"], [yS, S(1), 2, "Σ cₖ hₖ(x)"]];
        title = "output: weighted sum of all units";
      } else {
        const u = U[active];
        series = [[D.x.map((x) => h(u, x)), "var(--nn-faint)", 2, `h(x) = ${u.name}`],
          [D.x.map((x) => u.c * h(u, x)), color(u), 2.5, `${u.cname}·h(x)`]];
        title = `${u.name}:  ${u.cname} = ${fmt(u.c, 4)}`;
      }
      const yd = extent(series.map((s) => s[0]).concat([[0]]));
      const F = frame(sp, pw, ph, pm, [-Math.PI, Math.PI], yd, ticks(-3, 3, 1),
        ticks(yd[0], yd[1], niceStep(yd[1] - yd[0])), "x", "");
      for (const [ys, c, w] of series)
        el("path", { d: path(D.x, ys, F.sx, F.sy), fill: "none", stroke: c, "stroke-width": w,
          "stroke-linecap": "round" }, sp);
      el("text", { x: pm.l, y: 14, "font-weight": 600, text: title }, sp);
      series.forEach(([, c, w, name], i) => legendItem(sp, pm.l + i * 120, 28, c, name, null, Math.min(w, 4)));
    }

    function draw() {
      sd.replaceChildren();
      const U = units(N);
      const xin = 24, xh = 175, xout = 325, top = 60, bot = H - 40;
      const step = (bot - top) / (U.length - 1);
      const R = Math.min(22, step * 0.44);
      const yin = (top + bot) / 2;
      for (const [x, t] of [[xin, "input"], [xh, "hidden layer"], [xout, "output"]])
        el("text", { x, y: 20, "text-anchor": "middle", fill: "var(--nn-muted)", text: t,
          style: { fill: "var(--nn-muted)" } }, sd);
      el("text", { x: (xin + xh) / 2 - 20, y: H - 8, "text-anchor": "middle", class: "nn-tick",
        text: "fixed weights n" }, sd);
      el("text", { x: (xh + xout) / 2, y: H - 8, "text-anchor": "middle", class: "nn-tick",
        text: "coefficients (by projection)" }, sd);
      const maxc = Math.max(...U.map((u) => Math.abs(u.c)));
      const groups = U.map((u, i) => {
        const y = top + i * step;
        const g = el("g", { class: "nn-hot", tabindex: 0, role: "button",
          "aria-label": `${u.name}, weight ${u.w}, coefficient ${u.cname} = ${fmt(u.c)}` }, sd);
        const ang = Math.atan2(y - yin, xh - xin);
        if (u.w)
          el("line", { x1: xin + 20 * Math.cos(ang), y1: yin + 20 * Math.sin(ang),
            x2: xh - R * Math.cos(ang), y2: y - R * Math.sin(ang), stroke: "var(--nn-faint)",
            "stroke-width": 1.5, "stroke-dasharray": "4 3" }, g);
        const ang2 = Math.atan2(yin - y, xout - xh);
        el("line", { x1: xh + R * Math.cos(ang2), y1: y + R * Math.sin(ang2),
          x2: xout - 22 * Math.cos(ang2), y2: yin - 22 * Math.sin(ang2), stroke: color(u),
          "stroke-width": 1 + (5 * Math.abs(u.c)) / maxc, "stroke-linecap": "round" }, g);
        if (u.w) {
          const t = 0.8;
          el("text", { x: xin + t * (xh - R - xin), y: yin + t * (y - yin) - 4,
            "text-anchor": "middle", class: "nn-tick", text: String(u.w) }, g);
        }
        el("text", { x: xh + R + 22, y: y + (y < yin ? -6 : y > yin ? 14 : -6),
          "text-anchor": "middle", style: { fill: color(u) }, "font-style": "italic",
          text: u.cname }, g);
        el("circle", { cx: xh, cy: y, r: R, fill: "var(--nn-bg)", stroke: color(u),
          "stroke-width": 2.5 }, g);
        el("text", { x: xh, y: y + 4, "text-anchor": "middle",
          style: { fontSize: `${Math.min(12, R * 0.62)}px` }, text: u.name }, g);
        const on = () => { active = i; highlight(); plot(); };
        g.addEventListener("pointerenter", on);
        g.addEventListener("focus", on);
        g.addEventListener("click", on);
        return g;
      });
      for (const [x, t, r] of [[xin, "x", 20], [xout, "Σ", 22]]) {
        el("circle", { cx: x, cy: yin, r, fill: "var(--nn-bg)", stroke: "var(--nn-ink)",
          "stroke-width": 2.5 }, sd);
        el("text", { x, y: yin + 6, "text-anchor": "middle", "font-size": 17,
          "font-style": t === "x" ? "italic" : "normal", text: t, style: { fontSize: "17px" } }, sd);
      }
      el("text", { x: xout, y: yin + 44, "text-anchor": "middle", "font-style": "italic",
        text: "f(x)" }, sd);
      sd.onpointerleave = () => { active = null; highlight(); plot(); };
      function highlight() {
        groups.forEach((g, i) => g.classList.toggle("nn-dim", active !== null && i !== active));
      }
      plot();
    }
    ctl.update();
  }

  // y = c0 + c1 cos x + c2 sin x: a wave in x, a plane in (cos x, sin x).
  function featureSpace(root) {
    const c0 = 0.5, c1 = 0.8, c2 = -0.6, n = 40;
    const P = Array.from({ length: n }, (_, i) => {
      const x = -Math.PI + (2 * Math.PI * i) / n;
      return { x, h1: Math.cos(x), h2: Math.sin(x), y: c0 + c1 * Math.cos(x) + c2 * Math.sin(x), t: i / (n - 1) };
    });
    const col = (p) => `color-mix(in srgb, var(--nn-hi) ${(100 * p.t).toFixed(0)}%, var(--nn-lo))`;
    let hi = null;
    const tipText = (p) => `x = ${fmt(p.x, 2)}<br>(cos x, sin x) = (${fmt(p.h1, 2)}, ${fmt(p.h2, 2)})` +
      `<br>y = ${fmt(p.y)}`;

    const ctl = html("div", { class: "nn-controls" }, root);
    const bEdge = html("button", { class: "nn-btn", type: "button", text: "View the plane edge-on" }, ctl);
    const bReset = html("button", { class: "nn-btn", type: "button", text: "Reset view" }, ctl);
    html("span", { class: "nn-hint", text: "Drag the right panel to rotate." }, ctl);
    const row = html("div", { class: "nn-row" }, root);

    // input space
    const W = 320, H = 340, m = { l: 40, r: 10, t: 30, b: 38 };
    const s1 = svg(html("div", {}, row), W, H, "y against x");
    const F = frame(s1, W, H, m, [-Math.PI, Math.PI], [-0.7, 1.7], ticks(-3, 3, 1),
      [-0.5, 0, 0.5, 1, 1.5], "x", "y");
    el("text", { x: W / 2, y: 16, "text-anchor": "middle", "font-weight": 600,
      text: "input space: nonlinear in x" }, s1);
    const dots2 = P.map((p, i) => {
      const c = el("circle", { cx: F.sx(p.x), cy: F.sy(p.y), r: 5, style: { fill: col(p) },
        stroke: "var(--nn-bg)", "stroke-width": 1.5, class: "nn-hot" }, s1);
      c.addEventListener("pointermove", (e) => { hi = i; mark(); showTip(e, tipText(p)); });
      c.addEventListener("pointerleave", () => { hi = null; mark(); hideTip(); });
      return c;
    });

    // feature space
    const W3 = 340, H3 = 340;
    const s3 = svg(html("div", {}, row), W3, H3, "the same data in the feature space (cos x, sin x)");
    s3.style.overflow = "hidden";
    s3.style.cursor = "grab";
    s3.style.touchAction = "none";
    const g3 = el("g", {}, s3);
    el("text", { x: W3 / 2, y: 16, "text-anchor": "middle", "font-weight": 600,
      text: "feature space: linear in (cos x, sin x)" }, s3);
    const cap = html("div", { class: "nn-caption" }, root);
    const home = { th: -0.65, ph: 0.38 };
    let view = { ...home };
    const nrm = [-c1, -c2, 1];
    const A = Math.hypot(nrm[0], nrm[1]);
    const edgePh = 0.3;
    const edge = { th: Math.asin((nrm[2] * Math.tan(edgePh)) / A) - Math.atan2(nrm[1], nrm[0]), ph: edgePh };

    const k = 80, cx = W3 / 2, cy = H3 / 2 + 10;
    function proj([X, Y, Z]) {
      const ct = Math.cos(view.th), st = Math.sin(view.th), cp = Math.cos(view.ph), sp = Math.sin(view.ph);
      const x1 = X * ct - Y * st, y1 = X * st + Y * ct;
      return { x: cx + k * x1, y: cy - k * (y1 * sp + (Z - c0) * cp), d: y1 * cp - (Z - c0) * sp };
    }
    const floor = c0 - 1.3;
    const plane = (a, b) => [a, b, c0 + c1 * a + c2 * b];
    function render() {
      g3.replaceChildren();
      const L = 1.25;
      const poly = [[-L, -L], [L, -L], [L, L], [-L, L]].map(([a, b]) => proj(plane(a, b)));
      el("polygon", { points: poly.map((q) => `${q.x},${q.y}`).join(" "),
        style: { fill: S(2), fillOpacity: 0.12 }, stroke: S(2), "stroke-opacity": 0.6 }, g3);
      for (let t = -L; t <= L + 1e-9; t += L / 2.5) {
        for (const [a0, b0, a1, b1] of [[t, -L, t, L], [-L, t, L, t]]) {
          const p = proj(plane(a0, b0)), q = proj(plane(a1, b1));
          el("line", { x1: p.x, y1: p.y, x2: q.x, y2: q.y, stroke: S(2), "stroke-opacity": 0.3 }, g3);
        }
      }
      const ring = [];
      for (let i = 0; i <= 72; i++) {
        const q = proj([Math.cos((i * Math.PI) / 36), Math.sin((i * Math.PI) / 36), floor]);
        ring.push(`${q.x},${q.y}`);
      }
      el("polyline", { points: ring.join(" "), fill: "none", stroke: "var(--nn-muted)",
        "stroke-width": 1.5 }, g3);
      const o = [-1.4, -1.4, floor];
      for (const [d, lab] of [[[2.8, 0, 0], "cos x"], [[0, 2.8, 0], "sin x"], [[0, 0, 2.6], "y"]]) {
        const p = proj(o), q = proj([o[0] + d[0], o[1] + d[1], o[2] + d[2]]);
        el("line", { x1: p.x, y1: p.y, x2: q.x, y2: q.y, class: "nn-axis",
          style: { stroke: "var(--nn-muted)" } }, g3);
        el("text", { x: q.x, y: q.y - 5, "text-anchor": "middle", "font-style": "italic", text: lab }, g3);
      }
      const pts = P.map((p, i) => ({ p, i, q: proj([p.h1, p.h2, p.y]), f: proj([p.h1, p.h2, floor]) }));
      for (const { q, f } of pts)
        el("line", { x1: q.x, y1: q.y, x2: f.x, y2: f.y, stroke: "var(--nn-faint)" }, g3);
      pts.sort((a, b) => b.q.d - a.q.d);
      for (const { p, i, q } of pts) {
        const c = el("circle", { cx: q.x, cy: q.y, r: hi === i ? 8 : 5, style: { fill: col(p) },
          stroke: hi === i ? "var(--nn-ink)" : "var(--nn-bg)", "stroke-width": hi === i ? 2 : 1.5,
          class: "nn-hot" }, g3);
        c.addEventListener("pointermove", (e) => { if (!drag) { hi = i; mark(); showTip(e, tipText(p)); } });
        c.addEventListener("pointerleave", () => { hi = null; mark(); hideTip(); });
      }
    }
    function mark() {
      dots2.forEach((c, i) => {
        c.setAttribute("r", hi === i ? 8 : 5);
        c.setAttribute("stroke", hi === i ? "var(--nn-ink)" : "var(--nn-bg)");
      });
      render();
    }
    const say = (t) => (cap.textContent = t);
    const defaultCap = "The inputs land on a circle (grey). Above it, every data point sits on one flat plane, y = c₀ + c₁ cos x + c₂ sin x.";

    let drag = null;
    s3.addEventListener("pointerdown", (e) => {
      drag = { x: e.clientX, y: e.clientY, ...view };
      s3.setPointerCapture(e.pointerId);
      s3.style.cursor = "grabbing";
    });
    s3.addEventListener("pointermove", (e) => {
      if (!drag) return;
      view.th = drag.th + (e.clientX - drag.x) * 0.01;
      view.ph = Math.max(-1.3, Math.min(1.3, drag.ph + (e.clientY - drag.y) * 0.01));
      say(defaultCap);
      render();
    });
    const end = () => { drag = null; s3.style.cursor = "grab"; };
    s3.addEventListener("pointerup", end);
    s3.addEventListener("pointercancel", end);

    function animate(to, text) {
      const from = { ...view }, t0 = performance.now();
      let dth = to.th - from.th;
      dth = Math.atan2(Math.sin(dth), Math.cos(dth));
      const stepf = (now) => {
        const t = Math.min(1, (now - t0) / 700), e = t < 0.5 ? 2 * t * t : 1 - (-2 * t + 2) ** 2 / 2;
        view = { th: from.th + dth * e, ph: from.ph + (to.ph - from.ph) * e };
        render();
        if (t < 1) requestAnimationFrame(stepf); else say(text);
      };
      requestAnimationFrame(stepf);
    }
    bEdge.addEventListener("click", () => animate(edge,
      "Seen edge-on, the plane is a line and every point falls on it: in feature space, y is linear."));
    bReset.addEventListener("click", () => animate(home, defaultCap));
    say(defaultCap);
    render();
  }

  // A two-hidden-layer network in graph and matrix form, linked by hover.
  function deepNetwork(root) {
    const W = 640, H = 600;
    const s = svg(root, W, H, "a network with two hidden layers in graph form and matrix form");
    s.classList.add("nn-big");
    const cap = html("div", { class: "nn-caption" }, root);
    const C = { in: S(1), l1: S(2), l2: S(4), out: S(3) };
    const sets = { in: ["in"], l1: ["l1"], l2: ["l2"], out: ["out"], tf: ["in", "l1", "l2", "tf"],
      lr: ["lr", "out", "feat"] };
    const text = {
      in: "Input: n samples of one variable. X is (n×1).",
      l1: "Hidden layer 1: H₁ = σ(X W₁ + b₁). W₁ (1×2) maps each input to 2 numbers and σ bends them. H₁ is (n×2).",
      l2: "Hidden layer 2: H₂ = σ(H₁ W₂ + b₂) = h₂(h₁(x)). W₂ (2×3) maps to 3 numbers. The 3 columns of H₂ are the basis functions.",
      out: "Output: y = H₂ c + c₀. A linear combination of the columns of H₂, with no activation.",
      tf: "The hidden layers together are a nonlinear transform, a composition of functions, from x to 3 features.",
      lr: "Finding c and c₀ given H₂ is ordinary linear least squares: the last layer is linear regression.",
    };
    const def = "Hover over (or tap) a layer, a matrix or a bracket to see how the two pictures correspond.";
    const items = [];
    const G = (groups, parent = s) => {
      const g = el("g", { "data-g": groups, class: "nn-hot", tabindex: 0 }, parent);
      items.push(g);
      return g;
    };

    // graph form
    el("text", { x: W / 2, y: 22, "text-anchor": "middle", style: { fill: "var(--nn-muted)" },
      "font-size": 15, text: "graph form" }, s);
    const L = [
      { k: "in", x: 110, ys: [150], lab: ["x"], name: "input" },
      { k: "l1", x: 250, ys: [105, 195], lab: ["", ""], name: "hidden layer 1" },
      { k: "l2", x: 390, ys: [65, 150, 235], lab: ["", "", ""], name: "hidden layer 2" },
      { k: "out", x: 530, ys: [150], lab: ["y"], name: "output" },
    ];
    for (let j = 1; j < L.length; j++) {
      const g = G(L[j].k);
      for (const ya of L[j - 1].ys) for (const yb of L[j].ys)
        el("line", { x1: L[j - 1].x, y1: ya, x2: L[j].x, y2: yb, stroke: "var(--nn-muted)",
          "stroke-width": 1.3 }, g);
    }
    for (const l of L) {
      const g = G(l.k === "l2" ? "l2 feat" : l.k);
      l.ys.forEach((y, i) => {
        el("circle", { cx: l.x, cy: y, r: 20, fill: "var(--nn-bg)", stroke: C[l.k], "stroke-width": 3 }, g);
        if (l.lab[i]) el("text", { x: l.x, y: y + 6, "text-anchor": "middle", "font-style": "italic",
          style: { fontSize: "18px" }, text: l.lab[i] }, g);
      });
      el("text", { x: l.x, y: 282, "text-anchor": "middle", style: { fill: C[l.k] }, text: l.name }, g);
    }

    // matrix form
    el("text", { x: W / 2, y: 330, "text-anchor": "middle", style: { fill: "var(--nn-muted)" },
      "font-size": 15, text: "matrix form" }, s);
    const u = 28, top = 400, h = 120;
    const block = (x, cols, k, name, shape, groups) => {
      const g = G(groups || k);
      el("rect", { x, y: top, width: cols * u, height: h, rx: 3, style: { fill: C[k], fillOpacity: 0.22 },
        stroke: C[k], "stroke-width": 2 }, g);
      for (let i = 1; i < cols; i++)
        el("line", { x1: x + i * u, x2: x + i * u, y1: top, y2: top + h, stroke: C[k] }, g);
      el("text", { x: x + (cols * u) / 2, y: top + h / 2 + 6, "text-anchor": "middle",
        "font-weight": 700, style: { fontSize: "17px" }, text: name }, g);
      el("text", { x: x + (cols * u) / 2, y: top + h + 20, "text-anchor": "middle", class: "nn-tick",
        text: shape }, g);
      return x + cols * u;
    };
    const step = (x, k, label, W_, shape) => {
      const g = G(k);
      el("line", { x1: x + 8, x2: x + 82, y1: top + h / 2, y2: top + h / 2, stroke: "var(--nn-muted)",
        "stroke-width": 1.5, "marker-end": "url(#nn-arrow)" }, g);
      el("text", { x: x + 45, y: top + h / 2 - 10, "text-anchor": "middle", text: label }, g);
      el("rect", { x: x + 17, y: top - 52, width: 56, height: 36, rx: 6, fill: "var(--nn-bg)",
        stroke: C[k], "stroke-width": 1.5 }, g);
      el("text", { x: x + 45, y: top - 37, "text-anchor": "middle", "font-weight": 700,
        style: { fill: C[k] }, text: W_ }, g);
      el("text", { x: x + 45, y: top - 22, "text-anchor": "middle", class: "nn-tick", text: shape }, g);
      return x + 92;
    };
    const defs = el("defs", {}, s);
    const mk = el("marker", { id: "nn-arrow", viewBox: "0 0 10 10", refX: 9, refY: 5, markerWidth: 7,
      markerHeight: 7, orient: "auto-start-reverse" }, defs);
    el("path", { d: "M0,0L10,5L0,10z", style: { fill: "var(--nn-muted)" } }, mk);

    let x = 40;
    x = block(x, 1, "in", "X", "(n×1)");
    x = step(x, "l1", "σ(·W₁ + b₁)", "W₁", "(1×2)");
    x = block(x, 2, "l1", "H₁", "(n×2)");
    x = step(x, "l2", "σ(·W₂ + b₂)", "W₂", "(2×3)");
    const xH2 = x;
    x = block(x, 3, "l2", "H₂", "(n×3)", "l2 feat");
    const xH2e = x;
    x = step(x, "out", "·c + c₀", "c", "(3×1)");
    const xe = block(x, 1, "out", "y", "(n×1)");
    const brace = (x0, x1, y, k, color, lines) => {
      const g = G(k);
      el("path", { d: `M${x0},${y - 6}V${y}H${x1}V${y - 6}`, fill: "none", stroke: color,
        "stroke-width": 2 }, g);
      lines.forEach((t, i) => el("text", { x: (x0 + x1) / 2, y: y + 20 + 17 * i, "text-anchor": "middle",
        style: { fill: color }, text: t }, g));
    };
    brace(40, xH2e, 560, "tf", C.l1, ["nonlinear transform: 3 basis functions h₂(h₁(x))"]);
    brace(xH2e + 8, xe, 560, "lr", C.out, ["linear regression"]);
    void xH2;

    const set = (k) => {
      const on = k ? sets[k] : null;
      for (const g of items) {
        const gs = g.dataset.g.split(" ");
        g.classList.toggle("nn-dim", !!on && !gs.some((v) => on.includes(v)));
      }
      cap.textContent = k ? text[k] : def;
    };
    for (const g of items) {
      const k = g.dataset.g.split(" ")[0];
      const on = () => set(k === "feat" ? "l2" : k);
      g.addEventListener("pointerenter", on);
      g.addEventListener("focus", on);
      g.addEventListener("click", on);
    }
    s.addEventListener("pointerleave", () => set(null));
    set(null);
  }

  // The basis functions a trained network learned; toggle them in and out of the sum.
  function learnedBasis(root) {
    const D = data("basis-data");
    const K = D.c.length;
    const on = Array(K).fill(true);
    let weighted = false, hot = null;

    const ctl = html("div", { class: "nn-controls" }, root);
    const bH = html("button", { class: "nn-btn", type: "button", "aria-pressed": "true", text: "hₖ(x)" }, ctl);
    const bC = html("button", { class: "nn-btn", type: "button", "aria-pressed": "false", text: "cₖ·hₖ(x)" }, ctl);
    html("span", { class: "nn-hint", text: "Toggle basis functions in and out of the sum:" }, ctl);
    const chips = D.c.map((c, k) => {
      const b = html("button", { class: "nn-btn", type: "button", "aria-pressed": "true" }, ctl);
      html("span", { class: "nn-swatch", style: `background:${S(k + 1)}` }, b);
      html("span", { text: `h${sub(k + 1)}` }, b);
      b.addEventListener("click", () => { on[k] = !on[k]; b.setAttribute("aria-pressed", on[k]); draw(); });
      b.addEventListener("pointerenter", () => { hot = k; draw(); });
      b.addEventListener("pointerleave", () => { hot = null; draw(); });
      return b;
    });
    void chips;
    for (const [b, w] of [[bH, false], [bC, true]])
      b.addEventListener("click", () => {
        weighted = w;
        bH.setAttribute("aria-pressed", !w);
        bC.setAttribute("aria-pressed", w);
        draw();
      });

    const row = html("div", { class: "nn-row" }, root);
    const W = 320, H = 280, m = { l: 44, r: 10, t: 30, b: 38 };
    const s1 = svg(html("div", {}, row), W, H, "learned basis functions");
    const s2 = svg(html("div", {}, row), W, H, "linear combination of the selected basis functions");

    function draw() {
      s1.replaceChildren();
      s2.replaceChildren();
      const curves = D.H.map((col, k) => (weighted ? col.map((v) => D.c[k] * v) : col));
      const yd = extent(curves);
      const F = frame(s1, W, H, m, [-Math.PI, Math.PI], yd, ticks(-3, 3, 1),
        ticks(yd[0], yd[1], niceStep(yd[1] - yd[0])), "x", "");
      el("text", { x: W / 2, y: 16, "text-anchor": "middle", "font-weight": 600,
        text: weighted ? "weighted basis functions cₖ hₖ(x)" : "learned basis functions hₖ(x)" }, s1);
      curves.forEach((ys, k) => {
        const p = el("path", { d: path(D.x, ys, F.sx, F.sy), fill: "none", stroke: S(k + 1),
          "stroke-width": hot === k ? 4 : 2.5, "stroke-linecap": "round", class: "nn-hot",
          style: { opacity: !on[k] ? 0.12 : hot !== null && hot !== k ? 0.3 : 1 } }, s1);
        p.addEventListener("pointermove", (e) => {
          if (hot !== k) { hot = k; draw(); }
          showTip(e, `h${sub(k + 1)}: c${sub(k + 1)} = ${fmt(D.c[k])}`);
        });
        p.addEventListener("pointerleave", () => { hot = null; draw(); hideTip(); });
      });

      const yS = D.x.map((_, i) => D.c0 + D.H.reduce((s, col, k) => s + (on[k] ? D.c[k] * col[i] : 0), 0));
      const rms = Math.sqrt(D.f.reduce((s, f, i) => s + (f - yS[i]) ** 2, 0) / D.f.length);
      const yd2 = extent([D.f, yS.map((v) => Math.max(-1.5, Math.min(2.5, v)))]);
      const G2 = frame(s2, W, H, m, [-Math.PI, Math.PI], yd2, ticks(-3, 3, 1),
        ticks(yd2[0], yd2[1], niceStep(yd2[1] - yd2[0])), "x", "");
      el("path", { d: path(D.x, D.f, G2.sx, G2.sy), fill: "none", stroke: "var(--nn-faint)",
        "stroke-width": 6, "stroke-linecap": "round" }, s2);
      el("path", { d: path(D.x, yS.map((v) => Math.max(yd2[0], Math.min(yd2[1], v))), G2.sx, G2.sy),
        fill: "none", stroke: "var(--nn-ink)", "stroke-width": 2 }, s2);
      const n = on.filter(Boolean).length;
      el("text", { x: W / 2, y: 16, "text-anchor": "middle", "font-weight": 600,
        text: `c₀ + Σ cₖ hₖ with ${n} of ${K}: RMS error ${rms.toFixed(3)}` }, s2);
      legendItem(s2, m.l + 6, m.t + 10, "var(--nn-faint)", "f(x)", null, 6);
      legendItem(s2, m.l + 6, m.t + 28, "var(--nn-ink)", "linear combination");
    }
    draw();
  }

  const FIGS = { fourierSeries, fourierNetwork, featureSpace, deepNetwork, learnedBasis };
  const init = () => document.querySelectorAll(".nn-fig[data-nnfig]").forEach((r) => {
    if (r.dataset.ready) return;
    r.dataset.ready = 1;
    FIGS[r.dataset.nnfig](r);
  });
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", init);
  else init();
})();
