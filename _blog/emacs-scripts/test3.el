#!/usr/bin/emacs --script

(defun main ()
  (print (version))
  (print (format "Called with %s" command-line-args))
  (print (format "I did it. you passed in %s" command-line-args-left)))

(main)
;; Local Variables:
;; mode: emacs-lisp
;; End:
