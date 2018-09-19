function [Ker,Function] = readFunction(f)

Function = strrep(fscanf(f,'%s',1),',sigma=','');
Ker = Function;
switch Function
    case 'Gaussian'
        Ker = 'exp(argin)';
    case 'Cauchy'
        Ker = '1/(1-argin)';
    case 'Cauchy2'
        Ker = '1/(1-argin)^2';
    case 'Cubic'
        Ker = 'argin^1.5';
end