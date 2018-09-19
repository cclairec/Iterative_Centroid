
% a few iterations of surface matching with Gpu acceleration, to comapre
% with scriptsurfCpu and scriptsurfFgt

clear s target
chrono_=tic;
s.T = 10;
s.useDef = 'LargeDef';

%s.x = [1,0,0;0,1,0;0,0,1];%rand(3,3);
%[s.x,target{1}.vx] = readbyu('001_lpt_r.byu');
%[target{1}.y,target{1}.vy] = readbyu('000_lpt_r.byu');

Nx = 3000;
%s.x = [rand(3,Nx),[0,1,0,1;0,0,1,1;0,0,0,0]];
s.x = 2*(rand(3,Nx)-.5);
s.x = s.x(:,sum(s.x(1:2,:).^2)<1);
s.x(3,:) = 0*s.x(1,:);
target{1}.vx = delaunay(s.x(1,:),s.x(2,:))';
%target{1}.vx = orient(target{1}.vx);

Ny = 3000;
%target{1}.y = [rand(3,Ny),[0,1,0,1;0,0,1,1;0,0,0,0]];
target{1}.y = 2*(rand(3,Ny)-.5);
target{1}.y = target{1}.y(:,sum(target{1}.y(1:2,:).^2)<1);
target{1}.y(3,:) = .5 + sum((target{1}.y(1:2,:)).^2);
target{1}.y(1,:) = 2*target{1}.y(1,:);
target{1}.y(2,:) = .5*target{1}.y(2,:);
target{1}.vy = delaunay(target{1}.y(1,:),target{1}.y(2,:))';
%s.vy = orient(s.vy);


nfx = size(target{1}.vx,2);
nfy = size(target{1}.vy,2);


s.sigmaV = .5*ones(1,s.T);
s.targetweights = 1;
s.gammaR = 0;
s.optim_maxiter = 200;
s.optim_stepsize = 1;
s.optim_verbosemode = 1;
s.optim_breakratio = 1e-6;
s.optim_loopbreak = 10;
s.rigidmatching = 0;
s.useoptim = @adaptdesc;


target{1}.method = 'surfcurr';
target{1}.CppKer.Type = 'CauchyGpu';
%target{1}.CppKer.Function = 'Cauchy';
target{1}.sigmaW = .5;
%target{1}.y = s.x+.2;%rand(3,3);
%target{1}.vx = [1;2;3];
%target{1}.vy = [1;2;3];
target{1}.wx = ones(1,nfx);
target{1}.wy = ones(1,nfy);

s1 = s;
s1.CppKer.Type = 'CauchyGpu';
s1 = matchCpp(s1,target);
figure(1)
clf
s1.showpoints = 0;
%affiche(s1);

s2 = s;
s2.CppKer.Type = 'FastGauss';
s2.CppKer.epsilon = 1e-3;
%s2 = matchCpp(s2,target);
figure(2)
clf
s1.showpoints = 0;
%affiche(s2);

s3 = s;
s3.CppKer.Type = 'SqDistScalar';
s3.CppKer.Function = 'Gaussian';
%s3 = matchCpp(s3,target);
figure(3)
clf
s3.showpoints = 0;
%affiche(s3);
toc(chrono_)
