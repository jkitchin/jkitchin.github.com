(defun ox-export-to-ipynb ()
  (interactive)
  ;; Basically, we will break up the org-file into two types of blocks:
  ;; markdown cells and source cells and results cells
  (let ((regions '())
	(start (point-min))
	end
	src-cells
	(cells '())
	(next-src nil)
	(code-template "{
 \"cell_type\": \"${cell-type}\",
 \"metadata\": ${metadata},
 \"outputs\": [${outputs}],
 \"execution_count\": 1,
 \"source\": [
  ${source}
  ]
 }")
	(markdown-template "{
   \"cell_type\": \"markdown\",
   \"metadata\": {},
   \"source\": [
${lines}
   ]
  }")
	(ipynb-template "{
 \"cells\": [
  ${cells}
 ],
 \"metadata\": {
  \"kernelspec\": {
   \"display_name\": \"Python 3\",
   \"language\": \"python\",
   \"name\": \"python3\"
  },
  \"language_info\": {
   \"codemirror_mode\": {
    \"name\": \"ipython\",
    \"version\": 3
   },
   \"file_extension\": \".py\",
   \"mimetype\": \"text/x-python\",
   \"name\": \"python\",
   \"nbconvert_exporter\": \"python\",
   \"pygments_lexer\": \"ipython3\",
   \"version\": \"3.5.2\"
  }
 },
 \"nbformat\": 4,
 \"nbformat_minor\": 0
}
"))

    ;; Get boundaries of the src-blocks
    (setq src-cells (org-element-map (org-element-parse-buffer) 'src-block
		      (lambda (src)
			(if (string= (org-element-property :language src)
				     "python")
			    (cons (org-element-property :begin src)
				  (org-element-property :end src))))))
    (when src-cells
      (setq next-src (pop src-cells)))

    ;; this is the first markdown cell
    (push
     (s-format markdown-template 'aget
	       `(("lines" . ,(mapconcat
			      (lambda (line)
				(format "\"%s\\n\"" line))
			      (split-string
			       (org-export-string-as
				(buffer-substring-no-properties
				 (point-min)
				 (or (car next-src) (point-max)))
				'md t '(:with-toc nil))
			       "\n")
			      ",\n"))))
     
     cells)
    

    (while next-src
      (goto-char (or (car next-src) (point-max)))
      (push
       (s-format code-template 'aget
		 `(("cell-type" . "code")
		   ("metadata" . "{}")
		   ("outputs" . "")
		   ("source" . ,(mapconcat
				 (lambda (line)
				   (format "\"%s\\n\"" line))
				 (split-string
				  (buffer-substring-no-properties
				   (car next-src)
				   (cdr next-src))
				  "\n")
				 ",\n"))))
       cells)
      (goto-char (cdr next-src))

      (setq next-src (pop src-cells))
      (push
       (s-format markdown-template 'aget
		 `(("lines" . ,(mapconcat
				(lambda (line)
				  (format "\"%s\\n\"" line))
				(split-string
				 (org-export-string-as
				  (buffer-substring-no-properties
				   (point)
				   (or (car next-src) (point-max)))
				  'md t '(:with-toc nil))
				 "\n")
				",\n"))))
       
       cells))
    

    (s-format ipynb-template 'aget
	      `(("cells" . ,(mapconcat
			     'identity
			     (reverse  cells)
			     ",\n"))))

    

    
    

    ;; (s-format ipynb-template 'aget
    ;; 	      `(("cells" . ,(mapconcat
    ;; 			     'identity
    ;; 			     (mapcar (lambda (src-cell)
    ;; 				       (s-format cell-template 'aget src-cell))
    ;; 				     (org-element-map (org-element-parse-buffer) 'src-block
    ;; 				       (lambda (src)
    ;; 					 (if (string= (org-element-property :language src)
    ;; 						      "python")
    ;; 					     (list (cons "cell-type" "code")
    ;; 						   (cons "metadata" "{}")
    ;; 						   (cons "outputs" "")
    ;; 						   (cons "source"
    ;; 							 (mapconcat
    ;; 							  (lambda (line)
    ;; 							    (format "\"%s\\n\"" line))
    ;; 							  (split-string
    ;; 							   (org-element-property :value src)
    ;; 							   "\n")
    ;; 							  ",\n")))))))
    ;; 			     ",\n"))))
    ))
