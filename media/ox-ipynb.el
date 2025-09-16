;;; ox-ipynb.el --- Convert an org-file to an ipynb.

;;; Commentary:
;; 

;;; Code:
(require 'ox-md)

(defun export-ipynb-code-cell (src-result)
  "Return a lisp code cell for the org-element SRC-BLOCK."
  (let* ((src-block (car src-result))
	 (results-end (cdr src-result))
	 (results (car results-end)))
    
    `((cell_type . "code")
      (execution_count . 1)
      ;; the hashtable trick converts to {} in json
      (metadata . ,(make-hash-table))
      ;; (vector) converts to [] in json
      (outputs . ,(if (null results)
		      (vector)
		    (vconcat `(((name . "stdout")
				(output_type . "stream")
				(text . ,(s-trim results)))))))
      (source . ,(vconcat
		  (list (s-trim (org-element-property :value src-block))))))))


(defun ox-ipynb-filter-latex-fragment (text back-end info)
  "Export fragments the right way for markdown."
  (if (s-starts-with? "\\(" text)
      (format "$%s$" (substring text 2 -2))
    text))


(defun ox-ipynb-filter-link (text back-end info)
  "Make a link into markdown.
This only fixes file links with no description I think."
  (if (s-starts-with? "<" text)
      (let ((path (substring text 1 -1)))
	(format "[%s](%s)" path path))
    text))


(defun export-ipynb-markdown-cell (beg end)
  "Return the markdown cell for the region defined by BEG and END."
  (let* ((org-export-filter-latex-fragment-functions '(ox-ipynb-filter-latex-fragment))
	 (org-export-filter-link-functions '(ox-ipynb-filter-link)) 
	 (md (org-export-string-as
	      (buffer-substring-no-properties
	       beg end)
	      'md t '(:with-toc nil))))
    
    `((cell_type . "markdown")
      (metadata . ,(make-hash-table))
      (source . ,(vconcat
		  (list md))))))

(defun export-ipynb-buffer ()
  "Export the current buffer to ipynb format.
Only ipython source blocks are exported as code cells. Everything
else is exported as a markdown cell.
"
  (interactive)
  (let ((cells '())
	(metadata '(metadata . ((kernelspec . ((display_name . "Python 3")
					       (language . "python")
					       (name . "python3")))
				(language_info . ((codemirror_mode . ((name . ipython)
								      (version . 3)))
						  (file_extension . ".py")
						  (mimetype . "text/x-python")
						  (name . "python")
						  (nbconvert_exporter . "python")
						  (pygments_lexer . "ipython3")
						  (version . "3.5.2")))))) 
	(ipynb (concat (file-name-base (buffer-file-name)) ".ipynb"))
	src-blocks
	src-results
	current-src
	result
	result-end
	end
	data)

    (setq src-blocks (org-element-map (org-element-parse-buffer) 'src-block
		       (lambda (src)
			 (when (string= "ipython" (org-element-property :language src))
			   src))))

    ;; Get a list of (src . results)
    (setq src-results
	  (loop for src in src-blocks
		with result=nil
		do
		(setq result
		      (save-excursion
			(goto-char (org-element-property :begin src))
			(let ((location (org-babel-where-is-src-block-result nil nil))
			      start end)
			  (when location
			    (save-excursion
			      (goto-char location)
			      (when (looking-at
				     (concat org-babel-result-regexp ".*$")) 
				(setq start (1- (match-beginning 0))
				      end (progn (forward-line 1) (org-babel-result-end)))
				(cons
				 (replace-regexp-in-string
				  "#\\+RESULTS:\n" ""
				  (replace-regexp-in-string
				   "^: " ""
				   (buffer-substring start end)))
				 
				 end))))))) 
		collect
		(cons src result)))
    
    (setq current-source (pop src-results))

    ;; First block before a src is markdown
    (push (export-ipynb-markdown-cell
	   (point-min) (org-element-property :begin (car current-source)))
	  cells)

    (while current-source
      ;; add the src cell
      (push (export-ipynb-code-cell current-source) cells)
      (setq result-end (cdr current-source)
	    result (car result-end)
	    result-end (cdr result-end))
      
      (setq end (max
		 (or result-end 0)
		 (org-element-property :end (car current-source))))
      
      (setq current-source (pop src-results))
      
      (if current-source
	  (push (export-ipynb-markdown-cell 
		 end
		 (org-element-property :begin
				       (car current-source)))
		cells)
	;; on last block so add rest of document
	(push (export-ipynb-markdown-cell end (point-max)) cells)))

    (setq data (append
		`((cells . ,(reverse cells)))
		(list metadata)
		'((nbformat . 4)
		  (nbformat_minor . 0))))
    (with-temp-file ipynb
      (insert (json-encode data)))))

(provide 'ox-ipynb)

;;; ox-ipynb.el ends here
