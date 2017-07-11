#include "emacs-module.h"
#include "emacs-module-helpers.h"

int plugin_is_GPL_compatible;

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

int emacs_module_init (struct emacs_runtime *ert)
{
  emacs_env *env = ert->get_environment (ert);

  DEFUN("g4", Ff4, 2, 2, "testdoc", NULL);

  provide (env, "pretty");

  /* loaded successfully */
  return 0;
}
