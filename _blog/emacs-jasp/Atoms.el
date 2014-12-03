
(defclass Atoms ()
  ((atoms :initarg :atoms
	  :documentation "A list of `Atom' objects")
   (cell :initarg :cell
	 :documentation "A 3-tuple of lengths of an orthorhombic unit cell"))
  "A class to represent an atoms object.")


(defmethod get-atom ((atoms Atoms) &rest args)
  "Get a list of atoms in ARGS.
Return atom if ARGS contains one element, a list of atom objects
otherwise."
  (cond
   ((= 1 (length args))
    (elt (oref atoms atoms) (car args)))
   (t
    (mapcar (lambda (i)
	      (elt (oref atoms atoms) i))
	    args))))

(provide 'Atoms)
