<aside>
<section>
<script>
  (function() {
    var cx = '002533177287215655227:l7uvu35ssbc';
    var gcse = document.createElement('script');
    gcse.type = 'text/javascript';
    gcse.async = true;
    gcse.src = (document.location.protocol == 'https:' ? 'https:' : 'http:') +
        '//www.google.com/cse/cse.js?cx=' + cx;
    var s = document.getElementsByTagName('script')[0];
    s.parentNode.insertBefore(gcse, s);
  })();
</script>
<gcse:search></gcse:search>
</section>

<section>
    <h1 class="post_header_gradient theme_font">Twitter</h1>
    <a class="twitter-timeline" href="https://twitter.com/johnkitchin" data-widget-id="545217643582881792">Tweets by @johnkitchin</a> <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+"://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>
</section>


  <section>
    <h1 class="post_header_gradient theme_font">Links</h1>
    <ul>
      <li><a href="https://www.continuum.io">Anaconda Python</a></li>
      <li><a href="/pycse">Pycse</a></li>
      <li><a href="/dft-book">DFT-book</a></li>
    </ul>
  </section>

  <section>
    <h1 class="post_header_gradient theme_font">Latest Posts</h1>
    <ul>
      % for post in bf.config.blog.iter_posts_published(5):
      <li><a href="${post.path}">${post.title}</a></li>
      % endfor
    </ul>
  </section>

<section>
<h1 class="post_header_gradient theme_font">Latest GitHub Repos</h1>
  <a href="https://github.com/jkitchin">@jkitchin</a> on GitHub.
  <ul id="my-github-projects">
        <li class="loading">Status updating&#8230;</li>
  </ul>

</section>
</aside>
