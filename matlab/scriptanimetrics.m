
% Matching of two face surfaces using large deformations, surface currents method, and Gpu acceleration

%path('/home1/glaunes/currmatch',path) % au laga
%path('/cis/home/joan/currmatch/',path) % au cis

dataloc = '../dataTest/';
template  = '03530c19';
%targets = {'03685c16','train_03771_4','train_03776_4','03671c16','03712c21','train_03772_4','03682c16','train_03767_4','train_03773_4'};  
targets = {'train_03772_4'};  

subnbproc = 5000;
%decimbyu([dataloc,template],subnbproc,'check');
byuS = [dataloc,template,'sub',num2str(subnbproc),'.byu'];

subnbflow = 5000;
%decimbyu([dataloc,template],subnbflow,'check');

for k = 1:length(targets)
    tgt = targets{k};
    %decimbyu([dataloc,target],subnbproc,'check');
    byuT = [dataloc,tgt,'sub',num2str(subnbproc),'.byu'];
    clear s target
    [s.x,target{1}.vx] = readbyu(byuS);
    [target{1}.y,target{1}.vy] = readbyu(byuT);
    
    s.T = 10;
    s.sigmaV = linspace(0.1494,0.0050,s.T);
    s.typefloat = 'float';
    s.useDef = 'LargeDef';       
    target{1}.method = 'surfcurr';
    target{1}.sigmaW = 0.0500/2;
    s.gammaR = 1.0000e-006;
    s.optim_stepsize = 1;
    

    s.CppKer.Type = 'CauchyGpu';
    target{1}.CppKer.Type = 'CauchyGpu';
    
    s.optim_maxiter = 200;
    s.useoptim = 'adaptdesc';
    s.optim_verbosemode = 0;
    s.printname = [template,'_',tgt,'_sub',num2str(subnbproc)];
    
    s = matchCpp(s,target);

    %s.xtranslate = [-2;0;0];
    %s.ytranslate = [2;0;0];
    s.transparent = .5;
    s.templatebyu = [dataloc,template,'sub',num2str(subnbflow),'.byu'];
    %decimbyu([dataloc,target],subnbflow,'check');
    s.targetbyu = [dataloc,tgt,'sub',num2str(subnbflow),'.byu'];
    s.printname = 'face';
    s.transmatrix = eye(3);
    s.transvector = [0;0;0];
    %save([s.printname,'.mat'],'s');
    s.useproxmap = 0;
    makewrl([s.printname,'.wrl'],s);
       
    clf
    s.show = {'x','y','phi'};
    s.showpoints = 0;    s.showtitle = 0;
    s.showlegend = 0;
    s.transparent = 0;
    h = affiche(s);
    title([template,' -> ',tgt])
%    print('-djpeg',[s.printname,'.jpg'])
end


