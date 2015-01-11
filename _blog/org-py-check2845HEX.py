from scipy.integrate import odeint


def ode(y, x):
    return -k * x

xspan = [0, 1]
y0 = 1

sol = odeint(ode, y0, xspan)
print sol
