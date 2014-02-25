(require 'techela)
(require 'twittering-mode)
(require '15-110)

;;;###autoload
(defun 21-126 ()
  "Open the course syllabus"
  (interactive)
  (find-file (get-pkg-file '21-126 "syllabus.org")))

(defun 21-126-tweet (msg)
  (interactive "sTweet: ")
  (twittering-update-status (concat msg " #21126")))

(global-set-key "\C-ct" '21-126-tweet)

(defun 21-126-agenda ()
  (interactive)
  (let ((org-agenda-files '("syllabus.org")))
    (org-agenda "" "d")))

(easy-menu-define 21-126-menu global-map "My menu"
  '("21-126-course"
    ["Course home" 21-126]
    ["Course agenda" 21-126-agenda]
    ["email" course-email]
    ["tweet" 21-126-tweet]
    ["pydoc" pydoc]
    ))

(global-set-key "\C-ce" 'course-email)

(provide '21-126)
