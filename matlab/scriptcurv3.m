
% a simple example of curve matching with currents model and large deformations

scale = 1;

clear s target
target{1}.method = 'curvecurr';
nx = 20;
s.x = zeros(3,nx);
s.x(1,:) = -cos(2*pi*(1:nx)/nx);
s.x(2,:) = sin(2*pi*(1:nx)/nx);
s.x = scale*2*s.x;

ny = 30;
target{1}.y = zeros(3,ny);
target{1}.y(1,:) = -cos(2*pi*(1:ny)/ny);
target{1}.y(2,:) = 2*sin(2*pi*(1:ny)/ny);
target{1}.y(3,:) = 0.9*cos(2*pi*(1:ny)/ny).^2-.5;
indspike = 10;
szspike = .8;
A = target{1}.y(:,indspike);
B = target{1}.y(:,indspike+1);
target{1}.y = [target{1}.y(:,1:indspike),1.5*A,A+szspike*(B-A),target{1}.y(:,indspike+1:end)];
ny = ny + 2;
target{1}.y = 2*target{1}.y;
target{1}.y = target{1}.y + rand(size(target{1}.y))/100;
target{1}.y = target{1}.y * scale;

target{1}.nx = nx;

target{1}.sigmaW = scale;
target{1}.usefgt = 0;
target{1}.order = 3;
target{1}.K = 10;
target{1}.e = 9;

target{1}.vx = [1:nx;[2:nx,1]];
target{1}.vy = [1:ny;[2:ny,1]];
target{1}.wx = ones(1,nx);
target{1}.wy = ones(1,ny);

s.numbminims = 1;

s.sigmaV = scale;
s.gammaR = 0;

s.optim_breakratio = 1e-6;
s.useoptim = 'adaptdesc';
%s.useoptim = 'fixedesc';
s.optim_maxiter = 100;
s.optim_stepsize = 1;
s.optim_verbosemode = 1;

s.rigidmatching = 0;
s.elasticmatching = 1;
s = matchCpp(s,target);

s.showtitle = 0;
s.showpoints = 0;
s.showfaces = 1;
s.showgrid = 0;
s.showminim = 1;
s.showtraj = 1;
s.showmomtraj = 0;
s.show = {'y','phi','x','xrig'};
figure(1)
clf
affiche(s);




