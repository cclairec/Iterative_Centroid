function s = shootingCpp(s)

% geodesic shooting for point matching

global pathtobins
pathtobins = '/Users/clairec/Codes/Code2/catchine/trunk/bin/Darwin-14.3.0_DIM3_Release/';
%global pathtobins
% [~,tmp]=unix('hostname');
% if strfind(tmp,'lena56')
%     pathtobins = '/lena16/dartagnan2/cury/Code2/catchine/trunk/bin/Linux-2.6.18-194.11.1.el5_CUDA_DIM3_Release/'; % lena56
% else
%     pathtobins = '/lena16/dartagnan2/cury/Code2/catchine/trunk/bin/Linux-2.6.18-194.32.1.el5_DIM3_Release/';
% end

FileTemp = 'temp.mch';
FileResults = 'resmatch.mch';

f = fopen(FileTemp,'w');
fprintf(f,'Evol\n'); 
writeLargeDef(s,f);

fclose(f);

eval(['!rm ',FileResults])
command = ['!',pathtobins,'shooting double ',FileTemp,' ',FileResults];
eval(command)

s = readResult(FileResults);
