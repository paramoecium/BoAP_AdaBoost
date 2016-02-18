function [Img_lbp] = lbp(Img)
% input: Img: colored Img or gray image
% output: 0:255 
% gnereate 2^8 = 64 bin image
Height = size(Img,1);
Width = size(Img,2);
if length(size(Img)) == 3
    % color image
    Img_g = rgb2gray(Img);
else
    % gray image
    Img_g = Img;
end
Img_lbp = zeros(Height,Width);
temp_arr = zeros(1,8);
temp_value = 0;
for i = 2:Height-1
    for j = 2:Width-1
        temp_value = 0;
        temp_arr(1) = Img_g(i  ,j+1)-Img_g(i,j);
        temp_arr(2) = Img_g(i-1,j+1)-Img_g(i,j);
        temp_arr(3) = Img_g(i-1,j  )-Img_g(i,j);
        temp_arr(4) = Img_g(i-1,j-1)-Img_g(i,j);
        temp_arr(5) = Img_g(i-1,j  )-Img_g(i,j);
        temp_arr(6) = Img_g(i+1,j-1)-Img_g(i,j);
        temp_arr(7) = Img_g(i+1,j  )-Img_g(i,j);
        temp_arr(8) = Img_g(i+1,j+1)-Img_g(i,j);
        temp_arr2(find(temp_arr > 0)) = 1;
        temp_arr2(find(temp_arr <= 0)) = 0;
        for k = 1:8
            temp_value = temp_value + temp_arr2(k)*(2^(k-1));
        end
        Img_lbp(i,j) = temp_value;
    end
end
for i = 1:Height
    Img_lbp(i,1) = Img_lbp(i,2);
    Img_lbp(i,Width) = Img_lbp(i,Width-1);
end
for j = 1:Width
    Img_lbp(1,j) = Img_lbp(2,j);
    Img_lbp(Height,j) = Img_lbp(Height-1,j);
end
Img_lbp = uint8(Img_lbp);
end % end function