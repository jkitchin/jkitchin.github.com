
import numpy as np
TOLERANCE = 1e-5

def solve_solution():
    from scipy. optimize import fsolve
    import numpy as np

    def objective(x):
        return np.exp(x) - 3

    return fsolve(objective, 3)[0]


def test_solve(s):
    exec s in globals()
    if (abs(solve_solution() - solve()) <= TOLERANCE):
        print('Correct!')
    else:
        print('Incorrect')
