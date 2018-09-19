
% speed benchmark to compare direct, Fast Gauss Transform and GPU computations with on a simple matching example.

% benchmodes = {'Matlab Cauchy (double)','Matlab Gauss (double)','Matlab FGT (double)','C++ Cauchy float','C++ Gauss float',...
%     'C++ Cauchy double','C++ Gauss double','C++ FGT (double)','C++ GPU (float)','C++ GridGauss double','C++ GridGauss float'};
benchmodes = {'C++ FGT (double)','C++ Gauss double','C++ GPU (float)'};%,'C++ GridGauss double'};
Ns = [50,100,200,500,1000,2000];
clear BenchTab;

for i = 1:length(Ns)
    N = Ns(i);
    for k = 1:length(benchmodes)
        benchmode = benchmodes{k};
        clear s target
        
        s.T = 10;
        s.useDef = 'LargeDef';
        
        %s.x = [1,0,0;0,1,0;0,0,1];%rand(3,3);
        %[s.x,target{1}.vx] = readbyu('001_lpt_r.byu');
        %[target{1}.y,target{1}.vy] = readbyu('000_lpt_r.byu');
        
        Nx = N;
        %s.x = [rand(3,Nx),[0,1,0,1;0,0,1,1;0,0,0,0]];
        s.x = 2*(rand(3,Nx)-.5);
        s.x = s.x(:,sum(s.x(1:2,:).^2)<1);
        s.x(3,:) = 0*s.x(1,:);
        target{1}.vx = delaunay(s.x(1,:),s.x(2,:))';
        %target{1}.vx = orient(target{1}.vx);
        
        Ny = N;
        %target{1}.y = [rand(3,Ny),[0,1,0,1;0,0,1,1;0,0,0,0]];
        target{1}.y = 2*(rand(3,Ny)-.5);
        target{1}.y = target{1}.y(:,sum(target{1}.y(1:2,:).^2)<1);
        target{1}.y(3,:) = .5 + sum((target{1}.y(1:2,:)).^2);
        target{1}.y(1,:) = 2*target{1}.y(1,:);
        target{1}.y(2,:) = .5*target{1}.y(2,:);
        target{1}.vy = delaunay(target{1}.y(1,:),target{1}.y(2,:))';
        %s.vy = orient(s.vy);
        
        
        nfx = size(target{1}.vx,2);
        nfy = size(target{1}.vy,2);
        
        
        s.sigmaV = .5*ones(1,s.T);
        s.targetweights = 1;
        s.gammaR = 0;
        s.optim_maxiter = 10;
        s.optim_stepsize = 1;
        s.optim_verbosemode = 1;
        s.optim_breakratio = 1e-6;
        s.optim_loopbreak = 10;
        s.rigidmatching = 0;
        s.optim_useoptim = 'fixedesc';
             
        target{1}.method = 'surfcurr';
        switch benchmode
            case 'Matlab Cauchy (double)'
                s.useCpp = 0;
                s.usefgt = 0;
                cd('/Users/darkside/Desktop/sci/matlab/matchine')
                builtinker('exp(argin)','exp(argin)')
                cd('/Users/darkside/Desktop/sci/blitz')
            case 'Matlab Gauss (double)'
                s.useCpp = 0;
                s.usefgt = 0;
                cd('/Users/darkside/Desktop/sci/matlab/matchine')
                builtinker('1/(1-argin)','1/(1-argin)^2')
                cd('/Users/darkside/Desktop/sci/blitz')
            case 'Matlab FGT (double)'
                s.useCpp = 0;
                s.usefgt = 1;
                target{1}.usefgt = 1;
                cd('/Users/darkside/Desktop/sci/matlab/matchine')
                builtinker('exp(argin)','exp(argin)')
                cd('/Users/darkside/Desktop/sci/blitz')
            case 'C++ Cauchy double'
                s.useCpp = 1;
                s.typefloat = 'double';
                s.CppKer.Type = 'SqDistScalar';
                s.CppKer.Function = 'Cauchy';
                target{1}.CppKer.Type = 'SqDistScalar';
                target{1}.CppKer.Function = 'Cauchy';
            case 'C++ Gauss double'
                s.useCpp = 1;
                s.typefloat = 'double';
                s.CppKer.Type = 'SqDistScalar';
                s.CppKer.Function = 'Gaussian';
                target{1}.CppKer.Type = 'SqDistScalar';
                target{1}.CppKer.Function = 'Gaussian';
            case 'C++ Cauchy float'
                s.useCpp = 1;
                s.typefloat = 'float';
                s.CppKer.Type = 'SqDistScalar';
                s.CppKer.Function = 'Cauchy';
                target{1}.CppKer.Type = 'SqDistScalar';
                target{1}.CppKer.Function = 'Cauchy';
            case 'C++ Gauss float'
                s.useCpp = 1;
                s.typefloat = 'float';
                s.CppKer.Type = 'SqDistScalar';
                s.CppKer.Function = 'Gaussian';
                target{1}.CppKer.Type = 'SqDistScalar';
                target{1}.CppKer.Function = 'Gaussian';
            case 'C++ GPU (float)'
                s.useCpp = 1;
                s.CppKer.Type = 'CauchyGpu';
                target{1}.CppKer.Type = 'CauchyGpu';
            case 'C++ FGT (double)'
                s.useCpp = 1;
                s.CppKer.Type = 'FastGauss';
                s.CppKer.epsilon = 1e-3;                      % IFGT accuracy
                target{1}.CppKer.Type = 'FastGauss';
                target{1}.CppKer.epsilon = 9;                      % IFGT accuracy
            case 'C++ GridGauss float'
                s.typefloat = 'float';
                s.useCpp = 1;
                s.CppKer.Type = 'GridGauss';
                s.CppKer.ratio = .2;
                target{1}.CppKer.Type = 'GridGauss';
                target{1}.CppKer.ratio = .2;
            case 'C++ GridGauss double'
                s.typefloat = 'double';
                s.useCpp = 1;
                s.CppKer.Type = 'GridGauss';
                s.CppKer.ratio = .2;
                target{1}.CppKer.Type = 'GridGauss';
                target{1}.CppKer.ratio = .2;
            otherwise
                error('benchmode not listed')
        end
        target{1}.sigmaW = .5;
        %target{1}.y = s.x+.2;%rand(3,3);
        %target{1}.vx = [1;2;3];
        %target{1}.vy = [1;2;3];
        target{1}.wx = ones(1,nfx);
        target{1}.wy = ones(1,nfy);
        
        tic
        if s.useCpp
            s = matchCpp(s,target);
        else
            s = match(s,target);
        end
        BenchTab(i,k) = toc;
        
        clf
        s.showpoints = 0;
        if s.useDef==2
            s.T = 2;
            s.X(:,:,1) = s.x;
            s.X(:,:,2) = s.phix;
        end
        %affiche(s);
        
        s.transmatrix = eye(3);
        s.transvector = zeros(3,1);
        
        s.showtraj = 1;
        
        %s.showgrid = 1;
        %makewrl('ess.wrl',s);
    end
end

clf
loglog(Ns,BenchTab,'LineWidth',3)
legend(benchmodes)

