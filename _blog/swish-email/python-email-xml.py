#!/usr/bin/env python

from __future__ import print_function
import email, os
from xml.sax.saxutils import escape, quoteattr
import os
from os.path import join, getsize



def printtag(name,closing=False):
    if closing:
        return '</{}>'.format(name)
    else:
        return '<{}>'.format(name)


def tag(name, *content):
    return '{0}{1}{2}'.format(printtag(name),
                             ''.join(content),
                             printtag(name, closing=True))


template = '''Path-Name: {0}
Content-Length: {1}
Document-Type: XML*

{2}'''


headers_to_index = ['To', 'From', 'Subject', 'Cc',
                    'Bcc', 'Sender', 'Message-ID', 'Date']

def email_document(fname):
    with open(fname) as f:
        msg = email.message_from_file(f)

    headers = ''.join([tag(key.lower(), escape(msg.get(key, None)))
                       for key in headers_to_index if msg.get(key, None)])

    msg_body = ''
    attachments = ''
    if msg.is_multipart():
        for part in msg.walk():
            if part.get_content_type() in ['text/plain', 'text/html']:
                msg_body += part.get_payload()
            elif part.get_filename() is not None:
                attachments += tag('attachment',
                                   tag('content_type', escape(part.get_content_type())),
                                   tag('filename', escape(part.get_filename())))

    swishdefault = tag('swishdefault', escape(msg_body))

    desc = tag('desc', escape(msg['Subject']))

    # in MB
    size = tag('size', str(float(getsize(fname)) / 1024**2))

    xml = ''.join([i if ord(i) < 128 else ' ' for i in
                   tag("email", desc + headers + size
                       + swishdefault + attachments)])
    return template.format(os.path.abspath(fname), len(xml), xml)


for root, dirs, files in os.walk('/Users/jkitchin/Maildir-archive/2011/cur'):
    for f in files:
        try:
            # use end arg to avoid an extra space and carriage return
            print(email_document(os.path.join(root, f)), end='')
        except:
            pass
