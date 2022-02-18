function [output] = vote_3d(Y1T_1,Y2T_1,Y3T_1)
%UNTITLED8 3个输入，多数投票
%   此处提供详细说明
[m1,n1] = size(Y1T_1);
output = zeros(m1,n1);
for i = 1:m1
    for j = 1:n1
        if (Y1T_1(i,1) == Y2T_1(i,1))&&(Y1T_1(i,1)==Y3T_1(i,1)) &&(Y2T_1(i,1)== Y3T_1(i,1))
           output(i,1) = Y1T_1(i,1);
        elseif (Y1T_1(i,1) == Y2T_1(i,1))&&(Y1T_1(i,1)~=Y3T_1(i,1)) &&(Y2T_1(i,1)~= Y3T_1(i,1))
           output(i,1) = Y1T_1(i,1);
        elseif  (Y1T_1(i,1) ~= Y2T_1(i,1))&&(Y1T_1(i,1)==Y3T_1(i,1)) &&(Y2T_1(i,1)~= Y3T_1(i,1))
           output(i,1) = Y1T_1(i,1);
        elseif  (Y1T_1(i,1) ~= Y2T_1(i,1))&&(Y1T_1(i,1)~=Y3T_1(i,1)) &&(Y2T_1(i,1)== Y3T_1(i,1))
           output(i,1) = Y2T_1(i,1);
        else
           output(i,1) = 7;
        end
    end
end


end