function writeKernel(f,ker,sigma)

if strcmp(ker.Type,'FastGauss')
    if ~isfield(ker,'epsilon')
        warning('no required precision given for Fast Gauss Kernel; using default value 1e-3')
        ker.epsilon = 1e-3;
    end
    fprintf(f,'FastGauss,sigma,epsilon=\n%f %f\n',sigma,ker.epsilon);
elseif strcmp(ker.Type,'GridGauss')
    fprintf(f,'GridGauss,sigma,ratio=\n%f %f\n',sigma,ker.ratio);
elseif strcmp(ker.Type,'CauchyGpu')
    fprintf(f,'CauchyGpu,sigma=\n%f\n',sigma);
elseif strcmp(ker.Type,'GaussGpu')
    fprintf(f,'GaussGpu,sigma=\n%f\n',sigma);
elseif strcmp(ker.Function,'Cubic')
    fprintf(f,'%s,function=\nCubic\n',ker.Type);
else
    fprintf(f,'%s,function=\n%s,sigma=\n%f\n',ker.Type,ker.Function,sigma);
end
