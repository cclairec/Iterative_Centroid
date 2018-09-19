function [Ssrc B ]= IterBarySurf(S,gammaR,sigmaV,sigmaW,T,maxiter,MPeps)
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
Ssrc = S{1,1};
Ssrc.poids = [];
if (~isempty(S{1,1}.poids))
    poids_temp = S{1,1}.poids;
end
for k=2:numsujets
    k
    if(isempty(S{1,k}.poids))
        Stgt = S{1,k};
        sout = matchsurf(Ssrc,Stgt,gammaR,sigmaV,sigmaW,T,maxiter,0,0);
        tf = 1+(T-1)/k;
        etf = floor(tf);
        ftf = tf-etf;
        Ssrc.Vertices = ((1-ftf)*sout.X(:,:,etf) + ftf*sout.X(:,:,etf+1));
    else
        
        Stgt = S{1,k};
        sout = matchsurf(Ssrc,Stgt,gammaR,sigmaV,sigmaW,T,maxiter);
        poids_temp = (S{1,k}.poids+poids_temp),
        p = S{1,k}.poids*T/poids_temp; % poid Tnormalisé du sujet qui se deplace.
        etf = ceil(p)
        if p>9 etf = floor(p);end
        Ssrc.Vertices = ((1-p/T)*sout.X(:,:,etf) + (p/T)*sout.X(:,:,etf+1));
        
    end

    B{1,k}.Vertices=Ssrc.Vertices;
    B{1,k}.Faces = S{1,1}.Faces;
    B{1,k}.poids = Ssrc.poids;
    B{1,k}.temps = [num2str(toc(chrono_bary)),' secondes pour IterBarySurf at step ' num2str(k)];
    B{1,k}.mom = sout.mom;
    B{1,k}.sigmaV=sigmaV;
    B{1,k}.gammaR=gammaR;
    B{1,k}.sigmaW=sigmaW;
    %     clf;hold on;sout.showpoints=0;sout.show={'y','phi'};affiche(sout);%h=plotsurf(Ssrc,'y');camlight;alpha(h,.5)
    %     pause
    
    if mod(k,50)==0
        clear B_k;
        B_k=B{1,k};
%        save Datas_TestJournal/datas/Result_temp_IC1 B_k k S
    end
end

% Ssrc.Vertices=Ssrc.Vertices';
% Ssrc.Faces=Ssrc.Faces';
