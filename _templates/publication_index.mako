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

<script src="http://syndic8.scopus.com/getMessage?registrationId=EGADEHAELIAMGGAIGGBIEKDDGGCGGLFJMPEJKKGDHL"></script>

<br>
Our Publications:
<ol>
% for entry in bibtex_entries:
<li><a href="${entry['ID']}.html">${citation(entry)}</a> <a href="${entry['ID']}.bib">BIBTEX</a>
% if entry.get('doi', None) is not None:
<img src="http://api.elsevier.com/content/abstract/citation-count?doi=${entry['doi']}&httpAccept=image/jpeg&apiKey=${apikey}"></img>
<div data-badge-popover="right" data-badge-type="medium-donut" data-doi="${entry['doi']}" data-hide-no-mentions="true" class="altmetric-embed"></div>
% endif
</li>
% endfor
</ol>
</article>
