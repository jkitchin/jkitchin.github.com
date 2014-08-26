
function dXdt = VanderPol(t,X)
x = X(1);
y = X(2);
mu = 1;
dxdt = mu*(x-1/3*x^3-y);
dydt = x/mu;
dXdt = [dxdt; dydt];
end
