<aside>
<section>
Search
<form action="http://google.com/search" method="get">
  <fieldset role="search">
    <input type="hidden" name="q" value="site:jkitchin.github.com" />
    <input class="search" type="text" name="q" results="0" placeholder="Search"/>
  </fieldset>
</form>
<section><h1 class="post_header_gradient theme_font">Links</h1>
  <ul>
    <li><a href="/blog/category">Categories</a></li>
    <li><a href="/blog/feed/atom/index.xml">Atom feed</a></li>
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
  <ul id="gh_repos">
    <li class="loading">Status updating&#8230;</li>
  </ul>
  
  <a href="https://github.com/jkitchin">@jkitchin</a> on GitHub
  
  <script type="text/javascript">
    $.domReady(function(){
        if (!window.jXHR){
            var jxhr = document.createElement('script');
            jxhr.type = 'text/javascript';
            jxhr.src = '/js/libs/jXHR.js';
            var s = document.getElementsByTagName('script')[0];
            s.parentNode.insertBefore(jxhr, s);
        }

        github.showRepos({
            user: 'jkitchin',
            count: 8,
            skip_forks: true,
            target: '#gh_repos'
        });
    });
  </script>
  <script src="/js/github.js" type="text/javascript"> </script>
</section>
</aside>
