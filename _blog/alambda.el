;; -*- lexical-binding: t -*-

;; Graham's alambda
(defmacro alambda (parms &rest body)
  `(cl-labels ((self ,parms ,@body))
     #'self))

(setq
 N
 (alambda (n)
	  (if (> n 0)
	      (cons
	       n
	       (self (- n 1))))))

(princ (funcall N 3))
