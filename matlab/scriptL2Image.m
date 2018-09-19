
clear

Ns = [30;30;3];

h1s = linspace(0,1,Ns(1)+1);
h2s = linspace(0,1,Ns(2)+1);
h3s = linspace(0,1,Ns(3)+1);
[hxs,hys,hzs] = ndgrid(h1s,h2s,h3s);
hxs = permute(hxs,[3,2,1]);
hys = permute(hys,[3,2,1]);
hzs = permute(hzs,[3,2,1]);
xspec = [hxs(:),hys(:),hzs(:)]';
s.xspec = xspec;

N = [30;30;3];
h1 = linspace(0,1,N(1)+1);
h2 = linspace(0,1,N(2)+1);
h3 = linspace(0,1,N(3)+1);
[hx,hy,hz] = ndgrid(h1,h2,h3);
hx = permute(hx,[3,2,1]);
hy = permute(hy,[3,2,1]);
hz = permute(hz,[3,2,1]);
x = [hx(:),hy(:),hz(:)]';
s.x = x;

s.useDef = 'LargeDef';
s.typefloat = 'double';
s.CppKer.Type = 'CauchyGpu';
s.T = 10;
s.sigmaV = 0.2;
s.gammaR = 0;
s.optim_useoptim = 'adaptdesc';
s.optim_maxiter = 100;
s.optim_stepsize = .1;

t.method = 'l2image';
t.rx = 1:size(xspec,2);
t.weight = 1;
t.imsource = blobimage(Ns,.2,[.4;.5;.5]);
t.imtarget = blobimage(Ns,.2,[.6;.5;.5]);
% t.imsource = zeros(Ns');
% t.imsource(3,3,1) = 1;
% t.imtarget = zeros(Ns');
% t.imtarget(3,2,1) = 1;
% 
t.basetarget = [0;0;0]; 
t.voxsizetarget = [1;1;1]./Ns;  

target{1} = t;
s = matchCpp(s,target);

figure(1)
clf
hold on
%plot3(s.x(1,:),s.x(2,:),s.x(3,:),'o')
%plot3(s.phix(1,:),s.phix(2,:),s.phix(3,:),'*r')
a=s.phix-s.x;
quiver3(s.x(1,:),s.x(2,:),s.x(3,:),a(1,:),a(2,:),a(3,:),0)


