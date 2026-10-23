// Figures for "How a neural network builds features".
// Each <div class="fe-fig" data-fefig="name"> is filled in by FIGS[name].
// Colored squares are input features, grey squares are weights.
(() => {
  const NS = "http://www.w3.org/2000/svg";
  const SUB = "₀₁₂₃₄₅₆₇₈₉";
  const sub = (n) => String(n).replace(/\d/g, (d) => SUB[d]);
  const fmt = (v, d = 2) => (v < 0 ? "−" : "") + Math.abs(v).toFixed(d);
  const S = (k) => `var(--fe-s${k})`;
  let uid = 0;

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
      else e.setAttribute(k, v);
    }
    if (parent) parent.appendChild(e);
    return e;
  }

  function svg(parent, W, H, label) {
    return el("svg", { viewBox: `0 0 ${W} ${H}`, role: "img", "aria-label": label }, parent);
  }

  const scale = (d0, d1, r0, r1) => (v) => r0 + ((v - d0) * (r1 - r0)) / (d1 - d0);
  const path = (xs, ys, sx, sy) =>
    xs.map((x, i) => `${i ? "L" : "M"}${sx(x).toFixed(1)},${sy(ys[i]).toFixed(1)}`).join("");
  const linspace = (a, b, n) => Array.from({ length: n }, (_, i) => a + ((b - a) * i) / (n - 1));
  const relu = (z) => Math.max(0, z);

  // One shared tooltip.
  let tip;
  function showTip(evt, content) {
    if (!tip) tip = html("div", { class: "fe-tip", role: "status" }, document.body);
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
  function tipOn(node, content) {
    node.classList.add("fe-hot");
    node.addEventListener("pointermove", (e) => showTip(e, content));
    node.addEventListener("pointerleave", hideTip);
  }

  function slider(parent, label, min, max, step, value, onInput, describe) {
    const c = html("div", { class: "fe-controls" }, parent);
    const id = `fe-${++uid}`;
    html("label", { for: id, text: label }, c);
    const r = html("input", { type: "range", id, min, max, step, value }, c);
    const o = html("output", { for: id }, c);
    const update = () => { o.textContent = describe(+r.value); onInput(+r.value); };
    r.addEventListener("input", update);
    o.textContent = describe(+value);
    return { update };
  }

  // A row of toggle buttons; onPick(index) is called on click.
  function toggles(parent, labels, active, onPick) {
    const c = html("div", { class: "fe-controls" }, parent);
    const bs = labels.map((t, i) => {
      const b = html("button", { class: "fe-btn", type: "button", "aria-pressed": i === active, text: t }, c);
      b.addEventListener("click", () => {
        bs.forEach((o, j) => o.setAttribute("aria-pressed", i === j));
        onPick(i);
      });
      return b;
    });
    return c;
  }

  // A label with an optional subscript, e.g. W with subscript T.
  function label(g, x, y, main, subtext, size, cls) {
    const t = el("text", { x, y, "text-anchor": "middle", class: cls || "",
      style: { fontSize: `${size}px` } }, g);
    el("tspan", { text: main }, t);
    if (subtext) el("tspan", { dy: size * 0.3, style: { fontSize: `${size * 0.7}px` }, text: subtext }, t);
    return t;
  }

  // ---- the squares ----

  // A grey weight square.
  function wsq(g, x, y, s, main, subtext) {
    const q = el("g", {}, g);
    el("rect", { x, y, width: s, height: s, rx: 4, fill: "var(--fe-w)", stroke: "var(--fe-w-edge)",
      "stroke-width": 1 }, q);
    label(q, x + s / 2, y + s / 2 + s * 0.12, main, subtext, s * 0.36);
    return q;
  }

  // A colored input square for input k.
  function xsq(g, x, y, s, k, main, subtext) {
    const q = el("g", {}, g);
    el("rect", { x, y, width: s, height: s, rx: 4, style: { fill: S(k) } }, q);
    label(q, x + s / 2, y + s / 2 + s * 0.13, main, subtext, s * 0.4, "fe-on");
    return q;
  }

  // A feature square striped with the input colors in proportion to |weights|.
  // With bent = true a little tanh curve is drawn over it: the feature after σ.
  function stripes(g, x, y, s, ws, bent) {
    const q = el("g", {}, g);
    const id = `fe-clip-${++uid}`;
    const cp = el("clipPath", { id }, el("defs", {}, q));
    el("rect", { x, y, width: s, height: s, rx: 4 }, cp);
    const inner = el("g", { "clip-path": `url(#${id})` }, q);
    const tot = ws.reduce((a, w) => a + Math.abs(w), 0);
    let xx = x;
    ws.forEach((w, i) => {
      const dw = (s * Math.abs(w)) / tot;
      el("rect", { x: xx, y, width: dw + 0.5, height: s, style: { fill: S(i + 1) } }, inner);
      xx += dw;
    });
    if (bent) {
      const zs = linspace(-2.6, 2.6, 30);
      el("path", { d: path(zs, zs.map(Math.tanh), scale(-2.6, 2.6, x + 5, x + s - 5),
        scale(-1, 1, y + s - 6, y + 6)), fill: "none", stroke: "var(--fe-on-color)",
        "stroke-width": 2.2, "stroke-linecap": "round" }, inner);
    }
    return q;
  }

  // Lay out items left to right on one line, squares with top edge at y.
  // Items: {w: [main, sub]}, {x: [k, main, sub]}, {t: text, width}, {box: fn(x) -> width}.
  function lineup(g, x, y, s, items, gap = 3) {
    const pos = [];
    for (const it of items) {
      if (it.w) { pos.push({ q: wsq(g, x, y, s, ...it.w), x }); x += s + gap; }
      else if (it.x) { pos.push({ q: xsq(g, x, y, s, ...it.x), x }); x += s + gap; }
      else if (it.t !== undefined) {
        el("text", { x: x + it.width / 2, y: y + s / 2 + 8, "text-anchor": "middle",
          class: "fe-big", style: { fontSize: `${it.size || 22}px` }, text: it.t }, g);
        pos.push({ x }); x += it.width;
      } else if (it.box) { const w = it.box(x); pos.push({ x }); x += w + gap; }
    }
    return { x, pos };
  }

  function legend(g, x, y) {
    xsq(g, x, y, 16, 1, "");
    el("text", { x: x + 22, y: y + 13, text: "input feature" }, g);
    wsq(g, x + 130, y, 16, "");
    el("text", { x: x + 152, y: y + 13, text: "weight" }, g);
    stripes(g, x + 225, y, 16, [1, 1, 1], false);
    el("text", { x: x + 247, y: y + 13, text: "linear combination" }, g);
  }

  // ---- figures ----

  // One neuron: h = σ(w1 x1 + w2 x2 + w3 x3 + b), optionally with units.
  function neuronFig(root, units) {
    const W = 640, H = units ? 190 : 150, s = 44;
    const sv = svg(root, W, H, units ? "a neuron with units on every square" : "a single neuron");
    const g = el("g", {}, sv);
    const inp = units
      ? [["T", "", "K", "1/K", "temperature", "W", "T"], ["P", "", "Pa", "1/Pa", "pressure", "W", "P"],
         ["C", "", "mol/L", "L/mol", "concentration", "W", "C"]]
      : [["x", "1"], ["x", "2"], ["x", "3"]].map(([m, k]) => [m, k, "", "", "", "w", k]);
    const items = [{ t: "h =", width: 52 }, { t: "σ(", width: 34 }];
    inp.forEach((v, i) => {
      if (i) items.push({ t: "+", width: 26 });
      items.push({ w: [v[5], v[6]] }, { x: [i + 1, v[0], v[1]] });
    });
    items.push({ t: "+", width: 26 }, { w: ["b", ""] }, { t: ")", width: 20 });
    const width = 52 + 34 + 3 * (2 * s + 6) + 3 * 26 + s + 3 + 20;
    const y = 30;
    const L = lineup(g, (W - width) / 2, y, s, items);
    const sq = L.pos.filter((p) => p.q);
    sq.forEach((p, n) => {
      const i = Math.floor(n / 2), isW = n % 2 === 0;
      if (i === 3) {
        tipOn(p.q, units ? "b: the bias, dimensionless" : "b: the bias, a learned number");
        if (units) el("text", { x: p.x + s / 2, y: y + s + 18, "text-anchor": "middle", class: "fe-unit", text: "1" }, g);
        return;
      }
      const v = inp[i];
      const name = isW ? `${v[5]}${units ? "<sub>" + v[6] + "</sub>" : sub(v[6])}` : `${v[0]}${sub(v[1])}`;
      tipOn(p.q, units
        ? (isW ? `${name}: units of ${v[3]}. It is 1/${v[0]}*, a characteristic ${v[4]} the neuron learns.`
          : `${v[0]}: ${v[4]} in ${v[2]}`)
        : (isW ? `${name}: a weight, learned from data` : `${name}: an input feature`));
      if (units) el("text", { x: p.x + s / 2, y: y + s + 18, "text-anchor": "middle", class: "fe-unit",
        text: isW ? v[3] : v[2] }, g);
      if (units && !isW) {
        const x0 = p.x - s - 3, x1 = p.x + s, yb = y + s + 28;
        el("path", { d: `M${x0},${yb}v6H${x1}v-6`, fill: "none", stroke: "var(--fe-muted)" }, g);
        el("text", { x: (x0 + x1) / 2, y: yb + 22, "text-anchor": "middle", class: "fe-unit",
          text: "dimensionless" }, g);
      }
    });
    legend(g, (W - 360) / 2, H - 22);
  }
  const neuron = (root) => neuronFig(root, false);
  const units = (root) => neuronFig(root, true);

  // A layer: z = W x + b, h = σ(z), in squares.
  function layer(root) {
    const Wm = [[1.2, -0.4, 0.3], [-0.2, 0.9, 0.8], [0.5, 0.5, -1.1], [-1.3, 0.1, 0.6]];
    const b = [0.1, -0.5, 0.3, 0.8];
    const s = 38, p = 4, top = 40, W = 640, H = 250;
    const sv = svg(root, W, H, "a layer of four neurons in squares");
    const cap = html("div", { class: "fe-caption" }, root);
    const g = el("g", {}, sv);
    const rowY = (j) => top + j * (s + p);
    const colH = 4 * (s + p) - p, xTop = top + (colH - (3 * (s + p) - p)) / 2;
    const parts = [];   // [node, row or null]
    const head = (x, w, t) => el("text", { x: x + w / 2, y: top - 12, "text-anchor": "middle",
      style: { fill: "var(--fe-muted)" }, text: t }, g);
    const op = (x, t) => el("text", { x, y: top + colH / 2 + 8, "text-anchor": "middle", class: "fe-big", text: t }, g);

    let x = 40;
    head(x, 3 * (s + p) - p, "W  (4×3)");
    Wm.forEach((r, j) => r.forEach((w, i) => {
      const q = wsq(g, x + i * (s + p), rowY(j), s, fmt(w, 1));
      q.querySelector("text").style.fontSize = "12px";
      tipOn(q, `W${sub(j + 1)}${sub(i + 1)} = ${fmt(w, 1)}: how much neuron ${j + 1} uses x${sub(i + 1)}`);
      parts.push([q, j]);
    }));
    x += 3 * (s + p) + 8;
    head(x, s, "x");
    for (let i = 0; i < 3; i++) {
      const q = xsq(g, x, xTop + i * (s + p), s, i + 1, "x", String(i + 1));
      tipOn(q, `x${sub(i + 1)}: input feature ${i + 1}`);
      parts.push([q, null]);
    }
    x += s + 26; op(x - 13, "+");
    head(x, s, "b");
    b.forEach((v, j) => {
      const q = wsq(g, x, rowY(j), s, fmt(v, 1));
      q.querySelector("text").style.fontSize = "12px";
      parts.push([q, j]);
    });
    x += s + 30; op(x - 15, "=");
    head(x, s, "z");
    Wm.forEach((r, j) => {
      const q = stripes(g, x, rowY(j), s, r, false);
      tipOn(q, `z${sub(j + 1)}: a blend of x₁, x₂, x₃, striped by |weight|`);
      parts.push([q, j]);
    });
    x += s + 14;
    const ay = top + colH / 2;
    el("path", { d: `M${x},${ay}H${x + 58}`, stroke: "var(--fe-muted)", "stroke-width": 1.5, fill: "none" }, g);
    el("path", { d: `M${x + 58},${ay}l-8,-4v8z`, style: { fill: "var(--fe-muted)" } }, g);
    el("text", { x: x + 29, y: ay - 8, "text-anchor": "middle", text: "σ, each one" }, g);
    x += 72;
    head(x, s, "h");
    Wm.forEach((r, j) => {
      const q = stripes(g, x, rowY(j), s, r, true);
      tipOn(q, `h${sub(j + 1)} = σ(z${sub(j + 1)}): the same blend, bent`);
      parts.push([q, j]);
    });
    x += s + 24;
    el("text", { x, y: top + colH / 2 - 6, style: { fill: "var(--fe-muted)" }, text: "4 features," }, g);
    el("text", { x, y: top + colH / 2 + 12, style: { fill: "var(--fe-muted)" }, text: "no products" }, g);
    legend(g, (W - 360) / 2, H - 22);

    const def = "Each row of W makes one neuron. Hover over a square to see which row it belongs to.";
    const set = (j) => {
      for (const [q, r] of parts) q.classList.toggle("fe-dim", j !== null && r !== null && r !== j);
      if (j === null) { cap.textContent = def; return; }
      const terms = Wm[j].map((w, i) => `${i ? (w < 0 ? " − " : " + ") : w < 0 ? "−" : ""}${Math.abs(w).toFixed(1)} x${sub(i + 1)}`).join("");
      cap.textContent = `z${sub(j + 1)} = ${terms} ${b[j] < 0 ? "−" : "+"} ${Math.abs(b[j]).toFixed(1)}, ` +
        `and h${sub(j + 1)} = σ(z${sub(j + 1)}). Only sums of weighted inputs.`;
    };
    for (const [q, r] of parts) if (r !== null) q.addEventListener("pointerenter", () => set(r));
    sv.addEventListener("pointerleave", () => set(null));
    set(null);
  }

  // Marching squares: line segments where the gridded field V crosses level L.
  function contour(V, xs, ys, L) {
    let d = "";
    const lerp = (a, b, va, vb) => a + ((L - va) / (vb - va)) * (b - a);
    for (let j = 0; j < ys.length - 1; j++) for (let i = 0; i < xs.length - 1; i++) {
      const c = [[xs[i], ys[j], V[j][i]], [xs[i + 1], ys[j], V[j][i + 1]],
        [xs[i + 1], ys[j + 1], V[j + 1][i + 1]], [xs[i], ys[j + 1], V[j + 1][i]]];
      const pts = [];
      for (let e = 0; e < 4; e++) {
        const [xa, ya, va] = c[e], [xb, yb, vb] = c[(e + 1) % 4];
        if ((va >= L) !== (vb >= L)) pts.push([lerp(xa, xb, va, vb), lerp(ya, yb, va, vb)]);
      }
      for (let k = 0; k + 1 < pts.length; k += 2)
        d += `M${pts[k][0].toFixed(1)},${pts[k][1].toFixed(1)}L${pts[k + 1][0].toFixed(1)},${pts[k + 1][1].toFixed(1)}`;
    }
    return d;
  }

  // A heatmap panel of fn(x1, x2) over dom, with contour lines.
  // color(v, lo, hi) gives a fill; levels(lo, hi) gives contour levels.
  function heat(s, x0, y0, size, dom, fn, opts = {}) {
    const g = el("g", {}, s);
    const N = opts.N || 44;
    const sx = scale(dom[0], dom[1], x0, x0 + size), sy = scale(dom[0], dom[1], y0 + size, y0);
    const nodes = linspace(dom[0], dom[1], N + 1);
    const V = nodes.map((b) => nodes.map((a) => fn(a, b)));
    let lo = Infinity, hi = -Infinity;
    for (const r of V) for (const v of r) if (isFinite(v)) { lo = Math.min(lo, v); hi = Math.max(hi, v); }
    if (opts.range) [lo, hi] = opts.range;
    const cell = size / N;
    for (let j = 0; j < N; j++) for (let i = 0; i < N; i++) {
      const v = (V[j][i] + V[j][i + 1] + V[j + 1][i] + V[j + 1][i + 1]) / 4;
      el("rect", { x: x0 + i * cell, y: y0 + size - (j + 1) * cell, width: cell + 0.4, height: cell + 0.4,
        style: { fill: (opts.color || seqColor)(v, lo, hi) } }, g);
    }
    el("rect", { x: x0, y: y0, width: size, height: size, fill: "none", stroke: "var(--fe-faint)" }, g);
    const px = nodes.map(sx), py = nodes.map(sy);
    const levels = opts.levels ? opts.levels(lo, hi)
      : Array.from({ length: 7 }, (_, k) => lo + ((hi - lo) * (k + 1)) / 8);
    if (hi - lo > 1e-9)
      for (const L of levels)
        el("path", { d: contour(V, px, py, L), fill: "none", stroke: opts.stroke || "var(--fe-ink)",
          "stroke-width": 1.3, "stroke-opacity": 0.75, "stroke-dasharray": opts.dash || "none" }, g);
    for (const t of opts.ticks || []) {
      el("text", { x: sx(t), y: y0 + size + 14, "text-anchor": "middle", class: "fe-tick", text: String(t).replace("-", "−") }, g);
      el("text", { x: x0 - 5, y: sy(t) + 4, "text-anchor": "end", class: "fe-tick", text: String(t).replace("-", "−") }, g);
    }
    el("text", { x: x0 + size / 2, y: y0 + size + 30, "text-anchor": "middle", "font-style": "italic", text: "x₁" }, g);
    el("text", { x: x0 - 26, y: y0 + size / 2 + 4, "text-anchor": "middle", "font-style": "italic", text: "x₂" }, g);
    return { g, V, sx, sy, lo, hi, levels };
  }
  const seqColor = (v, lo, hi) =>
    `color-mix(in srgb, var(--fe-hi) ${(100 * (v - lo) / (hi - lo || 1)).toFixed(1)}%, var(--fe-lo))`;
  const divColor = (v, lo, hi) => {
    const m = Math.max(Math.abs(lo), Math.abs(hi)), p = Math.min(100, (100 * Math.abs(v)) / m);
    return `color-mix(in srgb, ${v < 0 ? S(2) : S(1)} ${(0.8 * p).toFixed(1)}%, var(--fe-lo))`;
  };

  // One neuron's contours are straight lines; a product's and a ratio's are not.
  function ridge(root) {
    let act = 0, th = 35, bias = 0;
    const acts = [Math.tanh, relu];
    toggles(root, ["tanh", "ReLU"], 0, (i) => { act = i; draw(); });
    const c1 = slider(root, "direction of w", 0, 180, 1, th, (v) => { th = v; draw(); }, (v) => `${v}°`);
    const c2 = slider(root, "bias b", -3, 3, 0.1, bias, (v) => { bias = v; draw(); }, (v) => fmt(v, 1));
    const row = html("div", { class: "fe-row" }, root);
    const W = 206, Hh = 236, size = 156, x0 = 40, y0 = 28, dom = [0.1, 1];
    const ticks = [0.2, 0.6, 1];
    const sN = svg(html("div", {}, row), W, Hh, "contours of one neuron");
    const sP = svg(html("div", {}, row), W, Hh, "contours of x1 times x2");
    const sR = svg(html("div", {}, row), W, Hh, "contours of x1 over x2");
    const title = (s, t) => el("text", { x: x0 + size / 2, y: 16, "text-anchor": "middle", "font-weight": 600, text: t }, s);
    title(sP, "x₁ · x₂");
    heat(sP, x0, y0, size, dom, (a, b) => a * b, { ticks });
    title(sR, "x₁ / x₂ (log color)");
    heat(sR, x0, y0, size, dom, (a, b) => Math.log(a / b), { ticks });
    function draw() {
      sN.replaceChildren();
      const t = (th * Math.PI) / 180, w = [5 * Math.cos(t), 5 * Math.sin(t)];
      const f = (a, b) => acts[act](w[0] * (a - 0.55) + w[1] * (b - 0.55) + bias);
      title(sN, `${act ? "ReLU" : "tanh"}(w₁x₁ + w₂x₂ + b)`);
      const Hm = heat(sN, x0, y0, size, dom, f, { ticks });
      const cx = Hm.sx(0.55), cy = Hm.sy(0.55), L = 48;
      el("path", { d: `M${cx},${cy}l${L * Math.cos(t)},${-L * Math.sin(t)}`, stroke: S(2), "stroke-width": 3,
        "stroke-linecap": "round" }, sN);
      el("circle", { cx: cx + L * Math.cos(t), cy: cy - L * Math.sin(t), r: 4, style: { fill: S(2) } }, sN);
      el("text", { x: cx + (L + 14) * Math.cos(t), y: cy - (L + 14) * Math.sin(t) + 5, "text-anchor": "middle",
        "font-weight": 700, style: { fill: S(2) }, text: "w" }, sN);
    }
    void c2;
    c1.update();
  }

  // x² from ReLU units placed at evenly spaced kinks.
  function reluFig(root) {
    let n = 4;
    const cap = html("div", { class: "fe-caption" });
    slider(root, "ReLU units", 1, 16, 1, n, (v) => { n = v; draw(); }, (v) => `n = ${v}`);
    const W = 640, H1 = 250, H2 = 160, m = { l: 44, r: 16, t: 14, b: 30 };
    const s1 = svg(root, W, H1, "x squared and its ReLU approximation");
    const s2 = svg(root, W, H2, "the slope of x squared and of the ReLU network");
    root.appendChild(cap);
    const xs = linspace(-1, 1, 401);
    const sx = scale(-1, 1, m.l, W - m.r);
    function axes(s, H, yd, yt, ylab) {
      const sy = scale(yd[0], yd[1], H - m.b, m.t);
      for (const t of yt) {
        el("line", { class: "fe-grid", x1: m.l, x2: W - m.r, y1: sy(t), y2: sy(t) }, s);
        el("text", { class: "fe-tick", x: m.l - 6, y: sy(t) + 4, "text-anchor": "end", text: String(t).replace("-", "−") }, s);
      }
      for (const t of [-1, -0.5, 0, 0.5, 1])
        el("text", { class: "fe-tick", x: sx(t), y: H - m.b + 16, "text-anchor": "middle", text: String(t).replace("-", "−") }, s);
      el("text", { x: 14, y: (m.t + H - m.b) / 2, "text-anchor": "middle",
        transform: `rotate(-90 14 ${(m.t + H - m.b) / 2})`, text: ylab }, s);
      const id = `fe-clip-${++uid}`;
      el("rect", { x: m.l, y: m.t, width: W - m.l - m.r, height: H - m.t - m.b },
        el("clipPath", { id }, el("defs", {}, s)));
      return { sy, g: el("g", { "clip-path": `url(#${id})` }, s) };
    }
    function draw() {
      s1.replaceChildren(); s2.replaceChildren();
      const h = 2 / n, t = Array.from({ length: n + 1 }, (_, k) => -1 + k * h);
      const slope = t.slice(0, -1).map((a, k) => a + t[k + 1]);          // slope on each piece
      const units = [{ c: slope[0], k: -1 }];                             // c·relu(x − k)
      for (let k = 1; k < n; k++) units.push({ c: slope[k] - slope[k - 1], k: t[k] });
      const net = (x) => 1 + units.reduce((a, u) => a + u.c * relu(x - u.k), 0);
      const A = axes(s1, H1, [-0.7, 1.3], [-0.5, 0, 0.5, 1], "y");
      units.forEach((u, i) => el("path", { d: path(xs, xs.map((x) => u.c * relu(x - u.k)), sx, A.sy),
        fill: "none", stroke: S((i % 4) + 1), "stroke-width": 1.4, "stroke-opacity": 0.8 }, A.g));
      el("path", { d: path(xs, xs.map((x) => x * x), sx, A.sy), fill: "none", stroke: "var(--fe-faint)",
        "stroke-width": 7, "stroke-linecap": "round" }, A.g);
      el("path", { d: path(xs, xs.map(net), sx, A.sy), fill: "none", stroke: "var(--fe-ink)", "stroke-width": 2 }, A.g);
      for (const u of units) el("circle", { cx: sx(u.k), cy: A.sy(net(u.k)), r: 3.5, style: { fill: "var(--fe-ink)" } }, A.g);
      el("text", { x: m.l + 8, y: m.t + 14, text: "x² (grey), network (dark), weighted units (color)" }, s1);

      const B = axes(s2, H2, [-2.3, 2.3], [-2, 0, 2], "slope");
      el("path", { d: path(xs, xs.map((x) => 2 * x), sx, B.sy), fill: "none", stroke: "var(--fe-faint)",
        "stroke-width": 7, "stroke-linecap": "round" }, B.g);
      let d = "";
      slope.forEach((sl, k) => { d += `${k ? "L" : "M"}${sx(t[k])},${B.sy(sl)}H${sx(t[k + 1])}`; });
      el("path", { d, fill: "none", stroke: "var(--fe-ink)", "stroke-width": 2 }, B.g);
      el("text", { x: m.l + 8, y: m.t + 14, text: "slope: 2x (grey) and the network's staircase (dark)" }, s2);
      cap.textContent = `${n} unit${n > 1 ? "s" : ""}, ${n} linear piece${n > 1 ? "s" : ""}, ` +
        `largest error 1/n² = ${(1 / n ** 2).toFixed(4)}. Each step in the slope is one kink.`;
    }
    draw();
  }

  // tanh curvature at an operating point, and a product from four tanh neurons.
  function tanhFig(root) {
    const epsOf = (v) => 0.05 * 30 ** (v / 100);
    let b = 0.66, eps = epsOf(67);
    slider(root, "bias b (operating point)", -2, 2, 0.02, b, (v) => { b = v; draw(); }, (v) => fmt(v, 2));
    slider(root, "weight scale ε", 0, 100, 1, 67, (v) => { eps = epsOf(v); draw(); }, (v) => epsOf(v).toFixed(2));
    const row = html("div", { class: "fe-row" }, root);
    const W = 310, H = 300;
    const sL = svg(html("div", {}, row), W, H, "tanh and its local parabola");
    const sR = svg(html("div", {}, row), W, H, "x1 x2 from four tanh neurons");
    const cap = html("div", { class: "fe-caption" }, root);
    const tp = (z) => 1 - Math.tanh(z) ** 2, tpp = (z) => -2 * Math.tanh(z) * tp(z);
    function draw() {
      sL.replaceChildren(); sR.replaceChildren();
      const m = { l: 40, r: 10, t: 34, b: 34 };
      const sx = scale(-3, 3, m.l, W - m.r), sy = scale(-1.4, 1.4, H - m.b, m.t);
      for (const t of [-1, 0, 1]) {
        el("line", { class: "fe-grid", x1: m.l, x2: W - m.r, y1: sy(t), y2: sy(t) }, sL);
        el("text", { class: "fe-tick", x: m.l - 6, y: sy(t) + 4, "text-anchor": "end", text: String(t).replace("-", "−") }, sL);
      }
      for (const t of [-3, -2, -1, 0, 1, 2, 3])
        el("text", { class: "fe-tick", x: sx(t), y: H - m.b + 16, "text-anchor": "middle", text: String(t).replace("-", "−") }, sL);
      el("text", { x: (m.l + W - m.r) / 2, y: H - 4, "text-anchor": "middle", "font-style": "italic", text: "z" }, sL);
      const zs = linspace(-3, 3, 241);
      el("path", { d: path(zs, zs.map(Math.tanh), sx, sy), fill: "none", stroke: "var(--fe-ink)", "stroke-width": 2 }, sL);
      const ds = linspace(-1.3, 1.3, 81).filter((d) => Math.abs(b + d) <= 3);
      const t0 = Math.tanh(b), t1 = tp(b), t2 = tpp(b);
      el("path", { d: path(ds.map((d) => b + d), ds.map((d) => t0 + t1 * d + 0.5 * t2 * d * d), sx, sy),
        fill: "none", stroke: S(2), "stroke-width": 2.5, "stroke-dasharray": "6 4" }, sL);
      el("circle", { cx: sx(b), cy: sy(t0), r: 5, style: { fill: S(2) }, stroke: "var(--fe-bg)", "stroke-width": 2 }, sL);
      el("text", { x: W / 2, y: 16, "text-anchor": "middle", "font-weight": 600,
        text: `tanh″(${fmt(b, 2)}) = ${fmt(t2, 3)}` }, sL);
      el("text", { x: m.l + 4, y: m.t + 4, style: { fill: S(2) }, text: "local parabola" }, sL);

      const size = 220, x0 = 52, y0 = 34;
      if (Math.abs(t2) < 0.03) {
        el("text", { x: W / 2, y: H / 2 - 8, "text-anchor": "middle", text: "No curvature at this operating point," }, sR);
        el("text", { x: W / 2, y: H / 2 + 12, "text-anchor": "middle", text: "so these neurons cannot make a product." }, sR);
        cap.textContent = "At b = 0, tanh is locally a straight line (plus a cubic). Move the bias onto the shoulder of the curve.";
        return;
      }
      const g = (sv) => Math.tanh(b + eps * sv);
      const c = 1 / (4 * eps * eps * t2);
      const P = (x1, x2) => c * (g(x1 + x2) + g(-x1 - x2) - g(x1 - x2) - g(x2 - x1));
      const lev = () => [-0.75, -0.5, -0.25, 0.25, 0.5, 0.75];
      const Hm = heat(sR, x0, y0, size, [-1, 1], (a, bb) => Math.max(-1.5, Math.min(1.5, P(a, bb))),
        { color: divColor, range: [-1, 1], levels: lev, ticks: [-1, 0, 1] });
      const tr = heat(el("g", {}, sR), x0, y0, size, [-1, 1], (a, bb) => a * bb,
        { color: () => "transparent", levels: lev, dash: "5 3", stroke: S(3) });
      void tr;
      el("text", { x: x0 + size / 2, y: 16, "text-anchor": "middle", "font-weight": 600,
        text: "four tanh neurons vs x₁x₂ (green dashes)" }, sR);
      let err = 0;
      for (const r of linspace(-1, 1, 41)) for (const q of linspace(-1, 1, 41)) err = Math.max(err, Math.abs(P(r, q) - r * q));
      cap.textContent = `ε = ${eps.toFixed(2)}: output weights ±${Math.abs(c).toFixed(1)}, largest error ${err.toFixed(3)}. ` +
        "Smaller ε is more accurate and needs bigger, canceling weights.";
      void Hm;
    }
    draw();
  }

  // A second-layer neuron, and the first-layer neurons it is made of.
  function compose(root) {
    const W = 640, H = 330, s = 38;
    const sv = svg(root, W, H, "a second layer neuron built from first layer neurons");
    const g = el("g", {}, sv);
    const L1 = [[0.8, 0.3], [0.2, -1.0]];
    const hs = [];
    const top = lineup(g, 40, 24, s, [{ t: "h⁽²⁾ =", width: 76 }, { t: "σ(", width: 32 },
      { w: ["v", "1"] }, { box: (x) => { hs.push(x); return s; } }, { t: "+", width: 26 },
      { w: ["v", "2"] }, { box: (x) => { hs.push(x); return s; } }, { t: "+", width: 26 },
      { w: ["c", ""] }, { t: ")", width: 20 }]);
    void top;
    el("text", { x: 470, y: 112 + s / 2 + 5, class: "fe-unit", text: "first layer" }, g);
    el("text", { x: 470, y: 24 + s / 2 + 5, class: "fe-unit", text: "second layer" }, g);
    hs.forEach((x, j) => {
      const q = stripes(g, x, 24, s, L1[j], true);
      tipOn(q, `h${sub(j + 1)}⁽¹⁾: a first-layer feature, a bent blend of x₁ and x₂`);
      el("text", { x: x + s / 2, y: 24 + s + 18, "text-anchor": "middle", class: "fe-unit",
        text: `h${sub(j + 1)}⁽¹⁾` }, g);
      // its definition on its own line below
      const y = 112 + j * 58;
      const r = lineup(g, 70, y, s, [{ t: `h${sub(j + 1)}⁽¹⁾ =`, width: 64, size: 18 }, { t: "σ(", width: 30 },
        { w: ["w", `${j + 1}1`] }, { x: [1, "x", "1"] }, { t: "+", width: 24 },
        { w: ["w", `${j + 1}2`] }, { x: [2, "x", "2"] }, { t: "+", width: 24 },
        { w: ["b", `${j + 1}`] }, { t: ")", width: 18 }]);
      void r;
    });

    // the patterns that never appear
    const yb = 248, x0 = 150;
    el("text", { x: x0, y: yb + 24, style: { fill: "var(--fe-muted)" }, text: "never formed:" }, g);
    const bad = (x, yy, w, h) => {
      el("rect", { x: x - 6, y: yy - 6, width: w + 12, height: h + 12, rx: 6, fill: "none",
        stroke: "var(--fe-bad)", "stroke-width": 1.5, "stroke-dasharray": "5 3" }, g);
      el("path", { d: `M${x - 6},${yy + h + 6}L${x + w + 6},${yy - 6}`, stroke: "var(--fe-bad)", "stroke-width": 2 }, g);
    };
    const ps = 28, px = x0 + 110;
    tipOn(xsq(g, px, yb + 4, ps, 1, "x", "1"), "x₁ next to x₂: a product. No layer ever does this.");
    xsq(g, px + ps + 2, yb + 4, ps, 2, "x", "2");
    bad(px, yb + 4, 2 * ps + 2, ps);
    el("text", { x: px + 2 * ps + 24, y: yb + 24, class: "fe-unit", text: "product" }, g);
    const rx = px + 170;
    tipOn(xsq(g, rx, yb - 14, ps, 1, "x", "1"), "x₁ over x₂: a ratio. No layer ever does this.");
    el("line", { x1: rx - 2, x2: rx + ps + 2, y1: yb + ps - 10, y2: yb + ps - 10, stroke: "var(--fe-ink)", "stroke-width": 2 }, g);
    xsq(g, rx, yb + ps - 6, ps, 2, "x", "2");
    bad(rx, yb - 14, ps, 2 * ps + 8);
    el("text", { x: rx + ps + 22, y: yb + 24, class: "fe-unit", text: "ratio" }, g);
  }

  const FIGS = { neuron, layer, ridge, relu: reluFig, tanh: tanhFig, units, compose };
  const init = () => document.querySelectorAll(".fe-fig[data-fefig]").forEach((r) => {
    if (r.dataset.ready) return;
    r.dataset.ready = 1;
    FIGS[r.dataset.fefig](r);
  });
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", init);
  else init();
})();
