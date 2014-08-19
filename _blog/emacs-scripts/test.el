
:;exec emacs -batch -l "$0" -f main "$@"

(defun main ()
  (print (version))
  (print (format "I did it. you passed in %s" command-line-args-left)))

;; Local Variables:
;; mode: emacs-lisp
;; End:
