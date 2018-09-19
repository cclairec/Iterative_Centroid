function Scmb = combcurr(a,Sa,b,Sb)

if(size(Sa.Vertices,2)~=3)
    Sa.Vertices=Sa.Vertices';
end
if(size(Sb.Vertices,2)~=3)    
    Sb.Vertices=Sb.Vertices';
end
Scmb.Vertices = [Sa.Vertices;Sb.Vertices]';
if(size(Sa.Faces,2)~=3)
    Sa.Faces=Sa.Faces';
end
if(size(Sb.Faces,2)~=3)
    Sb.Faces=Sb.Faces';     
end
Scmb.Faces = [Sa.Faces;Sb.Faces+size(Sa.Vertices,1)]';
if ~isfield(Sa,'Weights')
    Sa.Weights = ones(1,size(Sa.Faces,1));
end
if ~isfield(Sb,'Weights')
    Sb.Weights = ones(1,size(Sb.Faces,1));
end

Scmb.Weights = [a*Sa.Weights,b*Sb.Weights];

