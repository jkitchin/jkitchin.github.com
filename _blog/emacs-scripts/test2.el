#!/usr/bin/emacs --script

(defun main ()
  (print (version))
  (print (format "I did it. you passed in %s" command-line-args-left)))

(main)
;; Local Variables:
;; mode: emacs-lisp
;; End:
