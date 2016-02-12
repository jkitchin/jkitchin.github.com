<%inherit file="site.mako" />
<article class="page_box">
My Publications:
<ol>
% for entry in bibtex_entries:
<li><a href="${entry['ID']}.html">${citation(entry)}</a></li>
% endfor
</ol>
</article>
