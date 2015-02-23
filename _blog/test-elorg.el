;;; test-elorg.el ---    -*- lexical-binding: t -*-
;;; Header:

;;; Commentary:

;;; Code:
;; #+BEGIN_SRC emacs-lisp
(defcustom test-var nil "docstring")
;; #+END_SRC

;; * PMID (from PubMed) link and functions
;; A PMID is a number that identifies an entry in the Pubmed database.  The PMID is a unique reference number for PubMed citations. The PMID is a distinctly different number from the PMCID and is used only for PubMed records.


;; #+BEGIN_SRC emacs-lisp
(org-add-link-type
 "pmid"
 ;; clicking
 (lambda (link-string) (browse-url (format "http://www.ncbi.nlm.nih.gov/pubmed/%s" link-string)))
 ;; formatting
(lambda (keyword desc format)
   (cond
    ((eq format 'html)
     (format "<a href=\"http://www.ncbi.nlm.nih.gov/pmc/articles/mid/%s\">pmid:%s</a>" keyword keyword)); no output for html
    ((eq format 'latex)
     ;; write out the latex command
     (format "\\url{http://www.ncbi.nlm.nih.gov/pmc/articles/mid/%s}" keyword)))))
;; #+END_SRC



;; ** Get MEDLINE metadata
;; We can get bibliographic metadata from a pmid. Here we get the MEDLINE text. The website wraps the data in <pre></pre> tags.

;; #+BEGIN_SRC emacs-lisp
(defun pubmed-get-medline (pmid)
  "Get MEDLINE text for PMID as a string."
  (with-current-buffer
    (url-retrieve-synchronously
     (format "http://www.ncbi.nlm.nih.gov/pubmed/%s/?report=medline&format=text" pmid))
    (goto-char (point-min))
    (let ((p1 (search-forward "<pre>"))
	  (p2 (search-forward "</pre>")))
      (buffer-substring (+ 1 p1) (- p2 6)))))
;; #+END_SRC


;; ** Parse the PMID MEDLINE data
;; We can parse this into a data structure

;; #+BEGIN_SRC emacs-lisp
(defun pubmed-parse-medline (pmid)
  "Parse the medline text for PMID and return a list of cons cells."
  (let ((data '())
	(p1)
	(p2)
	(tag)
	(value))
    (with-temp-buffer (insert (pubmed-get-medline pmid))
		      (goto-char (point-min))
		      (while (re-search-forward "\\(^[A-Z]\\{2,4\\}\\)\\s-*- " nil t)
			(setq tag (match-string 1))
			;; point is at end of the search
			(setq p1 (point))
			;; now go to next tag
			(re-search-forward "\\(^[A-Z]\\{2,4\\}\\)\\s-*- " nil t)
			(setq p2 (- (match-beginning 1) 1))
			(setq value (buffer-substring p1 p2))
			(setq data (append data (list (cons tag value))))
			;; now go back to last tag to get the next one
			(goto-char p1)))
    data))
;; #+END_SRC

;; ** PMID to bibtex entry
;; The point of parsing the MEDLINE text is so we can make bibtex entries. We only support Journal articles for now.

;; #+BEGIN_SRC emacs-lisp
(defun pubmed-pmid-to-bibtex (pmid)
  "Convert a PMID to a bibtex entry."
  (let* ((data (pubmed-parse-medline pmid))
	 (type (cdr (assoc "PT" data)))
	 (title (cdr (assoc "TI" data)))
	 (authors (mapconcat 'cdr
			     (-filter (lambda (x)
					(string= (car x) "FAU"))
				      data)
			     " and "))
	 (abstract (cdr (assoc "AB" data)))
	 (volume (cdr (assoc "VI" data)))
	 (issue (cdr (assoc "IP" data)))
	 (journal (cdr (assoc "JT" data)))
	 (year (cdr (assoc "DP" data)))
	 (pages (cdr (assoc "PG" data)))
	 (aid (cdr (assoc "AID" data))))

    (cond
     ((string= type "JOURNAL ARTICLE")
      (concat "@article{,
 author = {" authors "},
 title = {" title "},
 abstract = {" abstract "},
 journal = {" journal "},
 volume = {" volume "},
 number = {" issue "},
 year = {" (car (split-string year)) "},
 pages = {" pages "},
 doi = {" (replace-regexp-in-string " \\[doi\\]" "" aid) "},
}"))
    (t
     (message "No conversion for type: %s" type)))))
;; #+END_SRC




;; And we probably want to be able to insert a bibtex entry

;; #+BEGIN_SRC emacs-lisp
(defun pubmed-insert-bibtex-from-pmid (pmid)
 "Insert a bibtex entry at point derived from PMID.
You must clean the entry after insertion."
 (interactive "sPMID: ")
 (insert (pubmed-pmid-to-bibtex pmid)))
;; #+END_SRC


;; ** PMID to xml
;; We can also get xml of the MEDLINE data. The web page here also wraps the xml in a <pre> block and escapes the <> with &lt; and &gt;, which we have to undo. I have not used this code for anything, so I am not sure how good the xml code is.

;; #+BEGIN_SRC emacs-lisp
(defun pubmed-get-medline-xml (pmid)
  "Get MEDLINE xml for PMID as a string."
  (interactive)
  (with-current-buffer
    (url-retrieve-synchronously
     (format "http://www.ncbi.nlm.nih.gov/pubmed/%s/?report=xml&format=text" pmid))
    (goto-char (point-min))
    (while (search-forward "&lt;" nil t)
      (replace-match "<"))
    (goto-char (point-min))
    (while (search-forward "&gt;" nil t)
      (replace-match ">"))
    (goto-char (point-min))

    (let ((p1 (search-forward "<pre>"))
	  (p2 (search-forward "</pre>")))
      (buffer-substring (+ 1 p1) (- p2 6)))))
;; #+END_SRC



;; ;;; test-elorg.el ends here

;; # Local Variables:
;; # lentic-init: lentic-orgel-org-init
;; # End:
