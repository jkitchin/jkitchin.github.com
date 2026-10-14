// Water surface behind the home page header. Moving the pointer is like
// drawing a stick through the water: it pushes the surface continuously along
// its path and leaves a wake. Clicking drops a stone. It is a finite-difference
// solution of the damped 2D wave equation,
//
//     u_tt = c^2 (u_xx + u_yy) - gamma u_t,
//
// on a grid at 1/CELL of screen resolution, using the two-buffer scheme
//
//     u_new = (u_N + u_S + u_E + u_W) / 2 - u_old,   then  u_new *= DAMP.
//
// It is drawn as faint highlights and shadows from the surface slope, so it
// reads as light on water rather than as motion. It only animates while there
// is energy in the field; a still page costs nothing. Nothing runs for readers
// who ask for reduced motion, or with ?water=off in the URL.
(function () {
  var host = document.querySelector("[data-water]");
  if (!host) return;
  if (window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
  if (/[?&]water=off\b/.test(window.location.search)) return;

  var CELL = 3;          // screen pixels per grid cell
  var DAMP = 0.975;      // per-step energy loss
  var STICK = 2.2;       // push per grid cell travelled by the stick
  var STICK_MAX = 9;     // cap on the push per cell, so a flick is not a splash
  var STICK_RADIUS = 1.6;
  var DROP_AMP = 300;    // a click
  var DROP_RADIUS = 5;
  var SHADE = 0.11;      // maximum opacity of a highlight or shadow
  var REST = 0.3;        // largest |u| below which the surface looks still

  var canvas = document.createElement("canvas");
  canvas.className = "water-canvas";
  canvas.setAttribute("aria-hidden", "true");
  host.insertBefore(canvas, host.firstChild);
  var ctx = canvas.getContext("2d");

  var w, h, cur, prev, img, running = false;
  var last = null;    // last stick position, in grid cells
  var path = [];      // stick positions since the last frame

  function resize() {
    var r = host.getBoundingClientRect();
    w = Math.max(8, Math.ceil(r.width / CELL));
    h = Math.max(8, Math.ceil(r.height / CELL));
    canvas.width = w;
    canvas.height = h;
    cur = new Float32Array(w * h);
    prev = new Float32Array(w * h);
    img = ctx.createImageData(w, h);
    last = null;
  }

  function toGrid(e) {
    var r = host.getBoundingClientRect();
    return { x: (e.clientX - r.left) / CELL, y: (e.clientY - r.top) / CELL };
  }

  // Add a smooth bump of height amp and radius rad (grid cells) at (gx, gy).
  function bump(gx, gy, amp, rad) {
    var R = Math.ceil(rad);
    var cx = Math.round(gx), cy = Math.round(gy);
    for (var dy = -R; dy <= R; dy++) {
      for (var dx = -R; dx <= R; dx++) {
        var x = cx + dx, y = cy + dy;
        if (x < 1 || y < 1 || x >= w - 1 || y >= h - 1) continue;
        var d = Math.sqrt((x - gx) * (x - gx) + (y - gy) * (y - gy));
        if (d >= rad) continue;
        cur[y * w + x] += amp * 0.5 * (1 + Math.cos(Math.PI * d / rad));
      }
    }
  }

  function wake() {
    // Push the surface at every cell along the stick's path, so a fast
    // stroke leaves a continuous wake rather than a row of drops.
    for (var k = 0; k < path.length; k++) {
      var p = path[k];
      if (last) {
        var dx = p.x - last.x, dy = p.y - last.y;
        var dist = Math.sqrt(dx * dx + dy * dy);
        var n = Math.max(1, Math.ceil(dist));
        var amp = Math.min(STICK_MAX, STICK * dist / n * 4);
        for (var i = 1; i <= n; i++) {
          bump(last.x + dx * i / n, last.y + dy * i / n, amp, STICK_RADIUS);
        }
      }
      last = p;
    }
    path.length = 0;
  }

  function start() {
    if (!running) {
      running = true;
      requestAnimationFrame(step);
    }
  }

  function step() {
    wake();
    var peak = 0;
    for (var y = 1; y < h - 1; y++) {
      var row = y * w;
      for (var x = 1; x < w - 1; x++) {
        var i = row + x;
        var v = ((cur[i - 1] + cur[i + 1] + cur[i - w] + cur[i + w]) * 0.5 - prev[i]) * DAMP;
        prev[i] = v;
        if (v > peak) peak = v; else if (-v > peak) peak = -v;
      }
    }
    var t = prev; prev = cur; cur = t;
    draw();
    if (peak > REST || path.length) {
      requestAnimationFrame(step);
    } else {
      running = false;
      cur.fill(0);
      prev.fill(0);
      draw();
    }
  }

  function draw() {
    var data = img.data;
    for (var y = 1; y < h - 1; y++) {
      for (var x = 1; x < w - 1; x++) {
        var i = y * w + x;
        // light from the upper left: shade by the surface slope, eased so
        // small slopes fade in gently instead of switching on
        var s = (cur[i - 1] - cur[i + 1]) + (cur[i - w] - cur[i + w]);
        var m = Math.abs(s) / 40;
        var a = SHADE * m / (1 + m);
        var p = i * 4;
        if (s > 0) { data[p] = 225; data[p + 1] = 240; data[p + 2] = 255; }
        else { data[p] = 2; data[p + 1] = 10; data[p + 2] = 26; }
        data[p + 3] = a * 255;
      }
    }
    ctx.putImageData(img, 0, 0);
  }

  host.addEventListener("pointermove", function (e) {
    path.push(toGrid(e));
    start();
  });
  host.addEventListener("pointerleave", function () { last = null; });
  host.addEventListener("pointerdown", function (e) {
    var g = toGrid(e);
    bump(g.x, g.y, DROP_AMP, DROP_RADIUS);
    start();
  });

  var pending;
  window.addEventListener("resize", function () {
    clearTimeout(pending);
    pending = setTimeout(resize, 150);
  });
  resize();
})();
