function [out] = Devide_label(label,features)
%UNTITLED3 分割标签
%   此处提供详细说明
[m3,n3] = size(features);

Divided_image2 = Divide_into_block2(label,256,256);
[m2,n2] = size(Divided_image2);
data1 = zeros(256,256);

for i = 1:m2
    for j = 1:n2
         data1(:,:)= Divided_image2{i,j};
         out(256*(i-1)+1:256*i,256*(j-1)+1:256*j) = data1(:,:);
    end
end

end