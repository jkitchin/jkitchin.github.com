<aside>
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
</aside>
