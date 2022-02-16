function Divided_image2 = Divide_into_block2(I,m,n)
%把二维图像矩阵I分割成m*n的矩阵块，当边界区域不足m*n时，用0填充
Divided_image_new2 = Divided_image_judge2(I,m,n);
[line,row] = size(Divided_image_new2);
Divided_image2 = mat2cell(Divided_image_new2,ones(line/m,1)*m,ones(row/n,1)*n);
end
