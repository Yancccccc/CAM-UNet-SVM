function [output] = nozeroPlus1(input)
%UNTITLED3 此处提供此函数的摘要
%   此处提供详细说明
[m3,n3] = size(input);
output = zeros(m3,n3);
for i =1:m3
    for j = 1:n3
        if input(i,j) ~=0
           output(i,j) = input(i,j)+1;
        end
    end
end
end