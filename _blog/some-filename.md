<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#sec-1">1. An exporter for org to docx via pandoc</a>
<ul>
<li><a href="#sec-1-1">1.1. Numbered list</a></li>
<li><a href="#sec-1-2">1.2. Bulleted list</a></li>
<li><a href="#sec-1-3">1.3. definitions</a></li>
<li><a href="#sec-1-4">1.4. Math</a></li>
<li><a href="#sec-1-5">1.5. An image</a></li>
<li><a href="#sec-1-6">1.6. A table</a></li>
<li><a href="#sec-1-7">1.7. Getting citations in docx with pandoc</a></li>
<li><a href="#sec-1-8">1.8. References</a></li>
</ul>
</li>
</ul>
</div>
</div>

# An exporter for org to docx via pandoc<a id="sec-1" name="sec-1"></a>


The idea here is to write a function that converts your org document to a word document using pandoc. Pandoc already converts org to word, but here we want to also get our citations in.

Here are some references to test [@needs-1989-calcul]. And a multiple reference [@jarvi-2008-devel-reaxf; @zhou-2004-first-lda-u; @curnan-2014-effec-concen]. Next, a link with pre text [@curnan-2014-effec-concen, for example, ] and, one with pre and post text [@zhou-2004-first-lda-u, pre text, post text].

Since we are testing, let us try it all out.

## Numbered list<a id="sec-1-1" name="sec-1-1"></a>

1.  Item 1
2.  Item 2
3.  Item 3

## Bulleted list<a id="sec-1-2" name="sec-1-2"></a>

-   item 1
-   item 2
-   item 3
    -   subitem

## definitions<a id="sec-1-3" name="sec-1-3"></a>

-   **org-mode:** tool for awesomeness

## Math<a id="sec-1-4" name="sec-1-4"></a>

<img src="ltxpng/org-to-docx-export_71dd900d7f17a20875918a89a10eb146fccdd464.png" alt="\(e^{i\pi} - 1 = 0\)" />

## An image<a id="sec-1-5" name="sec-1-5"></a>

![img](/Users/jkitchin/Desktop/emacs.png "A little icon.")

## A table<a id="sec-1-6" name="sec-1-6"></a>

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

## Getting citations in docx with pandoc<a id="sec-1-7" name="sec-1-7"></a>

See [Pandoc - Pandoc User’s Guide](http://johnmacfarlane.net/pandoc/README.html) for directions on citations. First, we redefine our format function. This is the function used  to export the cite link in org-ref. This is an experiment, so I will only do it for a cite link here.

    (defun org-ref-format-cite (keyword desc format)
      "New formatting function for cite links to pandoc"
    (message-box "format = %s" format)
      (cond
       ((eq format 'md)
        (cond
         (desc  ;; pre and or post text
          (let* ((text (split-string desc "::"))
                 (pre (car text))
                 (post (cadr text)))

            (concat
             (format "[@%s," keyword)
             (when pre (format " %s" pre))
             (when post (format ", %s" post))
             "]")))
         (t
          (format "[%s]"
                  (mapconcat
                   (lambda (x) (concat "@" x))
                   (split-string keyword ",")
                   "; ")))))))

    org-ref-format-cite

Now, we just export to Markdown

    (org-export-to-file 'md "some-filename.md")

    some-filename.md

Finally, we use pandoc to convert our markdown file to docx. This command requires you to specify your bibtex file in it.

    pandoc -s -S --bibliography=org-to-docx-export.bib some-filename.md -o some-filename.docx

Here is the result <some-filename.docx>. You can see a nicely formatted bibliography, and (author-year) style citations in the document.

There are other options in pandoc to fine tune the reference format (you need a csl file). These citations are not links in the word document, and it does not look like they can be converted to footnotes, endnotes or interact with Endnote or Zotero, but it is a step forward in getting a passable word document with references out of org-mode!

I am not sure going from org to markdown to docx will always work (for example, the tables above do not seem to export correctly), or if it is the best approach. It seems like going directly from org to docx would be better. Initially I tried exporting to org, with an attempt to convert the cite links during that process, but this approach did not work for that. Maybe a filter would do it in that case.

    (defun export-to-docx ()
     "Export the current org file as a docx via markdown."
     (interactive)
    (let* ((bibfile (expand-file-name (car (org-ref-find-bibliography))))
          (current-file (buffer-file-name))
          (md-file (replace-regexp-in-string "\\.org$" "\.md" current-file))
          (docx-file (replace-regexp-in-string "\\.org$" "\.docx" current-file))
          (dd (file-name-as-directory "org-to-docx-999"))
          (contents (buffer-string)))

      (org-export-to-file 'md md-file)
      (shell-command (format "rm -fr %s" docx-file))
      (shell-command (format
                      "pandoc -s -S --bibliography=%s %s -o %s"
                      bibfile md-file docx-file))
      (shell-command (format  "open %s" docx-file))
      ))

    (export-to-docx)

    0

## References<a id="sec-1-8" name="sec-1-8"></a>

<org-to-docx-export.bib>