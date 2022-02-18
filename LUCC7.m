function [out] = LUCC7(data1,data2)
%UNTITLED3 此处提供此函数的摘要LUcc
%   此处提供详细说明
[m1,n1] = size(data1);
for i = 1:m1
    for j = 1:n1
         if  data1(i,j) == 2 && data2(i,j) == 3 
            out(i,j) = 9; %2变3
         elseif data1(i,j) == 2 && data2(i,j) == 4            out(i,j) = 10;  %%
         elseif data1(i,j) == 2 && data2(i,j) ==5 
            out(i,j) = 11;  %
         elseif data1(i,j) == 2 && data2(i,j) ==6 
            out(i,j) = 12;  %
         elseif data1(i,j) == 2 && data2(i,j) ==7 
            out(i,j) = 13;  %
         elseif data1(i,j) == 2 && data2(i,j) ==8 
            out(i,j) = 14; 
         elseif data1(i,j) == 3 && data2(i,j) ==2 %%3
            out(i,j) = 15; 
         elseif data1(i,j) == 3 && data2(i,j) == 4 
            out(i,j) = 16;  %
         elseif data1(i,j) == 3 && data2(i,j) ==5 
            out(i,j) = 17;  %2变5
         elseif data1(i,j) == 3 && data2(i,j) ==6 
            out(i,j) = 18;  %2变6
         elseif data1(i,j) == 3 && data2(i,j) ==7 
            out(i,j) = 19;  %2变6
         elseif data1(i,j) == 3 && data2(i,j) ==8 
            out(i,j) = 20; 
         elseif data1(i,j) == 4 && data2(i,j) ==2%4
            out(i,j) = 21; 
         elseif data1(i,j) == 4 && data2(i,j) ==3 %4
            out(i,j) = 22;
         elseif data1(i,j) == 4 && data2(i,j) ==5%4
            out(i,j) = 23; 
         elseif data1(i,j) == 4 && data2(i,j) ==6%4
            out(i,j) = 24;
         elseif data1(i,j) == 4 && data2(i,j) ==7%4
            out(i,j) = 25; 
         elseif data1(i,j) == 4 && data2(i,j) ==8 %4
            out(i,j) = 26;
         elseif data1(i,j) == 5 && data2(i,j) ==2%4
            out(i,j) = 27; 
         elseif data1(i,j) == 5 && data2(i,j) ==3 %4
            out(i,j) = 28;
         elseif data1(i,j) == 5 && data2(i,j) ==4 %4
            out(i,j) = 29;
         elseif data1(i,j) == 5 && data2(i,j) == 6 
            out(i,j) = 30;  %%
         elseif data1(i,j) == 5 && data2(i,j) ==7 
            out(i,j) = 31;  %
         elseif data1(i,j) == 5 && data2(i,j) ==8 
            out(i,j) = 32;  %
         elseif data1(i,j) == 6 && data2(i,j) ==2 
            out(i,j) = 33;  %
         elseif data1(i,j) == 6 && data2(i,j) ==3 
            out(i,j) = 34; 
         elseif data1(i,j) == 6 && data2(i,j) ==4 %%3
            out(i,j) = 35; 
         elseif data1(i,j) == 6 && data2(i,j) == 5 
            out(i,j) = 36;  %
         elseif data1(i,j) == 6 && data2(i,j) ==7 
            out(i,j) = 37;  %2变5
         elseif data1(i,j) == 6 && data2(i,j) ==8 
            out(i,j) = 38;  %2变6
         elseif data1(i,j) == 7 && data2(i,j) ==2 
            out(i,j) = 39;  %2变6
         elseif data1(i,j) == 7 && data2(i,j) ==3 
            out(i,j) = 40; 
         elseif data1(i,j) == 7 && data2(i,j) ==4%4
            out(i,j) = 41; 
         elseif data1(i,j) == 7 && data2(i,j) ==5 %4
            out(i,j) = 42;
         elseif data1(i,j) == 7 && data2(i,j) ==6%4
            out(i,j) = 43; 
         elseif data1(i,j) == 7 && data2(i,j) ==8%4
            out(i,j) = 44;
         elseif data1(i,j) == 8 && data2(i,j) ==2%4
            out(i,j) = 45; 
         elseif data1(i,j) == 8 && data2(i,j) ==3 %4
            out(i,j) = 46;
         elseif data1(i,j) == 8 && data2(i,j) ==4%4
            out(i,j) = 47; 
         elseif data1(i,j) == 8 && data2(i,j) ==5 %4
            out(i,j) = 48;
         elseif data1(i,j) == 8 && data2(i,j) ==6 %4
            out(i,j) = 49;
         elseif data1(i,j) == 8 && data2(i,j) ==7 %4
            out(i,j) = 50;
         else 
             out(i,j) = 0;
        end
    end
end
end