;; Copyright (c) 2016 John Kitchin <jkitchin@andrew.cmu.edu>

;; Permission is hereby granted, free of charge, to any person obtaining a
;; copy of this software and associated documentation files (the "Software"),
;; to deal in the Software without restriction, including without limitation
;; the rights to use, copy, modify, merge, publish, distribute, sublicense,
;; and/or sell copies of the Software, and to permit persons to whom the
;; Software is furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be included in
;; all copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
;; THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;; DEALINGS IN THE SOFTWARE.

;;;; A module of help-related functions.
;;;;

(import hy)
(import re)

(defn hy-language-keywords []
  "Return list of functions in hy.core.language"
  (. hy core language *exports*))

(defn hy-shadow-keywords []
  "Return list of shadowed functions"
  (. hy core shadow *exports*))

(defn hy-macro-keywords []
  "Return list of macro keywords"
  (.keys (get hy.macros._hy_macros nil)))

(defn hy-compiler-keywords []
  "Return a list of keywords defined in compiler.py with @build.
These are read out of the hy/compiler.py file."
  (let [keywords {}]
    (with [f (open (.replace  (. hy compiler __file__) ".pyc" ".py"))]
          (for [(, i line) (enumerate (.readlines f))]
            (when (re.search "@build" line)
              (let [m (re.search "\"(.*)\"" line)]
                (when m
                  (assoc keywords (get (.groups m) 0)
                         (, (.replace  (. hy compiler __file__)
                                       ".pyc" ".py")
                            ;; add one because lines start at 1 not 0
                            (+ 1 i))))))))
    keywords))

(defmacro hylp-info [sym]
  "Return Usage, docstring filename, lineno for the string SYM."
  `(cond
    [(in ~sym (hy-language-keywords))
     (,  (.format
          "({0} {1})"
          ~sym
          (if (hasattr (. hy core language ~(HySymbol sym)) "__code__")
            (get-args
             (get-code
              (. hy core language ~(HySymbol sym) __code__ co_filename)
              (. hy core language ~(HySymbol sym) __code__ co_firstlineno)))
            "unknown args"))
         (. hy core language ~(HySymbol sym) __doc__)
         (if (hasattr (. hy core language ~(HySymbol sym)) "__code__")
           (. hy core language ~(HySymbol sym) __code__ co_filename)
           "no code")
         (if (hasattr (. hy core language ~(HySymbol sym)) "__code__")
           (. hy core language ~(HySymbol sym) __code__ co_firstlineno)
           -1))]

    [(in ~sym (hy-shadow-keywords))
     (,  (.format "({0} {1})"
                  ~sym
                  (get-args
                   (get-code
                    (. hy core shadow ~(HySymbol sym) __code__ co_filename)
                    (. hy core shadow ~(HySymbol sym) __code__ co_firstlineno))))
         (. hy core shadow ~(HySymbol sym) __doc__)
         (. hy core shadow ~(HySymbol sym) __code__ co_filename)
         (. hy core shadow ~(HySymbol sym) __code__ co_firstlineno))]

    [(in ~sym (hy-macro-keywords))
     (, (.format "({0} {1})"
                 ~sym
                 (get-args
                  (get-code
                   (. (get hy.macros._hy_macros nil ~sym) func_code co_filename)
                   (. (get hy.macros._hy_macros nil ~sym) func_code co_firstlineno))))
        (. (get hy.macros._hy_macros nil ~sym)  __doc__)
        (. (get hy.macros._hy_macros nil ~sym) func_code co_filename)
        (. (get hy.macros._hy_macros nil ~sym) func_code co_firstlineno))]

    [(in ~sym (.keys (hy-compiler-keywords)))
     (, (.format "{0} defined in hy/compiler" ~sym)
        "No docstring available."
        (get (get (hy-compiler-keywords) ~sym) 0)
        (get (get (hy-compiler-keywords) ~sym) 1))]

    [(= (. (type ~(HySymbol (.replace (string sym) "-" "_"))) __name__)
        "builtin_function_or_method")
     (, ~sym
        (. ~(HySymbol sym) __doc__)
        nil
        nil)]

    ;; Not found. Maybe a regular symbol from hy? or a python func?
    [true
     (let [SYM ~(HySymbol (.replace (string sym) "-" "_"))]
       (, ~sym
          (. SYM __doc__)
          (. SYM func_code co_filename)
          (. SYM func_code co_firstlineno)))]))


(defn get-code [fname lineno]
  "Extract the code for the sexp in FNAME after LINENO."
  (when (and fname lineno)
    (with [f (open fname)]
          (for [i (range (- lineno 1))]
            (.readline f))
          (setv state 0
                in-string False
                in-comment False
                s "("
                j 0
                ch ""
                pch "")

          ;; get to start
          (while True

            (setv pch ch
                  ch (.read f 1))
            (when (= ch "(")
              (setv state 1)
              (break)))

          (while (and (not (= 0 state)))
            (setv ch (.read f 1))
            (+= s ch)
            (cond
             ;; check for in -string, but not escaped "
             ;; we do not consider comments. () in comments will break this.
             [(and (not (= pch "\\")) (= ch "\""))
              (setv in-string (not in-string))]
             ;; comment line
             [(and (not in-string) (not (= pch "\\")) (= ch ";"))
              (setv in-comment True)]
             ;; break out of comment
             [(and in-comment (= ch "\n"))
              (setv in-comment False)]
             [(and (not in-string) (not in-comment) (= ch ")"))
              (setv state (- state 1))]
             [(and (not in-string) (not in-comment) (= ch "("))
              (+= state 1)]
             ))
          s)))


(defn get-args (code-string)
  "Parse the args out of the CODE-STRING."
  (when code-string
    (let [state 0
          in-string False
          i 0
          args "["]
      (while True
        (setv ch (get code-string i))
        (when (= "[" ch)
          (setv state 1)
          (break))
        (+= i 1))

      (while (not (= 0 state))
        (+= i 1)
        (setv ch (get code-string i))
        (+= args ch)
        (cond
         [(and (= ch "[") (not in-string))
          (+= state 1)]
         [(and (= ch "]") (not in-string))
          (-= state 1)]))
      (setv args (.replace args "\n" ""))
      (setv args (re.sub " +" " " args))
      ;; cut off leading and trailing []
      (cut args 1 -1))))


(defmacro ? [sym]
  "Return help for SYM which is a string."
  `(let [flds (hylp-info ~sym)]
     (.format "Usage: {0}\n\n{1}\n\n[[{2}::{3}]]\n"
              (get flds 0) ;;Usage
              (get flds 1) ;; docstring
              (get flds 2) ;; file
              (get flds 3) ;; lineno
              )))
