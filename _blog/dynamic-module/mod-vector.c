#include "emacs-module.h"
#include <stdlib.h>

/* Declare mandatory GPL symbol.  */
int plugin_is_GPL_compatible;

/* Bind NAME to FUN.  */
static void bind_function (emacs_env *env, const char *name, emacs_value Sfun)
{
  /* Set the function cell of the symbol named NAME to SFUN using
     the 'fset' function.  */

  /* Convert the strings to symbols by interning them */
  emacs_value Qfset = env->intern (env, "fset");
  emacs_value Qsym = env->intern (env, name);

  /* Prepare the arguments array */
  emacs_value args[] = { Qsym, Sfun };

  /* Make the call (2 == nb of arguments) */
  env->funcall (env, Qfset, 2, args);
}

/* Provide FEATURE to Emacs.  */
static void
provide (emacs_env *env, const char *feature)
{
  /* call 'provide' with FEATURE converted to a symbol */

  emacs_value Qfeat = env->intern (env, feature);
  emacs_value Qprovide = env->intern (env, "provide");
  emacs_value args[] = { Qfeat };

  env->funcall (env, Qprovide, 1, args);
}

/*                                                                  */

// This just returns the argument, works for a list.
static emacs_value Ff1 (emacs_env *env, int nargs, emacs_value args[], void *data)
{
  return args[0];
}

// get first element of a vector
static emacs_value Ff2 (emacs_env *env, int nargs, emacs_value args[], void *data)
{
  return env->vec_get(env, args[0], 0);
}

// This just returns a vector of integers!!!
static emacs_value Ff3 (emacs_env *env, int nargs, emacs_value args[], void *data)
{
 int len = 2;
 emacs_value *array = malloc(sizeof(emacs_value) * len);
 array[0] = env->make_integer(env, 2);
 array[1] = env->make_integer(env, 4);

 emacs_value Fvector = env->intern(env, "vector");
 emacs_value vec = env->funcall(env, Fvector, len, array);
 free(array);
 return vec;
}

// return vector * n
static emacs_value Ff4 (emacs_env *env, int nargs, emacs_value args[], void *data)
{
 emacs_value input = args[0];
 double N = env->extract_float(env, args[1]);

 int len = env->vec_size (env, input);

 emacs_value *array = malloc(sizeof(emacs_value) * len);

 // multiply each value by N
 for (ptrdiff_t i = 0; i < len; i++)
   {
     array[i] = env->make_float(env,
				N * env->extract_float(env,
						       env->vec_get (env, input, i)));
   }

 // If you change this to list, you get a list instead!
 emacs_value Fvector = env->intern(env, "vector");
 emacs_value vec = env->funcall(env, Fvector, len, array);
 free(array);
 return vec;
}

// return 2nd element of vector
static emacs_value Ff5 (emacs_env *env, int nargs, emacs_value args[], void *data)
{
 emacs_value vec = args[0];

 return env->vec_get (env, vec, 1);
}

// get second value of second vector
static emacs_value Ff6 (emacs_env *env, int nargs, emacs_value args[], void *data)
{
 emacs_value vec = args[0];
 emacs_value v2 = env->vec_get (env, vec, 1);
 return env->vec_get (env, v2, 1);
}

// index a list
static emacs_value Ff7 (emacs_env *env, int nargs, emacs_value args[], void *data)
{
 emacs_value nth = env->intern(env, "nth");

 return env->funcall (env, nth, 2, args);
}

int emacs_module_init (struct emacs_runtime *ert)
{
  emacs_env *env = ert->get_environment (ert);

#define DEFUN(lsym, csym, amin, amax, doc, data) \
  bind_function (env, lsym, \
		 env->make_function (env, amin, amax, csym, doc, data))

  DEFUN("f1", Ff1, 1, 1, NULL, NULL);
  DEFUN("f2", Ff2, 1, 1, NULL, NULL);
  DEFUN("f3", Ff3, 0, 0, NULL, NULL);
  DEFUN("f4", Ff4, 2, 2, NULL, NULL);
  DEFUN("f5", Ff5, 1, 1, NULL, NULL);
  DEFUN("f6", Ff6, 1, 1, NULL, NULL);
  DEFUN("f7", Ff7, 2, 2, NULL, NULL);

  provide (env, "mod-vector");

  /* loaded successfully */
  return 0;
}
