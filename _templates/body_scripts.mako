  <script src="//ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js"></script>
  <script>!window.jQuery && document.write(unescape('%3Cscript src="/js/libs/jquery-1.5.1.min.js"%3E%3C/script%3E'))</script>
  <script src="${bf.util.site_path_helper('js/plugins.js')}"></script>
  <script src="${bf.util.site_path_helper('js/script.js')}"></script>
  <script src="${bf.util.site_path_helper('js/jquery.tweet.js')}"></script>  
  <script src="${bf.util.site_path_helper('js/site.js')}"></script>
  <!--[if lt IE 7 ]>
  <script src="js/libs/dd_belatedpng.js"></script>
  <script> DD_belatedPNG.fix('img, .png_bg');</script>
  <![endif]-->
 
<!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-PH8NF4F0RE"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'G-PH8NF4F0RE');
</script>

  % if bf.config.blog.disqus.enabled:
  <script>
  (function() {
      var links = document.getElementsByTagName('a');
      var query = '?';
      for(var i = 0; i < links.length; i++) {
          if(links[i].href.indexOf('#disqus_thread') >= 0) {
              query += 'url' + i + '=' + encodeURIComponent(links[i].href) + '&';
          }
      }
      document.write('<script charset="utf-8" type="text/javascript" src="http://disqus.com/forums/${bf.config.blog.disqus.name}/get_num_replies.js' + query + '"></' + 'script>');
  })();
  </script>
  % endif
