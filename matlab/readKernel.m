function [CppKer,Ker,sigma] = readKernel(f)

CppKer.Type = strrep(fscanf(f,'%s',1),',function=','');

if strcmp(CppKer.Type,'FastGauss,sigma,order,K,e=')
    CppKer.Type = 'FastGauss';
    sigma = fscanf(f,'%f',1);
    CppKer.order = fscanf(f,'%d',1);
    CppKer.K = fscanf(f,'%d',1);
    CppKer.e = fscanf(f,'%f',1);
    Ker = 'FastGauss';
elseif strcmp(CppKer.Type,'FastGauss,sigma,epsilon=')
    CppKer.Type = 'FastGauss';
    sigma = fscanf(f,'%f',1);
    CppKer.epsilon = fscanf(f,'%f',1);
    Ker = 'FastGauss';
elseif strcmp(CppKer.Type,'CauchyGpu,sigma=')
    CppKer.Type = 'CauchyGpu';
    sigma = fscanf(f,'%f',1);
    Ker = 'CauchyGpu';
elseif strcmp(CppKer.Type,'GaussGpu,sigma=')
    CppKer.Type = 'GaussGpu';
    sigma = fscanf(f,'%f',1);
    Ker = 'GaussGpu';
else
    [Ker,CppKer.Function] = readFunction(f);
    if strcmp(CppKer.Type,'SqDistScalar')
        Ker = 'Vect';
    end
    sigma = fscanf(f,'%f',1);
end