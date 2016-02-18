function [master_map] = Saliency(Img)
% generate saliency map
if (size(Img,1) < 128)
    Img = imresize(Img, 128/size(Img,1));
end
if (size(Img,2) < 128)
    Img = imresize(Img, 128/size(Img,2));
end
map = gbvs(Img); 
master_map = map.master_map_resized;    
master_map = double(master_map);
master_map = 255*master_map;
master_map = uint8(master_map);
end % end function
