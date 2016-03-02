function bounding_boxes = auto_crop(bigImg, model)
% from Automatic_view_finding.m
% input : bigImg to be cropped, model of Adaboost
% output: bounding boxes of each aspect ratio
% function to find the optimal composition
img_height = size(bigImg,1);
img_width =  size(bigImg,2);

ratio=[[12,8]; [12,9]; [16,9]; [8,8]; [9,16]; [9,12]; [8,12]]; %[width,height]

%step_size = 50;
step_size = 200;
%multiplier = 40; %%[width,height] = ratio(i,:)*multiplier
multiplier = 40;
hor_step = step_size;
ver_step = step_size;
bounding_boxes = zeros(size(ratio,1),5);
for r = 1:size(ratio,1)
    r
    view_width  = ratio(r,1)*multiplier;  %%%% set crop size
    view_height = ratio(r,2)*multiplier;  %%%% set crop size
    assert(view_height<size(bigImg,1) && view_width<size(bigImg,2),'The window size is larger than the image size.')
    rest_height = img_height - view_height;
    rest_width  = img_width  - view_width;
    % exclusive of the end border point
    ver_scan_num = 1+floor(rest_height/ver_step);
    hor_scan_num = 1+floor(rest_width/hor_step);
    % find max resize ratio
    for i = 1:10
        max_resize_ratio = i-1;
        reImg = imresize(bigImg, 0.9^i);
        if ( size(reImg,1) <= view_height ) || ( size(reImg,2) <= view_width )
            break;
        end
    end
    clear reImg;


    confidence_map = zeros(ver_scan_num,hor_scan_num,max_resize_ratio+1);
    class_map = zeros(ver_scan_num,hor_scan_num,max_resize_ratio+1);
    %%Img_candidate = cell(ver_scan_num,hor_scan_num,max_resize_ratio+1);
    max_resize_ratio
    assert(max_resize_ratio>=0,'max_resize_ratio is smaller than 0')
    for k = 1:max_resize_ratio+1
        % for each scale, generate a confidence map
        % resize the test image
        testImg = imresize(bigImg,0.9^(k-1));
        img_height = size(testImg,1);
        img_width =  size(testImg,2);
        rest_height = img_height - view_height;
        rest_width  = img_width  - view_width;
        ver_step_now = floor(ver_step*(0.9^(k-1)));
        hor_step_now = floor(hor_step*(0.9^(k-1)));
        ver_scan_num_now = 1+floor(rest_height/ver_step_now);
        hor_scan_num_now = 1+floor(rest_width/hor_step_now);
        for i = 1:ver_scan_num_now
            for j = 1:hor_scan_num_now
                disp([k,i,j])
                % ----- go through all candidates ----- 
                if i == ver_scan_num_now && j == hor_scan_num_now
                    up_coordi = size(testImg,1)-view_height+1;
                    dn_coordi = size(testImg,1);
                    lt_coordi = size(testImg,2)-view_width+1;
                    rt_coordi = size(testImg,2);
                else 
                    up_coordi = 1+(i-1)*ver_step_now;
                    dn_coordi = (i-1)*ver_step_now+view_height;
                    lt_coordi = 1+(j-1)*hor_step_now;
                    rt_coordi = (j-1)*hor_step_now+view_width;
                end
                
                test_window = testImg(up_coordi:dn_coordi,lt_coordi:rt_coordi,:);
                %%Img_candidate{i,j,k} = test_window;
                % -----    bag of feature extraction    ----- 
                %if i == 1 && j == 1 && k == 1
                %   imshow(test_window)
                %end
                testdata = feature_extraction(test_window);
                [testclass,m,confidence]=adaboost('apply',testdata,model);
                confidence_map(i,j,k) = confidence; 
                class_map(i,j,k) = testclass; 
            end % end j
        end % end i
    end % end scale


    % show the image of highest confidence 
    % find the index i,j,k of max
    [max_Y max_I] = max(confidence_map(:));
    max_k = 1+floor((max_I-1)/(ver_scan_num*hor_scan_num));
    max_I = max_I - (max_k-1)*(ver_scan_num*hor_scan_num);
    max_j = 1+floor((max_I-1)/ver_scan_num);
    max_i = max_I - (max_j-1)*(ver_scan_num);
    ver_step_now = floor(ver_step*(0.9^(max_k-1)));
    hor_step_now = floor(hor_step*(0.9^(max_k-1)));
    up_coordi = 1+(max_i-1)*ver_step_now;
    dn_coordi = (max_i-1)*ver_step_now+view_height;
    lt_coordi = 1+(max_j-1)*hor_step_now;
    rt_coordi = (max_j-1)*hor_step_now+view_width;
    
    bounding_boxes(r,:) = [max_Y, up_coordi, dn_coordi, lt_coordi, rt_coordi]
    %testImg = imresize(bigImg,0.9^(max_k-1));
    %max_con_img = testImg(up_coordi:dn_coordi,lt_coordi:rt_coordi,:);  %max_con_img = Img_candidate{max_i,max_j,max_k};
end
