function [output] = DimensionImprove(data,reference)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明
[m,n,r] = size(reference);
output=zeros(m,n);
for i = 1:m
    for j = 1:n
        output(i,j) = data((i-1)*n+j,1);
    end
end

end