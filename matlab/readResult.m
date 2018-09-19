function s = readResult(FileName)


f = fopen(FileName,'r');
while 1
    Tag = fscanf(f,'%s',1);
    switch Tag
        case ''
            break;
        case 'Evol'
            switch fscanf(f,'%s',1)
                case 'LargeDef'
                    s.useDef = 'LargeDef';
                    s.elasticmatching = 1;
                    for k = 1:5
                        Tag = fscanf(f,'%s',1);
                        switch Tag
                            case 'Dimension='
                                Dim = fscanf(f,'%d',1);
                            case 'NumTimeSteps='
                                s.T = fscanf(f,'%d',1);
                                s.sigmaV = zeros(1,s.T);
                            case 'NumPoints='
                                s.nx = fscanf(f,'%d',1);
                            case 'Kernel=same'
                                [s.CppKer,s.kerV,sigma] = readKernel(f);
                                s.sigmaV = sigma * ones(1,s.T);
                            case 'Kernel='
                                for t=1:s.T
                                    [s.CppKer,s.kerV,s.sigmaV(t)] = readKernel(f);
                                end
                            case 'Position,Momentum='
                                s.X = readArr(f);
                                s.x = s.X(:,:,1);
                                s.phix = s.X(:,:,end);
                                s.mom = readArr(f);
                        end
                    end
                    s.distIdPhi = sqrt(.5 * sum(sum(sum((s.mom(:,:,2:end)+s.mom(:,:,1:end-1)).*diff(s.X,[],3)))));
                case 'LargeDefSpec'
                    s.useDef = 'LargeDefSpec';
                    s.elasticmatching = 1;
                    for k = 1:6
                        Tag = fscanf(f,'%s',1);
                        switch Tag
                            case 'Dimension='
                                Dim = fscanf(f,'%d',1);
                            case 'NumTimeSteps='
                                s.T = fscanf(f,'%d',1);
                                s.sigmaV = zeros(1,s.T);
                            case 'NumPoints='
                                s.nx = fscanf(f,'%d',1);
                            case 'NumPointsSpec='
                                s.nx = fscanf(f,'%d',1);
                            case 'Kernel=same'
                                [s.CppKer,s.kerV,sigma] = readKernel(f);
                                s.sigmaV = sigma * ones(1,s.T);
                            case 'Kernel='
                                for t=1:s.T
                                    [s.CppKer,s.kerV,s.sigmaV(t)] = readKernel(f);
                                end
                            case 'Position,PositionSpec,Momentum='
                                s.X = readArr(f);
                                s.Xspec = readArr(f);
                                s.x = s.X(:,:,1);
                                s.xspec = s.Xspec(:,:,1);
                                s.phix = s.Xspec(:,:,end);
                                s.mom = readArr(f);
                        end
                    end
                    s.distIdPhi = .5 * sum(sum(sum((s.mom(:,:,2:end)+s.mom(:,:,1:end-1)).*diff(s.X,[],3)))) / (s.T-1);
                case 'SmallDef'
                    s.useDef = 'SmallDef';
                    s.elasticmatching = 1;
                    for k = 1:4
                        Tag = fscanf(f,'%s',1);
                        switch Tag
                            case 'Dimension='
                                Dim = fscanf(f,'%d',1);
                            case 'NumPoints='
                                s.nx = fscanf(f,'%d',1);
                            case 'Kernel='
                                [s.CppKer,s.kerV,s.sigmaV] = readKernel(f);
                            case 'Position,Momentum,Phi='
                                s.x = readArr(f);
                                s.mom = readArr(f);
                                s.phix = readArr(f);
                        end
                    end
                case 'FreeEvol'
                    s.useDef = 'FreeEvol';
                    s.elasticmatching = 0;
                    for k = 1:3
                        Tag = fscanf(f,'%s',1);
                        switch Tag
                            case 'Dimension='
                                Dim = fscanf(f,'%d',1);
                            case 'NumPoints='
                                s.nx = fscanf(f,'%d',1);
                            case 'Position,Momentum,Phi='
                                s.x = readArr(f);
                                s.mom = readArr(f);
                                s.phix = readArr(f);
                        end
                    end
            end
        case 'Targets'
            s.ntargets = fscanf(f,'%d',1);
            for i=1:s.ntargets
                Tag = fscanf(f,'%s',1);
                switch Tag
                    case 'Measure'
                        s.target{i}.method = 'measures';
                        for k = 1:5
                            switch fscanf(f,'%s',1)
                                case 'Range='
                                    s.target{i}.vx = fscanf(f,'%d',1):fscanf(f,'%d',1);
                                case 'Weight='
                                    s.targetweights(i) = fscanf(f,'%f',1);
                                case 'Kernel='
                                    [s.target{i}.CppKer,s.target{i}.kerI,s.target{i}.sigmaI] = readKernel(f);
                                case 'Y='
                                    s.target{i}.y = readArr(f);
                                case 'WX,WY='
                                    s.target{i}.wx = readArr(f);
                                    s.target{i}.wy = readArr(f);
                            end
                        end
                    case 'SurfCurr'
                        s.target{i}.method = 'surfcurr';
                        for k = 1:7
                            Tag = fscanf(f,'%s',1);
                            switch Tag
                                case 'Range='
                                    offset = fscanf(f,'%d',1) - 1;
                                    fscanf(f,'%d',1);
                                case 'Weight='
                                    s.targetweights(i) = fscanf(f,'%f',1);
                                case 'Kernel='
                                    [s.target{i}.CppKer,s.target{i}.kerW,s.target{i}.sigmaW] = readKernel(f);
                                case 'VY='
                                    s.target{i}.y = readArr(f);
                                case 'FY='
                                    s.target{i}.vy = readArr(f);
                                case 'FX='
                                    s.target{i}.vx = readArr(f);
                                case 'WX,WY='
                                    s.target{i}.wx = readArr(f);
                                    s.target{i}.wy = readArr(f);
                            end
                        end
                        s.target{i}.vx = s.target{i}.vx + offset;
                    case 'CurveCurr'
                        s.target{i}.method = 'curvecurr';
                        for k = 1:7
                            switch fscanf(f,'%s',1)
                                case 'Range='
                                    offset = fscanf(f,'%d',1) - 1;
                                    fscanf(f,'%d',1);
                                case 'Weight='
                                    s.targetweights(i) = fscanf(f,'%f',1);
                                case 'Kernel='
                                    [s.target{i}.CppKer,s.target{i}.kerW,s.target{i}.sigmaW] = readKernel(f);
                                case 'VY='
                                    s.target{i}.y = readArr(f);
                                case 'FY='
                                    s.target{i}.vy = readArr(f);
                                case 'FX='
                                    s.target{i}.vx = readArr(f);
                                case 'WX,WY='
                                    s.target{i}.wx = readArr(f);
                                    s.target{i}.wy = readArr(f);
                            end
                        end
                        s.target{i}.vx = s.target{i}.vx + offset;
                    case 'CurveCycleTarget'
                        s.target{i}.method = 'curvecycle';
                        for k = 1:11
                            switch fscanf(f,'%s',1)
                                case 'Range='
                                    offset = fscanf(f,'%d',1) - 1;
                                    fscanf(f,'%d',1);
                                case 'Weight='
                                    s.targetweights(i) = fscanf(f,'%f',1);
                                case 'FunctionPoint='
                                    [s.target{i}.kerW,s.target{i}.CppKer.Function] = readFunction(f);
                                    s.target{i}.sigmaW = fscanf(f,'%f',1);
                                case 'OrderConeFunction='
                                    s.target{i}.OrderConeFunction = fscanf(f,'%f',1);
                                case 'AccConeFunction='
                                    s.target{i}.AccConeFunction = fscanf(f,'%f',1);
                                case 'OrderEdgeFunction='
                                    s.target{i}.OrderEdgeFunction = fscanf(f,'%f',1);
                                case 'AccEdgeFunction='
                                    s.target{i}.AccEdgeFunction = fscanf(f,'%f',1);
                                case 'VY='
                                    s.target{i}.y = readArr(f);
                                case 'FY='
                                    s.target{i}.vy = readArr(f);
                                case 'FX='
                                    s.target{i}.vx = readArr(f);
                                case 'WX,WY='
                                    s.target{i}.wx = readArr(f);
                                    s.target{i}.wy = readArr(f);
                            end
                        end
                        s.target{i}.vx = s.target{i}.vx + offset;
                    case 'CurveAcc'
                        s.target{i}.method = 'curvacc';
                        for k = 1:7
                            switch fscanf(f,'%s',1)
                                case 'Range='
                                    offset = fscanf(f,'%d',1) - 1;
                                    fscanf(f,'%d',1);
                                case 'Weight='
                                    s.targetweights(i) = fscanf(f,'%f',1);
                                case 'Kernel='
                                    [s.target{i}.CppKer,s.target{i}.kerW,s.target{i}.sigmaW] = readKernel(f);
                                case 'VY='
                                    s.target{i}.y = readArr(f);
                                case 'FY='
                                    s.target{i}.vy = readArr(f);
                                case 'FX='
                                    s.target{i}.vx = readArr(f);
                                case 'WX,WY='
                                    s.target{i}.wx = readArr(f);
                                    s.target{i}.wy = readArr(f);
                            end
                        end
                        s.target{i}.vx = s.target{i}.vx + offset;
                    case 'Landmarks'
                        s.target{i}.method = 'landmarks';
                        for k = 1:3
                            switch fscanf(f,'%s',1)
                                case 'Range='
                                    s.target{i}.vx = fscanf(f,'%d',1):fscanf(f,'%d',1);
                                case 'Weight='
                                    s.targetweights(i) = fscanf(f,'%f',1);
                                case 'Y='
                                    s.target{i}.y = readArr(f);
                            end
                        end
                    case 'Landmarks_New'
                        s.target{i}.method = 'landmarks';
                        for k = 1:4
                            switch fscanf(f,'%s',1)
                                case 'Range='
                                    s.target{i}.vx = fscanf(f,'%d',1):fscanf(f,'%d',1);
                                case 'Weight='
                                    s.targetweights(i) = fscanf(f,'%f',1);
                                case 'Y='
                                    s.target{i}.y = readArr(f);
                                case 'W='
                                    s.target{i}.w = readArr(f);
                            end
                        end
                    case 'L2Image'
                        s.target{i}.method = 'l2image';
                        for k = 1:6
                            Tag = fscanf(f,'%s',1);
                            switch Tag
                                case 'Range='
                                    s.target{i}.vx = fscanf(f,'%d',1):fscanf(f,'%d',1);
                                case 'Weight='
                                    s.targetweights(i) = fscanf(f,'%f',1);
                                case 'SourceImage='
                                    s.target{i}.imsource = readArr(f);
                                case 'TargetImage='
                                    s.target{i}.imtarget = readArr(f);
                                case 'TargetGridBase='
                                    s.target{i}.basetarget = fscanf(f,'%f',3);
                                case 'TargetGridVoxSize='
                                    s.target{i}.voxsizetarget = fscanf(f,'%f',3);
                            end
                        end
                    otherwise
                        error('la cible n''est pas de type connu')
                end
            end
        case 'Functional'
            s.J = readArr(f);
        otherwise
            error('probleme pendant la lecture du fichier')
    end
end

fclose(f);
s.xrig = s.x;
s.useCpp = 1;

if s.useDef=='SmallDef'
    s.T = 2;
    s.X(:,:,1) = s.x;
    s.X(:,:,2) = s.phix;
end


