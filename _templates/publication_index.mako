<%inherit file="_templates/site.mako" />
<article class="page_box">

<h1>Online collections of our work</h1>
Pick your favorite:
<ul>
<li><a href="http://orcid.org/0000-0003-2625-9232">orcid:0000-0003-2625-9232</a></li>

<li><a href="http://www.researcherid.com/rid/A-2363-2010">researcherid:A-2363-2010</a></li>

<li><a href="http://www.scopus.com/authid/detail.url?origin=AuthorProfile&authorId=7004212771">scopusid:7004212771</a></li>

<li><a href="https://scholar.google.com/citations?user=jD_4h7sAAAAJ">Google Scholar</a></li>

<li><a href="https://www.researchgate.net/profile/John_Kitchin">Research Gate</a></li>

<li><a href="https://www.growkudos.com/profiles/40205">Kudos</a></li>
</ul>


My Publications:
<ol>
% for entry in bibtex_entries:
<li><a href="${entry['ID']}.html">${citation(entry)}</a></li>
% endfor
</ol>
</article>
