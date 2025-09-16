
import requests
import json, os
from my_scopus import MY_API_KEY

def get_abstract_info(EID, refresh=False):
    'Get and save the json data for EID.'
    base = 'scopus-data/get_abstract_info'
    if not os.path.exists(base):
        os.makedirs(base)

    fname = '{0}/{1}'.format(base, EID)
    if os.path.exists(fname) and not refresh:
        with open(fname) as f:
            return json.loads(f.read())

    # Otherwise retrieve and save results
    url = ("http://api.elsevier.com/content/abstract/eid/" + EID)
    resp = requests.get(url,
                    headers={'Accept':'application/json',
                             'X-ELS-APIKey': MY_API_KEY})
    results = json.loads(resp.text.encode('utf-8'))
    with open(fname, 'w') as f:
        f.write(json.dumps(results))

    return results

def get_author_link(EID):
    data = get_abstract_info(EID)
    result = data['abstracts-retrieval-response']
    html = '<a href="http://www.scopus.com/authid/detail.url?origin=AuthorProfile&authorId={0}">{1}</a>'
    authors = [html.format(auid, name) for auid, name in
               zip([x['@auid'] for x in result['authors']['author']],
                   [x['ce:indexed-name'] for x in result['authors']['author']])]

    return ','.join(authors)

def get_journal_link(EID):
    data = get_abstract_info(EID)
    result = data['abstracts-retrieval-response']
    sid = result['coredata']['source-id']
    journal = result['coredata']['prism:publicationName']
    s = '<a href="http://www.scopus.com/source/sourceInfo.url?sourceId={sid}">{journal}</a>'

    return s.format(sid=sid, journal=journal)

def get_doi_link(EID):
    data = get_abstract_info(EID)
    result = data['abstracts-retrieval-response']
    s = '<a href="https://doi.org/{doi}">doi:{doi}</a>'
    return s.format(doi=result['coredata']['prism:doi'])

def get_cite_img_link(EID):
    data = get_abstract_info(EID)
    result = data['abstracts-retrieval-response']
    s = '<img src="http://api.elsevier.com/content/abstract/citation-count?doi={doi}&httpAccept=image/jpeg&apiKey={apikey}"></img>'
    return s.format(doi=result['coredata']['prism:doi'].strip(), apikey=MY_API_KEY)

def get_abstract_link(EID):
    data = get_abstract_info(EID)
    result = data['abstracts-retrieval-response']
    title = result['coredata']['dc:title']
    for ref in result['coredata']['link']:
        if ref['@rel'] == 'scopus':
            link = ref['@href'].replace('&amp;', '&')

    s = '<a href="{link}">{title}</a>'
    return s.format(link=link, title=title)

def get_html(EID):
    data = get_abstract_info(EID)
    result = data['abstracts-retrieval-response']

    s = '<li>{authors}, <i>{title}</i>, {journal}, <b>{volume}{issue}</b>, p. {pages}, ({year}), {doi}, {cites}.</li>'

    issue = ''
    if result['coredata'].get('prism:issue'):
        issue = '({})'.format(result['coredata'].get('prism:issue'))
    return s.format(authors=get_author_link(EID),
                    title=get_abstract_link(EID),
                    journal=get_journal_link(EID),
                    volume=result['coredata'].get('prism:volume'),
                    issue=issue,
                    pages=result['coredata'].get('prism:pageRange'),
                    year=result['coredata'].get('prism:coverDate'),
                    doi=get_doi_link(EID),
                    cites=get_cite_img_link(EID))
