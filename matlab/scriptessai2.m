
% test of divergence free kernels for large deformation

clear

y = [.25;0;0];
target{1}.y = y;

Nx = 4;
x = zeros(3,Nx);
x(1,:) = cos(2*pi*(1:Nx)/(Nx));
x(2,:) = sin(2*pi*(1:Nx)/(Nx));
x = [x,[-.25;0;0]];
Nx = Nx + 1;
%x = x+1;
s.x = x;

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
target{1}.vx = Nx;
target{1}.sigmaI = .5;
target{1}.CppKer.Type = 'SqDistScalar';
target{1}.CppKer.Function = 'Gaussian';

s.targetweights = [1];

Kernels.Type = {'SqDistScalar','CurlFree','DivFree'};
Kernels.Function = {'Gaussian','Cauchy'};

useCpp = 1;%input('taper 1 pour le code C++, ou 2 pour le code Matlab: ');
switch useCpp
    case 1
        s.useDef = 'LargeDef';
        s.CppKer.Type = 'DivFree';
        s.CppKer.Function = 'Gaussian';
        s = matchCpp(s,target);
    case 2
        s.useDef = 1;
        disp('Grandes Deformations')
        s.CppKer.Type = 'SqDistScalar';
        s.CppKer.Function  = 'Gaussian';
        disp('noyaux gaussiens')
        s = match(s,target);
        s.elapsedtime
        X = s.X;
end



clf
% hold on
% y = [target{1}.y,target{2}.y];
% plot3(y(1,:),y(2,:),y(3,:),'o')
% plot3(s.x(1,:),s.x(2,:),s.x(3,:),'*')
% plot3(squeeze(s.X(1,:,:))',squeeze(s.X(2,:,:))',squeeze(s.X(3,:,:))','LineWidth',3)
if s.useDef==2
    s.T = 2;
    s.X(:,:,1) = s.x;
    s.X(:,:,2) = s.phix;
end
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



% h = 0:.001:.1;
% [Yg,Xg,Zg] = meshgrid(h,h,h);
% P = [Xg(:),Yg(:),Zg(:)]';
% % P = rand(3,100)*4-2;
% % P(3,:) = 1;
% 
% f = fopen('points.mch','w');
% writeArr(P,f);
% fclose(f);
% eval(['!./flow ',num2str(s.sigmaV(1))])
% f = fopen('resflow.mch','r');
% PhiP = readArr(f);
% fclose(f);
% %plot3(squeeze(PhiP(1,:,:))',squeeze(PhiP(2,:,:))',squeeze(PhiP(3,:,:))','b
% %')
% Xg = reshape(PhiP(1,:,end),size(Xg));
% Yg = reshape(PhiP(2,:,end),size(Yg));
% Zg = reshape(PhiP(3,:,end),size(Zg));
% %plotgrid(Xg,Yg,Zg);
% plot3(Xg(:,:,5),Yg(:,:,5),Zg(:,:,5));



