(TeX-add-style-hook "writing-exams-in-orgmode"
 (lambda ()
    (LaTeX-add-labels
     "sec-1"
     "sec-1-1"
     "sec-1-1-1"
     "sec-1-1-2"
     "sec-1-1-2-1"
     "sec-1-1-2-2"
     "sec-1-1-3"
     "sec-1-2"
     "sec-1-3")
    (TeX-run-style-hooks
     "hyperref"
     "linktocpage"
     "colorlinks"
     "minted"
     "latex2e"
     "art11"
     "article"
     "11pt")))

