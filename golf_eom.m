function xdot = golf_eom(t,var)
r = (1/2)*.0427;% Golf ball radius (m)
m = .0459;% Golf ball mass (kg)
g = 9.81;% Acceleration due to gravity (m/s^2)
Cd = 0.3;% Coefficient of drag. CD varies with the velocity of the ball, but it has been experimentally measured to be approximately 0.3
A = pi*(r^2);% Cross-sectional area of the ball
rho = 1.225;% Density of air (kg/m^3)
Cdrag = Cd*rho*A/(2*m);% Multiply this by Vr^2 to get aD. golf_dynamics_F2018.pdf p. 2 equation (2)
M = r*rho*A/(2*m);

% Relative wind (the difference between the ball velocity and the wind
% velocity
Vrx = var(4)-var(7);% Relative wind velocity in x
Vry = var(5)-var(8);% Relative wind velocity in y
Vrz = var(6)-var(9);% Relative wind velocity in z

xdot = zeros(12,1);

xdot(1) = var(4);% Velocity in the x
xdot(2) = var(5);% Velocity in the y
xdot(3) = var(6);% Velocity in the z
xdot(4) = -Cdrag*Vrx*abs(Vrx) + M*(var(11)*Vrz-var(12)*Vry);% Acceleration in the x
xdot(5) = -g-Cdrag*Vry*abs(Vrx) + M*(var(12)*Vrx-var(10)*Vrz);% Acceleration in the y
xdot(6) = -Cdrag*Vrz*abs(Vrx) + M*(var(10)*Vry-var(11)*Vrx);% Acceleration in the z
xdot(7) = 0;% Derivative of wind speed in the x
xdot(8) = 0;% Derivative of wind speed in the y
xdot(9) = 0;% Derivative of wind speed in the z
xdot(10) = 0;% Derivative of spin in the x
xdot(11) = 0;% Derivative of spin in the y
xdot(12) = 0;% Derivative of spin in the z
end