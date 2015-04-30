<%inherit file="_templates/site.mako" />
<article class="page_box">
<%self:filter chain="markdown">

Welcome to the Kitchin Group Research
=====================================

Our group utilizes chemistry, catalysis and engineering to develop solutions to energy and environment related problems such as CO<sub>2</sub> capture and chemical energy storage. We use experimental and computational methods in electrochemistry, sorbent development and electrocatalyst design.

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



Department publications
========================

<script src="http://syndic8.scopus.com/getMessage?registrationId=HAGDHBGEOCGMJAGIJAHIHEJDHJGGLIMGIIIKOHGJKD"></script>



</%self:filter>
</article>
