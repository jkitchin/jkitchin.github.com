
(print (do  (defn ? [sym]
  "Return doc string for the symbol SYM in hylang."

  (import hy)

  (cond
   [(in (name sym) (. hy core language *exports*))
    (.format "{0} is in hy.core.language\n\n  {1}\n\n  [[{2}::{3}]]"
             (name sym)
             (eval `(. hy core language ~sym __doc__))
             (eval `(. hy core language ~sym __code__ co_filename))
             (eval `(. hy core language ~sym __code__ co_firstlineno)))]

   [(in (name sym) (. hy core shadow *exports*))
    (.format "{0} is in hy.core.shadow\n\n  {1}\n\n [[{2}::{3}]]"
             (name sym)
             (eval `(. hy core shadow ~sym __doc__))
             (eval `(. hy core shadow ~sym __code__ co_filename))
             (eval `(. hy core shadow ~sym __code__ co_firstlineno)))]

   [(in (name sym) (.keys (get hy.macros._hy_macros nil)))
    (.format "{0} is a macro.\n\n  {1}\n\n[[{2}::{3}]]"
             (name sym)
             (. (get hy.macros._hy_macros nil (name sym))  __doc__)
             (. (get hy.macros._hy_macros nil (name sym)) func_code co_filename)
             (. (get hy.macros._hy_macros nil (name sym))
                func_code co_firstlineno))]
   ;; default to python
   [true (print "python:" )(help sym)]))
))
