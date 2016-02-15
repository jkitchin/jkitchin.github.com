
import os
import tempfile

config = {"name": "org-mode",
        "author": "John Kitchin",
        "description": "Renders org-mode formatted text to HTML"}

# Directory where posts are stored
_posts = "/Users/jkitchin/blogofile-jkitchin.github.com/_posts"

def run(content):
    # we need to write the content to a file
    fid, tmp = tempfile.mkstemp(".org",
                                dir=_posts)

    html_file = tmp.replace('.org', '.html')

    with open(tmp, 'w') as f:
        f.write(content)

    # run emacs to export it.
    cmd = ("""emacsclient --eval """
           """'(progn (with-current-buffer (find-file-noselect "{0}")"""
           """   (re-search-forward "^*")"""
           """   (let ((html (save-window-excursion (concat (bf-get-HTML) (bf-copyright)))))"""
           """     (bf-copy-org-to-blog)"""
           """     (save-buffer) (kill-buffer)"""
           """     (with-temp-file "{1}" """
           """        (insert html)))))'""".format(tmp, html_file))

    os.system(cmd)

    # read the results in and return them
    with open(html_file, 'r') as f:
        html = f.read()

    os.unlink(tmp)
    os.unlink(html_file)
    return html
