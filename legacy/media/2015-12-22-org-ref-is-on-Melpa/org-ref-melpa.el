(setq user-emacs-directory "~/Desktop/org-ref-example/sandbox")

(require 'cl)
(require 'package)
(setq package-archives
      '(("org" . "http://orgmode.org/elpa/")
	("gnu" . "http://elpa.gnu.org/packages/")
	("melpa" . "http://melpa.org/packages/")))

(package-initialize)

(let ((packages (list 'org-plus-contrib 'org-ref)))
  ; refresh if needed.
  (unless (cl-every #'package-installed-p packages)
    (package-refresh-contents))
  
  (dolist (package packages)
    (unless (package-installed-p package)
      (package-install package))))

;; wrap lines
(global-visual-line-mode 1)

;; setup org-ref
(setq org-ref-bibliography-notes "~/Desktop/org-ref-example/notes.org"
      org-ref-default-bibliography '("~/Desktop/org-ref-example/references.bib")
      org-ref-pdf-directory "~/Desktop/org-ref-example/bibtex-pdfs/")

(unless (file-exists-p org-ref-pdf-directory)
  (make-directory org-ref-pdf-directory t))

;; Some org-mode customization
(setq org-src-fontify-natively t
      org-confirm-babel-evaluate nil
      org-src-preserve-indentation t)

(org-babel-do-load-languages
 'org-babel-load-languages '((python . t)))

(setq org-latex-pdf-process
      '("pdflatex -interaction nonstopmode -output-directory %o %f"
	"bibtex %b"
	"pdflatex -interaction nonstopmode -output-directory %o %f"
	"pdflatex -interaction nonstopmode -output-directory %o %f"))

(setq bibtex-autokey-year-length 4
      bibtex-autokey-name-year-separator "-"
      bibtex-autokey-year-title-separator "-"
      bibtex-autokey-titleword-separator "-"
      bibtex-autokey-titlewords 2
      bibtex-autokey-titlewords-stretch 1
      bibtex-autokey-titleword-length 5)

(require 'dash)
(setq org-latex-default-packages-alist
      (-remove-item
       '("" "hyperref" nil)
       org-latex-default-packages-alist))

;; Append new packages
(add-to-list 'org-latex-default-packages-alist '("" "natbib" "") t)
(add-to-list 'org-latex-default-packages-alist
	     '("linktocpage,pdfstartview=FitH,colorlinks,
linkcolor=blue,anchorcolor=blue,
citecolor=blue,filecolor=blue,menucolor=blue,urlcolor=blue"
	       "hyperref" nil)
	     t)

;; some requires for basic org-ref usage
(require 'org-ref)
(require 'org-ref-pdf)
(require 'org-ref-url-utils)

