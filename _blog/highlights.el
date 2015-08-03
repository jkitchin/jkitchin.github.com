;;; highlights.el --- Highlight text in emacs

;;; Commentary:
;;

(defun highlight-get-highlights ()
  "Scan buffer for list of highlighted regions.
These are defined only by the highlighted property. That means
adjacent highlighted regions will be merged into one region with
the color of the first one."
  (save-excursion
    (goto-char (point-min))
    (let ((highlights '())
	  (p)
	  (beg)
	  (end)
          (note)
	  (color))
      ;; corner case of first point being highlighted
      (when (get-text-property (point) 'highlighted)
	(setq beg (point)
	      end (next-single-property-change (point) 'highlighted)
	      color (background-color-at-point)
	      help-echo (get-text-property (point) 'help-echo))
	(add-to-list 'highlights (list beg end color help-echo) t)
	(goto-char end))

      ;; Now the rest of the buffer
      (while (setq p (next-single-property-change (point) 'highlighted))
	(setq beg (goto-char p))
	(setq color (background-color-at-point))
        (setq note (get-text-property (point) 'help-echo))
	(setq end (next-single-property-change (point) 'highlighted))
	(when (and beg end)
	  (goto-char end)
	  (add-to-list 'highlights (list beg
					 end
					 color
					 note)
		       t)
	  (goto-char end)))
      highlights)))

(defun highlight-save-filename ()
  "Return name of file to save overlays in."
  (when (buffer-file-name)
    (concat "." (file-name-nondirectory (buffer-file-name)) ".highlights")))

(defun highlight-save ()
  "Loop through buffer and save regions with property highlighted.
Save beginning, end of each region, color and help-echo on the
first character of the region. Delete highlight file if it is empty."
  (interactive)
  (let ((fname (highlight-save-filename))
	(highlights (highlight-get-highlights)))
    (if (and fname highlights)
	  (with-temp-file fname
	    (print highlights (current-buffer)))
	;; get rid of file if there are not highlights
	(when (and fname (file-exists-p fname))
	  (delete-file fname)))))

(add-hook 'after-save-hook 'highlight-save)

(defun highlight-load ()
  "Load and apply highlights."
  (interactive)
  (setq font-lock-extra-managed-props (delq 'help-echo font-lock-extra-managed-props))
  (let ((fname (highlight-save-filename)))
    (when (and fname (file-exists-p fname))
      (mapcar
       (lambda (entry)
	 (let ((beg (nth 0 entry))
	       (end (nth 1 entry))
	       (color (nth 2 entry))
	       (help-echo (nth 3 entry)))
	   (set-text-properties
	    beg end
	    `(font-lock-face (:background ,color)
			     help-echo ,help-echo
			     highlighted t))))
       (with-temp-buffer (insert-file-contents fname)
			 (read (current-buffer)))))))


(add-hook 'org-mode-hook 'highlight-load)

(defun highlight (beg end &optional color)
  "Highlight region from BEG to END with COLOR.
COLOR is selected from `helm-colors' when run interactively."
  (interactive "r")
  (unless (or (get-text-property (point) 'highlighted)
	      (region-active-p))
    (error "No region selected or not on a highlight."))
  (unless color
    (setq color (s-trim (helm-colors))))
  (if (get-text-property (point) 'highlighted)
      ;; update color
      (let ((beg (previous-single-property-change (point) 'highlighted))
	    (end (next-single-property-change (point) 'highlighted)))
	(set-text-properties
	 beg end
	 `(font-lock-face (:background ,color)
			  highlighted t)))
  (set-text-properties
   beg end
   `(font-lock-face (:background ,color)
		    highlighted t))))

(defun highlight-list ()
  "Make a list of highlighted text in another buffer. "
  (interactive)
  (let ((cb (current-buffer))
	(fname (buffer-file-name))
	(hls (mapcar
	      (lambda (entry)
		(list (nth 0 entry)
		      (buffer-substring (nth 0 entry) (nth 1 entry))))
	      (highlight-get-highlights))))
    (if hls
	(progn
	  (split-window-right)
	  (switch-to-buffer-other-window "*highlights*") (org-mode)
	  (setq buffer-read-only nil)
	  (erase-buffer)
	  (insert "Click on text to jump to the position.\n\n")

	  (dolist (s hls)
	    (let ((map (make-sparse-keymap)))
	      (define-key map [mouse-1]
		`(lambda ()
		   (interactive)
		   (find-file ,fname)
		   (goto-char ,(nth 0 s))))
	      (insert (propertize
		       (concat (nth 1 s) "\n")
		       'local-map map))))
	  (setq buffer-read-only t))
      (message "No highlights found."))))

(defun highlight-green ()
  "Highlight region in green."
  (interactive)
  (highlight (region-beginning) (region-end) "Darkolivegreen1"))

(defun highlight-yellow ()
  "Highlight region in yellow."
  (interactive)
  (highlight (region-beginning) (region-end) "Yellow"))

(defun highlight-blue ()
  "Highlight region in blue."
  (interactive)
  (highlight (region-beginning) (region-end) "LightBlue"))

(defun highlight-pink ()
  "Highlight region in pink."
  (interactive)
  (highlight (region-beginning) (region-end) "Pink"))

;; create the advice for use later
(defadvice mouse-set-region (after my-highlight () disable)
  "Highlight"
  (highlight-green))

(defun highlight-mouse-on ()
  "Turn on mouse highlighting"
  (interactive)
  (ad-enable-advice 'mouse-set-region 'after 'my-highlight)
  (ad-activate 'mouse-set-region))

(defun highlight-mouse-off ()
  (interactive)
  (ad-disable-advice 'mouse-set-region 'after 'my-highlight)
  (ad-deactivate 'mouse-set-region))

(defun highlight-picasso-blues ()
 (interactive)
 (save-excursion
   (let ((colors '("PowderBlue"
		   "Lightskyblue1"
		   "Lightskyblue2"
		   "Lightskyblue3"
		   "Lightskyblue4"))
	 (beg (region-beginning))
	 (end (region-end)))
     (goto-char beg)
     (while (< (point) (- end 1))
       (highlight (point) (+ 1 (point))
		  (nth (mod (- (point) (region-beginning)) (length colors)) colors))
       (forward-char)))))

(defun highlight-rainbow ()
 (interactive)
 (save-excursion
   (let ((colors '("Red1"
		   "Orange1"
		   "Yellow1"
		   "Darkolivegreen1"
		   "Skyblue1"
		   "Blue1"
		   "DarkViolet"))
	 (beg (region-beginning))
	 (end (region-end)))
     (goto-char beg)
     (while (< (point) (- end 1))
       (highlight (point) (+ 1 (point))
		  (nth (mod (- (point) (region-beginning)) (length colors)) colors))
       (forward-char)))))

(defun highlight-note (beg end color &optional note)
  "Highlight selected text and add NOTE to it as a tooltip."
  (interactive
   (list
    (region-beginning)
    (region-end)
    (s-trim (helm-colors))))
  (unless note (setq note (read-input "Note: ")))
  (unless (region-active-p)
    (error "No region selected."))
  (set-text-properties
   beg end
   `(help-echo ,note font-lock-face (:background ,color)
	       highlighted t)))


(defun highlight-note-edit (new-note)
  "Set tooltip of highlight at point to NEW-NOTE."
  (interactive (list (read-input "Note: " (get-text-property (point) 'help-echo))))
  (let* ((region (button-lock-find-extent (point) 'highlighted))
	 (beg (car region))
	 (end (cdr region)))
    (put-text-property beg end 'help-echo new-note)))

(defun highlight-clear ()
  "Clear highlight at point."
  (interactive)
  (when (get-text-property (point) 'highlighted)
    (set-text-properties
     (next-single-property-change (point) 'highlighted)
     (previous-single-property-change (point) 'highlighted)
     nil)))


(defun highlight-clear-all ()
  "Clear all highlights.
They are really deleted when you save the buffer."
  (interactive)
  (mapcar
   (lambda (entry)
     (let ((beg (nth 0 entry))
	   (end (nth 1 entry)))
       (set-text-properties
	beg end nil)))
   (highlight-get-highlights))
  (when (get-buffer "*highlights*")
    (kill-buffer "*highlights*")))

(defhydra highlighter (:color blue) "highlighter"
  ("b" highlight-blue "blue")
  ("g" highlight-green "Green")
  ("p" highlight-pink "Pink")
  ;; define as many special colors as you like.
  ("s" (highlight (region-beginning) (region-end) "Lightsalmon1") "Salmon")
  ("y" highlight-yellow "yellow")
  ("c" highlight "Choose color")
  ("n" (highlight-note (region-beginning) (region-end) "Thistle") "Note")
  ("N" highlight-note "Note (c)")
  ("m" highlight-mouse-on "Mouse")
  ("M" highlight-mouse-off "Mouse off")
  ("e" highlight-note-edit "Edit note")
  ("l" highlight-list "List highlights")
  ("r" highlight-load "Reload")
  ("S" highlight-save "Save")
  ("d" highlight-clear "Delete")
  ("D" highlight-clear-all "Delete All"))

(easy-menu-change
 '("Org") "highlighter"
 '(["Highlight" highlight]
   ["Highlight (B)" highlight-blue]
   ["Highlight (G)" highlight-green]
   ["Highlight (P)" highlight-pink]
   ["Highlight (Y)" highlight-yellow]
   ["Highlight note" highlight-note]
   ["List highlights" highlight-list]
   ["Delete highlight" highlight-clear]
   ["Delete highlights" highlight-clear-all])
 "Show/Hide")

(provide 'highlights)

;;; highlights.el ends here
