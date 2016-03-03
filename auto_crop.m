function bounding_box = auto_crop(bigImg, model)
% from Automatic_view_finding.m
% input : bigImg to be cropped, model of Adaboost
% output: bounding boxes of each aspect ratio
% function to find the optimal composition
img_height = size(bigImg,1);
img_width =  size(bigImg,2);

hor_step = floor(0.05*img_width);
ver_step = floor(0.05*img_width);
scales = [0.5, 0.6, 0.7, 0.8, 0.9];

min_view_height = scales(1)*img_height;  %%%% set crop size
min_view_width  = scales(1)*img_width;  %%%% set crop size

max_ver_scan_num = 1+floor((img_height-min_view_height)/ver_step);
max_hor_scan_num = 1+floor((img_width-min_view_width)/hor_step);
confidence_map = zeros(max_ver_scan_num, max_hor_scan_num, size(scales,2));
class_map = zeros(max_ver_scan_num, max_hor_scan_num, size(scales,2));

for k = 1:size(scales,2)
    % for each scale, generate a confidence map
    view_height = floor(scales(k)*img_height);
    view_width = floor(scales(k)*img_width);
    ver_scan_num_now = 1+floor((img_height-view_height)/ver_step);
    hor_scan_num_now = 1+floor((img_width- view_width)/hor_step);
    for i = 1:ver_scan_num_now
        for j = 1:hor_scan_num_now
            disp([k,i,j])
            % ----- go through all candidates -----
            up_coordi = 1+(i-1)*ver_step;
            dn_coordi = (i-1)*ver_step+view_height;
            lt_coordi = 1+(j-1)*hor_step;
            rt_coordi = (j-1)*hor_step+view_width;
            [up_coordi,dn_coordi,lt_coordi,rt_coordi]
            crop_window = bigImg(up_coordi:dn_coordi,lt_coordi:rt_coordi,:);
            testdata = feature_extraction(crop_window);
            [testclass,m,confidence]=adaboost('apply',testdata,model);
            confidence_map(i,j,k) = confidence; 
            class_map(i,j,k) = testclass; 
        end % end j
    end % end i
end % end scale

% find the index i,j,k of max
[max_confidence max_I] = max(confidence_map(:));
max_k = 1+floor((max_I-1)/(max_ver_scan_num*max_hor_scan_num));
max_I = max_I - (max_k-1)*(max_ver_scan_num*max_hor_scan_num);
max_j = 1+floor((max_I-1)/max_ver_scan_num);
max_i = max_I - (max_j-1)*(max_ver_scan_num);
view_height = max_k*img_height;
view_width = max_k*img_width;
up_coordi = 1+(max_i-1)*ver_step;
dn_coordi = (max_i-1)*ver_step+view_height;
lt_coordi = 1+(max_j-1)*hor_step;
rt_coordi = (max_j-1)*hor_step+view_width;
max_confidence
bounding_box = [up_coordi, dn_coordi, lt_coordi, rt_coordi];
%max_con_img = testImg(up_coordi:dn_coordi,lt_coordi:rt_coordi,:);  %max_con_img = Img_candidate{max_i,max_j,max_k};
