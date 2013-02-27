<aside>
<section>
Search
<form action="http://google.com/search" method="get">
  <fieldset role="search">
    <input type="hidden" name="q" value="site:jkitchin.github.com" />
    <input class="search" type="text" name="q" results="0" placeholder="Search"/>
  </fieldset>
</form>
</section>

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
  <a href="https://github.com/jkitchin">@jkitchin</a> on GitHub.
<ul id="my-github-projects">
    <li class="loading">Status updating&#8230;</li>
  </ul>

</section>
</aside>
