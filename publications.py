# These seem to be my publications.

from scopus.scopus_xml import *

from scopus.utils import load_api_key
MY_API_KEY = load_api_key()


import requests
import json, sys

resp = requests.get("http://api.elsevier.com/content/search/scopus?query=AU-ID(7004212771)&field=eid,aggregationType&count=100",
                    headers={'Accept':'application/json',
                             'X-ELS-APIKey': MY_API_KEY})

results = resp.json()

data = [r['eid'] for r in
        results['search-results']["entry"] if str(r['prism:aggregationType']) == 'Journal']


with open('publications.html.mako', 'w') as f:
    f.write('''<%inherit file="_templates/site.mako" />
<article class="page_box">
<%self:filter chain="markdown">

<script type='text/javascript' src='https://d1bxh8uas1mnw7.cloudfront.net/assets/embed.js'></script>

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

<h1>Publications</h1>
The authors are linked to their Scopus page, the title linked to the Scopus abstract, the journal linked to the Scopus journal page, and the DOI is linked to http://dx.doi.org which normally redirects you to the journal page.

<ol reversed="reversed">
''')

    for eid in data:
        try:
            f.write('<li>{}</li>'.format(get_html_citation(eid)))
        except:
            print('Error in {}: {}'.format(eid, sys.exc_info()))
    f.write('''</ol>

</%self:filter>
</article>
''')
