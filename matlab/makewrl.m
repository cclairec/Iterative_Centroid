function makewrl(wrlfile,s)

if strcmp(s.useDef,'SmallDef')
	disp('vrml animation only for Large Deformation currently..')
	return;
end
% build vrml file from structure s

fwrlout = fopen(wrlfile,'w');
% header
fprintf(fwrlout,'#VRML V2.0 utf8\n');
fprintf(fwrlout,'Background { skyColor 1 1 1 }\n');
%fprintf(fwrlout,'Group {\n');
%fprintf(fwrlout,'children [\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% display parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

templatebyu = 0;                % use byu file as template data
show = {'x','phi','y'};         % elements to be plotted
xcolor = [0;0;1];               % color for template data
xrigcolor = [1;1;1];            % color for xrig
targetbyu = 0;                  % use byu file as target data
ycolor = [.1;.5;0];             % color for target data
phicolor = [1;0;0];             % color for deformation of template
showtraj = 0;                   % plot trajectories
showgrid = 0;
targetcolors = [1,0,0,1,1,0,1,0;...
    0,1,0,1,1,1,0,0;...
    0,0,1,1,0,1,1,0];
gridsize = 10;
transparent = 1;                % transparent display
showanim = 1;                   % show animation of deformation
useCpp = 0;                     % use C++ code


% update by variables of structure s
loadstruct('s')
ntargets = length(target);
if ntargets && ~isstruct(target{1})
    ntargets = 0;
end
if ntargets
    loadstruct('target{1}')
end

if showgrid
    fprintf(fwrlout,'Shape {\n');
    fprintf(fwrlout,'appearance Appearance {\n');
    fprintf(fwrlout,'material Material {\n');
    fprintf(fwrlout,'diffuseColor 1.0 1.0 1.0\n');
    fprintf(fwrlout,'}\n');
    fprintf(fwrlout,'}\n');
    fprintf(fwrlout,'geometry IndexedLineSet {\n');
    fprintf(fwrlout,'coord ');
    if showanim
        fprintf(fwrlout,'DEF CD_3 ');
    end
    fprintf(fwrlout,'Coordinate {\n');
    fprintf(fwrlout,'point [\n');
    sz = 1.2*(max(x') - min(x'))';
    gridstep = max(sz)/gridsize;
    g1 = mean(x(1,:))-sz(1)/2:gridstep:mean(x(1,:))+sz(1)/2;
    s1 = length(g1);
    g2 = mean(x(2,:))-sz(2)/2:gridstep:mean(x(2,:))+sz(2)/2;
    s2 = length(g2);
    g3 = mean(x(3,:))-sz(3)/2:gridstep:mean(x(3,:))+sz(3)/2;
    s3 = length(g3);
    g1 = repmat(g1',1,s2*s3);
    g2 = kron(g2,ones(s3,s1));
    g3 = kron(ones(s1,s2),g3);
    g1 = g1(:)';
    g2 = g2(:)';
    g3 = g3(:)';
    g = [g1;g2;g3];
    gev = zeros([size(g),T]);
    %gev(:,:,1) = g;%flowCpp(s,g,0,1); 
    if useCpp
        gev = allflowCpp(s,g);
    else
        gev = allflow(s,g);
    end
%     for t = 1:T-1
%         gev(:,:,t+1) = flowCpp(s,gev(:,:,t),t,t+1);
%     end
    fprintf(fwrlout,'%f %f %f,\n',gev(:,:,1));
    fprintf(fwrlout,']\n}\n');
    fprintf(fwrlout,'coordIndex [\n');
    indices = 0:s1*s2*s3-1;
    eval(['fprintf(fwrlout,''',strcat(repmat('%d, ',1,s1)),' -1,\n'',indices);'])
    indices = reshape(indices,[s1,s2,s3]);indices = shiftdim(indices,1);indices = indices(:)';
    eval(['fprintf(fwrlout,''',strcat(repmat('%d, ',1,s3)),' -1,\n'',indices);'])
    indices = reshape(indices,[s3,s1,s2]);indices = shiftdim(indices,1);indices = indices(:)';
    eval(['fprintf(fwrlout,''',strcat(repmat('%d, ',1,s2)),' -1,\n'',indices);'])
    fprintf(fwrlout,']\n');
    fprintf(fwrlout,'}\n');
    fprintf(fwrlout,'},\n');
end


if showtraj
    if ntargets
        for k = 1:ntargets
            ix{k} = unique(s.target{k}.vx(:));
            cx{k} = targetcolors(:,k);
        end
    else
        ix{1} = 1:nx;
        cx{1} = targetcolors(:,1);
    end
    for k = 1:length(ix)
        fprintf(fwrlout,'Shape {\n');
        fprintf(fwrlout,'appearance Appearance {\n');
        fprintf(fwrlout,'material Material {\n');
        fprintf(fwrlout,'emissiveColor %f %f %f\n',targetcolors(:,k));
        fprintf(fwrlout,'}\n');
        fprintf(fwrlout,'}\n');
        fprintf(fwrlout,'geometry IndexedLineSet {\n');
        fprintf(fwrlout,'coord ');
        if showanim
            fprintf(fwrlout,'DEF CD_%d ',k+1);
        end
        fprintf(fwrlout,'Coordinate {\n');
        fprintf(fwrlout,'point [\n');
        ech = [ones(1,T),2:T];
        if showanim
            ech1 = ones(1,T);
        else
            ech1 = 1:T;
        end
        nvx = length(ix{k});
        fprintf(fwrlout,'%f %f %f,\n',[...
            reshape(squeeze(X(1,ix{k},ech1))',1,nvx*T);...
            reshape(squeeze(X(2,ix{k},ech1))',1,nvx*T);...
            reshape(squeeze(X(3,ix{k},ech1))',1,nvx*T)]);...
            fprintf(fwrlout,']\n}\n');
        fprintf(fwrlout,'coordIndex [\n');
        %eval(['fprintf(fwrlout,''',strcat(repmat('%d, ',1,T)),' -1,\n'',reshape(0:floor(nvx*.1)*T-1,T,floor(nvx*.1)));'])
        eval(['fprintf(fwrlout,''',strcat(repmat('%d, ',1,T)),' -1,\n'',reshape(0:nvx*T-1,T,nvx));'])
        fprintf(fwrlout,']\n');
        fprintf(fwrlout,'}\n');
        fprintf(fwrlout,'},\n');
    end
end

for i = 1:length(show)
    it = show{i};
    if it
    fprintf(fwrlout,'Transform {\n');
    fprintf(fwrlout,'children [\n');
    fprintf(fwrlout,'Shape {\n');
    fprintf(fwrlout,'geometry IndexedFaceSet {\n');
    fprintf(fwrlout,'solid FALSE\n');

    % write vertices data

    fprintf(fwrlout,'coord ');

    switch(it)
        case 'y'
            if isstr(targetbyu)
                [V,F] = readbyu(targetbyu);
            else
                V = y;
                F = vy;
            end
        case 'x'
            if isstr(templatebyu)
                [V,F] = readbyu(templatebyu);
            else
                V = x;
                F = vx;
            end
        case 'xrig'
            if templatebyu
                [V,F] = readbyu(templatebyu);
            else
                V = x;
                F = vx;
            end
            V = transmatrix * V + repmat(transvector,1,size(V,2));
        case 'phi'
            if isstr(templatebyu)
                [V,F] = readbyu(templatebyu);
            else
                V = x;
                F = vx;
            end
            V = transmatrix * V + repmat(transvector,1,size(V,2));
            Vev = zeros([size(V),T]);
%            Vev(:,:,1) = V;
            Vev = allflowCpp(s,V);
%             for t = 1:T-1
%                 Vev(:,:,t+1) = flowCpp(s,Vev(:,:,t),t,t+1);
%             end
            V = Vev(:,:,T);
            if showanim
                fprintf(fwrlout,'DEF CD_1 ');
            end
    end

    fprintf(fwrlout,'Coordinate {\n');
    fprintf(fwrlout,'point [');
    fprintf(fwrlout,'\n%f %f %f,',V(:,1:end-1));
    fprintf(fwrlout,'\n%f %f %f',V(:,end));

    % write faces data
    fprintf(fwrlout,'\n]\n}\ncoordIndex [');
    fprintf(fwrlout,'\n%d %d %d -1,',F(:,1:end-1)-1); % "-1" : indices start at 0
    fprintf(fwrlout,'\n%d %d %d -1',F(:,end)-1);
    fprintf(fwrlout,'\n]\n');

    % write color data
    clr = eval([it,'color']);
    fprintf(fwrlout,'}\n');
    fprintf(fwrlout,'appearance Appearance {\nmaterial Material {\n');
    fprintf(fwrlout,'diffuseColor %f %f %f\n',clr);
    if transparent
        fprintf(fwrlout,'transparency 0.5\n');
    end
    fprintf(fwrlout,'}\n}\n}\n]\n}\n');
    end
end

if sum(strcmp(show,'phi')) & showanim
    fprintf(fwrlout,'DEF COD_INT1 CoordinateInterpolator {\n');
    fprintf(fwrlout,'key [ \n');
    fprintf(fwrlout,'%f ',.75*(0:T-1)/(T-1));
    fprintf(fwrlout,']\n');
    fprintf(fwrlout,'keyValue [\n\n');
    fprintf(fwrlout,'%f %f %f,\n',Vev);
    fprintf(fwrlout,']\n}\n');
    fprintf(fwrlout,'DEF TIMER1 TimeSensor {\n');
    fprintf(fwrlout,'cycleInterval 10\n');
    fprintf(fwrlout,'loop TRUE\n}\n');
    fprintf(fwrlout,'ROUTE TIMER1.fraction_changed TO COD_INT1.set_fraction\n');
    fprintf(fwrlout,'ROUTE COD_INT1.value_changed TO CD_1.set_point\n');
end

if showtraj & showanim
    for k = 1:ntargets
        fprintf(fwrlout,'DEF COD_INT%d CoordinateInterpolator {\n',k+1);
        fprintf(fwrlout,'key [ \n');
        fprintf(fwrlout,'%f ',.75*(0:T-1)/(T-1));
        fprintf(fwrlout,']\n');
        fprintf(fwrlout,'keyValue [\n\n');
        ixk = unique(s.target{k}.vx(:));
        nvx = length(ixk);
        for t=1:T
            fprintf(fwrlout,'%f %f %f,\n',[...
                reshape(squeeze(X(1,ixk,ech(t:T+t-1)))',1,nvx*T);...
                reshape(squeeze(X(2,ixk,ech(t:T+t-1)))',1,nvx*T);...
                reshape(squeeze(X(3,ixk,ech(t:T+t-1)))',1,nvx*T)]);
        end
        fprintf(fwrlout,']\n}\n');
        fprintf(fwrlout,'DEF TIMER%d TimeSensor {\n',k+1);
        fprintf(fwrlout,'cycleInterval 10\n');
        fprintf(fwrlout,'loop TRUE\n}\n');
        fprintf(fwrlout,'ROUTE TIMER%d.fraction_changed TO COD_INT%d.set_fraction\n',[k+1 k+1]);
        fprintf(fwrlout,'ROUTE COD_INT%d.value_changed TO CD_%d.set_point\n',[k+1 k+1]);
    end
end

if showgrid & showanim
    fprintf(fwrlout,'DEF COD_INT3 CoordinateInterpolator {\n');
    fprintf(fwrlout,'key [ \n');
    fprintf(fwrlout,'%f ',.75*(0:T-1)/(T-1));
    fprintf(fwrlout,']\n');
    fprintf(fwrlout,'keyValue [\n\n');
    fprintf(fwrlout,'%f %f %f,\n',gev);
    fprintf(fwrlout,']\n}\n');
    fprintf(fwrlout,'DEF TIMER3 TimeSensor {\n');
    fprintf(fwrlout,'cycleInterval 10\n');
    fprintf(fwrlout,'loop TRUE\n}\n');
    fprintf(fwrlout,'ROUTE TIMER3.fraction_changed TO COD_INT3.set_fraction\n');
    fprintf(fwrlout,'ROUTE COD_INT3.value_changed TO CD_3.set_point\n');
end

%fprintf(fwrlout,']\n}');
fclose(fwrlout);

disp(['wrote VRML file ',wrlfile])
