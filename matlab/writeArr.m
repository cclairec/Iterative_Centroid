function writeArr(A,f)

fprintf(f,'%d \n',length(size(A)));
fprintf(f,'%d ',size(A));
fprintf(f,'\n');
fprintf(f,'%f ',A);
fprintf(f,'\n');

% function writeArr(A,f,groupes)
% 
% if nargin==2
%     groupes = ones(1,ndims(A));
% end
% 
% index = 1;
% for i = 1:length(groupes)
%     A = permute(A,index+groupe(i)-1:-1:index);
%     index = index + groupe(i);
% end
% 
% fprintf(f,'%d \n',length(size(A)));
% fprintf(f,'%d ',size(A));
% fprintf(f,'\n');
% fprintf(f,'%f ',A);
% fprintf(f,'\n');