function I = blobimage(N,sigma,center)

if nargin < 3
    center = [.5;.5;.5];
end
if nargin < 2
    sigma = .5;
end
if nargin < 1
    N = [10,10,10];
end
if length(N)==1
    N = N*ones(1,3);
end

N = N(:)';

sigma2 = sigma^2;
I = zeros(N);

for i = 1:N(1)
    for j = 1:N(2)
        for k = 1:N(3)
            I(i,j,k) = exp((-(i/N(1)-center(1))^2-(j/N(2)-center(2))^2-(k/N(3)-center(3))^2)/sigma2);
        end
    end
end



h1 = linspace(0,1,N(1));
h2 = linspace(0,1,N(2));
h3 = linspace(0,1,N(3));
[hx,hy,hz] = ndgrid(h1,h2,h3);
