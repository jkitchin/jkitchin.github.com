# Generate web pages for the publications in a bibtex file.
import sys
import os
from blogofile.cache import bf
from bibtexparser.bparser import BibTexParser

reload(sys)
sys.setdefaultencoding('utf8')

config = {"name": "Publication gallery",
          "description": "Generates html pages from bibtex entries."}

publications_dir = os.path.join("publications")


def normalize_author(name):
    'convert name to lastname, initials. Neglects von names, and jr.'
    if ',' in name:
        # last, first
        fields = name.split(',')
        return '{0}, {1}'.format(fields[0],
                                 ' '.join([x[0] + '.'
                                           for x in fields[1].split()]))
    else:
        # first last
        fields = name.split()
        return '{0}, {1}'.format(fields[-1],
                                 ' '.join(x[0] + '.'
                                          for x in fields[0:-1]))


def author_string(entry):
    'return formatted author string'
    authors = entry['author'].split(' and ')
    if len(authors) == 1:
        return authors[0]
    elif len(authors) == 2:
        return '{0} and {1}'.format(*authors)
    else:
        return ', '.join([normalize_author(name) for name
                          in authors[0:-1]]) + ' and {}'.format(authors[-1])


def citation(entry):
    '''Generate a simple html citation.'''
    if entry['ENTRYTYPE'] == 'article':
        s = ''
        s += author_string(entry) + ', '
        s += "<i>{}</i>, ".format(entry.get('title', 'no title'))
        s += entry.get('journal', 'no journal') + ', '
        vol = entry.get('volume', 'no vol')
        iss = entry.get('number', 'no num')
        if vol != 'no vol' and iss != 'no num':
            s += '<b>{0}</b>({1}), '.format(vol, iss)
        else:
            s += '<b>{}</b>, '.format(vol)
        s += '{0}, ({1}).'.format(entry.get('pages', None),
                                  entry.get('year', None))
        doi = entry.get('doi', None)
        if doi:
            s += ' <a href="http://dx.doi.org/{}">doi</a>.'.format(doi)

    elif entry['ENTRYTYPE'] == 'inbook':
        s = ''
        s += author_string(entry) + ', '
        s += "{}, ".format(entry.get('chapter', None))
        s1 = 'in {0}, {1} ({2}). http://dx.doi.org/{3}'
        s += s1.format(entry['title'],
                       entry['publisher'],
                       entry['year'],
                       entry['doi'])
    elif entry['ENTRYTYPE'] == 'mastersthesis':
        print entry
        s = '''{0}, {1}, {2} ({3}). Masters thesis.'''.format(entry['author'],
                                                              entry['title'],
                                                              entry['school'],
                                                              entry.get('year',
                                                                        None))

    elif entry['ENTRYTYPE'] == 'phdthesis':
        print entry
        s = '''{0}, {1}, {2} ({3}). PhD thesis.'''.format(entry['author'],
                                                          entry['title'],
                                                          entry['school'],
                                                          entry.get('year',
                                                                    None))

    elif entry['ENTRYTYPE'] == 'misc':
        s = '{0}, {1}, {2}'.format(entry['author'],
                                   entry['title'],
                                   ', '.join([entry[key] for key in entry
                                              if (key != 'ENTRYTYPE'
                                                  and key != 'ID')]))

    else:
        s = '{0}'.format(entry)

    return s


def run():
    bibtex_entries = read_bibtex_entries()
    write_pages(bibtex_entries)
    write_publication_index(bibtex_entries)


def read_bibtex_entries():
    bib_files = [p for p in os.listdir(publications_dir)
                 if p.lower().endswith(".bib")]

    entries = []
    for f in bib_files:
        with open(os.path.join(publications_dir, f)) as f:
            bp = BibTexParser(f.read())
            entries += bp.get_entry_list()

    return sorted(entries, reverse=True,
                  key=lambda entry: entry.get('year', 0))


def write_pages(bibtex_entries):
    for entry in bibtex_entries:
        bf.template.materialize_template("bibtex_entry.mako",
                                         (publications_dir,
                                          entry['ID'] + ".html"),
                                         {"entry": entry})


def write_publication_index(bibtex_entries):
    bf.template.materialize_template("publication_index.mako",
                                     (publications_dir,
                                      "index.html"),
                                     {"bibtex_entries": bibtex_entries,
                                      "citation": citation})
