function [outputArg1] = DimensionReduction2D(input)
%%降维
[m,n] = size(input);
outputArg1 =zeros(m*n,1);
for i = 1:m
    for j = 1:n
        outputArg1((i-1)*n+j,1) = input(i,j);
    end
end

end
