function Divided_image_new = Divided_image_judge(I,m,n,b)
%函数用来判断I矩阵是否可以被m*n整数划分，如果不能，则把矩阵边界扩充，扩充部分用0填充
%I表示输入矩阵；m*n表示分块大小
[line,row,c] = size(I);
rem_m = rem(line,m);
rem_n = rem(row,n);
rem_c = rem(b,c);
if rem_m == 0 && rem_n == 0 && rem_c
   Divided_image_new = I;
else
    if rem_m > 0
       line_new =line + m - rem_m;
    end
    if rem_n > 0
       row_new = row + n - rem_n;
    end
   Divided_image_new = zeros(line_new,row_new,b);
   Divided_image_new(1:line,1:row,:) = I;
end
end