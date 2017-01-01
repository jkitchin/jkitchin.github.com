;;; org-db.el --- An org database

;;; Commentary:
;;

(require 'emacsql-sqlite)

(defcustom org-db-root "~/org-db/"
  "Root directory for db files."
  :group 'org-db)

(unless (file-directory-p org-db-root)
  (make-directory org-db-root t))

(defvar org-db (emacsql-sqlite (expand-file-name "org-db.sqlite" org-db-root)))


(condition-case nil (emacsql org-db [:select * :from links])
  (error (emacsql org-db [:create-table links
					([(id integer :primary-key)
					  filename
					  type
					  path
					  raw-link
					  description
					  search-option
					  begin])])))

(condition-case nil (emacsql org-db [:select * :from headlines])
  (error (emacsql org-db
		  [:create-table headlines
				 ([(id integer :primary-key)
				   filename
				   title
				   level
				   tags
				   todo-keyword
				   todo-type
				   priority
				   scheduled
				   deadline
				   archived-p
				   commented-p
				   begin])])))




(defun org-db-clean-db ()
  "Check all files in the db exist and delete those that don't."
  (loop for (fname) in (emacsql org-db [:select :distinct [filename] :from links])
	do
	(unless (file-exists-p fname)
	  (emacsql org-db [:delete :from links :where (= filename $s1)] fname) 
	  (message "links for %s were removed from the link table." fname)))
  (loop for (fname) in (emacsql org-db [:select :distinct [filename] :from headlines])
	do
	(unless (file-exists-p fname)
	  (emacsql org-db [:delete :from headlines :where (= filename $s1)] fname)
	  (message "links for %s were removed from the headlines table." fname))))


(defun org-db-link-update ()
  "Update the database with links in the current buffer."
  (interactive)
  (emacsql org-db [:delete :from links :where (= filename $s1)] (buffer-file-name))
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward org-any-link-re nil t)
      (let ((link (save-excursion (goto-char (match-beginning 0)) (org-element-context))))
	(emacsql org-db [:insert :into links :values $v1]
		 (list (vector 
			nil
			(buffer-file-name)
			(org-element-property :type link)
			(org-element-property :path link)
			(org-element-property :raw-link link)
			(if (org-element-property :contents-begin link)
			    (buffer-substring-no-properties
			     (org-element-property :contents-begin link)
			     (org-element-property :contents-end link))
			  "")			   
			(org-element-property :search-option link)
			(org-element-property :begin link))))))))

(defun org-db-headlines-update ()
  "Update the database with headlines in the current buffer."
  (interactive)
  (emacsql org-db [:delete :from headlines :where (= filename $s1)] (buffer-file-name))
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward org-heading-regexp nil t)
      (let ((hl (save-excursion (goto-char (match-beginning 0)) (org-element-context))))
	(emacsql org-db [:insert :into headlines :values $v1]
		 (list (vector 
			nil
			(buffer-file-name)
			(org-element-property :title hl)
			(org-element-property :level hl)
			(org-element-property :tags hl)
			(org-element-property :todo-keyword hl)
			(org-element-property :todo-type hl) 
			(org-element-property :priority hl)
			(org-element-property :scheduled hl)
			(org-element-property :deadline hl)
			(org-element-property :archived-p hl)
			(org-element-property :commented-p hl) 
			(org-element-property :begin hl))))))))


(defun org-db-link-query (query)
  "Search for and open links using QUERY.
QUERY is an unquoted form that is used in a where clause of the
query. Here are some examples:
 (= type \"cite\")  find all links of type cite
 (glob path \"*kitchin*\") find all links whose path matches *kitchin*
 (and (= type \"cite\") (glob path \"mathias*\"))

Note: this function only works interactively. I don't know how to
enter the query as an unevaluated sexp in code.
"
  (interactive "xQuery: ") 
  (let* ((results (eval `(emacsql org-db [:select [filename raw-link description begin]
						  :from links :where ,query])))
	 (candidates (loop for result in results
			   collect
			   (list (format "%s | %s" (nth 1 result) (nth 0 result))
				 (nth 0 result)
				 (nth 3 result))))
	 (choice (completing-read "Open: " candidates))
	 (data (assoc choice candidates))
	 (fname (nth 1 data))
	 (pos (nth 2 data)))
    (find-file fname)
    (goto-char pos)))


;; add local hooks to org-mode files. Update on opening, and saving.
(add-hook
 'org-mode-hook
 (lambda ()
   (org-db-link-update)
   (org-db-headlines-update)
   (message "Updated links database!")
   (add-hook 'after-save-hook
	     (lambda ()
	       (org-db-link-update)
	       (org-db-headlines-update))
	     nil t)))




;; * End
(provide 'org-db)

;;; org-db.el ends here
