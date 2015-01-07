
# -*- coding: utf-8 -*-
"""
Created on Wed Aug 27 10:12:00 2014

@author: mathiasstrupler
"""


import sys
import re
import datetime 

#try:
#    import urllib2
#except ImportError:
#    print('We need urllib2, sorry...')
#    sys.exit(1)

try:    
    from suds.client import Client
except ImportError:
    print('We need suds.client, sorry...')
    sys.exit(1)   
    
try:
    import xml.etree.ElementTree as ET
except ImportError:
    print('We need xml.etree.ElementTree, sorry...')
    sys.exit(1)  

class Error(Exception):
    """Base class for any wok3 error."""
    
class SearchQueryError(Error):
    """You need to set a user query"""

class Edition(object):    
    """
    This class is only used to let you know easily all the databases 
    that can be searched in World of sciences
    example : wokSearch.setEdition(Edition.SCI)
    """    
    SCI   = {'collection' : 'WOS', 'edition' : 'SCI'}    #Science Citation Index Expanded
    SSCI  = {'collection' : 'WOS', 'edition' : 'SSCI'}   #Social Sciences Citation Index
    AHCI  = {'collection' : 'WOS', 'edition' : 'AHCI'}   #Arts & Humanities Citation Index
    ISTP  = {'collection' : 'WOS', 'edition' : 'ISTP'}   #Conference Proceedings Citation Index - Science
    ISSHP = {'collection' : 'WOS', 'edition' : 'ISSHP'}  #Conference Proceedings Citation Index - Social Sciences
    IC    = {'collection' : 'WOS', 'edition' : 'IC'}     #Index Chemicus
    CCR   = {'collection' : 'WOS', 'edition' : 'CCR'}    #Current Chemical Reactions
    BSCI  = {'collection' : 'WOS', 'edition' : 'BSCI'}   #Book Citation Index - Science
    BHCI  = {'collection' : 'WOS', 'edition' : 'BHCI'}   #Book Citation Index - Social Sciences and Humanities
 
        
class SearchRespAnalyzer(object): 
    """
    This class is used to parse the soap answer received 
    after a search request
    """    
    def __init__(self,searchResp):
        self._searchResp = searchResp
    
    def toDict(self):
        """
        This method parse the answer into a dictonnary
        It does not retreive all the information that gives WOS 
        It looks for the following info:
            UID : WOS identifier
            title : Title of the document
            journal : Name of the journal 
            year : Year of publication
            volume : Volume
            issue : Issue
            page : page [begin, end]
            authors : list of author dict {name, dais_id, affiliations list}
            language : primary language of the document
            docType : document type (article, review, book,...)
            publisher : name of the publisher
        """  
        
        ans = {'records' : [] }
        records = re.sub(' xmlns="http://scientific.thomsonreuters.com/schema/wok5.4/public/FullRecord"', '', self._searchResp.records, count=1)
        #records = re.sub(' r_id_disclaimer="ResearcherID data provided by Thomson Reuters"', '', resp.records, count=resp.recordsFound)
        recordsTree = ET.fromstring( records)
        for rec in recordsTree.iter('REC'):
            #retreive UID
            record = {'UID' : rec.find('UID').text}
            #retreive title and journal name
            record['title'] = None
            record['journal'] = None
            for title in rec.findall('static_data/summary/titles/title'):
                if title.attrib['type'] == 'item':
                    record['title'] = title.text
                if title.attrib['type'] == 'source':
                    record['journal'] = title.text
            #retreive publication information 
            pubinfo = rec.find('static_data/summary/pub_info').attrib
            record['year'] = pubinfo['pubyear']
            record['volume'] = pubinfo['vol']
            if 'issue' in  pubinfo:
                record['issue'] = pubinfo['issue']
            else:
                record['issue'] = ''
            page = rec.find('static_data/summary/pub_info/page').attrib
            if 'begin' in  page:
                record['page'] = [page['begin'],page['end']]
            else:
                record['page'] = []
            #retreive author list 
            record['authors'] = []
            for name in rec.findall('static_data/summary/names/name'):
                if name.attrib['role']=='author':
                    author = {'name' : ''}
                    if name.find('wos_standard') is not None:
                        author['name'] = name.find('wos_standard').text
                    elif name.find('display_name') is not None:
                        author['name'] = name.find('display_name').text
                    elif name.find('full_name') is not None:
                        author['name'] = name.find('full_name').text
                    if 'dais_id' in name.attrib:
                        author['dais_id'] = name.attrib['dais_id'] 
                    author['affiliation']=[]
                    record['authors'].append(author)
            #retrieve publication language
            record['language'] = None
            for language in rec.findall('static_data/fullrecord_metadata/languages/language'):    
                if language.attrib['type']=='primary':
                    record['language'] = language.text
            #retrieve adressess
            affiliations = []
            for adresses in rec.findall('static_data/fullrecord_metadata/addresses/address_name'):
                affiliations.append({'nb' : adresses.find('address_spec').attrib['addr_no'],'add' : adresses.find('address_spec/full_address').text})
            record['affiliations'] = affiliations
            if len(affiliations)==1:
                for author in record['authors']:
                    author['affiliation']=[affiliations[0]['add']]
            if len(affiliations)>=1:
                aff_names = rec.findall('static_data/fullrecord_metadata/addresses/address_name/names/name')
                aff_names_list = []                
                for aff_name in aff_names:
                    tmp = {'nb' : aff_name.attrib['addr_no'], 'name' : aff_name.find('wos_standard').text}
                    aff_names_list.append(tmp)    
                for author in record['authors']:
                    for name in aff_names_list:
                        if author['name'] == name['name']:                            
                            author['affiliation'].append(name['nb'])
                                    
            #retrieve doctype
            record['docType'] = []
            for docType in rec.findall('static_data/fullrecord_metadata/normalized_doctypes/doctype'):
                record['docType'].append(docType.text)  
            #retrieve publisher
            record['publisher'] = rec.find('static_data/summary/publishers/publisher/names/name/full_name').text
            
            #append record to answer
            ans['records'].append(record)
        return ans

    def saveAsJSON(self,directory):
        """
        This method save as a JSON file 
        the dictionnary produced by the toDict() method
        """   
        try:
            import json
        except ImportError:
            print('We need JSON, sorry...')
            sys.exit(1)  
        
        searchRespDict = self.toDict()
        with open(directory, 'wb') as fp:
            json.dump(searchRespDict , fp, sort_keys=True, indent=4, separators=(',', ': '))
            
    def saveRawAsXML(self,directory):
        """
        This method save as a XML file the raw records 
        returned by the WOS search
        It only adds identations to make it more pretty
        """  
        from xml.dom import minidom
        records = re.sub(' xmlns="http://scientific.thomsonreuters.com/schema/wok5.4/public/FullRecord"', '', self._searchResp.records, count=1)
        #records = re.sub(' r_id_disclaimer="ResearcherID data provided by Thomson Reuters"', '', resp.records, count=resp.recordsFound)
        recordsTree = ET.fromstring( records)
        rough_string = ET.tostring(recordsTree, 'utf-8')
        reparsed = minidom.parseString(rough_string)
        with open(directory, 'wb') as fp:
            reparsed.writexml(fp, indent="", addindent="\t", newl="\n")
    
    def saveAsBibtex(self,directory):
        """
        This method save as a bibtex files all the records
        It should be rewritten better handle different document types 
        """  
        searchRespDict = self.toDict()
        with open(directory, 'w') as fp:
            for rec in searchRespDict['records']:
                if rec['docType'][0]=='Article' or rec['docType'][0]=='Review' or rec['docType'][0]=='Letter':
                    bibtexentry = '@article{'
                elif rec['docType'][0]=='Proceedings Paper' or rec['docType'][0]=='Meeting':
                    bibtexentry = '@proceedings{'
                elif rec['docType'][0]=='Book':
                    bibtexentry = '@book{'
                elif rec['docType'][0]=='Book Chapter':
                    bibtexentry = '@inbook{'
                else:
                    bibtexentry = '@misc{'
                bibtexentry = bibtexentry + rec['UID'] + ',\n' 
                bibtexentry = bibtexentry + '  title={' + rec['title'] + '},\n'
                
                authors = ''
                authorlist = rec['authors']
                firstauthor = authorlist.pop(0)
                authors = firstauthor['name']
                for author in authorlist:
                    authors = authors + ' and ' + author['name']
                    
                bibtexentry = bibtexentry + '  author={' + authors + '},\n'
                bibtexentry = bibtexentry + '  journal={' + rec['journal'] + '},\n'
                if not(rec['volume']==''):
                    bibtexentry = bibtexentry + '  volume={' + rec['volume'] + '},\n'
                if not(rec['issue']==''):
                    bibtexentry = bibtexentry + '  number={' + rec['issue'] + '},\n'
                if rec['page']:
                    bibtexentry = bibtexentry + '  pages={'  + rec['page'][0] + '--' + rec['page'][1] + '},\n'
                if not(rec['year']==''):
                    bibtexentry = bibtexentry + '  year={' + rec['year'] + '},\n'
                if not(rec['publisher']==''):
                    bibtexentry = bibtexentry + '  publisher={' + rec['publisher'] + '},\n'
                bibtexentry = bibtexentry  + '}\n'
                fp.write(bibtexentry)
            
        
        
   

class WokSearch(object):
    """
    This class is used 
        - to define the query parameters of a WOK search 
        - open a session on WOK 
        - send requests
        - close the session
    
    """
    AUTH_URL = 'http://search.webofknowledge.com/esti/wokmws/ws/WOKMWSAuthenticate?wsdl'
    SEARCH_URL = 'http://search.webofknowledge.com/esti/wokmws/ws/WokSearch?wsdl'
    def __init__(self):
        #initialization
        self._queryLanguage = 'en'
        self._databaseId = 'WOS'
        self._timeSpanStart = None
        self._timeSpanEnd = None
        self._edition = None
        self._query = None
        self._resultsRetrieved = 0
        self._resultsPerRequest = 100
    
    def setQuery(self, query):
        self._query = query
        
    def setEdition(self, edition):
        self._edition = edition
    
    def setTimeSpanStart(self, date):
        self._timeSpanStart = date
        
    def setTimeSpanEnd(self, date):
        self._timeSpanEnd = date
        
    def clearEdition(self):
        self._edition = None
    
    def clearSpanTime(self):
        self._timeSpanStart = None
        self._timeSpanEnd = None
        
    def queryToSOAP(self):
        if self._query is not None:
            soap =  {'databaseId' : self._databaseId, 'userQuery' : self._query, 'queryLanguage': self._queryLanguage}
            if self._edition is not None:
                soap['editions'] = self._edition
            soaptime = {}
            if self._timeSpanStart is not None:
                soaptime['begin'] = self._timeSpanStart.isoformat()
            if self._timeSpanEnd is not None:
                soaptime['end'] = self._timeSpanEnd.isoformat()
            if soaptime :    
                soap['timeSpan'] = soaptime     
            return soap
        else:
            raise SearchQueryError
    
    def retrieveParamToSOAP(self):
        soap = {'firstRecord' : self._resultsRetrieved+1, 'count' : self._resultsPerRequest}
        return soap
        
    def openSOAPsession(self):
        self._authClient = Client(self.AUTH_URL)
        self._sid = self._authClient.service.authenticate()
        headers = { 'Cookie': 'SID='+self._sid}
        self._authClient.set_options(soapheaders=headers)
        self._searchClient = Client(self.SEARCH_URL, headers= { 'Cookie': 'SID='+self._sid})
    
    def closeSOAPsession(self):
        self._authClient.service.closeSession()
        
    def sendSearchRequest(self):
        resp = self._searchClient.factory.create('searchResponse')
        resp = self._searchClient.service.search(self.queryToSOAP(),self.retrieveParamToSOAP())
        return resp        
        
            
        
def main():
    wokSearch = WokSearch()
    
    wokSearch.setQuery('TS = Optical Coherence Tomography')
   
    #wokSearch.setEdition(Edition.SCI)
    wokSearch.setTimeSpanEnd(datetime.date(2014,01,01))
    wokSearch.setTimeSpanStart(datetime.date(2003,01,01))
    print wokSearch.queryToSOAP()
    print wokSearch.retrieveParamToSOAP()
    
    wokSearch.openSOAPsession()
    resp = wokSearch.sendSearchRequest()
    aResp = SearchRespAnalyzer(resp)
    aResp.saveRawAsXML('/Users/mathiasstrupler/WOS3/OCT2003_2010.xml')
    aResp.saveAsJSON('/Users/mathiasstrupler/WOS3/OCT2003_2010.JSON')
    aResp.saveAsBibtex('/Users/mathiasstrupler/WOS3/OCT2003_2010.bib')
    wokSearch.closeSOAPsession()
    
if __name__ == "__main__":
    sys.exit(main())    
    
