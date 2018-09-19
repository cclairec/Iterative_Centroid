function s = matchCpp(s,targets)

global pathtobins
pathtobins = '/Users/clairec/Codes/Code2/catchine/trunk/bin/Darwin-14.3.0_DIM3_Release/';

%setenv('PATH',['/usr/local/cuda/bin:',getenv('PATH')]);
%setenv('DYLD_LIBRARY_PATH',['/usr/local/cuda/lib64:',getenv('DYLD_LIBRARY_PATH')]);
%setenv('LD_LIBRARY_PATH',[getenv('LD_LIBRARY_PATH') ':/usr/local/cuda/lib64']);
setenv('LD_LIBRARY_PATH','');

matchfloatcmd = [pathtobins,'match -f float'];
matchdoublecmd = [pathtobins,'match -f double'];
%if ~isfield(s,'filename')
%    s.filename = '';
%else
[~,tmp]=unix('hostname');
%RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));
randtag = num2str(rand(1),10);
ee = 4;
if ee > length(tmp)
    ee = length(tmp)-1;
end
s.filename = [tmp(1:ee) '_' randtag(3:end)];
num_rand=s.filename;
%end

FileTemp = [s.filename,'_temp.mch'];
FileResults = [s.filename,'_resmatch.mch'];



if isfield(s,'rigidmatching') && s.rigidmatching==1
    s.rigidmatching = 0;
    disp('Rigid matching not implemented in C++ code')
end

if ~isfield(s,'typefloat')
    disp('no typefloat field given, assuming type of float is double')
    s.typefloat = 'double';
end

f = fopen(FileTemp,'w');
fprintf(f,'Evol\n'); 
if ~isfield(s,'useDef')
    s.useDef = 'LargeDef';
    disp('No useDef field given; assuming large deformations')
end
if ~isfield(s,'CppKer')
    if ~isfield(s,'usefgt') || s.usefgt==0
        s.CppKer.Type = 'SqDistScalar';
    else
        s.CppKer.Type = 'FastGauss';
        s.CppKer.order = 7;
        s.CppKer.K = 55;
        s.CppKer.e = 9;
    end
    s.CppKer.Function = 'Gaussian';
    disp('no CppKer field given (deformation). Assuming gaussian kernel')
end
switch s.useDef
    case 'LargeDef'
        writeLargeDef(s,f);
    case 'LargeDefSpec'
        writeLargeDefSpec(s,f);
    case 'SmallDef'
        writeSmallDef(s,f);
    case 'FreeEvol'
        writeFreeEvol(s,f);
    otherwise
        error('unknown deformation type')
end

if (strcmp(s.CppKer.Type,'CauchyGpu') || strcmp(s.CppKer.Type,'GaussGpu')) && ~strcmp(s.typefloat,'float')
    s.typefloat = 'float';
    disp('redefining typefloat to ''float'' for use of Gpu code')
end


% writing the targets
fprintf(f,'Targets\n'); 
ntargets = length(targets);
fprintf(f,'%d\n',ntargets);
for i=1:ntargets
    if ~isfield(targets{i},'weight')
        targets{i}.weight = 1;
    end
    switch(targets{i}.method)
        case 'measures'
            if ~isfield(targets{i},'CppKer')
                targets{i}.CppKer.Type = 'SqDistScalar';
                targets{i}.CppKer.Function = 'Gaussian';
                disp(['no CppKer field given for target ',num2str(i),'. Assuming scalar gaussian kernel'])
            end
            fprintf(f,'Measure\n'); 
            fprintf(f,'Range=\n%d %d\n',targets{i}.vx(1),targets{i}.vx(end));
            fprintf(f,'Weight=\n%f\n',targets{i}.weight);
            fprintf(f,'Kernel=\n');
            writeKernel(f,targets{i}.CppKer,targets{i}.sigmaI)
            if (strcmp(targets{i}.CppKer.Type,'CauchyGpu')||strcmp(targets{i}.CppKer.Type,'GaussGpu')) && ~strcmp(s.typefloat,'float')
                s.typefloat = 'float';
                disp('redefining typefloat to ''float'' for use of Gpu code')
            end
            fprintf(f,'Y=\n'); 
            writeArr(targets{i}.y,f);
            fprintf(f,'WX,WY=\n'); 
            if ~isfield(targets{i},'wx')
                nx = length(targets{i}.vx);
                targets{i}.wx = ones(1,nx)/nx;
            end
            writeArr(targets{i}.wx(:)',f);
            if ~isfield(targets{i},'wy')
                ny = size(targets{i}.y,2);
                targets{i}.wy = ones(1,ny)/ny;
            end
            writeArr(targets{i}.wy(:)',f);
        case 'surfcurr'
            fprintf(f,'SurfCurr\n'); 
            fprintf(f,'Range=\n%d %d\n',min(targets{i}.vx(:)),max(targets{i}.vx(:)));
            fprintf(f,'Weight=\n%f\n',targets{i}.weight);
            if ~isfield(targets{i},'CppKer')
                targets{i}.CppKer.Type = 'SqDistScalar';
                targets{i}.CppKer.Function = 'Gaussian';
                disp(['no CppKer field given for target ',num2str(i),'. Assuming scalar gaussian kernel'])
            end
            fprintf(f,'Kernel=\n');
            writeKernel(f,targets{i}.CppKer,targets{i}.sigmaW)
            if (strcmp(targets{i}.CppKer.Type,'CauchyGpu')||strcmp(targets{i}.CppKer.Type,'GaussGpu')) && ~strcmp(s.typefloat,'float')
                s.typefloat = 'float';
                disp('redefining typefloat to ''float'' for use of Gpu code')
            end            
            fprintf(f,'VY=\n'); 
            writeArr(targets{i}.y,f);
            fprintf(f,'FX=\n'); 
            writeArrInt(targets{i}.vx-min(targets{i}.vx(:))+1,f);
            fprintf(f,'FY=\n'); 
            writeArrInt(targets{i}.vy,f);
            fprintf(f,'WX,WY=\n'); 
            if ~isfield(targets{i},'wx')
                targets{i}.wx = ones(1,size(targets{i}.vx,2));
            end
            writeArr(targets{i}.wx,f);
            if ~isfield(targets{i},'wy')
                targets{i}.wy = ones(1,size(targets{i}.vy,2));
            end
            writeArr(targets{i}.wy,f);
        case 'curvecurr'
            fprintf(f,'CurveCurr\n'); 
            fprintf(f,'Range=\n%d %d\n',min(targets{i}.vx(:)),max(targets{i}.vx(:)));
            fprintf(f,'Weight=\n%f\n',targets{i}.weight);
            if ~isfield(targets{i},'CppKer')
                targets{i}.CppKer.Type = 'SqDistScalar';
                targets{i}.CppKer.Function = 'Gaussian';
                disp(['no CppKer field given for target ',num2str(i),'. Assuming scalar gaussian kernel'])
            end
            fprintf(f,'Kernel=\n');
            writeKernel(f,targets{i}.CppKer,targets{i}.sigmaW)
            if (strcmp(targets{i}.CppKer.Type,'CauchyGpu')||strcmp(targets{i}.CppKer.Type,'GaussGpu')) && ~strcmp(s.typefloat,'float')
                s.typefloat = 'float';
                disp('redefining typefloat to ''float'' for use of Gpu code')
            end
            fprintf(f,'VY=\n'); 
            writeArr(targets{i}.y,f);
            fprintf(f,'FX=\n'); 
            writeArrInt(targets{i}.vx-min(targets{i}.vx(:))+1,f);
            fprintf(f,'FY=\n'); 
            writeArrInt(targets{i}.vy,f);
            fprintf(f,'WX,WY=\n'); 
            if ~isfield(targets{i},'wx')
                targets{i}.wx = ones(1,size(targets{i}.vx,2));
            end
            writeArr(targets{i}.wx,f);
            if ~isfield(targets{i},'wy')
                targets{i}.wy = ones(1,size(targets{i}.vy,2));
            end
            writeArr(targets{i}.wy,f);
        case 'curvecycle'
            fprintf(f,'CurveCycle\n'); 
            fprintf(f,'Range=\n%d %d\n',min(targets{i}.vx(:)),max(targets{i}.vx(:)));
            fprintf(f,'Weight=\n%f\n',targets{i}.weight);
            if ~isfield(targets{i},'CppKer')
                targets{i}.CppKer.Type = 'SqDistScalar';
                targets{i}.CppKer.Function = 'Gaussian';
                disp(['no CppKer field given for target ',num2str(i),'. Assuming scalar gaussian kernel'])
            end
            fprintf(f,'FunctionPoint=\n');
            fprintf(f,'%s,sigma=\n%f\n',targets{i}.CppKer.Function,targets{i}.sigmaW);
            if (strcmp(targets{i}.CppKer.Type,'CauchyGpu')||strcmp(targets{i}.CppKer.Type,'GaussGpu')) && ~strcmp(s.typefloat,'float')
                s.typefloat = 'float';
                disp('redefining typefloat to ''float'' for use of Gpu code')
            end
            fprintf(f,'OrderConeFunction=\n%f\n',targets{i}.OrderConeFunction);
            fprintf(f,'AccConeFunction=\n%f\n',targets{i}.AccConeFunction);
            fprintf(f,'OrderEdgeFunction=\n%f\n',targets{i}.OrderEdgeFunction);
            fprintf(f,'AccEdgeFunction=\n%f\n',targets{i}.AccEdgeFunction);
            fprintf(f,'VY=\n'); 
            writeArr(targets{i}.y,f);
            fprintf(f,'FX=\n'); 
            writeArrInt(targets{i}.vx-min(targets{i}.vx(:))+1,f);
            fprintf(f,'FY=\n'); 
            writeArrInt(targets{i}.vy,f);
        case 'curvacc'
            fprintf(f,'CurveAcc\n'); 
            fprintf(f,'Range=\n%d %d\n',min(targets{i}.vx(:)),max(targets{i}.vx(:)));
            fprintf(f,'Weight=\n%f\n',targets{i}.weight);
            if ~isfield(targets{i},'CppKer')
                targets{i}.CppKer.Type = 'SqDistScalar';
                targets{i}.CppKer.Function = 'Gaussian';
                disp(['no CppKer field given for target ',num2str(i),'. Assuming scalar gaussian kernel'])
            end
            fprintf(f,'Kernel=\n');
            writeKernel(f,targets{i}.CppKer,targets{i}.sigmaW)
            if (strcmp(targets{i}.CppKer.Type,'CauchyGpu')||strcmp(targets{i}.CppKer.Type,'GaussGpu')) && ~strcmp(s.typefloat,'float')
                s.typefloat = 'float';
                disp('redefining typefloat to ''float'' for use of Gpu code')
            end
            fprintf(f,'VY=\n'); 
            writeArr(targets{i}.y,f);
            fprintf(f,'FX=\n'); 
            writeArrInt(targets{i}.vx-min(targets{i}.vx(:))+1,f);
            fprintf(f,'FY=\n'); 
            writeArrInt(targets{i}.vy,f);
            fprintf(f,'WX,WY=\n'); 
            if ~isfield(targets{i},'wx')
                targets{i}.wx = ones(1,size(targets{i}.vx,2));
            end
            writeArr(targets{i}.wx,f);
            if ~isfield(targets{i},'wy')
                targets{i}.wy = ones(1,size(targets{i}.vy,2));
            end
            writeArr(targets{i}.wy,f);
        case 'landmarks'
            fprintf(f,'Landmarks\n'); 
            fprintf(f,'Range=\n%d %d\n',targets{i}.vx(1),targets{i}.vx(end));
            fprintf(f,'Weight=\n%f\n',targets{i}.weight);
            fprintf(f,'Y=\n'); 
            writeArr(targets{i}.y,f);
        case 'l2image'
            fprintf(f,'L2Image\n'); 
            fprintf(f,'Range=\n%d %d\n',targets{i}.rx(1),targets{i}.rx(end));
            fprintf(f,'Weight=\n%f\n',targets{i}.weight);
            fprintf(f,'SourceImage=\n'); 
            writeArr(targets{i}.imsource,f);
            fprintf(f,'TargetImage=\n'); 
            writeArr(targets{i}.imtarget,f);
            fprintf(f,'TargetGridBase=\n%f %f %f\n',targets{i}.basetarget); 
            fprintf(f,'TargetGridVoxSize=\n%f %f %f\n',targets{i}.voxsizetarget);             
    end
end
fclose(f);

if ~isfield(s,'optim_maxiter')
    s.optim_maxiter = 500;
end
if ~isfield(s,'optim_stepsize')
    s.optim_stepsize = 1;
    disp('no auto mode for gradient step size in C++ code. Setting it to 1')
end
if ~isfield(s,'optim_breakratio')
    s.optim_breakratio = 1e-6;
end
if ~isfield(s,'optim_loopbreak')
    s.optim_loopbreak = 40;
end

if ~isfield(s,'typefloat')
    s.typefloat = 'double';
end

eval(['!rm ',FileResults])
switch s.typefloat
    case 'float'
        matchcmd = matchfloatcmd;
    case 'double'
        matchcmd = matchdoublecmd;
end

if ~isfield(s,'optim_useoptim')
    s.optim_useoptim = 'adaptdesc';
end
switch s.optim_useoptim
    case 'adaptdesc'
        useoptim = 1;
    case 'fixedesc'
        useoptim = 0;
end

command = ['!',matchcmd,' -d ',FileTemp,' -o ',FileResults,' -i ',num2str(s.optim_maxiter),...
    ' -s ',num2str(s.optim_stepsize),...
    ' -w ',num2str(s.gammaR),' -u ',num2str(useoptim),' -b ',num2str(s.optim_breakratio),...
    ' -l ',num2str(s.optim_loopbreak)]
tic;
s
eval(command)
elapsedTime = toc;

typefloat = s.typefloat;
s = readResult(FileResults);
s.typefloat = typefloat;
s.elapsedTime = elapsedTime;
system(['rm ',num_rand,'*']);


