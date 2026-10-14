// Small accessibility fixes to Quarto's page chrome.
(function () {
  // Two <nav> landmarks need distinct names (navbar and the page's TOC).
  var nav = document.querySelector("nav.navbar");
  if (nav && !nav.getAttribute("aria-label")) nav.setAttribute("aria-label", "Site");
  var toc = document.querySelector("nav#TOC");
  if (toc && !toc.getAttribute("aria-label")) toc.setAttribute("aria-label", "On this page");
  // The skip link target must take focus.
  var main = document.getElementById("quarto-document-content");
  if (main && !main.hasAttribute("tabindex")) main.setAttribute("tabindex", "-1");
})();
