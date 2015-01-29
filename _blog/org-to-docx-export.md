<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#sec-1">1. An exporter for org to docx via pandoc with citations and bibliography</a>
<ul>
<li><a href="#sec-1-1">1.1. Getting citations in docx with pandoc</a></li>
<li><a href="#sec-1-2">1.2. Numbered list</a></li>
<li><a href="#sec-1-3">1.3. Bulleted list</a></li>
<li><a href="#sec-1-4">1.4. definitions</a></li>
<li><a href="#sec-1-5">1.5. Math</a></li>
<li><a href="#sec-1-6">1.6. An image</a></li>
<li><a href="#sec-1-7">1.7. A table</a></li>
<li><a href="#sec-1-8">1.8. References</a></li>
</ul>
</li>
</ul>
</div>
</div>


# An exporter for org to docx via pandoc with citations and bibliography<a id="sec-1" name="sec-1"></a>


Pandoc continues to develop, and since [the last time](http://kitchingroup.cheme.cmu.edu/blog/2014/07/17/Pandoc-does-org-mode-now/) I wrote about it there is improved support for citations. We will use that to convert org documents to Word documents that actually have citations and a bibliography in them. The idea is to export the org document to markdown and then use pandoc to make it into a Word document. I could not figure out how to do a direct org to docx format easily. The key to this transformation is converting the org-links into the pandoc citation format. I added a markdown format into org-ref, so this happens automatically when you export org to markdown with org-ref cite links.

Here are some references to test [@needs-1989-calcul]. And a multiple reference [@jarvi-2008-devel-reaxf; @zhou-2004-first-lda-u; @curnan-2014-effec-concen]. Next, a link with pre text [@curnan-2014-effec-concen, for example, ] and, one with pre and post text [@zhou-2004-first-lda-u, pre text, post text].

We need this in Emacs to enable export to markdown.

    (require 'ox-md)

## Getting citations in docx with pandoc<a id="sec-1-1" name="sec-1-1"></a>

See [Pandoc - Pandoc User’s Guide](http://johnmacfarlane.net/pandoc/README.html) for directions on citation format. The key is to format the cite links to the pandoc format.

Here is our function to export to markdown, and then convert via pandoc. We just calculate some names, export and run pandoc as a shell-command, then open the file (that shell command is

    (defun ox-export-to-docx-and-open ()
     "Export the current org file as a docx via markdown."
     (interactive)
    (let* ((bibfile (expand-file-name (car (org-ref-find-bibliography))))
           ;; this is probably a full path
           (current-file (buffer-file-name))
           (basename (file-name-sans-extension current-file))
           (md-file (concat basename ".md"))
           (docx-file (concat basename ".docx")))

      (when (file-exists-p docx-file) (delete-file docx-file))
      (org-export-to-file 'md md-file)
      (shell-command (format
                      "pandoc -s -S --bibliography=%s %s -o %s"
                      bibfile md-file docx-file))
      (org-open-file docx-file '(16))))

    (ox-export-to-docx-and-open)

    0

Here is the result <org-to-docx-export.docx>. You can see a nicely formatted bibliography, and (author-year) style citations in the document, including the pre and post text. There are other options in pandoc to fine tune the reference format (you need a csl file). That can be included in the org-file via file tags pretty easily. These citations are not links in the word document, and it does not look like they can be converted to footnotes, endnotes or interact with Endnote or Zotero, but it is a step forward in getting a passable word document with references out of org-mode!

I am not sure going from org to markdown to docx will always work (for example, the equations and tables below do not seem to export correctly). I am not fluent in markdown, in the exported file, these appear as html (<org-to-docx-export.md>). It seems like going directly from org to docx would be better. There are certainly ways you could do that but they all require a little more effort than the little code block above.

Since we are testing, let us try it some other typical features in an org-file.

## Numbered list<a id="sec-1-2" name="sec-1-2"></a>

1.  Item 1
2.  Item 2
3.  Item 3

## Bulleted list<a id="sec-1-3" name="sec-1-3"></a>

-   item 1
-   item 2
-   item 3
    -   subitem

## definitions<a id="sec-1-4" name="sec-1-4"></a>

-   **org-mode:** tool for awesomeness

## Math<a id="sec-1-5" name="sec-1-5"></a>

One equation:
<img src="ltxpng/org-to-docx-export_71dd900d7f17a20875918a89a10eb146fccdd464.png" alt="\(e^{i\pi} - 1 = 0\)" />

A second equation:


<div class="figure">
<p><img src="ltxpng/org-to-docx-export_fb56117cdd3c3ac81c363d24325cfc6b5a530420.png" alt="\begin{equation}
e^{i\pi} - 1 = 0
\end{equation}" /></p>
</div>

## An image<a id="sec-1-6" name="sec-1-6"></a>

![img](/Users/jkitchin/Desktop/emacs.png "A little icon.")

## A table<a id="sec-1-7" name="sec-1-7"></a>

<table id="my-table" border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">
<caption class="t-above"><span class="table-number">Table 1:</span> A little table.</caption>

<colgroup>
<col  class="right" />

<col  class="right" />
</colgroup>
<thead>
<tr>
<th scope="col" class="right">x</th>
<th scope="col" class="right">y</th>
</tr>
</thead>

<tbody>
<tr>
<td class="right">1</td>
<td class="right">2</td>
</tr>


<tr>
<td class="right">3</td>
<td class="right">4</td>
</tr>
</tbody>
</table>

a plain table

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="right" />

<col  class="right" />
</colgroup>
<thead>
<tr>
<th scope="col" class="right">x</th>
<th scope="col" class="right">y</th>
</tr>
</thead>

<tbody>
<tr>
<td class="right">1</td>
<td class="right">2</td>
</tr>


<tr>
<td class="right">3</td>
<td class="right">4</td>
</tr>
</tbody>
</table>

## References<a id="sec-1-8" name="sec-1-8"></a>

<org-to-docx-export.bib>