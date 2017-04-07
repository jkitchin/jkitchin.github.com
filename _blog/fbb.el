;;; fbb --- fix typos in a buffer  -*- lexical-binding: t; -*-

(defun flyspell-buffer-buffer ()
  "Return list of word, point line"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (flyspell-buffer)
    (let ((cb (current-buffer))
	  (ov (ov-next 'face 'flyspell-incorrect))
	  (sp '()))
      (while ov
	(goto-char (ov-beg ov))
	(push (list (buffer-substring (ov-beg ov) (ov-end ov))
		    (point)
		    (line-number-at-pos))
	      sp)
        (goto-char (ov-end ov))
	(setq ov (ov-next 'face 'flyspell-incorrect)))
      (reverse sp))))


(defun fbb-jump ()
  "Jump to position of typo."
  (interactive)
  (let ((buf (get-text-property (line-beginning-position) 'ov-buffer))
	(pos (get-text-property (line-beginning-position) 'ov-position)))
    (switch-to-buffer-other-window buf)
    (goto-char pos)))

(defvar fbb-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "o") 'fbb-jump)
    map))


(defun fbb-refresh-list ()
  (let ((entries))
    (with-current-buffer fbb-source-buffer
      (setq entries (flyspell-buffer-buffer)))
    (setq tabulated-list-entries (loop for (word pos ln) in entries
				       collect
				       (list
					nil
					(vector
					 (cons (format "%s" ln) (list 'ov-buffer fbb-source-buffer
								      'ov-position pos))
					 (cons word (list 'ov-buffer fbb-source-buffer
							  'ov-position pos))
					 "help!")))
	  tabulated-list-format (vector
				 '("Line #" 5 t)
				 '("Word" 40 t))))
  (tabulated-list-init-header)
  (tabulated-list-print))


(define-derived-mode fbb-mode
  tabulated-list-mode "fbb"
  "Mode for viewing flyspell-buffer-buffer candidates as a tabular list.
\\{fbb-mode-map}"
  (setq tabulated-list-sort-key nil)
  (add-hook 'tabulated-list-revert-hook
	    #'fbb-refresh-list))



(defvar fbb-source-buffer nil
  "Buffer to list typos in.")

(defun fbb ()
  (interactive)
  (setq fbb-source-buffer (current-buffer))
  (switch-to-buffer-other-window (get-buffer-create "*fbb*"))
  (fbb-mode)
  (fbb-refresh-list))
