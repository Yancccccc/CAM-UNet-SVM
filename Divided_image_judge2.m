function Divided_image_new2 = Divided_image_judge2(I,m,n)
%函数用来判断I矩阵是否可以被m*n整数划分，如果不能，则把矩阵边界扩充，扩充部分用0填充
%I表示输入矩阵；m*n表示分块大小
[line,row] = size(I);
rem_m = rem(line,m);
rem_n = rem(row,n);
if rem_m == 0 && rem_n == 0
   Divided_image_new2 = I;
else
    if rem_m > 0
       line_new =line + m - rem_m;
    end
    if rem_n > 0
       row_new = row + n - rem_n;
    end
   Divided_image_new2 = zeros(line_new,row_new);
   Divided_image_new2(1:line,1:row,:) = I;
end
end