;;; contacts.el --- Contact manager for org-mode


;;; Commentary:
;; 

;;; Code:

(defvar contacts-files '("/Users/jkitchin/Dropbox/org-mode/contacts/advisees.org"
			 "/Users/jkitchin/Dropbox/org-mode/contacts/aiche-chairs.org"
			 "/Users/jkitchin/Dropbox/org-mode/contacts/alumni.org" 
			 "/Users/jkitchin/Dropbox/org-mode/contacts/cmu-contacts.org"
			 "/Users/jkitchin/Dropbox/org-mode/contacts/contacts.org"
			 "/Users/jkitchin/Dropbox/org-mode/contacts/cre-contacts.org"
			 "/Users/jkitchin/Dropbox/org-mode/contacts/department-contacts.org"
			 "/Users/jkitchin/Dropbox/org-mode/contacts/department-seminars.org"
			 "/Users/jkitchin/Dropbox/org-mode/contacts/group-contacts.org"
			 "/Users/jkitchin/Dropbox/org-mode/contacts/laird.org")
  
  "A list of org-files to retrieve contacts from.")


(defvar contacts-cache-file "~/.contacts-cache"
  "File to store cached contacts in.")


(defvar contacts-cache-data
  '((hashes . ())
    (contacts . ()))
  "Cache data as an a-list.
'hashes is a list of cons cells (contact-file . hash)
'contacts are a list of cons cells (contact-file . contacts)
These are stored persistently in `contacts-cache-file'.")

(defvar contacts '()
  "List of contacts. (display-string property-a-list)")

;; * load and clear cache functions
(defun contacts-load-cache-file ()
  "Load the cache file to set `contacts-cache-data'."
  (when (file-exists-p contacts-cache-file)
    (with-temp-buffer
      (insert-file-contents contacts-cache-file)
      (setq contacts-cache-data (read (current-buffer))))))


(defun contacts-clear-cache ()
  "Reset `contacts-cache-data' and delete cache file."
  (setq contacts '()
	contacts-cache-data '((hashes . nil)
			      (contacts . nil)))

  (when (file-exists-p contacts-cache-file)
    (delete-file contacts-cache-file))
  (message "cleared"))


(defun contacts-known-hash (fname)
  "Return the known hash for FNAME."
  (cdr (assoc fname (cdr (assoc 'hashes contacts-cache-data)))))


(defun contacts-known-contacts (fname)
  "Return the known hash for FNAME."
  (cdr (assoc fname (cdr (assoc 'contacts contacts-cache-data)))))


(defun contacts-update-cache ()
  "Update cache for each file in `contacts-files' if needed."
  (setq contacts
	(cl-loop for contacts-file in contacts-files
		 append
		 (with-temp-buffer
		   (insert-file-contents contacts-file)
		   ;; return the known results if hash matches
		   (let* ((hash (secure-hash 'sha256 (current-buffer)))
			  (results)) 
		     (setq results (if (string=
					hash
					(or (contacts-known-hash contacts-file) ""))
				       (contacts-known-contacts contacts-file)
				     ;; we need to get the results
				     (org-mode) (goto-char (point-min))
				     (org-map-entries
				      (lambda ()
					(append 
					 (list
					  ;; display string
					  (format "%35s | %40s | %s"
						  (org-no-properties
						   (org-get-heading t t))
						  (org-entry-get (point) "EMAIL")
						  (s-join ":" (org-get-tags-at))))
					 ;; since we use a temp buffer we have to set the file here.
					 (let ((properties (org-entry-properties)))
					   (setf (cdr (assoc "FILE" properties)) contacts-file)
					   properties)
					 
					 (list
					  (cons "NAME" (org-no-properties
							(org-get-heading t t)))
					  (cons "POSITION" (point)))))
				      "EMAIL<>\"\"")))

		     (unless (string= hash
				      (or (contacts-known-hash contacts-file) "")) 
		       ;; update the cache
		       (let ((place (cdr (assoc contacts-file
						(cdr (assoc 'hashes contacts-cache-data))))))
			 (if place
			     (setf place hash)
			   (cl-pushnew (cons contacts-file hash)
				       (cdr (assoc 'hashes contacts-cache-data)))))

		       (let ((place (cdr (assoc contacts-file
						(cdr (assoc 'contacts contacts-cache-data))))))
			 (if place
			     (setf place results)
			   (cl-pushnew (cons contacts-file results)
				       (cdr (assoc 'contacts contacts-cache-data)))))
		       
		       (with-temp-file contacts-cache-file
			 (print contacts-cache-data (current-buffer))))
		     results)))))


;;;###autoload
(defun ivy-contacts (arg)
  "Select contacts using ivy."
  (interactive "P")
  (when arg
    (setq contacts-cache-data '((hashes . ())
				(contacts . ()))))
  (contacts-update-cache)
  (ivy-read "Contact: " contacts
	    :action '(1
		      ("i" (lambda (contact)
			     (with-ivy-window
			       (unless (or (eolp)
					   (looking-at "\\>"))
				 (re-search-forward "\\>"))
			       (when (not (looking-back " ")) (insert ","))
			       (insert (cdr (assoc "EMAIL" contact)))))
		       "Insert email")
		      ("o" (lambda (contact)
			     (find-file (cdr (assoc "FILE" contact)))
			     (goto-char (cdr (assoc "POSITION" contact)))
			     (outline-show-entry))
		       "Open contact")
		      ("e" (lambda (contact)
			     (compose-mail)
			     (message-goto-to)
			     (insert (cdr (assoc "EMAIL" contact)))
			     (message-goto-subject))
		       "Email contact")
		      ("q" nil "Quit"))))

(provide 'contacts)

;;; contacts.el ends here

