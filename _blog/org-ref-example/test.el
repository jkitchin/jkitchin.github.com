(require 'package)

(setq package-archives
'(("org" . "http://orgmode.org/elpa/")
  ("gnu" . "http://elpa.gnu.org/packages/")
  ("melpa" . "http://melpa.org/packages/")))

(package-initialize)

(setq reftex-default-bibliography '("~/stok/Biblio/biblio.bib"))

;; see org-ref for use of these variables
(setq org-ref-bibliography-notes "~/stok/Biblio/biblio-notes.org")
(setq org-ref-default-bibliography '("~/stok/Biblio/biblio.bib"))
(setq org-ref-pdf-directory "~/stok/Biblio/")

(setq helm-bibtex-bibliography "~/stok/Biblio/biblio.bib")
(setq helm-bibtex-library-path "~/stok/Biblio")

(setq helm-bibtex-pdf-open-function 'org-open-file)

(setq helm-bibtex-notes-path "~/stok/Biblio")

(require 'org-ref)
(require 'org-ref-latex)
(require 'org-ref-pdf)
(require 'org-ref-url-utils)