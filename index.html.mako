<%inherit file="_templates/site.mako" />
<article class="page_box">
<%self:filter chain="markdown">

Welcome to the Kitchin Group Research
=====================================

Our group utilizes chemistry, catalysis and engineering to develop solutions to energy and environment related problems such as CO<sub>2</sub> capture and chemical energy storage. We use experimental and computational methods in electrochemistry, sorbent development and electrocatalyst design.

News
====

<ul>
% for post in bf.config.blog.posts:
  % if "news" in post.categories:
     <li>${post.date.strftime("%B %d, %Y")}<a href="${post.path}">${post.title}</a></li>
  % endif
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
