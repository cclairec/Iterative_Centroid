function [Bary B ] = BarycentreSurface(ind_1,SkelSuj,fileout,pct,mod,param)
% ind_1: -1 for random subject ordering, ind_1 to use subject ind_1 as first
% subject, the other are in a random ordering.
% SkelSuj: 1 subject per cell, each cell contains at least 2 fields: .vertices and . faces
% pct: to use pct% of the population
% mode: 'IC1', 'IC2', or 'PW'
% fileout: Base for fileout, the extension of the method used will be added
% automatically.
% param: Structure containing all the parameters, which default values are:
%     param.gammaR =  1.e-5; regularity parameter. 0, no constraints.
%     param.sigmaV = 11;  Kernel size of the deformation space (around 1/3
%     of the long axis of the considered shape usually)
%     param.sigmaW = [10 8 5]; % different values for the kernel of the
%     current space.
%     param.maxiters = [200 300 800]; Shoule be the same size as sigmaW.
%     Maximum number of iterations allowded per kernel size of the current
%     space.
%     param.T = 10; Number of steps of the geodesic
%     param.ntries = 1; number times one wants to estimate the barycentre.
%     param.MPeps = 0;

clear tttt;
tttt=tic;


%
%  if(~isstruct(SkelSuj{1}))
% %
%  for k=1:length(SkelSuj);
%     S{k}.Vertices = SkelSuj{k}';
%     S{k}.Faces = faces{k}';
%      S{k}.poids = [];
%  end
%  else

for k=1:length(SkelSuj);
    %          SkelSuj{k}.Vertices = SkelSuj{k}.Vertices';
    %          SkelSuj{k}.Faces = SkelSuj{k}.Faces';
    SkelSuj{1,k}.poids = [];
end
%      S = SkelSuj;
% end
S = SkelSuj;
clear SkelSuj*;
numsujets = length(S);

if nargin==3
    pct=numsujets;
elseif pct==-1
    pct=numsujets;
end

if nargin < 6
    param.gammaR =  1.e-6;
    param.sigmaV = 11; % fixe
    param.sigmaW = [10 8 5];% [17 12 9 6 3];%15./2.^[0 1 2 3 3.5];%16./2.^[0,1,2,2.5,3,4];%[1,1.2,1.5,2,2.5,3];%10./2.^[0,1,1.5,2,2.5,3];%10./2.^[0,1,2,3];
    param.maxiters = [200 300 800];% [200 300 400 500 700 1000 1000];% [800 800 800 1000];% [10 10 10 20];%maxiters = [10 25 100 500];
    param.T = 10;
    param.ntries = 1;
    param.MPeps = 0;%1e-6;
end
gammaR =  param.gammaR;
sigmaV = param.sigmaV;
sigmaW = param.sigmaW;
maxiters = param.maxiters;
T = param.T;
ntries = param.ntries;
MPeps = param.MPeps;

if nargin<5
    mod = 'IC1'; % si 0 pas de combi -> une surface
end
mod
pct
clear Bary;
for j=1:ntries
    clear ind;
    if ind_1==-1
        az=[1:numsujets];
        azperm = randperm(length(az));
        ind = az(azperm);
    else
        az=[1:ind_1-1, (ind_1 + 1):numsujets]; azperm = randperm(length(az));
        ind = [ind_1 az(azperm)];%[ind_1 az];
    end
    ind = ind(1:ceil(numsujets*pct/100)); % Prend que 10% des sujets.
    if strcmp(mod, 'IC2')
        [Bary{j} B] = IterBaryCombiSurf(S(1,ind),gammaR,sigmaV,sigmaW,T,maxiters,MPeps);
        Bary{1,j}.indices = ind;
        %          Bary{1,j}.Vertices = Bary{j}.Vertices';
        %          Bary{1,j}.Faces = Bary{j}.Faces';
    elseif strcmp(mod, 'IC1')
        ind
        [Bary{j} B] = IterBarySurf(S(1,ind),gammaR,sigmaV,sigmaW,T,maxiters,MPeps);
        Bary{1,j}.indices = ind;
    elseif strcmp(mod, 'PW')
        [Bary poids] = PairewiseBarySurf(S(1,ind),gammaR,sigmaV,sigmaW,T,maxiter,MPeps,fileout)
        Bary{1,j}.weights = poids;
        Bary{1,j}.indices = ind;
    else
        disp('Only IC1 IC2 and PW are autorised for mod variable');
    end
    
end


d=datestr(now)
temps = toc(tttt);
tps= [num2str(temps/60) ' min pour le calcul du Barycentre'];
disp(tps);
Bary{1,1}.temps=tps;
Bary{1,1}.date=d;
Bary{1,1}.maxiters=maxiters;
Bary{1,1}.T=T;
Bary{1,1}.gammaR = gammaR;
Bary{1,1}.sigmaW=sigmaW;
Bary{1,1}.sigmaV=sigmaV;
save(fileout, 'Bary', 'ind','tps','param','B');

whos

%%
% load
%
% clf
% hold on
% for k=1:numsujets
%     plotsurf(S{k},[0 0 1]); % surfaces originales
% end
% alpha .2
% clear h
% for j=1:ntries
%     h(j)=plotsurf(Stpl{j},'r'); % template
% end
% alpha(h,.5)
% camlight
%
% a=zeros(1,numsujets);
% v=zeros(1,numsujets);
% for k=1:numsujets
%     a(k)=aire(S{k});
%     v(k)=volume(S{k});
% end

% figure(2)
% clf
% hold on
% plot(a,v,'ob')
% for j=1:ntries
%     if docombi
%         plot(aire(Stpl{j})/numsujets,volume(Stpl{j})/numsujets,'or')
%     else
%         plot(aire(Stpl{j}),volume(Stpl{j}),'or')
%     end
% end
%
% clear h
% for j=1:ntries
% figure(j+2)
% clf
% hold on
% for k=1:numsujets
%     plotsurf(S{k},[0 0 1]);
% end
% alpha .2
%     h(j)=plotsurf(Stpl{j},'r');
% alpha(h,.5)
% camlight
% end


end

