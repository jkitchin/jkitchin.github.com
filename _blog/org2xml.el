
:;exec emacs -batch -l $0 -f main "$@"
(require 'org)
(require 'xml)

(defun print-tag (name attrs &optional closingp)
  "Print an xml tag with symbol NAME and ATTRS (a cons list of (attribute . value)).
if CLOSINGP print the closing tag instead.
You should use `xml-escape-string' on text going into the attributes to avoid errors."
  (format
   "<%s%s%s>"
   (if closingp "/" "")
   name
   (if (and attrs (not closingp))
       (concat
	" "
	(mapconcat
	 (lambda (x)
	   (format "%s=\"%s\"" (car x) (cdr x)))
	   attrs
	   " "))
     "")))

(defmacro tag (name attributes &rest body)
  `(format "%s%s%s"
	   (print-tag ,name ,attributes nil)
           (concat
	   ,@body)
	   (print-tag ,name nil t)))

(defun main ()
  (find-file (car command-line-args-left))
  (princ (tag 'root `((filename . ,(buffer-file-name))
		      (indexed-on . ,(current-time-string)))
	      ;; map the headlines
	      (mapconcat
	       'identity
	       (org-map-entries
		(lambda ()
		  (let* ((tags (org-get-tags))
			 (heading-components (org-heading-components))
			 (todo (nth 2 heading-components))
			 (headline (nth 4 heading-components))
			 (thislevel (nth 0 heading-components))
			 (properties (org-entry-properties)))
		    (tag 'heading `((level . ,thislevel))
			 (tag 'headline () (xml-escape-string headline))
			 (tag 'tags () (mapconcat 'identity tags " "))
			 (when todo
			   (tag 'todo () todo))
			 (tag 'properties ()
			      (mapconcat
			       (lambda (x)
				 (tag 'property `((name . ,(xml-escape-string (car x))))
				      (xml-escape-string (cdr x))))
			       properties
			       ""))))))
	       "")

	      ;; get file keywords, TITLE, authors, etc...
	      (tag 'file-keywords ()
		   (mapconcat 'identity
			      (org-element-map (org-element-parse-buffer 'element) 'keyword
				(lambda (keyword)
				  (tag (xml-escape-string (org-element-property :key keyword)) ()
				       (xml-escape-string (org-element-property :value keyword)))))
			      ""))

	      ;; map specific element types
	      (tag 'source-blocks ()
		   (mapconcat
		    'identity
		    (org-element-map
			(org-element-parse-buffer)
			'src-block
		      (lambda (element)
			(tag 'src-block
			     `((language .
					 ,(org-element-property
					   :language element)))
			     (tag 'contents ()
				  (xml-escape-string
				   (org-element-property :value element)))))) ""))

	      (tag 'tables ()
		   (mapconcat
		    'identity
		    (org-element-map
			(org-element-parse-buffer)
			'table
		      (lambda (element)
			(tag 'table ()
			     (when (org-element-property :caption element)
			       (tag 'caption ()
				    (format
				     "%s"
				     (org-element-property
				      :caption element))))
			     (xml-escape-string
			      (buffer-substring
			       (org-element-property :contents-begin element)
			       (org-element-property :contents-end element))))))
		    ""))

	      (tag 'paragraphs ()
		   (mapconcat
		    'identity
		    (org-element-map
			(org-element-parse-buffer)
			'paragraph
		      (lambda (element)
			(tag 'paragraph ()
			     (xml-escape-string
			      (buffer-substring
			       (org-element-property :contents-begin element)
			       (org-element-property :contents-end element))))))
		    ""
		    )))))
