
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% demo / tutoriel pour le programme de matching %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% pour toute question, mon email est : joan_glaunes@yahoo.fr

% Dans cet exemple on va apparier deux ensembles compos�s de quatre paires
% source/cible de types surfaces, courbes, nuages de points et landmarks

% 1/ Dans une premi�re variable "s", on rentre tout ce qui concerne la
% partie d�formations.

% s.x doit �tre un tableau de taille 3*n contenant les coordonn�es 3D de tous les
% points source. Ici la surface source est form�e
% de deux triangles (4 sommets), la courbe source de quatre points,
% le nuage source comporte 2 points et il y a 2 landmarks source, donc n=12

setenv('LD_LIBRARY_PATH','')

clear s
s.x = [0,1,1,0,1.5,1.6,1.8,2, 3,3.2,3.8, 4;
       0,0,1,1, 0 , 0 , 0 ,0, 0, 0 , 0 , 0 ;
       0,0,0,0, 0 , 0 , 0 ,0, 0, 0 , 0 , 0];
   
% s.sigmaV est l'�chelle de d�formation, intervenant dans le calcul du noyau. Il
% faut fixer une valeur correspondant � l'ordre de grandeur des coordonn�es des
% points. Par exemple, si ces coordonn�es vont de 0 � 250, et que les courbes �
% apparier ne sont pas trop isol�es dans une r�gion de l'espace, sigmaV = 20 est
% un bon choix. Ici les coordonn�es sont de l'ordre de l'unit�, on va
% choisir sigmaV = 0.5
s.sigmaV = .5;

% Autres param�tres importants (voir aussi le fichier match.m)

s.rigidmatching = 0; % mettre = 1 pour effectuer un recalage rigide pr�alable

s.gammaR = 0;        % poids du terme de r�gularit� dans la fonctionnelle
% Avec gammaR = 0, on minimise uniquement le terme d'attache aux donn�es,
% mais la d�formation reste quand m�me r�guli�re du fait de l'espace dans
% lequel s'effectue la minimisation

s.numbminims = 1; % signifie que l'on effectue une seule minimisation. Pour am�liorer
% le matching, on peut fixer par exemple numbminims=3 et l'algo effectue
% alors plusieurs minimisations en diminuant � chaque fois la taille des
% noyaux d'appariement sigmaW, sigmaI (cf plus bas)

s.usefgt = 0; % =1 signifie que l'on utilise la Fast Gauss Transform pour les convolutions 
% (efficace � partir de 50 points environ).




% 2/ Dans une deuxi�me variable "target", on met tous ce qui concerne les
% cibles et les m�thodes d'appariement utilis�es

clear target

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Premi�re cible de type surface
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

target{1}.method = 'surfcurr';

% indices des triangles de la surface SOURCE dans target{1}.vx
% Ces indices font r�f�rence � des colonnes de s.x
target{1}.vx = [1,1;
                2,3;
                3,4];
% coordonn�es des sommets de la surface CIBLE dans target{1}.y
target{1}.y = [.5,1,0
                0,1,.5
               .5,1,.5];
% indices des triangles de la surface CIBLE dans target{1}.vy            
target{1}.vy = [1;
                2;
                3];
% �chelle du noyau d'appariement de surfaces. Plus cette valeur est petite,
% plus l'appariement est pr�cis. Un bon choix est une valeur
% de l'ordre de la distance entre l'objet source et cible. Cependant si on
% effectue plusieurs minimisations successives (variable s.numbminims), on
% peut fixer une valeur petite car l'algorithme effectue les premi�res �tapes
% � des �chelles sup�rieures
target{1}.sigmaW = .5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Deuxi�me cible de type courbe
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
target{2}.weight = 0;
target{2}.method = 'curvecurr';

% indices des segments de la courbe SOURCE dans target{2}.vx
% Ces indices font r�f�rence � des colonnes de s.x
target{2}.vx = [5,6,7;
                6,7,8];
% coordonn�es des points de la courbe CIBLE dans target{2}.y
target{2}.y = [1.5, 2 ,2.5;
                0 , 0 ,0.5;
               0.5,0.5, 1 ];
% indices des segments de la courbe CIBLE dans target{2}.vy            
target{2}.vy = [1,2;
                2,3];
% �chelle du noyau d'appariement de courbes
target{2}.sigmaW = .5;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Troisi�me cible de type nuage de points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

target{3}.method = 'measures';

% indices des points SOURCE dans target{3}.vx
% Ces indices font r�f�rence � des colonnes de s.x
target{3}.vx = [9,10];
% coordonn�es des points CIBLE dans target{3}.y
target{3}.y = [3 , 3.2,3.4;
              0.5, 0.7,0.5;
               0.5,0.5,0.5];
% �chelle du noyau d'appariement de nuages de points
target{3}.sigmaI = 2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Quatri�me cible de type landmarks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

target{4}.method = 'landmarks';

% indices des points SOURCE dans target{4}.vx
% Ces indices font r�f�rence � des colonnes de s.x
target{4}.vx = [11,12];
% coordonn�es des points CIBLE dans target{3}.y
target{4}.y = [ 4 , 4;
               0.5,0.5;
               0.5,0.8];


           
% On lance le programme:
s = matchCpp(s,target);

% La structure retourn�e "s" contient entre autres les variables "X" 
% (trajectoires de points template) et "mom" (vecteurs moments)
% qui param�trent la d�formation optimale. Aussi "distIdPhi" donne le co�t
% de d�formation obtenu (racine carr�e de l'�nergie)
disp(['co�t de d�formation D = D(id,phi) = ',num2str(s.distIdPhi)])
disp(' ')

% affichage du r�sultat
s.show = {'phi','y','xrig','x'};
s.showtraj = 1;    % affiche les trajectoires des points template (en bleu)
s.showmomtraj = 0; % affiche les vecteurs moments (fl�ches vertes)
s.showpoints = 1;
s.showlegend = 0;
clf
affiche(s);
view(-20,20)
zoom(1.7)

% Le programme flow.m permet ensuite de calculer l'image d'un ensemble de
% points 3D par la d�formation optimale

disp('L''image des points')
V = rand(3,4)
disp('par la transformation est')
phiV = flowCpp(s,V)


