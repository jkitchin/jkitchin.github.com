
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
  `(format "%s%s%s"
	   (print-tag ,name ,attributes nil)
           (concat
	   ,@body)
	   (print-tag ,name nil t)))

(defun src-block-xml ()
  "Return xml string of src-blocks in the buffer"
  (tag 'src-blocks ()
       (mapconcat 'identity
		  (org-element-map
		      (org-element-parse-buffer)
		      'src-block
		    (lambda (element)
		      (tag
		       'src-block
		       `((language . ,(xml-escape-string
				       (org-element-property :language element)))
			 (switches . ,(xml-escape-string
				       (format
					"%s"
					(org-element-property :switches element))))
			 (parameters . ,(xml-escape-string
					 (format
					  "%s"
					  (org-element-property :parameters element)))))
		       (tag 'code ()
			    (xml-escape-string
			     (org-element-property :value element))))))
		  "")))

(defun process-file (fname)
  (let* ((buf (find-file-noselect fname))
	 (xml (replace-regexp-in-string
	       "[^[:ascii:]]" ""
	       (with-current-buffer buf
		 (concat
		  (tag 'document ()
		       (tag 'content () (xml-escape-string (buffer-string)))
		       (src-block-xml)) "\n")))))
    (format "Path-Name: %s
Content-Length: %s

%s" fname (length xml) xml)))

(get-buffer-create "swish-log")

(loop for dir in '("/Users/jkitchin/blogofile-jkitchin.github.com/_blog"
		   "/Users/jkitchin/blogofile-jkitchin.github.com/_site")
      do
      (loop for fname in (f-entries dir (lambda (x)
					  (string=
					   "org"
					   (file-name-extension x)))
				    t)
	    do
	    (set-buffer "swish-log")
	    (insert (concat fname "\n"))
	    (ignore-errors
	      (princ (process-file fname)))))

(with-temp-file "swish.log"
  (insert (with-current-buffer "shish-log" (buffer-string))))
