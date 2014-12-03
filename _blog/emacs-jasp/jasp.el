
(defmacro with-current-directory (directory &rest body)
  "Set the working directory temporarily set to DIRECTORY and run BODY.
DIRECTORY is expanded, and create it and its parents if needed."
  `(progn
     (unless (file-exists-p (file-name-as-directory
			     (expand-file-name ,directory)))
       (make-directory ,directory t))
     
     (let ((default-directory (file-name-as-directory
				(expand-file-name ,directory)))) 
	,@body)))


(defclass Jasp ()
  ((wd :initarg :wd
       :initform "."  ; default to the current working directory
       :documentation "Directory to run calculation in.")
   (encut :initarg :encut
	  :documentation "Positive number in eV for planewave cutoff.
See URL `http://cms.mpi.univie.ac.at/vasp/vasp/ENCUT_tag.html'.")
   (nbands :initarg :nbands
	   :documentation "Integer number of bands.
See URL `http://cms.mpi.univie.ac.at/vasp/vasp/NBANDS_tag.html'.")
   (kpts :initarg :kpts
	 :initform (1 1 1)  ; default value
	 :documentation "3-tuple for Monkhorst-Pack K-point grid.")
   (xc :initarg :xc
       :documentation "String of exchange correlation functional.")
   (atoms :initarg :atoms
	  :documentation "An `Atoms' object."))
 "A class to represent a calculator that runs VASP.")


(defmethod view-atoms ((calc Jasp))
  "Open the ase-gui"
  (unless (and (file-exists-p "POSCAR")
	       (file-exists-p "POTCAR"))
    (write-poscar calc)
    (write-potcar calc))
  (shell-command "ase-gui POSCAR"))


(defmethod write-poscar ((calc Jasp))
  "create a POSCAR file for CALC."
  (with-temp-file "POSCAR"
    (insert "Created by jasp.el\n")
    (insert "  1.0") ; unit cell scale factor
    (let* ((atoms (oref calc atoms))
	   (cell (oref atoms cell)))
      (loop for v in cell
	    for i below (length cell)	  
	    do
	    (insert "\n")
	    (loop for j below (length cell)
		  do
		  (if (equal i j)
		      (insert (format " %f " (float (elt cell i))))
		    (insert (format " %f " 0.0 ))))))
    ;; The next line is counts for each atom type. For each number in
    ;; this line, there will be a copy of the POTCAR in the POTCAR
    ;; file. In ase, we sort the atoms and group them so that there is
    ;; only one POTCAR per atom. We do not do that here yet. We will
    ;; have a POTCAR for each atom.
    (insert "\n")
    (loop for atom in (oref (oref calc atoms) atoms)
	  do (insert (format "1 ")))
    
    ;; now we do the atoms
    (insert "\nCartesian\n")
    (loop for atom in (oref (oref calc atoms) atoms)
	  do
	  (insert
	   (format "%f %f %f\n"
		   (oref atom x)
		   (oref atom y)
		   (oref atom z))))
    (buffer-string)))


(defmethod write-kpoints ((calc Jasp))
  "Create KPOINTS file for CALC. 
Limited to automatic generation, and no offset."
  (with-temp-file "KPOINTS"
    (insert "Automatic mesh
0
Monkhorst-Pack
")
    (dolist (k (oref calc kpts))
      (insert (format "%4d " k)))
    (insert "\n0.0 0.0 0.0")
    (buffer-string)))


(defmethod write-potcar ((calc Jasp))
  "Generate the POTCAR file for CALC.
No `Atom' grouping is done, there is one POTCAR for each atom."
  (with-temp-file "POTCAR"
    (let ((xc (oref calc xc))
	  (atoms (oref calc atoms))
	  (vasp_pp_path (getenv "VASP_PP_PATH")))
      (loop for atom in (oref atoms atoms)
	    do
	    (insert-file-contents
	     (f-join
	      vasp_pp_path
	      (concat "potpaw_" xc)
	      (oref atom symbol)
	      "POTCAR"))))
    (buffer-string)))


(defmethod write-incar ((calc Jasp))
  "Generate the INCAR file for CALC."
  (with-temp-file "INCAR"
    (insert (format "ENCUT = %f\n" (oref calc encut)))
    (insert (format "NBANDS = %d\n" (oref calc nbands)))
    (buffer-string)))


(defmethod run ((calc Jasp))
  "Write out input files, and run VASP as a simple shell command"
  (write-poscar calc)
  (write-kpoints calc)
  (write-potcar calc)
  (write-incar calc)
  (shell-command "vasp"))


(defmethod update ((calc Jasp))
  "Run vasp if needed for CALC.
We just check for a properly ended OUTCAR."
  (with-current-directory
   (oref calc wd)
   (unless (and (file-exists-p "OUTCAR")
		(with-temp-buffer
		  (insert-file-contents "OUTCAR")
		  (re-search-forward
		  "                 Voluntary context switches:"
		  (point-max)
		  t)))
     (run calc))))


(defmethod get-potential-energy ((calc Jasp))
  "Get potential energy from CALC."
  (update calc)
  (with-current-directory
   (oref calc wd)
   (with-temp-buffer
     (insert-file-contents "OUTCAR")
     ;; go to last entry
     (while (re-search-forward
	     "free  energy   TOTEN  =\\s-*\\([-]?[0-9]*\\.[0-9]*\\) eV"
	     (point-max)
	     t)
       nil)
     ;; return last match
     (string-to-number  (match-string 1)))))

(provide 'jasp)
