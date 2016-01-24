;;; org-ref-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (or (file-name-directory #$) (car load-path)))

;;;### (autoloads nil "org-ref" "org-ref.el" (22141 16821 0 0))
;;; Generated autoloads from org-ref.el

(autoload 'org-ref "org-ref" "\
Opens a helm interface to actions for ‘org-ref’.
Shows bad citations, ref links and labels

\(fn)" t nil)

(autoload 'org-ref-helm-insert-cite-link "org-ref" "\
Insert a citation link with ‘helm-bibtex’.
With one prefix ARG, insert a ref link.
With two prefix ARGs, insert a label link.

\(fn ARG)" t nil)

(autoload 'org-ref-cite-click-helm "org-ref" "\
Open helm for actions on a cite link.
subtle points.

1. get name and candidates before entering helm because we need
the org-buffer.

2. switch back to the org buffer before evaluating the
action.  most of them need the point and buffer.

KEY is returned for the selected item(s) in helm.

\(fn KEY)" t nil)

;;;***

;;;### (autoloads nil nil ("doi-utils.el" "nist-webbook.el" "org-ref-arxiv.el"
;;;;;;  "org-ref-bibtex.el" "org-ref-isbn.el" "org-ref-latex.el"
;;;;;;  "org-ref-pdf.el" "org-ref-pkg.el" "org-ref-pubmed.el" "org-ref-sci-id.el"
;;;;;;  "org-ref-scifinder.el" "org-ref-scopus.el" "org-ref-url-utils.el"
;;;;;;  "org-ref-worldcat.el" "org-ref-wos.el" "x2bib.el") (22141
;;;;;;  16821 874678 0))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; org-ref-autoloads.el ends here
