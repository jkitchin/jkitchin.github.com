
:;exec emacs -batch -l $0 "$@"
(require 'org)
(require 'xml)
(require 'cl)

(add-to-list 'load-path "~/Dropbox/kitchingroup/jmax/elpa/f-20140828.716")
(add-to-list 'load-path "~/Dropbox/kitchingroup/jmax/elpa/s-20140910.334")
(add-to-list 'load-path "~/Dropbox/kitchingroup/jmax/elpa/dash-20141201.2206")
(require 'f)

(defun print-tag (name attrs &optional closingp)
  "Print an xml tag with symbol NAME and ATTRS (a cons list of (attribute . value)).
if CLOSINGP print the closing tag instead."
  (format
   "<%s%s%s>"
   (if closingp "/" "")
   name
   (if (and attrs (not closingp))
       (concat
	" "
	(mapconcat
	 (lambda (x)
	   (format "%s=\"%s\""
		   (car x)
		   (xml-escape-string (cdr x))))
	 attrs
	 " "))
     "")))


(defmacro tag (name attributes &rest body)
  "macro to create an xml tag with NAME, ATTRIBUTES. BODY is executed in the tag."
  `(format "%s%s%s"
	   (print-tag ,name ,attributes nil)
           (concat
	    ,@body)
	   (print-tag ,name nil t)))


(defun document (fname char content)
  "Return string for a swish-e document to be indexed.
FNAME is path to file.
CHAR is a position in FNAME of the CONTENT."
  (let ((stripped-content (replace-regexp-in-string
			   "[^[:ascii:]]" "" content)))
    (format "Path-Name: [[elisp:(progn (find-file \"%s\") (goto-char %s) (show-children))][link]]
Content-Length: %s
Document-Type: XML*

%s" fname char (length stripped-content) stripped-content)))


;; * Document - for broadest of searching
(defun document-xml ()
  (tag 'document ()
       (tag 'content () (xml-escape-string (buffer-string)))
       (tag 'file-keywords ()
	    (mapconcat
	     'identity
	     (org-element-map (org-element-parse-buffer 'element) 'keyword
	       (lambda (keyword)
		 (tag (xml-escape-string (org-element-property :key keyword)) ()
		      (xml-escape-string (org-element-property :value keyword)))))
	     ""))))


(defun document-document ()
  (document (buffer-file-name) 1 (document-xml)))

;; * Headlines
(defun headline-xml (headline)
  "Return xml representation of an element HEADLINE."
  (let ((title (org-element-property :title headline))
	(properties (save-excursion
		      (goto-char
		       (org-element-property :begin headline))
		      (org-entry-properties))))
    (tag 'headline ()
	 (tag 'title () (xml-escape-string (mapconcat 'identity title " ")))
	 (when properties
	   (tag 'properties ()
		(mapconcat
		 'identity
		 (loop for (p . v) in properties
		       collect (tag p () (xml-escape-string v)))
		 ""))))))

(defun headline-document (headline)
  "Return the headline \"document\" for swish-e to index."
  (document (buffer-file-name)
	    (org-element-property :begin headline)
	    (headline-xml headline)))

;; * Links
(defun link-xml (link)
  (tag 'link
       `((type . ,(xml-escape-string (org-element-property :type link)))
	 (path . ,(xml-escape-string (org-element-property :path link)))
	 (raw-link . ,(xml-escape-string
		       (org-element-property :raw-link link))))
       ;; captions are in the parent paragraph.
       (when (org-element-property
	      :caption
	      (org-element-property :parent link))
	 (tag 'caption ()
	      (xml-escape-string
	       (mapconcat
		(lambda (x)
		  (mapconcat 'car x " "))
		(org-element-property
		 :caption
		 (org-element-property :parent link))
		" "))))
       (when (org-element-property :contents-begin link)
	 (buffer-substring (org-element-property :contents-begin link)
			   (org-element-property :contents-end link)))))

(defun link-document (link)
  (document (buffer-file-name)
	    (org-element-property :begin link)
	    (link-xml link)))

;; * Tables
(defun table-xml (table)
  (tag 'table ()
       (let* ((caption (mapconcat
			(lambda (x)
			  (mapconcat 'car x " "))
			(org-element-property :caption table) ""))
	      (begin (org-element-property :begin table))
	      (end (org-element-property :end table))
	      (contents (buffer-substring begin end)))
	 (tag 'caption () (xml-escape-string caption))
	 (tag 'table-contents () (xml-escape-string contents)))))

(defun table-document (table)
  (document (buffer-file-name)
	    (org-element-property :begin table)
	    (table-xml table)))

;; * src-blocks
(defun src-block-xml (src-block)
  (tag
   'src-block
   `((language . ,(xml-escape-string
		   (org-element-property :language src-block)))
     (switches . ,(xml-escape-string
		   (format
		    "%s"
		    (org-element-property :switches src-block))))
     (parameters . ,(xml-escape-string
		     (format
		      "%s"
		      (org-element-property :parameters src-block)))))
   (when (org-element-property :name src-block)
     (tag 'name () (xml-escape-string
		    (org-element-property :name src-block))))
   (when (org-element-property :caption src-block)
     (tag 'caption ()
	  (mapconcat
	   (lambda (x)
	     (mapconcat 'car x " "))
	   (org-element-property :caption src-block) "")))
   (tag 'code ()
	(xml-escape-string
	 (org-element-property :value src-block)))))

(defun src-block-document (src-block)
  (document (buffer-file-name)
	    (org-element-property :begin src-block)
	    (src-block-xml src-block)))

;; * paragraphs
(defun paragraph-xml (paragraph)
  (tag 'paragraph ()
       (xml-escape-string (buffer-string
			   (org-element-property :begin paragraph)
			   (org-element-property :end paragraph)))))

(defun paragraph-document (paragraph)
   (document (buffer-file-name)
	     (org-element-property :begin paragraph)
	     (paragraph-xml link)))


(defun process-file (fname)
  "Print the `headline-document' for each headline in FNAME."
  (with-current-buffer (find-file-noselect fname)
    (princ (document-document))

    (org-element-map (org-element-parse-buffer)
	'headline
      (lambda (headline)
	(princ (headline-document headline))))

    (org-element-map (org-element-parse-buffer)
	'link
      (lambda (link)
	(princ (link-document link))))

    (org-element-map (org-element-parse-buffer)
	'table
      (lambda (table)
	(princ (table-document table))))

    (org-element-map (org-element-parse-buffer)
	'src-block
      (lambda (src-block)
	(princ (src-block-document src-block))))

    (org-element-map (org-element-parse-buffer)
	'paragraph
      (lambda (paragraph)
	(princ (paragraph-document paragraph))))))

(process-file "org.org")
;; Here is the main work in the script.
;; (loop for dir in '("/Users/jkitchin/blogofile-jkitchin.github.com/_blog")
;;       do
;;       (loop for fname in (f-entries
;;			  dir
;;			  (lambda (x)
;;			    (string=  "org"  (file-name-extension x)))
;;			  t)
;;	    do (ignore-errors
;;		 (princ (process-file fname)))))
