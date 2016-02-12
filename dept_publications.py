from scopus.scopus_xml import *
from scopus.my_scopus import MY_API_KEY
from scopus.scopus_search import ScopusSearch
from scopus.scopus_api import ScopusAbstract

for YEAR in ['2005',
             '2006',
             '2007',
             '2008',
             '2009',
             '2010',
             '2011',
             '2012',
             '2013',
             '2014',
             '2015']:

    ss = ScopusSearch('(affil(carnegie mellon university and chemical engineering)'
                      ' or au-id(7004596535)) AND pubyear is {}'.format(YEAR))

    with open('dept-publications-{}.html.mako'.format(YEAR), 'w') as f:
        f.write('''<%inherit file="_templates/site.mako" />
<article class="page_box">
<%self:filter chain="markdown">

<script type='text/javascript' src='https://d1bxh8uas1mnw7.cloudfront.net/assets/embed.js'></script>

<h1>Chemical Engineering publications for {year}</h1>

    This bibliography is generated from a Scopus search.

The authors are linked to their Scopus page, the title linked to the Scopus abstract, the journal linked to the Scopus journal page, and the DOI is linked to http://dx.doi.org which normally redirects you to the journal page.

<ol reversed="reversed">
    '''.format(year=YEAR))

        for eid in ss.EIDS:
            ab = ScopusAbstract(eid)
            if ab.aggregationType != 'Journal':
                continue
            html = ab.html
            if ab.doi is not None:
                html += '''<div class='altmetric-embed' data-badge-type='donut' data-doi="{}"></div>'''.format(ab.doi)
                html += get_cite_img_link(eid)
                f.write('<li>{}</li>'.format(html))
        f.write('''</ol>

</%self:filter>
</article>
''')
