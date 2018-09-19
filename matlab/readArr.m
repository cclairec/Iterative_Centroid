function A = readArr(f)

Ndims = fscanf(f,'%d',1);
sz = fscanf(f,'%d',Ndims);
A = fscanf(f,'%f',prod(sz));
if length(sz)>1
    A = reshape(A,sz');
end
