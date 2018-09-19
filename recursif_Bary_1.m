function [B poids] = recursif_Bary_1(Bs,gammaR,sigmaV,sigmaW,T,maxiter,MPeps,poids)

if length(Bs)>3
    length(Bs)
    [Bsub{1} ps1]=recursif_Bary_1(Bs(1:floor(length(Bs)/2)),gammaR,sigmaV,sigmaW,T,maxiter,MPeps,poids);
    [Bsub{2} ps2]=recursif_Bary_1(Bs(ceil((length(Bs)+1)/2):end),gammaR,sigmaV,sigmaW,T,maxiter,MPeps,poids);
    [B poids]=Bary(Bsub,gammaR,sigmaV,sigmaW,T,maxiter,MPeps, [ps1 ps2]);
else
    [B poids]=Bary(Bs,gammaR,sigmaV,sigmaW,T,maxiter,MPeps,ones(1,length(Bs)));
end
end

function [B p_]=Bary(Ba,gammaR,sigmaV,sigmaW,T,maxiter,MPeps,poids)

p_ = sum(poids);

if length(maxiter)==1
    maxiter = repmat(maxiter,1,length(sigmaW));
end


numsujets = length(Ba)
Ssrc = Ba{1};
Ssrc.poids = [];
if (~isempty(Ba{1}.poids))
    poids_temp = Ba{1}.poids;
else
    poids_temp = poids(1);
end
for k=2:numsujets
    k
    if (isempty(Ba{k}.poids))
        Ba{k}.poids = poids(1);
    end
    Stgt = Ba{k};
    whos
    sout = matchsurf(Ssrc,Stgt,gammaR,sigmaV,sigmaW,T,maxiter);
    poids_temp = (Ba{k}.poids+poids_temp); % poid total temporaire
    p = Ba{k}.poids*T/poids_temp; % poid Tnormalisé du sujet qui se deplace.
    etf = ceil(p);
    if p>(T-1) etf = floor(p);end
    Ssrc.Vertices = ((1-p/T)*sout.X(:,:,etf) + (p/T)*sout.X(:,:,etf+1));
    Ssrc.poids = poids_temp;
end

B.Vertices=Ssrc.Vertices;
B.Faces = Ba{1}.Faces;
B.poids = Ssrc.poids

% B{1}.temps = [num2str(toc(chrono_bary)),' secondes pour IterBarySurf at step ' num2str(k)];
    B.mom = sout.mom;
    B.sigmaV=sigmaV;
    B.gammaR=gammaR;
    B.sigmaW=sigmaW;

end