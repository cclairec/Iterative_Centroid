function P = allflowCpp(s,p)

 global pathtobins
% [~,tmp]=unix('hostname');
% if strfind(tmp,'lena56')
%     pathtobins = '/lena13/home_users/users/cury/Desktop/code/catchine/trunk/bin/Linux-2.6.18-194.11.1.el5_CUDA_DIM3_Release/'; % lena56
% else
%     pathtobins = '/lena13/home_users/users/cury/Desktop/code/catchine/trunk/bin/Linux-2.6.18-194.32.1.el5_DIM3_Release/';
% end

allflowfloatcmd = [pathtobins,'allflow -f float'];
allflowdoublecmd = [pathtobins,'allflow -f double'];

FileTemp1 = 'temp1.mch';
FileTemp2 = 'temp2.mch';
FileTemp3 = 'temp3.mch';

f = fopen(FileTemp1,'w');
fprintf(f,'Evol\n');
switch s.useDef
    case 'LargeDef'
        writeLargeDef(s,f);
    case 'SmallDef'
        writeSmallDef(s,f);
end
fclose(f);

f = fopen(FileTemp2,'w');
writeArr(p,f);
fclose(f);

switch s.typefloat
    case 'float'
        allflowcmd = allflowfloatcmd;
    case 'double'
        allflowcmd = allflowdoublecmd;
end

eval(['!',allflowcmd,' -m ',FileTemp1,' -d ',FileTemp2,' -o ',FileTemp3])

f = fopen(FileTemp3,'r');
P = readArr(f);
fclose(f);