% if post is not UNDEFINED:
<title>${post.title}</title>
% elif category is not UNDEFINED:
<title>${bf.config.blog.name}: ${category}</title>
% else:
<title>${bf.config.blog.name}</title>
% endif
  <meta name="google-site-verification" content="CGcacJdHc2YoZyI0Vey9XRA5qwhhFDzThKJezbRFcJ4" />
  <meta name="description" content="${bf.config.blog.description}">
%if bf.config.site.author:
  <meta name="author" content="${bf.config.site.author}">
%endif
  <link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="${bf.util.site_path_helper(bf.config.blog.path,'/feed')}" />
  <link rel="alternate" type="application/atom+xml" title="Atom 1.0" href="${bf.util.site_path_helper(bf.config.blog.path,'/feed/atom')}" />
  <link rel="shortcut icon" href="${bf.util.site_path_helper('favicon.ico')}">
  <link rel="apple-touch-icon" href="${bf.util.site_path_helper('img/apple-touch-icon.png')}">

  <link rel="stylesheet" href="${bf.util.site_path_helper('css/base.css?v=1')}">
  <link rel="stylesheet" href="${bf.util.site_path_helper('css/grid.css?v=1')}">
  <link rel="stylesheet" media="handheld" href="${bf.util.site_path_helper('/css/handheld.css?v=1')}">
  <link rel="stylesheet" href="${bf.util.site_path_helper(bf.config.filters.syntax_highlight.css_dir,'/pygments_'+bf.config.filters.syntax_highlight.style+'.css')}" type="text/css" />

  <script src="${bf.util.site_path_helper('js/libs/modernizr-1.7.min.js')}"></script>
<script type="text/x-mathjax-config">
    MathJax.Hub.Config({
        displayAlign: "center",
        displayIndent: "0em",

        "HTML-CSS": { scale: 100,
                        linebreaks: { automatic: "false" },
                        webFont: "TeX"
                       },
        SVG: {scale: 100,
              linebreaks: { automatic: "false" },
              font: "TeX"},
        NativeMML: {scale: 100},
        TeX: { equationNumbers: {autoNumber: "AMS"},
               MultLineWidth: "85%",
               TagSide: "right",
               TagIndent: ".8em"
             }
});
</script>
<script type="text/javascript"
        src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config=TeX-AMS_HTML"></script>
  <%include file="theme.mako"/>
