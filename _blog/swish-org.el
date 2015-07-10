
:;exec emacs -batch -l $0 "$@"
(require 'org)
(require 'xml)
(require 'cl)

(add-to-list 'load-path "~/Dropbox/kitchingroup/jmax/elpa/f-20140828.716")
(add-to-list 'load-path "~/Dropbox/kitchingroup/jmax/elpa/s-20140910.334")
(add-to-list 'load-path "~/Dropbox/kitchingroup/jmax/elpa/dash-20141201.2206")
(require 'f)

(add-to-list 'load-path "~/Dropbox/kitchingroup/jmax")
(require 'swish-org-xml)

(loop for dir in '("/Users/jkitchin/blogofile-jkitchin.github.com/_blog"
		   "/Users/jkitchin/blogofile-jkitchin.github.com/_site")
      do
      (loop for fname in (f-entries
			  dir
			  (lambda (x)
			    (string=  "org"  (file-name-extension x)))
			  t)
	    do (ignore-errors
		 (princ (process-file fname)))))
