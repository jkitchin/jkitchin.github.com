@${entry['ENTRYTYPE']}{${entry['ID']},
  author =	 {${entry.get('author', None)}},
  title =	 {${entry.get('title', None)}},
  journal =	 {${entry.get('journal', None)}},
  volume =	 ${entry.get('volume', None)},
  number =	 ${entry.get('number', None)},
  pages =	 ${entry.get('pages', None)},
  year =	 ${entry.get('year', None)},
  url =          ${entry.get('url', None)},
  doi =		 {${entry.get('doi','no-doi')}}
}
