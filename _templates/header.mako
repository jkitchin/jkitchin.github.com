<header>
<div id="header" class="header_gradient theme_font">
<table><tr><td>
    <h1><a href="${bf.util.site_path_helper()}">${bf.config.blog.name}</a></h1>
    <h2>${bf.config.blog.description}</h2>
</td>
<td colspan=100%><div style="float:right;width:100%;text-align:right;"> <span id='badgeCont737515' style='width:126px'><script src='http://labs.researcherid.com/mashlets?el=badgeCont737515&mashlet=badge&showTitle=false&className=a&rid=A-2363-2010'></script></span></div>
</td></tr>
</table>
</div>
  <div id="navigation" class="grid_12">
<%
def nav_class(path):
   # this is a hack to build publications/index.html
   if isinstance(bf.template_context.render_path, tuple):
       return ""
   render_path = bf.template_context.render_path.rsplit("/index.html")[0]
   if render_path == path or (path == "/" and render_path == "."):
       return "selected"
   return ""
%>
    <ul class="theme_font">
      <li><a href="${bf.util.site_path_helper(bf.config.blog.path)}"
             class="${nav_class(bf.util.site_path_helper(bf.config.blog.path))}">Blog</a></li>

      <li><a href="${bf.util.site_path_helper(bf.config.blog.path,'archive')}"
             class="${nav_class(bf.util.site_path_helper(bf.config.blog.path,'archive'))}">Archives</a></li>

      <li><a href="${bf.util.site_path_helper('/publications/index.html')}">Publications</a></li>

      <li><a href="${bf.util.site_path_helper('research.html')}"
             class="${nav_class(bf.util.site_path_helper('research.html'))}">Research</a></li>

      <li><a href="${bf.util.site_path_helper('categories.html')}"
             class="${nav_class(bf.util.site_path_helper('categories.html'))}">Categories</a></li>

      <li><a href="${bf.util.site_path_helper('about.html')}"
             class="${nav_class(bf.util.site_path_helper('about.html'))}">About us</a></li>

      <li><a href="${bf.util.site_path_helper('subscribe.html')}">Subscribe</a></li>

    </ul>
  </div>
</header>
