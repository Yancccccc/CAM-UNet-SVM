function [outputArg1] = mask(inputArg1)
%UNTITLED5 
%   此处提供详细说明
[m1,n1] = size(inputArg1);
outputArg1= zeros(m1,n1);
for i = 1:m1
    for j = 1:n1
        if inputArg1(i,j) > 0
           outputArg1(i,j) = 1;
        else 
           outputArg1(i,j) = 0;
        end
    end
end
end