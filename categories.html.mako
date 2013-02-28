<%inherit file="_templates/site.mako" />
<article class="page_box">
<%self:filter chain="markdown">

 <div id="categories">
<h3>Categories</h3>
<ul>
% for category, num_posts in bf.config.blog.all_categories:
<li><a href="${category.path}">${category}</a> (<a href="${category.path}/feed">rss</a>) (${num_posts})</li>
% endfor
</ul>
</div>

</%self:filter>
</article>
