
:;exec emacs -batch -l $0 "$@"

(defun nomessage (arg &rest args) nil)

(advice-add 'message :around #'nomessage)

(load-file "~/Dropbox/kitchingroup/jmax/init.el")

:;exec emacs -batch -l $0 "$@"
(defun message (arg &rest args) nil)

(with-output-to-string
  (load-file "~/Dropbox/kitchingroup/jmax/init.el"))
