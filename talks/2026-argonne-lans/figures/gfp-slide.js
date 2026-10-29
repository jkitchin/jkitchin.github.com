// Interactive GFP campaign explorer for the MFI update slide.
// Reads window.GFP_DATA (figures/gfp-data.js) and renders into every .gfpx element.
(function () {
  const NS = 'http://www.w3.org/2000/svg';
  const W = 400, H = 330, M = { l: 58, r: 12, t: 26, b: 42 };
  const ORDER_GLC = ['R01', 'R02', 'R03', 'R04', 'R09'];
  const ORDER_GAL = ['R05', 'R06', 'R07', 'R08', 'R10'];
  const ORDER_OTHER = ['R11', 'R12'];
  const BLUES = ['#9ecae1', '#6baed6', '#3182bd', '#08519c', '#08306b'];
  const ORANGES = ['#fdae6b', '#fd8d3c', '#e6550d', '#a63603', '#7f2704'];

  function color(rid) {
    let i = ORDER_GLC.indexOf(rid);
    if (i >= 0) return BLUES[i];
    i = ORDER_GAL.indexOf(rid);
    if (i >= 0) return ORANGES[i];
    return rid === 'R11' ? '#7b2d8e' : '#7a7a7a';
  }

  function label(rid, rec) {
    const r = rec[rid];
    if (r.glc && r.gal) return `${r.glc}% glc + ${r.gal}% gal`;
    if (r.glc) return `${r.glc}% glucose`;
    if (r.gal) return `${r.gal}% galactose`;
    return 'no sugar';
  }

  function niceTicks(min, max, n) {
    const step0 = (max - min) / n, p = Math.pow(10, Math.floor(Math.log10(step0)));
    const step = [1, 2, 2.5, 5, 10].map(m => m * p).find(s => s >= step0);
    const ticks = [];
    for (let v = Math.floor(min / step) * step; ticks.length === 0 || ticks[ticks.length - 1] < max; v += step)
      ticks.push(+v.toFixed(6));
    return ticks;
  }

  function fmt(v, ch) {
    if (v == null) return 'n/a';
    if (ch === 'OD600') return v.toFixed(2);
    return Math.abs(v) >= 1000 ? (v / 1000).toFixed(v >= 1e5 ? 0 : 1) + 'k' : Math.round(v).toString();
  }

  function el(tag, attrs, parent) {
    const e = document.createElementNS(NS, tag);
    for (const k in attrs) e.setAttribute(k, attrs[k]);
    if (parent) parent.appendChild(e);
    return e;
  }

  function pathFor(t, ys, sx, sy) {
    let d = '', pen = false;
    ys.forEach((y, i) => {
      if (y == null) { pen = false; return; }
      d += (pen ? 'L' : 'M') + sx(t[i]).toFixed(1) + ',' + sy(y).toFixed(1);
      pen = true;
    });
    return d;
  }

  function bandFor(t, lo, hi, sx, sy) {
    // one closed polygon per contiguous run of non-null points
    let d = '', seg = [];
    const flush = () => {
      if (seg.length > 1) {
        d += 'M' + seg.map(i => sx(t[i]).toFixed(1) + ',' + sy(hi[i]).toFixed(1)).join('L');
        d += 'L' + seg.slice().reverse().map(i => sx(t[i]).toFixed(1) + ',' + sy(lo[i]).toFixed(1)).join('L') + 'Z';
      }
      seg = [];
    };
    t.forEach((_, i) => (lo[i] == null || hi[i] == null) ? flush() : seg.push(i));
    flush();
    return d;
  }

  function init(root) {
    const D = window.GFP_DATA;
    if (!D) { root.textContent = 'GFP data failed to load (figures/gfp-data.js).'; return; }
    const state = { run: 'Run2', sel: 'R10', hover: null };
    const panels = [
      { ch: 'OD600', svg: root.querySelector('.gfpx-od'), title: 'OD600 (blank-corrected)' },
      { ch: 'GFP', svg: root.querySelector('.gfpx-gfp'), title: 'GFP, RFU (blank-corrected)' },
    ];
    const readout = root.querySelector('.gfpx-readout');
    const note = root.querySelector('.gfpx-note');

    // media chips
    const chips = root.querySelector('.gfpx-chips');
    [['Glucose', ORDER_GLC], ['Galactose', ORDER_GAL], ['Other', ORDER_OTHER]].forEach(([name, ids]) => {
      const row = document.createElement('div');
      row.className = 'gfpx-row';
      row.innerHTML = `<span class="gfpx-rowlab">${name}</span>`;
      ids.forEach(rid => {
        const b = document.createElement('button');
        b.className = 'gfpx-chip';
        b.dataset.rid = rid;
        b.style.setProperty('--c', color(rid));
        const r = D.recipes[rid];
        b.textContent = name === 'Other' ? (r.glc ? 'mix' : 'none') : (r.glc || r.gal) + '%';
        b.title = label(rid, D.recipes);
        b.onclick = () => { state.sel = state.sel === rid ? null : rid; render(); };
        row.appendChild(b);
      });
      chips.appendChild(row);
    });

    root.querySelectorAll('.gfpx-run').forEach(b => {
      b.onclick = () => { state.run = b.dataset.run; render(); };
    });

    function scales(p) {
      const C = D.runs[state.run].channels[p.ch];
      let ymax = 0, ymin = 0;
      for (const rid in C.series) {
        const s = C.series[rid];
        for (const arr of [s.lo, s.hi, s.mean]) for (const v of arr) if (v != null) { ymax = Math.max(ymax, v); ymin = Math.min(ymin, v); }
      }
      // ignore small negative blank-correction noise when choosing the bottom of the axis
      const ticks = niceTicks(ymin < -0.1 * ymax ? ymin : 0, ymax * 1.03, 5);
      const top = ticks[ticks.length - 1];
      const bot = Math.min(ticks[0], ymin);
      const sx = x => M.l + (x / 48) * (W - M.l - M.r);
      const sy = y => H - M.b - ((y - bot) / (top - bot)) * (H - M.t - M.b);
      return { C, ticks, sx, sy };
    }

    function drawPanel(p) {
      const svg = p.svg;
      svg.innerHTML = '';
      const { C, ticks, sx, sy } = scales(p);
      p.sx = sx; p.sy = sy; p.C = C;
      el('text', { x: M.l, y: 15, class: 'gfpx-ptitle' }, svg).textContent = p.title;
      ticks.forEach(v => {
        el('line', { x1: M.l, x2: W - M.r, y1: sy(v), y2: sy(v), class: 'gfpx-grid' }, svg);
        el('text', { x: M.l - 6, y: sy(v) + 4, class: 'gfpx-tick', 'text-anchor': 'end' }, svg).textContent = fmt(v, p.ch);
      });
      [0, 12, 24, 36, 48].forEach(v => {
        el('text', { x: sx(v), y: H - M.b + 16, class: 'gfpx-tick', 'text-anchor': 'middle' }, svg).textContent = v;
      });
      el('text', { x: (M.l + W - M.r) / 2, y: H - 6, class: 'gfpx-tick', 'text-anchor': 'middle' }, svg).textContent = 'time (h)';
      el('line', { x1: M.l, x2: M.l, y1: M.t, y2: H - M.b, class: 'gfpx-axis' }, svg);
      el('line', { x1: M.l, x2: W - M.r, y1: sy(0), y2: sy(0), class: 'gfpx-axis' }, svg);

      // keep curves inside the plot area (non-GFP control can exceed the GFP-strain range)
      const clipId = 'gfpx-clip-' + p.ch + '-' + Math.random().toString(36).slice(2, 8);
      el('rect', { x: M.l, y: M.t, width: W - M.l - M.r, height: H - M.t - M.b }, el('clipPath', { id: clipId }, svg));
      const plot = el('g', { 'clip-path': `url(#${clipId})` }, svg);

      const sel = state.sel;
      if (sel) {
        const s = C.series[sel];
        el('path', { d: bandFor(C.t, s.lo, s.hi, sx, sy), fill: color(sel), opacity: 0.22 }, plot);
      }
      for (const rid in C.series) {
        if (rid === sel) continue;
        el('path', { d: pathFor(C.t, C.series[rid].mean, sx, sy), stroke: color(rid), class: 'gfpx-line',
                     opacity: sel ? 0.18 : 0.95 }, plot);
      }
      if (sel) {
        const s = C.series[sel];
        el('path', { d: pathFor(C.t, s.ctrl, sx, sy), stroke: '#555', class: 'gfpx-line gfpx-ctrl' }, plot);
        el('path', { d: pathFor(C.t, s.mean, sx, sy), stroke: color(sel), class: 'gfpx-line gfpx-sel' }, plot);
      }
      if (state.hover != null) {
        const x = sx(C.t[state.hover]);
        el('line', { x1: x, x2: x, y1: M.t, y2: H - M.b, class: 'gfpx-cross' }, svg);
        if (sel && C.series[sel].mean[state.hover] != null)
          el('circle', { cx: x, cy: sy(C.series[sel].mean[state.hover]), r: 4.5, fill: color(sel), stroke: '#fff', 'stroke-width': 1.5 }, svg);
      }
      const hit = el('rect', { x: M.l, y: M.t, width: W - M.l - M.r, height: H - M.t - M.b, fill: 'transparent', class: 'gfpx-hit' }, svg);
      hit.addEventListener('mousemove', e => onMove(e, p));
      hit.addEventListener('mouseleave', () => { state.hover = null; render(); });
      hit.addEventListener('click', e => onClick(e, p));
    }

    function svgXY(e, svg) {
      const r = svg.getBoundingClientRect();
      return [(e.clientX - r.left) / r.width * W, (e.clientY - r.top) / r.height * H];
    }

    function nearestIndex(p, x) {
      const t = ((x - M.l) / (W - M.l - M.r)) * 48;
      let best = 0;
      p.C.t.forEach((v, i) => { if (Math.abs(v - t) < Math.abs(p.C.t[best] - t)) best = i; });
      return best;
    }

    function onMove(e, p) {
      const [x] = svgXY(e, p.svg);
      const i = nearestIndex(p, x);
      if (i !== state.hover) { state.hover = i; render(); }
    }

    function onClick(e, p) {
      // select the curve closest to the click at that time
      const [x, y] = svgXY(e, p.svg);
      const i = nearestIndex(p, x);
      let best = null, bd = Infinity;
      for (const rid in p.C.series) {
        const v = p.C.series[rid].mean[i];
        if (v == null) continue;
        const dd = Math.abs(p.sy(v) - y);
        if (dd < bd) { bd = dd; best = rid; }
      }
      if (best && bd < 25) { state.sel = best; render(); }
    }

    function renderReadout() {
      const R = D.runs[state.run].channels;
      const sel = state.sel;
      if (!sel) { readout.innerHTML = '<div class="gfpx-muted">Click a medium or a curve to see the starter spread and the non-GFP control.</div>'; return; }
      const i = state.hover != null ? state.hover : R.GFP.t.length - 1;
      const t = R.GFP.t[i];
      const row = ch => {
        const s = R[ch].series[sel];
        const rng = s.lo[i] == null ? '' : ` <span class="gfpx-muted">(${fmt(s.lo[i], ch)} to ${fmt(s.hi[i], ch)})</span>`;
        return `<tr><td>${ch === 'GFP' ? 'GFP' : 'OD600'}</td><td><b>${fmt(s.mean[i], ch)}</b>${rng}</td><td>${fmt(s.ctrl[i], ch)}</td></tr>`;
      };
      const n = R.GFP.series[sel].n[i];
      readout.innerHTML =
        `<div class="gfpx-rlab" style="color:${color(sel)}">${label(sel, D.recipes)}</div>` +
        `<div class="gfpx-muted">t = ${t.toFixed(1)} h · ${n} of 3 starters valid (GFP)</div>` +
        `<table><tr><th></th><th>GFP strain</th><th>non-GFP</th></tr>${row('OD600')}${row('GFP')}</table>`;
    }

    function render() {
      root.querySelectorAll('.gfpx-run').forEach(b => b.classList.toggle('on', b.dataset.run === state.run));
      root.querySelectorAll('.gfpx-chip').forEach(b => b.classList.toggle('on', b.dataset.rid === state.sel));
      panels.forEach(drawPanel);
      renderReadout();
      note.textContent = state.run === 'Run1'
        ? 'Run 1: the GFP reader saturated in many wells; those readings are censored and shown as gaps. Do not compare RFU across runs.'
        : 'Run 2: 12 media × 3 GFP starter cultures + non-GFP control, BioLector XT. Mean of starters; band = min to max.';
    }

    render();
  }

  function start() { document.querySelectorAll('.gfpx').forEach(init); }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start);
  else start();
})();
