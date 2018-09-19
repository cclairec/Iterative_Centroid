
% matching two curves via scalar measure model and large deformations

clear

Nx = 50;
x = zeros(3,Nx);
x(1,:) = (1:Nx)/(Nx);
x(2,:) = 0*sin(2*pi*(1:Nx)/(Nx));
s.x = x;
s.T = 10;
% s.X = repmat(s.x,[1 1 s.T]);
% s.mom = zeros(size(s.X));

Ny = 50;
y = zeros(3,Ny);
y(1,:) = (1:Ny)/(Ny);
y(2,:) = .5*sin(2*pi*(1:Ny)/(Ny));
target{1}.y = y;

s.gammaR = 0;
s.sigmaV = .25;
s.optim_maxiter = 100;
s.optim_stepsize = 1;
s.optim_verbosemode = 1;
s.optim_breakratio = 1e-10;
s.optim_loopbreak = 10;
s.rigidmatching = 0;
s.useoptim = @adaptdesc;


target{1}.method = 'measures';
target{1}.vx = 1:Nx;
target{1}.sigmaI = .25;

s.targetweights = [1];

s.useDef = 'LargeDef';
s.CppKer.Type = 'FastGauss';
s.CppKer.Function = 'Gaussian';
s.CppKer.K = 8;
s.CppKer.order = 4;
s.CppKer.e = 9;
target{1}.CppKer.Type = 'FastGauss';
target{1}.CppKer.Function = 'Gaussian';
target{1}.CppKer.K = 8;
target{1}.CppKer.order = 4;
target{1}.CppKer.e = 9;
s = matchCpp(s,target);



clf
s.showtraj = 1;
s.optim_verbosemode = 1;
s.transmatrix = eye(3);
s.transvector = ones(3,1);
s.showgrid = 1;
s.gridsize = 30;
s.usefgt = 0;
s.sigmaV2 = s.sigmaV.^2;
s.tau = 1/(s.T-1);
s.normcoefV = ones(1,s.T);
s.xmarker = ' ';
s.ymarker = ' ';
s.phimarker = ' ';
affiche(s);
axis equal

s.target{1}.vx = [1:size(s.x,2)-1;2:size(s.x,2)];
s.target{1}.vy = [1:size(s.target{1}.y,2)-1;2:size(s.target{1}.y,2)];

