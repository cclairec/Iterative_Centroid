function writeLargeDef(s,f)

fprintf(f,'LargeDef\n'); 
fprintf(f,['Dimension=\n',num2str(size(s.x,1)),'\n']);
if ~isfield(s,'T')
    s.T = 30;
end
fprintf(f,'NumTimeSteps=\n%d\n',s.T); 
fprintf(f,'NumPoints=\n%d\n',size(s.x,2)); 
switch length(s.sigmaV)
    case 1
        fprintf(f,'Kernel=same\n');
        writeKernel(f,s.CppKer,s.sigmaV);
    case s.T
        fprintf(f,'Kernel=\n');
        for t=1:s.T
            writeKernel(f,s.CppKer,s.sigmaV(t));
        end
end
if isfield(s,'X') && isfield(s,'mom') && size(s.X,3)==s.T && size(s.mom,3)==s.T
    fprintf(f,'Position,Momentum=\n');
    writeArr(s.X,f);
    writeArr(s.mom,f);
elseif isfield(s,'x') && isfield(s,'mom') && (size(s.mom,3)==1 || all(~s.mom(:,:,2:end)))
    fprintf(f,'Position(1),Momentum(1)=\n');
    writeArr(s.x,f);
    writeArr(s.mom,f);
else
    fprintf(f,'Position(1)=\n');
    writeArr(s.x,f);
end
