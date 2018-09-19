function [Bary poids] = PairewiseBarySurf(S,gammaR,sigmaV,sigmaW,T,maxiter,MPeps,fileout)
chrono_bary=tic;
if nargin < 7
    MPeps = 0;
end

if nargin < 6
    maxiter = 1000;
end

if length(maxiter)==1
    maxiter = repmat(maxiter,1,length(sigmaW));
end

if nargin < 5
    T = 30;
end

k=1;
indices=[1:length(S)]; %randperm(length(S));
for i=indices
    if(~isfield(S{i},'poids'))
        S{i}.poids=[];
    end
    S_{k}=S{i};
    k=k+1;
end
clear S;
S=S_;
clear S_;

[B_pairewise poids] = recursif_Bary_1(S,gammaR,sigmaV,sigmaW,T,maxiter,MPeps,zeros(1,length(S)))


Bary{1}=B_pairewise;
Bary{1}.T=T;
Bary{1}.temp=[num2str(toc(chrono_bary)/60),' minutes pour PaireWiseBarySurf ']
Bary{1}.indices=indices;
Bary{1}.maxiters=maxiter;

save(fileout,'Bary','B_pairewise');
end