;;; cappa.el --- Catalysis Preprint Archive          -*- lexical-binding: t; -*-

;; Copyright (C) 2016  John Kitchin

;; Author: John Kitchin <jkitchin@andrew.cmu.edu>
;; Keywords:
;; Package-Version: 20160130.1058

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(defvar cappa-preprints '()
  "Contains a list of installed preprints.")

(defun cappa (preprint-label &rest args)
  "Register the symbol PREPRINT-LABEL in `cappa-preprints'."
  (pushnew (cons preprint-label args) cappa-preprints)
  (cappa-open preprint-label))


(defmacro cappa-open (preprint-label)
  "Create function to open PREPRINT-LABEL."
  `(defun ,(intern (format "cappa-%s" preprint-label)) ()
     (interactive)
     (find-file (expand-file-name
	      "README.org"
	      (file-name-directory
	       (locate-library ,(symbol-name preprint-label)))))))
(cappa-open kitchingroup-43)

(provide 'cappa)
;;; cappa.el ends here
