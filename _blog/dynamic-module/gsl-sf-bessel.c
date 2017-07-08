#include <assert.h>
#include <gsl/gsl_sf_bessel.h>
#include "emacs-module.h"

int plugin_is_GPL_compatible;

static emacs_value
F_gsl_sf_bessel_J0 (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void *data)
{
  assert (nargs == 1);
  double x = env->extract_float (env, args[0]);
  return env->make_float (env, gsl_sf_bessel_J0 (x));
}

int
emacs_module_init(struct emacs_runtime *ert)
{
	emacs_env *env = ert->get_environment(ert);

	emacs_value gsl_sf_bessel_J0_fn = env->make_function(env, 1, 1, F_gsl_sf_bessel_J0, "Regular cylindrical Bessel function of zeroth order, J_0(x)", NULL);

	emacs_value Qfset = env->intern(env, "fset");
	emacs_value Q_gsl_sf_bessel_J0 = env->intern(env, "gsl-sf-bessel-J0");
	emacs_value fset_args[] = { Q_gsl_sf_bessel_J0, gsl_sf_bessel_J0_fn };
	env->funcall(env, Qfset, 2, fset_args);

	emacs_value Qprovide = env->intern(env, "provide");
	emacs_value Q_gsl_sf_bessel = env->intern(env, "gsl-sf-bessel");
	emacs_value provide_args[] = { Q_gsl_sf_bessel };
	env->funcall(env, Qprovide, 1, provide_args);

	return 0;
}
