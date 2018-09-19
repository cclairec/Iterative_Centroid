function [X,Y,Z] = plotgrid(X,Y,Z)

hold on
for i = 1:3
    X = shiftdim(X,1);
    Y = shiftdim(Y,1);
    Z = shiftdim(Z,1);
    for i=1:size(X,3)
        plot3(X(:,:,i),Y(:,:,i),Z(:,:,i),'b')
    end
end
