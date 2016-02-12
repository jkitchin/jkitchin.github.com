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

<h1>Publications</h1>
The authors are linked to their Scopus page, the title linked to the Scopus abstract, the journal linked to the Scopus journal page, and the DOI is linked to http://dx.doi.org which normally redirects you to the journal page.

<ol reversed="reversed">
  <%
import sys

reload(sys)
sys.setdefaultencoding('utf8')
from scopus.scopus_xml import get_abstract_info, get_html_citation, get_bibtex

import requests
import json
from scopus.my_scopus import MY_API_KEY
resp = requests.get("http://api.elsevier.com/content/search/scopus?query=AU-ID(7004212771)&field=eid,aggregationType&count=100",
                    headers={'Accept':'application/json',
                             'X-ELS-APIKey': MY_API_KEY})

results = resp.json()

data = [[str(r['eid']), str(r['prism:aggregationType'])] for r in
  results['search-results']["entry"] if str(r['prism:aggregationType']) == 'Journal']

citations = [(eid, get_html_citation(eid).encode('utf-8')) for eid,type in data]

for eid, type in data:
    bibtex = get_bibtex(eid)
    with open('publications/{}.bib'.format(eid), 'w') as f:
        f.write(bibtex)


%>

    % for eid,citation in citations:
        <li>${citation} <a href="publications/${eid}.bib">bibtex</a></li>
    % endfor
</ol>

</article>
