function testFGT(Dim,Sigma,nx,order,K,e)

Sigma2 = Sigma^2;
a = rand(Dim,nx);
x = rand(Dim,nx);
essdir = zeros(Dim,nx);
tic
for m = 1:nx
    locm = 3*(m-1);
    for l = 1:nx
        locl = 3*(l-1);
        argin = -( ...
            (x(1+locm)-x(1+locl))^2 + ...
            (x(2+locm)-x(2+locl))^2 + ...
            (x(3+locm)-x(3+locl))^2)/Sigma2;
        argout = exp(argin);  %% BUILT IN KERNEL kerV, do not remove this comment
        essdir(:,m) = essdir(:,m) + argout * a(:,l);
    end
end
tocdir = toc
tic
essfgt = fgt(Dim,x,a,x,Sigma,order,K,e);
tocfgt = toc
timefgt = tocfgt/tocdir
errfgt = mean(sum((essdir-essfgt).^2));
disp(['erreur fgt diffeos : ',num2str(errfgt)])
disp(['ratio temps fgt/dir diffeos : ',num2str(timefgt)])
