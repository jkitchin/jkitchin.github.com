
(defclass Atom ()
  ((symbol :initarg :symbol
	   :documentation "A string for the chemical symbol")
   (x :initarg :x
      :documentation "The x coordinate")
   (y :initarg :y
      :documentation "The y coordinate")
   (z :initarg :z
      :documentation "The z coordinate"))
 "A class to represent an atom.")

(provide 'Atom)
