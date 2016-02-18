function [ex2, ey2, e2, angles2] = edge_map(Img)
% input: Img: colored Img
% output: ex2, ey2, e2, angles2
    g_Img = rgb2gray(Img);
    % generage edge map
    g_Img = double(g_Img);
    ex = conv2(g_Img,[1,-1]);
    ex = ex(1:size(ex,1), 2:size(ex,2));
    ex(:,size(ex,2)) = ex(:,size(ex,2)-1);
    ey = conv2(g_Img,[-1;1]);
    ey = ey(2:size(ey,1), 1:size(ey,2));
    ey(size(ey,1),:) = ey(size(ey,1)-1,:);
    e = abs(ex)+abs(ey);
    
    ex_max = max(max(ex));
    ex_min = min(min(ex));
    ey_max = max(max(ey));
    ey_min = min(min(ey));
    ex2 = 255*(ex-ex_min)/(ex_max-ex_min);
    ey2 = 255*(ey-ey_min)/(ey_max-ey_min);
    ex2 = uint8(ex2);
    ey2 = uint8(ey2);
    emax = max(max(e));
    emin = min(min(e));
    e = 255*(e-emin)/(emax-emin);
    e2 = uint8(e);
    angles=atan2(ey,ex);
    max_ang = max(max(angles));
    min_ang = min(min(angles));
    angles2 = (angles-min_ang)/(max_ang-min_ang);
    angles2 = 255*angles2;
    angles2 = uint8(angles2);
end % end function