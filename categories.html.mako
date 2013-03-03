<%inherit file="_templates/site.mako" />
<article class="page_box">
<%self:filter chain="markdown">
<table>
<tr>
<td>
<div id="categories">
<h3>Categories</h3>
<ul>
% for category, num_posts in bf.config.blog.all_categories:
<li><a href="${category.path}">${category}</a> (<a href="${category.path}/feed">rss</a>) (${num_posts})</li>
% endfor
</ul>
</div>
</td>



<% all_tags = {}
for post in bf.config.blog.posts:
    for tag in getattr(post,'tags', None):
        if tag in all_tags:
            all_tags[tag] += 1
        else:
            all_tags[tag] = 1
tag_count = [(tag, all_tags[tag]) for tag in all_tags]
%>

<td style="vertical-align:top">
<div id="tags">
<h3>Tags</h3>
Coming soon.
<ul>
% for tag,count in tag_count:
<li>${tag} (${count})</li>
% endfor
</ul>
</div>
</td></tr></table>

</%self:filter>
</article>
