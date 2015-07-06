
;;; ob-sudo.el --- An org-mode source block to run shell commands as sudo

;;; Commentary:
;; Runs the block of code as a shell command with sudo.

;;; Code:

(defun org-babel-execute:sudo (body params)
  "Run BODY as a shell command using sudo."
  (let* ((passwd (shell-quote-argument (read-passwd "Password? ")))
	 (result (shell-command-to-string
		  (concat "echo " passwd
			  " | sudo -S " body))))
    ;; this is verbatim from ob-emacs-lisp
    (org-babel-result-cond (cdr (assoc :result-params params))
      (let ((print-level nil)
	    (print-length nil))
	(if (or (member "scalar" (cdr (assoc :result-params params)))
		(member "verbatim" (cdr (assoc :result-params params))))
	    (format "%S" result)
	  (format "%s" result)))
      (org-babel-reassemble-table
       result
       (org-babel-pick-name (cdr (assoc :colname-names params))
			    (cdr (assoc :colnames params)))
       (org-babel-pick-name (cdr (assoc :rowname-names params))
			    (cdr (assoc :rownames params)))))))

(provide 'ob-sudo)
;;; ob-sudo.el ends here
