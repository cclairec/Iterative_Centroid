%clear

Nx = 500 %length(xx);%500;

s1 = [SkelSuj{1} SkelSuj{2} SkelSuj{3} SkelSuj{4} SkelSuj{5} SkelSuj{6} SkelSuj{7} SkelSuj{8}]; Nx = length(s1);
s.x = s1; %rand(3,Nx);
s.mom = 0.8*(rand(3,Nx)-.5);

s.sigmaV = 1;
s.T = 5;


s.CppKer.Type = 'SqDistScalar';s.CppKer.Function = 'Gaussian';
%s.CppKer.Type = 'FastGauss';s.CppKer.e = 16;s.CppKer.K = 20;s.CppKer.order = 9;

s = shootingCpp(s);

s.showtraj = 1;
s.typefloat = 'double';
s.optim_verbosemode = 1;
s.transmatrix = eye(3);
s.transvector = ones(3,1);
s.showgrid = 1;
s.gridsize = 10;
s.usefgt = 0;
s.sigmaV2 = s.sigmaV.^2;
s.tau = 1/(s.T-1);
s.normcoefV = ones(1,s.T);
s.target = {};
s.show = {0};
figure(),affiche(s);
figure(), plot3(squeeze(s.X(1,:,:))',squeeze(s.X(2,:,:))',squeeze(s.X(3,:,:))')
axis equal

s.show = {0};
s.target{1}.vx = 1:size(s.x,2);
%s.target{1}.vy = 1:size(s.target{1}.y,2);
makewrl('ess.wrl',s);

figure(),
for j = 1:s.T
    plot3(s.x(1,:),s.x(2,:),s.x(3,:),'ro');hold on,plot3(squeeze(s.X(1,:,j))',squeeze(s.X(2,:,j))',squeeze(s.X(3,:,j))','+');hold off;
    
    SkelSuj{j} = s.X(:,:,j); % un sujet par cellule. 
end

save CSkels1_A SkelSuj;