
:;exec emacs -batch -l $0 -f main "$@"
(require 'org)
;(add-to-list 'load-path "/Users/jkitchin/Dropbox/kitchingroup/jmax/elpa")
;(add-to-list 'load-path "/Users/jkitchin/Dropbox/kitchingroup/jmax/org-ref")
;(setq package-user-dir "/Users/jkitchin/Dropbox/kitchingroup/jmax/elpa")
;(package-initialize)
;(require 'org-ref)
(defun main ()
  (find-file (car command-line-args-left))
  (org-html-export-as-html nil nil nil t)
  (switch-to-buffer "*Org HTML Export*")
  (print (buffer-string)))

;; Local Variables:
;; mode: emacs-lisp
;; End:
