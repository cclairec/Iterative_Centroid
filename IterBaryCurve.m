function Csrc = IterBaryCurve(C,gammaR,sigmaV,sigmaW,T)

numsujets = length(C);
Csrc = C{1};
for k=2:numsujets
    k
    Ctgt = C{k};
    sout = matchcurve2(Csrc,Ctgt,gammaR,sigmaV,sigmaW,T);
    tf = 1+(T-1)/k;
    etf = floor(tf);
    ftf = tf-etf;
    V = sout.X(:,:,etf);
    Vp = flowCpp(sout,V,etf,etf+1);
    Csrc.Vertices = ((1-ftf)*V + ftf*Vp)';
end
