function [B_pairewise poids] = PairewiseBarySurf(S,gammaR,sigmaV,sigmaW,T,maxiter,MPeps)
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

for i=1:length(S)
    if(~isfield(S{i},'poids'))
        S{i}.poids=[];
    end
end

[B poids] = recursif_Bary_1(S,gammaR,sigmaV,sigmaW,T,maxiter,MPeps,zeros(1,length(S)))

B.temp=[num2str(toc(chrono_bary)/60),' minutes pour PaireWiseBarySurf '];
B_pairewise{1}=B;
end