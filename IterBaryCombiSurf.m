function [Stgt B] = IterBaryCombiSurf(S,gammaR,sigmaV,sigmaW,T,maxiter,MPeps)
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

numsujets = length(S);
Stgt = S{1};

Ssrc.poids = [];
if (~isempty(S{1}.poids))
    poids_temp = S{1}.poids;
end
for k=2:numsujets
    k
    S{k}
    if(isempty(S{k}.poids))
        Ssrc = S{k};
        sout = matchsurf(Ssrc,Stgt,gammaR,sigmaV,sigmaW,T,maxiter,MPeps);
        tf = 1+(T-1)*(1-1/k);
        etf = floor(tf);
        ftf = tf-etf;
        Ssrc.Vertices = ((1-ftf)*sout.X(:,:,etf) + ftf*sout.X(:,:,etf+1))';
        Vp = flowCpp(sout,Stgt.Vertices,T,etf+1);
        V = flowCpp(sout,Vp,etf+1,etf);
        Stgt.Vertices = ((1-ftf)*V + ftf*Vp)';
        Stgt = combcurr(1/k,Ssrc,1-1/k,Stgt);
    else
disp('poid!!');
    end
    
    B{k}.Vertices = Stgt.Vertices';
    B{k}.Faces = Stgt.Faces';
    size(B{k}.Vertices)
    size(B{k}.Faces)
    B{k}.poids = Stgt.Weights;
    B{k}.temps = [num2str(toc(chrono_bary)),' secondes pour IterBarySurf at step ' num2str(k)];
    B{k}.mom=sout.mom;
    B{k}.sigmaV=sigmaV;
    B{k}.gammaR=gammaR;
    B{k}.sigmaW=sigmaW;
    %Stgt = approxcurr(Stgt,1e-3,@cauchy,sigmaW(end));
%     clf;hold on;
%     %sout.showpoints=0;sout.show={'y','x'};affiche(sout);
%     plotsurf(Stgt,'y');plotsurf(Ssrc,'r');
%     camlight;alpha .5
%     pause
end
Ssrc.Vertices=Ssrc.Vertices';
Ssrc.Faces=Ssrc.Faces';