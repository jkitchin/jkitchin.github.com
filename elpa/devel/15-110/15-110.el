(require 'techela)

;;;###autoload
(defun 15-110 ()
  "Open the course syllabus"
  (interactive)
  (find-file (get-pkg-file '15-110 "syllabus.org")))


(defun pydoc (arg)
  "Run pydoc on arg"
  (interactive "spydoc: ")
  (shell-command (format "python -m pydoc %s" arg) nil))

;; these allow me to write mod:numpy or func:numpy.dot to get
;; clickable links to documentation
(org-add-link-type
 "pydoc"
 (lambda (arg)
   (shell-command (format "python -m pydoc %s" arg) nil)))

(provide '15-110)
