%	Example 1.3-1 Paper Airplane Flight Path
%	Copyright 2005 by Robert Stengel
%	August 23, 2005
clear; clc; close all;
%	a) Equilibrium Glide at Maximum Lift/Drag Ratio
    [V,Gam,H,R] = setup_sim();
	to		=	0;			% Initial Time, sec
	tf		=	6;			% Final Time, sec
	tspan	=	[to tf];
% 	xo		=	[V;Gam;H;R];
% 	[ta,xa]	=	ode23('EqMotion',tspan,xo);
% 
% %	b) Oscillating Glide due to Zero Initial Flight Path Angle
% 	xo		=	[V;0;H;R];
% 	[tb,xb]	=	ode23('EqMotion',tspan,xo);
% 
% %	c) Effect of Increased Initial Velocity
% 	xo		=	[1.5*V;0;H;R];
% 	[tc,xc]	=	ode23('EqMotion',tspan,xo);
% 
% %	d) Effect of Further Increase in Initial Velocity
% 	xo		=	[3*V;0;H;R];
% 	[td,xd]	=	ode23('EqMotion',tspan,xo);
% 
	% figure   Commented out to simplify process
	% plot(xa(:,4),xa(:,3),xb(:,4),xb(:,3),xc(:,4),xc(:,3),xd(:,4),xd(:,3))
	% xlabel('Range, m'), ylabel('Height, m'), grid
    % legend('1');
    % 
	% figure
	% subplot(2,2,1)
	% plot(ta,xa(:,1),tb,xb(:,1),tc,xc(:,1),td,xd(:,1))
	% xlabel('Time, s'), ylabel('Velocity, m/s'), grid
	% subplot(2,2,2)
	% plot(ta,xa(:,2),tb,xb(:,2),tc,xc(:,2),td,xd(:,2))
	% xlabel('Time, s'), ylabel('Flight Path Angle, rad'), grid
	% subplot(2,2,3)
	% plot(ta,xa(:,3),tb,xb(:,3),tc,xc(:,3),td,xd(:,3))
	% xlabel('Time, s'), ylabel('Altitude, m'), grid
	% subplot(2,2,4)
	% plot(ta,xa(:,4),tb,xb(:,4),tc,xc(:,4),td,xd(:,4))
	% xlabel('Time, s'), ylabel('Range, m'), grid

%% 2: Case A
% varying plots for nominal, higher, and lower v0 and gam-0
% lower: red, nominal: black, higher: green
% 2x1 subplots for vel and gam vs. time

% velocity:
% nominal
xo		=	[V;Gam;H;R];
[tnv,xnv]	=	ode23('EqMotion',tspan,xo);
% lower
xo		=	[7.5;Gam;H;R];
[tlv,xlv]	=	ode23('EqMotion',tspan,xo);
% higher
xo		=	[2;Gam;H;R];
[thv,xhv]	=	ode23('EqMotion',tspan,xo);
% Plotting
figure; hold on;
subplot(2,1,1);
plot(xnv(:,3),xnv(:,4),'k',xlv(:,3),xlv(:,4),'r',xhv(:,3),xhv(:,4),'g');
xlabel('Altitude, m'), ylabel('Range, m'), grid;
legend('Nominal', 'Lower', 'Higher');
title('Velocity Case A');

% Flight path angle
% nominal
xo		=	[V;Gam;H;R];
[tng,xng]	=	ode23('EqMotion',tspan,xo);
% lower
xo		=	[V;-0.5;H;R];
[tlg,xlg]	=	ode23('EqMotion',tspan,xo);
% higher
xo		=	[V;0.4;H;R];
[thg,xhg]	=	ode23('EqMotion',tspan,xo);
% Plotting
subplot(2,1,2);
plot(xng(:,3),xng(:,4),'k',xlg(:,3),xlg(:,4),'r',xhg(:,3),xhg(:,4),'g');
xlabel('Altitude, m'), ylabel('Range, m'), grid;
legend('Nominal', 'Lower', 'Higher');
title('Flight Path Angle Case A');


%% 3: Simultaneous variations

% initialize min and max values to be used for random number generator
vmin = 2; vmax = 7.5;
gmin = -0.5; gmax = 0.4;

% For loop to do 100 iterations with random initial values and plot each
vi = nan; gi = nan;
figure; hold on;
title('Simultaneous Variations');
xlabel('Time (s)');
ylabel('Altitude (m)');
tspan = linspace(to,tf,50);
% Matrices to create an aveage line for range and height
r_ave = zeros(50,1);
h_ave = zeros(50,1);
for i = 1:100
    vi = vmin + (vmax-vmin)*rand(1);
    gi = gmin + (gmax-gmin)*rand(1);
    xo		=	[vi;gi;H;R];
    [t,x]	=	ode23('EqMotion',tspan,xo);
    plot(t,x(:,3), 'color', [0 0 0 0.25]);
    r_ave  = r_ave + x(:,4);
    h_ave = h_ave + x(:,3);
end


%% 4: Fit a Curve to 3

% use for loop from above to create an average line
% Calculate actual usable aveage matrices
r_ave = r_ave/50;
h_ave = h_ave/50;
% plot average lines vs time for visualization
% figure;
% plot(t,h_ave);
% title('Average Altitude');
% xlabel('Time (s)');
% ylabel('Altitude (m)');
% figure;
% plot(t,r_ave);
% title('Average range');
% xlabel('Time (s)');
% ylabel('Range (m)');

% Fit and plot polynomials using simple polyfit
% Altitude vs. Time
ph = polyfit(t,h_ave,12);
yfith = polyval(ph,t);
figure; hold on;
plot(t,yfith);
plot(t,h_ave);
title('Average Altitude vs. fitted');
xlabel('Time (s)');
ylabel('Altitude (m)');
legend('Numerical Average','Polynomial Fitted');
% Range vs. Time
pr = polyfit(t,r_ave,12);
yfitr = polyval(pr,t);
figure; hold on;
plot(t,yfitr);
plot(t,r_ave);
title('Average range vs. fitted');
xlabel('Time (s)');
ylabel('Range (m)');
legend('Numerical Average','Polynomial Fitted');


%% 5: First Time Derivatives
% Using finite forward difference, based off what we did in class

drl = length(t);
fp_numh = nan*zeros(1, drl);
fp_numr = fp_numh;
% height
for i = 1:drl-1
    fp_numh(i) = (yfith(i+1) - yfith(i))/(t(i+1) - t(i));
end
% range
for i = 1:drl-1
    fp_numr(i) = (yfitr(i+1) - yfitr(i))/(t(i+1) - t(i));
end

% Potting
figure; hold on;
% height
subplot(2,1,1);
plot(t, fp_numh);
title('Derivative For Altitude');
xlabel('Time (s)');
ylabel('Altitude Derivative');
% range
subplot(2,1,2);
plot(t, fp_numr);
title('Derivative for Range');
xlabel('Time (s)');
ylabel('Range Derivative');