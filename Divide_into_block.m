function Divided_image = Divide_into_block(I,m,n,b)
%把二维图像矩阵I分割成m*n的矩阵块，当边界区域不足m*n*b时，用0填充
Divided_image_new = Divided_image_judge(I,m,n,b);
[line,row,c] = size(Divided_image_new);
Divided_image = mat2cell(Divided_image_new,ones(line/m,1)*m,ones(row/n,1)*n,b);
end
