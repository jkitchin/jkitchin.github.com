
import requests
import os
import xml.etree.ElementTree as ET

from my_scopus import MY_API_KEY

def get_abstract_info(EID, refresh=False):
    'Get and save the json data for EID.'
    base = 'scopus-xml/get_abstract_info'
    if not os.path.exists(base):
        os.makedirs(base)

    fname = '{0}/{1}'.format(base, EID)
    if os.path.exists(fname) and not refresh:
        with open(fname) as f:
            return ET.fromstring(f.read())

    # Otherwise retrieve and save results
    url = ("http://api.elsevier.com/content/abstract/eid/" + EID + '?view=META_ABS')
    resp = requests.get(url,
                    headers={'Accept':'application/xml',
                             'X-ELS-APIKey': MY_API_KEY})
    with open(fname, 'w') as f:
        f.write(resp.text.encode('utf-8'))

    results = ET.fromstring(resp.text.encode('utf-8'))

    return results

def get_author_link(EID):
    results = get_abstract_info(EID)
    authors = results.find('./{http://www.elsevier.com/xml/svapi/abstract/dtd}authors')
    if authors is None:
        return 'No authors found'
    s = []

    for author in authors:
        name = author.find('{http://www.elsevier.com/xml/ani/common}indexed-name').text
        auid = author.attrib['auid']
        s += ['<a href="http://www.scopus.com/authid/detail.url?origin=AuthorProfile&authorId={0}">{1}</a>'.format(auid, name)]

    return ', '.join(s)

def get_journal_link(EID):
    results = get_abstract_info(EID)
    coredata = results.find('./{http://www.elsevier.com/xml/svapi/abstract/dtd}coredata')

    journal = coredata.find('{http://prismstandard.org/namespaces/basic/2.0/}publicationName').text
    sid = coredata.find('{http://www.elsevier.com/xml/svapi/abstract/dtd}source-id').text
    s = '<a href="http://www.scopus.com/source/sourceInfo.url?sourceId={sid}">{journal}</a>'

    return s.format(sid=sid, journal=journal)

def get_doi_link(EID):
    results = get_abstract_info(EID)
    coredata = results.find('./{http://www.elsevier.com/xml/svapi/abstract/dtd}coredata')
    doi = coredata.find('{http://prismstandard.org/namespaces/basic/2.0/}doi')
    if doi is not None: doi = doi.text
    s = '<a href="https://doi.org/{doi}">doi:{doi}</a>'
    return s.format(doi=doi)

def get_abstract_link(EID):
    results = get_abstract_info(EID)
    coredata = results.find('./{http://www.elsevier.com/xml/svapi/abstract/dtd}coredata')

    data = get_abstract_info(EID)

    title = coredata.find('{http://purl.org/dc/elements/1.1/}title').text.encode('utf-8')
    link = coredata.find("./{http://www.elsevier.com/xml/svapi/abstract/dtd}link/[@rel='scopus']").attrib['href'].encode('utf-8')
    s = '<a href="{link}">{title}</a>'
    return s.format(link=link, title=title)

def get_cite_img_link(EID):
    results = get_abstract_info(EID)
    coredata = results.find('./{http://www.elsevier.com/xml/svapi/abstract/dtd}coredata')
    doi = coredata.find('{http://prismstandard.org/namespaces/basic/2.0/}doi')
    if doi is not None: doi = doi.text
    s = '<img src="http://api.elsevier.com/content/abstract/citation-count?doi={doi}&httpAccept=image/jpeg&apiKey={apikey}"></img>'

    return s.format(doi=doi, apikey=MY_API_KEY, cite_link=None)

def get_html_citation(EID):
    results = get_abstract_info(EID)
    coredata = results.find('./{http://www.elsevier.com/xml/svapi/abstract/dtd}coredata')
    s = '{authors}, <i>{title}</i>, {journal}, <b>{volume}{issue}</b>, {pages}, ({year}), {doi}, {cites}.'

    issue = ''
    if coredata.find('{http://prismstandard.org/namespaces/basic/2.0/}issueIdentifier') is not None:
        issue = '({})'.format(    coredata.find('{http://prismstandard.org/namespaces/basic/2.0/}issueIdentifier').text)

    volume = coredata.find('{http://prismstandard.org/namespaces/basic/2.0/}volume')
    if volume is not None:
        volume = coredata.find('{http://prismstandard.org/namespaces/basic/2.0/}volume').text
    else:
        volume = 'None'

    pages = ''
    if coredata.find('{http://prismstandard.org/namespaces/basic/2.0/}pageRange') is not None:
        pages = 'p. ' + coredata.find('{http://prismstandard.org/namespaces/basic/2.0/}pageRange').text
    elif coredata.find('{http://www.elsevier.com/xml/svapi/abstract/dtd}article-number') is not None:
        pages = coredata.find('{http://www.elsevier.com/xml/svapi/abstract/dtd}article-number').text
    else:
        pages = 'no pages found'


    year = coredata.find('{http://prismstandard.org/namespaces/basic/2.0/}coverDate').text

    return s.format(authors=get_author_link(EID),
                    title=get_abstract_link(EID),
                    journal=get_journal_link(EID),
                    volume=volume,
                    issue=issue,
                    pages=pages,
                    year=year,
                    doi=get_doi_link(EID),
                    cites=get_cite_img_link(EID))
