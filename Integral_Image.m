function [Img_add, Img_sqr] = Integral_Image(Img)
Height = size(Img,1);
Width = size(Img,2);
Img_add = zeros(Height,Width);
Img_sqr = zeros(Height,Width);
Img_add = double(Img_add);
Img_sqr = double(Img_sqr);
for i = 1:Height
    for j = 1:Width
        if j ~= 1
             Img_add(i,j) = double(Img(i,j))+Img_add(i,j-1);
             Img_sqr(i,j) = double(Img(i,j).^2)+Img_sqr(i,j-1);
         else
             Img_add(i,j) = double(Img(i,j));
             Img_sqr(i,j) = double(Img(i,j).^2);
         end
    end
end
for j = 1:Width
    for i = 1:Height
        if i ~= 1
             Img_add(i,j) = Img_add(i,j)+Img_add(i-1,j);
             Img_sqr(i,j) = Img_sqr(i,j)+Img_sqr(i-1,j);
         else
             Img_add(i,j) = Img_add(i,j);
             Img_sqr(i,j) = Img_sqr(i,j);
         end
    end
end

end % end function
