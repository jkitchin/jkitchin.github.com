#include <gsl/gsl_const_mksa.h>
#include <string.h>
#include "emacs-module.h"

int plugin_is_GPL_compatible;

// I assume here that all values will be double. I can't think of any that would
// be ints
static void defconst (emacs_env *env, const char *name, double value, const char *doc)
{
  // These are functions we will call
  emacs_value eval = env->intern(env, "eval");  
  emacs_value list = env->intern(env, "list");

  // These will make up the list we will eventally eval
  emacs_value fdefconst = env->intern(env, "defconst");
  emacs_value sym = env->intern(env, name);
  emacs_value val = env->make_float(env, value);
  emacs_value sdoc = env->make_string(env, doc, strlen(doc));

  // make a list of (defconst sym val doc)
  emacs_value largs[] = {fdefconst, sym, val, sdoc};
  emacs_value qlist = env->funcall(env, list, 4, &largs);   

  // now eval the list of symbols
  emacs_value args[] = { qlist };  
  env->funcall(env, eval, 1, &args);
}

int emacs_module_init(struct emacs_runtime *ert)
{
  emacs_env *env = ert->get_environment(ert);

  defconst(env, "GSL-CONST-MKSA-SPEED-OF-LIGHT",
	   GSL_CONST_MKSA_SPEED_OF_LIGHT,
	   "Speed of light in vacuum (m/s).");
  
  defconst(env, "GSL-CONST-MKSA-PLANCKS-CONSTANT-H",
	   GSL_CONST_MKSA_PLANCKS_CONSTANT_H,
	   "Plank's constant, h");

  // This is what allows the shared library to provide a feature 
  emacs_value provide = env->intern(env, "provide");
  emacs_value provide_args[] = { env->intern(env, "gsl-constants") };
  env->funcall(env, provide, 1, provide_args);
  
  return 0;
}
