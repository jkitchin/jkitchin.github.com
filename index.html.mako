<%inherit file="_templates/site.mako" />
<article class="page_box">
<%self:filter chain="markdown">

Welcome to the Kitchin Group
============================

Our group utilizes data science and machine learning to solve problems in catalysis and engineering. Our current focuses include developing machine learned potentials for molecular simulations, and design of experiments for high-throughput experimentation.

<a href="/blog/category/news/">News</a>
====
<%
nposts = len(bf.config.blog.posts)
posts = []
for post in bf.config.blog.posts:
    if "news" in post.categories:
        posts.append(post)
%>

<ul>
% for post in posts[0:5]:
<%
var = "{0:20s}".format(post.date.strftime("%B %d, %Y"))
%>
     <li>${var}   <a href="${post.path}">${post.title}</a></li>
% endfor
</ul>

Current post (${nposts} and counting)
=====================================

<%
post = bf.config.blog.posts[0]
date = "{0:20s}".format(post.date.strftime("%B %d, %Y"))
excerpt = post.content[0:200] + " ... "
%>
<a href="${post.path}">${post.title}</a>
${date}  ${excerpt}
<a href="${post.path}">click here for more</a>
<br>


</%self:filter>
</article>
