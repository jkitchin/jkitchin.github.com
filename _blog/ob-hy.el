
(require 'ob)

(add-to-list 'org-structure-template-alist
             '("hy" "#+BEGIN_SRC hy\n?\n#+END_SRC" "<src lang=\"hy\">\n?\n</src>"))

(defvar org-babel-tangle-lang-exts)
(add-to-list 'org-babel-tangle-lang-exts '("hy" . "hy"))

(defvar org-babel-default-header-args:hy '())
(defvar org-babel-header-args:hy '((:results . "output")))

(defun org-babel-expand-body:hy (body params)
  "Expand BODY according to PARAMS, return the expanded body."
  (let* ((vars (mapcar #'cdr (org-babel-get-header params :var)))
	 (result-params (cdr (assoc :result-params params)))
	 (print-level nil)
	 (print-length nil)
	 (body (org-babel-trim
		(if (> (length vars) 0)
		    (concat "(let ["
			    (mapconcat
			     (lambda (var)
			       (format
				"%S (quote %S)"
				(car var)
				(cdr var)))
			     vars "\n      ")
			    "]\n" body ")")
		  body))))
    (when (not (member "output" result-params))
      (setq body (format "(print (do  %s\n))" body)))
    body))

(defun org-babel-execute:hy (body params)
  "Execute a block of hy code with Babel."
  (let* ((temporary-file-directory ".")
	 (tempfile (make-temp-file "hy-"))
	 result
	 (result-params (cdr (assoc :result-params params)))
	 (body (org-babel-expand-body:hy body params)))

    (with-temp-file tempfile
      (insert body))

    (unwind-protect
	(progn
	  (cond
	   ((member "body" result-params)
	    (setq result body))
	   ((member "python" result-params)
	    (setq result (shell-command-to-string
			  (format "hy2py %s" tempfile))))
	   ((member "ast" result-params)
	    (setq result (shell-command-to-string
			  (format "hy2py -a -np %s" tempfile))))
	   (t
	    (setq result (shell-command-to-string
			  (format "hy %s" tempfile)))))

	  (org-babel-result-cond result-params
	    result
	    (condition-case nil (org-babel-script-escape result)
	      (error result))))
      (delete-file tempfile))))

(provide 'ob-hy)
