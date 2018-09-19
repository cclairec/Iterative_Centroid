clear

Nx = 10;
x = zeros(3,Nx);
x(1,:) = cos(2*pi*(1:Nx)/(Nx));
x(2,:) = 0*sin(2*pi*(1:Nx)/(Nx));

s.x = x;


y = x;
y(2,:) = .2+y(2,:) + rand(1,Nx)/5;
target{1}.y = y;


s.gammaR = 0;
s.sigmaV = .5;
s.optim_maxiter = 50;
s.optim_stepsize = 1;
s.optim_verbosemode = 1;
s.optim_breakratio = 1e-6;
s.optim_loopbreak = 10;
s.rigidmatching = 0;
s.useoptim = @adaptdesc;
s.T = 10;


target{1}.method = 'measures';
target{1}.vx = 1:Nx;
target{1}.sigmaI = .5;
target{1}.CppKer.Type = 'SqDistScalar';
target{1}.CppKer.Function = 'Gaussian';

s.targetweights = [1];

s.useDef = 'LargeDef';
s.CppKer.Type = 'SqDistScalar';
s.CppKer.Function = 'Gaussian';

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
affiche(s);
axis equal

s.show = {0};
s.target{1}.vx = 1:size(s.x,2);
s.target{1}.vy = 1:size(s.target{1}.y,2);
makewrl('ess.wrl',s);





