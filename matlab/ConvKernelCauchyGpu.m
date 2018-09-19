function gamma = ConvKernelCauchyGpu(sigma,x,alpha,y)

global pathtobins

xFile = 'x.mch';
alphaFile = 'alpha.mch';
yFile = 'y.mch';
gammaFile = 'gamma.mch';

setenv('PATH',['/usr/local/cuda/bin:',getenv('PATH')]);
setenv('DYLD_LIBRARY_PATH',['/usr/local/cuda/lib64:',getenv('DYLD_LIBRARY_PATH')]);
setenv('LD_LIBRARY_PATH',[getenv('LD_LIBRARY_PATH') ':/usr/local/cuda/lib64']);
%setenv('LD_LIBRARY_PATH','');

cmd = [pathtobins,'ConvKernelCauchyGpu'];

f = fopen(xFile,'w');
writeArr(x,f);
f = fopen(alphaFile,'w');
writeArr(alpha,f);
f = fopen(yFile,'w');
writeArr(y,f);

eval(['! ',cmd,' ',num2str(sigma),' ',xFile,' ',...
    alphaFile,' ',yFile,' ',gammaFile])

f = fopen(gammaFile,'r');
gamma = readArr(f);
fclose(f);

