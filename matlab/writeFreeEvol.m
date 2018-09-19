function writeFreeEvol(s,f)

fprintf(f,'FreeEvol\n'); 
fprintf(f,'Dimension=\n3\n');
fprintf(f,'NumPoints=\n%d\n',size(s.x,2)); 
if isfield(s,'mom') && isfield(s,'phix')
    fprintf(f,'Position,Momentum,Phi=\n');
    writeArr(s.x,f);
    writeArr(s.mom,f);
    writeArr(s.phix,f);
else
    fprintf(f,'Position=\n');
    writeArr(s.x,f);
end
