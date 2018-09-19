
clear s target
chrono_=tic;
s.T = 10;
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
s.CppKer.Type = 'SqDistScalar';
s.CppKer.Function = 'Cauchy';
s.useDef = 'LargeDef';
s.typefloat = 'float';
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
target{1}.CppKer.Type = 'SqDistScalar';
target{1}.CppKer.Function = 'Cauchy';
target{1}.sigmaW = .5;
%target{1}.y = s.x+.2;%rand(3,3);
%target{1}.vx = [1;2;3];
%target{1}.vy = [1;2;3];
target{1}.wx = ones(1,nfx);
target{1}.wy = ones(1,nfy);

s = matchCpp(s,target);

clf
s.showpoints = 0;
if s.useDef==2
s.T = 2;
s.X(:,:,1) = s.x;
s.X(:,:,2) = s.phix;
end
affiche(s);

s.transmatrix = eye(3);
s.transvector = zeros(3,1);

s.showtraj = 1;

%s.showgrid = 1;
makewrl('ess.wrl',s);
toc(chrono_)