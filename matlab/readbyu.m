function [V,F] = readbyu(byufile)

% load vertices of byu surface

fbyu = fopen(byufile,'r');

% read header
ncomponents = fscanf(fbyu,'%d',1);	% number of components
npoints = fscanf(fbyu,'%d',1);		% number of vertices
nfaces = fscanf(fbyu,'%d',1);		% number of faces
nedges = fscanf(fbyu,'%d',1);		% number of edges
fscanf(fbyu,'%d',2*ncomponents);	% components (ignored)

% read data
V = fscanf(fbyu,'%f',[3,npoints]);		% vertices
F = fscanf(fbyu,'%d',[3,nfaces]);		% faces

fclose(fbyu);

ind = [find(F<0);nedges+1];
F = abs(F);
