from pytagcloud import create_tag_image, create_html_data, make_tags, \
    LAYOUT_HORIZONTAL, LAYOUTS
from pytagcloud.colors import COLOR_SCHEMES
from pytagcloud.lang.counter import get_tag_counts
from string import Template
import os
import time
import unittest

text = '''
Project Gutenberg's The Hound of the Baskervilles, by A. Conan Doyle

This eBook is for the use of anyone anywhere at no cost and with
almost no restrictions whatsoever. You may copy it, give it away or
re-use it under the terms of the Project Gutenberg License included
with this eBook or online at www.gutenberg.org


Title: The Hound of the Baskervilles

Author: A. Conan Doyle

Posting Date: December 8, 2008 [EBook #2852]
Release Date: October, 2001

Language: English


*** START OF THIS PROJECT GUTENBERG EBOOK THE HOUND OF THE BASKERVILLES ***




Produced by Shreevatsa R





THE HOUND OF THE BASKERVILLES

By A. Conan Doyle




Chapter 1. Mr. Sherlock Holmes



Mr. Sherlock Holmes, who was usually very late in the mornings, save
upon those not infrequent occasions when he was up all night, was seated
at the breakfast table. I stood upon the hearth-rug and picked up the
stick which our visitor had left behind him the night before. It was a
fine, thick piece of wood, bulbous-headed, of the sort which is known as
a "Penang lawyer." Just under the head was a broad silver band nearly
an inch across. "To James Mortimer, M.R.C.S., from his friends of the
C.C.H.," was engraved upon it, with the date "1884." It was just such a
stick as the old-fashioned family practitioner used to carry--dignified,
solid, and reassuring.
'''


tags = make_tags(get_tag_counts(text, maxsize=120, colors=COLOR_SCHEMES['audacity']))
                 
data = create_html_data(tags, (440,600), layout=LAYOUT_HORIZONTAL, fontname='PT Sans Regular')
        
template_file = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'web/template.html'), 'r')
html_template = Template('''
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; utf-8">
<title>PyTagCloud</title>
<style type="text/css">
body{
background-color: black;
}

@font-face {
font-family: 'PTSans';
src: url('../webfonts/ptsans/pt_sans-web-regular-webfont-2.eot');
src: url('../webfonts/ptsans/pt_sans-web-regular-webfont-2.eot?iefix') format('eot'),
url('../webfonts/ptsans/pt_sans-web-regular-webfont-2.woff') format('woff'),
url('../webfonts/ptsans/pt_sans-web-regular-webfont-2.ttf') format('truetype'),
url('../webfonts/ptsans/pt_sans-web-regular-webfont-2.svg#PTSansRegular') format('svg');
font-weight: normal;
font-style: normal;
}

a.tag{
font-family: 'PTSans';
text-decoration: none;
}

li.cnt{
overflow: hidden;
position: absolute;
display: block;
}

ul.cloud{
position: relative;
display: block;
width: ${width}px;
height: ${height}px;
overflow: hidden;
margin: 0;
padding: 0;
list-style: none;
}

$css
</style>
</head>
<body>
<ul class="cloud">
$tags
</ul>
</body>
</html>''')
        
context = {}
        
tags_template = '<li class="cnt" style="top: %(top)dpx; left: %(left)dpx; height: %(height)dpx;"><a class="tag %(cls)s" href="#%(tag)s" style="top: %(top)dpx;\
left: %(left)dpx; font-size: %(size)dpx; height: %(height)dpx; line-height:%(lh)dpx;">%(tag)s</a></li>'
        
context['tags'] = ''.join([tags_template % link for link in data['links']])
context['width'] = data['size'][0]
context['height'] = data['size'][1]
context['css'] = "".join("a.%(cname)s{color:%(normal)s;}\
a.%(cname)s:hover{color:%(hover)s;}" %
                         {'cname':k,
                          'normal': v[0],
                          'hover': v[1]}
                         for k,v in data['css'].items())
        
html_text = html_template.substitute(context)
        
html_file = open('cloud.html', 'w')
html_file.write(html_text)
html_file.close()
