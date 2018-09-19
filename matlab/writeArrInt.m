function writeArrInt(A,f)

fprintf(f,'%d \n',length(size(A)));
fprintf(f,'%d ',size(A));
fprintf(f,'\n');
fprintf(f,'%d ',int32(A));
fprintf(f,'\n');