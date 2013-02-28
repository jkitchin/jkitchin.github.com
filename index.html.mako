<%inherit file="_templates/site.mako" />
<article class="page_box">
<%self:filter chain="markdown">

Welcome to the Kitchin Group Research
=====================================

Our group utilizes chemistry, catalysis and engineering to develop solutions to energy and environment related problems such as CO<sub>2</sub> capture and chemical energy storage. We use experimental and computational methods in electrochemistry, sorbent development and electrocatalyst design.

News
====
<%
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

We gratefully acknowledge funding from:

-  NETL-RUA
-  DOE-BES 	
-  Siemens
-  IFYRE/SURF
-  CMU
-  Berkman Foundation
-  CMU REU/PREM


</%self:filter>
</article>
