<%page args="post"/>

<%
   category_links = []
   for category in post.categories:
       if post.draft:
           #For drafts, we don't write to the category dirs, so just write the categories as text
           category_links.append(category.name)
       else:
           category_links.append("<a href='%s'>%s</a>" % (category.path, category.name))
%>

<%
   tag_links = []
   for tag in post.tags:
       if post.draft:
           #For drafts, we don't write to the category dirs, so just write the categories as text
           tag_links.append(tag)
       else:
           tag_links.append("<a href='{0}'>{1}</a>".format(tag.path, tag.name))
%>

<article>
  <div class="blog_post">
    <header>
      <div id="${post.slug}"></div>
      <h2 class="blog_post_title"><a href="${post.permapath()}" rel="bookmark" title="Permanent Link to ${post.title}">${post.title}</a></h2>
      <p><small><span class="blog_post_date">Posted ${post.date.strftime("%B %d, %Y at %I:%M %p")}</span> | categories:
        <span class="blog_post_categories">${", ".join(category_links)}</span> | tags: ${", ".join(tag_links)}
        % if bf.config.blog.disqus.enabled:
        | <a href="${post.permalink}#disqus_thread">View Comments</a>
        % endif
        % if post.date < post.updated:
      <p><small><span class="blog_post_date">Updated ${post.updated.strftime("%B %d, %Y at %I:%M %p")}</span></small>
        % endif
      </small></p>
    </header>
    <div class="post_prose">
      ${self.post_prose(post)}
    </div>
  </div>
</article>

<%def name="post_prose(post)">
${post.content}
</%def>

Discuss on Twitter: <a href="https://twitter.com/share" class="twitter-share-button" data-via="johnkitchin">Tweet</a> <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>
