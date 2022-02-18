function [out1,out2] = nozero(label,pred)
%UNTITLED7 去零
%   此处提供详细说明
[m1,n1] = size(label);

t1 = 1;
for i = 1:m1
    for j = 1:n1
        if  label(i,j) ~= 0
            out1(t1,j) = label(i,j);
            out2(t1,j) = pred(i,j);
            t1 = t1 +1;
        end
    end
end

end