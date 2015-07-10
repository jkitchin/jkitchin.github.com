
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
  (let ((xml (replace-regexp-in-string
	      "[^[:ascii:]]" ""
	      (headline-xml headline))))
    (format "Path-Name: [[elisp:(progn (find-file \"%s\") (goto-char %s) (show-children))][link]]
Content-Length: %s
Document-Type: XML*

%s" (buffer-file-name)
(org-element-property :begin headline)
(length xml)
xml)))

(defun process-file (fname)
  "Print the `headline-document' for each headline in FNAME."
  (with-current-buffer (find-file-noselect fname)
    (mapconcat 'identity
	       (org-element-map (org-element-parse-buffer)
		   'headline
		 (lambda (headline)
		   (princ (headline-document headline))))
	       "")))

;; Here is the main work in the script.
(loop for dir in '("/Users/jkitchin/blogofile-jkitchin.github.com/_blog")
      do
      (loop for fname in (f-entries
			  dir
			  (lambda (x)
			    (string=  "org"  (file-name-extension x)))
			  t)
	    do (ignore-errors
		 (princ (process-file fname)))))
