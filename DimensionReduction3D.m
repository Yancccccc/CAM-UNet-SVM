function [outputArg1] = DimensionReduction3D(input)
%%三维降二维
[m,n,r] = size(input);
 outputArg1=zeros(m*n,r);

for i = 1:m
    for j = 1:n
        for k = 1:r
            outputArg1((i-1)*n+j,k) = input(i,j,k);
        end
    end
end

end