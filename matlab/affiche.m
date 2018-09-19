function ghandle = affiche(s,ghandle)

% display results of matching algorithm
% usage:
%   affiche(s);              s is the output structure of a call to match
%   ghandle = affiche(s);    to store the graphical handles
%   affiche(s,ghandle);      to update the current figure
%
% contact : Joan Glaun�s - joan_glaunes@yahoo.fr

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% display parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

showminim = 0;                  % if 1 plot functional vs iterations
showtitle = 0;                  % if 1 write parameters on figure
show = {'x','y','phi'};         % elements to be plotted: x, y, phi, xrig
xcolor = [92;33;165]/256;       % color for template data
xrigcolor = [.5;.5;.5];            % color for xrig
phicolor = [92;165;33]/256;     % color for deformation of template
ycolor = [168;30;30]/256;       % color for target data
xlegend = 'template';           % legend for template plot
ylegend = 'target';
philegend = 'elastic';
xriglegend = 'rigid';
xmarker = 'd';            % marker for template plot
ymarker = '*';
phimarker = '+';
xrigmarker = 'o';
showbyu = 0;                    % if='name.byu' plot deformation of byu surface
timeflow = 1;                   % time fraction of deformation flow
showfaces = 0;                  % if 1 display faces of triangular mesh
facethickness = .5;
showpoints = 1;                 % if 1 display vertices of triangular mesh
showtraj = 0;                   % plot trajectories
showmomtraj = 0;                % plot momentum as arrows along trajectories
showgrid = 0;                   % display grid
showimage = 0;                  % display image
gridsize = 10;                  % size of grid
transparent = .5;               % transparency for surfaces
targetcolors = [1,0,0,1,1,0,1,0;...
                0,1,0,.5,1,1,0,0;...
                0,0,1,.1,0,1,1,0];
viewvector = 0;                 % 3D display view vector
axisvector = 0;                 % 3D display axis vector
updategraph = 0;                % only update deformed data
printag = 0;                    % if 1 save figure
printname = 's';                % file name to save figure
printmode = '-depsc';           % file type
printext = '.eps';              % file extension
printopt = '';                  % additional printing options
showlegend = 1;                 % if 1 print legend

ntargets = length(s.target);
if ntargets
    switch s.target{1}.method
    case {'landmarks','measures'}
        showpoints = 1;
    case {'curvecurr','surfcurr'}
        showfaces = 1;
    end
end

% load variables of structure s
loadstruct('s')

if ntargets > size(targetcolors,2)
    targetcolors = rand(3,ntargets);
end

% save all variables in structure s
savestruct('s',who);

% for compatibility
for k = 1:ntargets
    loadstruct('target{k}')
    if ~exist('vx')
        if exist('mx')
            target{k}.vx = mx;
        elseif exist('bx')
            target{k}.vx = bx;
            target{k}.vy = by;
        end
    end
    if ~exist('vy')
        target{k}.vy = 1:size(y,2);
    end
end

stepflow = round(timeflow*(T-1)+1);
if elasticmatching
    phi = X(:,:,stepflow);
else
    phi = xrig;
end

%clf

if showminim & isfield(s,'J')
    subplot(6,3,17)
    hold on
    if length(s.J) > 1
        plot(s.J,'k')
    end
    subplot(1.2,1,1)
end

hold on
if showtraj & length(size(X))==3
    if size(X,1)==2
        X(3,1,1) = 0;
    end

    for k = 1:ntargets
        loadstruct('target{k}')
        ghandle.traj{k} = plot3(squeeze(X(1,target{k}.vx,1:stepflow))',squeeze(X(2,target{k}.vx,1:stepflow))',squeeze(X(3,target{k}.vx,1:stepflow))');       % plot trajectories
        set(ghandle.traj{k},'Color',[0;0;1])
      %  ghandle.momtraj = quiver3(squeeze(X(1,:,1:stepflow))',squeeze(X(2,:,1:stepflow))',squeeze(X(3,:,1:stepflow))',tau*squeeze(mom(1,:,1:stepflow))',tau*squeeze(mom(2,:,1:stepflow))'/10,tau*squeeze(mom(3,:,1:stepflow))'/10,'g');

    end
end

if showmomtraj & mom~=0
    ghandle.momtraj = quiver3(squeeze(X(1,:,1:stepflow))',squeeze(X(2,:,1:stepflow))',squeeze(X(3,:,1:stepflow))',tau*squeeze(mom(1,:,1:stepflow))',tau*squeeze(mom(2,:,1:stepflow))'/10,tau*squeeze(mom(3,:,1:stepflow))'/10,'g');
end

legh = [];

% a=repmat(x,1,2);%randn(3,60)
% phi = flowCpp(s,a)
% phi = flowCpp(s,a(:,end-6:end))

for l = 1:length(show)
    clear h
    eln = show{l};
    if eln
    elc = eval([eln,'color']);
    for k = 1:ntargets
        h.title = [eval([eln,'legend']),' ',num2str(k)];
        clear vy
        loadstruct('target{k}')
        el = eval(eln);
        if size(el,1)==2
            el(3,1) = 0;
        end
        if strcmp(eln,'y')
            if exist('vy')
                vx = vy;
            else
                vx = 1:size(y,2);
            end
        end
        if showpoints
            h.points = plot3(el(1,vx),el(2,vx),el(3,vx),eval([eln,'marker']));
            set(h.points,'MarkerSize',8,'Color',targetcolors(:,k),...
                'MarkerFaceColor',targetcolors(:,k),...
                'LineWidth',1.5);
            set(h.points,'Tag',h.title);
            legh = [legh,h.points];
        end
        if showfaces
            dim = size(vx,1);
            if dim >= 2
                h.faces = patch(reshape(el(1,vx),dim,size(vx,2)),...
                    reshape(el(2,vx),dim,size(vx,2)),...
                    reshape(el(3,vx),dim,size(vx,2)),shiftdim(elc,-2));
                if dim == 3
                    set(h.faces,'LineStyle','none');
                else
                    set(h.faces,'EdgeColor',elc);
                end
                set(h.faces,'Tag',h.title);
                set(h.faces,'LineWidth',facethickness);
                legh = [legh,h.faces];
            end
        end
    end
    eval(['ghandle.',eln,' = h;'])
    end
end

if showbyu
    [V,F] = readbyu(showbyu);
    Vphi = flow(s,V,0,stepflow);
    delete ess.byu
    makebyu(Vphi,F,'ess.byu')
    plotbyu('ess.byu',[92;33;165]/256);
end

if showgrid
    ghandle.grid = grid3(s,stepflow);
end

if showimage
    %A = repmat(1:50,50,1)';
    A = flipud(double(imread('ess.jpg'))');
    I = repmat(A,[1,1,50]);
    C = [0,1;0,1;0,1];
    J = transport(s,I,C);
    imagesc([0,1],[0,1],flipud(J(:,:,1)'),'AlphaData',.5);
end

if showlegend & legh
    legend(legh,get(legh,'Tag'))
end

if size(viewvector) ~= [1,1]
    view(viewvector);
else
    viewvector = view;
end

axisvector = 0;
if size(axisvector) ~= [1,1]
    axis(axisvector);
else
    axisvector = axis;
end

axis equal
%axis tight

if showtitle
    if min(sigmaV) < max(sigmaV)
        sigmaVstr = [num2str(max(sigmaV)),' -> ',num2str(min(sigmaV))];
    else
        sigmaVstr = num2str(sigmaV(1));
    end
    title(['\sigma_V=',sigmaVstr,', \sigma_W=',num2str(sigmaW)]);%,', \gamma=',num2str(gammaR)]);
end

if transparent==1
    transparent = .5; % for old files
end

alpha(1-transparent)
axis off

%camlight
%shading interp

drawnow
shg

if printag
    print(printopt,printmode,[printname,printext]);
end
hold off;

function h = grid3(s,stepflow)
% construction et affichage de la grille 3D
loadstruct('s')
sz = 1.1 * max(max(x') - min(x'));
gridstep = sz/gridsize;
meanx = .5 * (max(x')+min(x'));
g1 = (meanx(1)-sz/2):gridstep:(meanx(1)+sz/2);
s1 = length(g1);
g2 = (meanx(2)-sz/2):gridstep:(meanx(2)+sz/2);
s2 = length(g2);
if x(3,:)
    g3 = (meanx(3)-sz/2):gridstep:(meanx(3)+sz/2);
else
    g3 = 0;
end
s3 = length(g3);
g1 = repmat(g1',1,s2*s3);
g2 = kron(g2,ones(s3,s1));
g3 = kron(ones(s1,s2),g3);
g1 = g1(:)';
g2 = g2(:)';
g3 = g3(:)';
g = flowCpp(s,[g1;g2;g3]);
g1 = reshape(g(1,:),s1,s2*s3);
g2 = reshape(g(2,:),s1,s2*s3);
g3 = reshape(g(3,:),s1,s2*s3);
h = [];
if s1 > 1
    h = [h;plot3(g1,g2,g3,'k')];
end
g1 = g1';
g1 = reshape(g1,s3,s1*s2);
g2 = g2';
g2 = reshape(g2,s3,s1*s2);
g3 = g3';
g3 = reshape(g3,s3,s1*s2);
if s3 > 1
    h = [h;plot3(g1,g2,g3,'k')];
end
g1 = g1';
g1 = reshape(g1,s2,s1*s3);
g2 = g2';
g2 = reshape(g2,s2,s1*s3);
g3 = g3';
g3 = reshape(g3,s2,s1*s3);
if s2 > 1
    h = [h;plot3(g1,g2,g3,'k')];
end
set(h,'Color',.6*[1,1,1]);

