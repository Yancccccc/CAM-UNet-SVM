function [features] = actions_DevideImgae(net,x,layer)
%分割图片提特征
[m1,n1,r1] = size(x);
Divided_image = Divide_into_block(x,256,256,r1);
[m2,n2] = size(Divided_image);
X3 = zeros(256,256,r1);

for i = 1:m2
    for j = 1:n2
         X3(:,:,:)= Divided_image{i,j};
        features_xingbin_layer(256*(i-1)+1:256*i,256*(j-1)+1:256*j,:) = activations(net,X3,layer);
    end
end

[m3,n3,r3] = size(features_xingbin_layer);
features = zeros(m3*n3,r3);
for i = 1:m3
    for j = 1:n3
        for k = 1:r3
           features((i-1)*n3+j,k) = features_xingbin_layer(i,j,k);
        end
    end
end

end