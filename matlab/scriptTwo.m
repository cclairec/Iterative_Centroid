
clear

Ny = 50;
y = zeros(3,Ny);
y(1,:) = cos(2*pi*(1:Ny)/Ny);
y(2,:) = sin(2*pi*(1:Ny)/Ny);
y(3,:) = sin(8*pi*(1:Ny)/Ny);
y = y+1;
target{1}.y = y;

Nx = 25;
x = zeros(3,Nx);
x(1,:) = cos(2*pi*(1:Nx)/Nx);
x(2,:) = sin(2*pi*(1:Nx)/Nx);
x = x+1;
s.x = x;

s.gammaR = 0;
s.sigmaV = 1;
s.optim_maxiter = 50;
s.optim_stepsize = 1;
s.optim_verbosemode = 1;
s.optim_breakratio = 1e-6;
s.optim_loopbreak = 10;
s.rigidmatching = 0;
s.useoptim = @adaptdesc;
s.T = 30;


target{1}.method = 'measures';
target{1}.vx = 1:Nx;
target{1}.sigmaI = .5;

target{2} = target{1};
target{2}.y = target{1}.y-2;
s.x = [s.x,x-2];
target{2}.vx = Nx+(1:Nx);


s.targetweights = [.5 .5];

s = matchCpp(s,target);



clf
s.showtraj = 1;
s.showgrid = 1;
affiche(s);
axis equal
view(3)





