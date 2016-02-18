function [Img_fv] = feature_extraction_value(Img_add, Img_sqr, ori_x, ori_y, Img_height, Img_width)
% ImgMap is a map of feature values in specific feature space (0:255)
Img_fv = [];
%% step1. ========== image decomposition ==========   
% --------- finest-grained decomposition ----------
height_size = floor(Img_height/6);
width_size  = floor( Img_width/6);
add_66_arr = zeros(6,6);
sqr_66_arr = zeros(6,6);
pixel_num = height_size*width_size;
% (lp_x,lp_y) , (ln_x,ln_y) , (rp_x,rp_y) , (rn_x,rn_y)
for blk_i = 1:6
    for blk_j = 1:6
        lp_x = (blk_i-1)*height_size+1+(ori_x-1);
        rp_x = lp_x;
        ln_x = (blk_i)*height_size+(ori_x-1);
        rn_x = ln_x;
        lp_y = (blk_j-1)*width_size+1+(ori_y-1);
        ln_y = lp_y;
        rp_y = (blk_j)*width_size+(ori_y-1);
        rn_y = rp_y; 
        %sum1
        sum1_a = Img_add(rn_x,rn_y);
        sum1_r = Img_sqr(rn_x,rn_y);
        %sum2
        if lp_x == 1 || lp_y == 1
            sum2_a = 0;
            sum2_r = 0;
        else
            sum2_a = Img_add(lp_x-1,lp_y-1);
            sum2_r = Img_sqr(lp_x-1,lp_y-1);
        end
        %sum3
        if lp_x == 1
            sum3_a = 0;
            sum3_r = 0;
        else
            sum3_a = Img_add(rp_x-1,rp_y);
            sum3_r = Img_sqr(rp_x-1,rp_y);
        end
        %sum4
        if lp_y == 1
            sum4_a = 0;
            sum4_r = 0;
        else
            sum4_a = Img_add(ln_x,ln_y-1);
            sum4_r = Img_sqr(ln_x,ln_y-1);
        end
        add_66_arr(blk_i,blk_j) = double( (sum1_a+sum2_a-(sum3_a+sum4_a))/pixel_num );
        sqr_66_arr(blk_i,blk_j) = double( (sum1_r+sum2_r-(sum3_r+sum4_r))/pixel_num );
%         if lp_x == 1 && lp_y == 1
%             add_66_arr(blk_i,blk_j) = double((( Img_add(rn_x,rn_y) )-( Img_add(rp_x-1,rp_y)+Img_add(ln_x,ln_y-1) ))/pixel_num);
%             sqr_66_arr(blk_i,blk_j) = double((( Img_sqr(rn_x,rn_y) )-( Img_sqr(rp_x-1,rp_y)+Img_sqr(ln_x,ln_y-1) ))/pixel_num);
%         elseif lp_x == 1
%             add_66_arr(blk_i,blk_j) = double((( Img_add(rn_x,rn_y)+Img_add(lp_x-1,lp_y-1) )-( Img_add(rp_x-1,rp_y)+Img_add(ln_x,ln_y-1) ))/pixel_num);
%             sqr_66_arr(blk_i,blk_j) = double((( Img_sqr(rn_x,rn_y)+Img_sqr(lp_x-1,lp_y-1) )-( Img_sqr(rp_x-1,rp_y)+Img_sqr(ln_x,ln_y-1) ))/pixel_num);
%                                                 sum1               sum2                       sum3                 sum4                                 
%                                                                                              
%         elseif lp_y == 1
%         end
    end
end
%% step2. ===========   rules generation   ===========     
% ---------- 6*6 composition ----------
% type1: 1, 1-back(value), 1-back(abs)
% dimension: 6*36=216
for blk_i = 1:6
    for blk_j = 1:6
        p1_mean = add_66_arr(blk_i, blk_j);
        p1_vari = sqr_66_arr(blk_i, blk_j);
        p2_mean = (sum(add_66_arr(:)) - p1_mean)/35;
        p2_vari = (sum(sqr_66_arr(:)) - p1_vari)/35;
        p1_vari = p1_vari-(p1_mean)^2;
        p2_vari = p2_vari-(p2_mean)^2;
        p12_mean = p1_mean-p2_mean;
        p12_vari = p1_vari-p2_vari;
        ap12_mean = abs(p12_mean);
        ap12_vari = abs(p12_vari);
        Img_fv = [Img_fv p1_mean p1_vari p12_mean p12_vari ap12_mean ap12_vari];
    end
end

% ---------- 3*3 composition ----------
add_33_arr = zeros(3,3);
sqr_33_arr = zeros(3,3);
for blk_i = 1:3
    for blk_j = 1:3
        add_33_arr(blk_i,blk_j) = mean(mean( add_66_arr(blk_i*2-1:blk_i*2, blk_j*2-1:blk_j*2) ));
        sqr_33_arr(blk_i,blk_j) = mean(mean( sqr_66_arr(blk_i*2-1:blk_i*2, blk_j*2-1:blk_j*2) ));
    end
end
v_add_33_arr = add_33_arr(:);
v_sqr_33_arr = sqr_33_arr(:);

% type2: C9-1: 1, 1-back(value), 1-back(abs)
% dimension: (216)+6*25=366
for blk_i = 1:5
    for blk_j = 1:5
        p1_mean = add_66_arr(blk_i, blk_j)+add_66_arr(blk_i, blk_j+1)+add_66_arr(blk_i+1, blk_j)+add_66_arr(blk_i+1, blk_j+1);
        p1_vari = sqr_66_arr(blk_i, blk_j)+sqr_66_arr(blk_i, blk_j+1)+sqr_66_arr(blk_i+1, blk_j)+sqr_66_arr(blk_i+1, blk_j+1);
        p2_mean = (sum(add_66_arr(:)) - p1_mean)/32;
        p2_vari = (sum(sqr_66_arr(:)) - p1_vari)/32;
        p1_mean = p1_mean/4;
        p1_vari = p1_vari/4;
        p1_vari = p1_vari-(p1_mean)^2;
        p2_vari = p2_vari-(p2_mean)^2;
        p12_mean = p1_mean-p2_mean;
        p12_vari = p1_vari-p2_vari;
        ap12_mean = abs(p12_mean);
        ap12_vari = abs(p12_vari);
        Img_fv = [Img_fv p1_mean p1_vari p12_mean p12_vari ap12_mean ap12_vari];
    end
end
% type3: C9-2: 1-1(value), 1-1(abs)
% dimension: (366)+36*4 = 510
for i = 1:8
    for j = i+1:9        
        p1_mean = v_add_33_arr(i);
        p1_vari = v_sqr_33_arr(i);
        p2_mean = v_add_33_arr(j);
        p2_vari = v_sqr_33_arr(j);
        p1_vari = p1_vari-(p1_mean)^2;
        p2_vari = p2_vari-(p2_mean)^2;
        p12_mean = p1_mean-p2_mean;
        p12_vari = p1_vari-p2_vari;
        ap12_mean = abs(p12_mean);
        ap12_vari = abs(p12_vari);
        Img_fv = [Img_fv p12_mean p12_vari ap12_mean ap12_vari];
    end
end
% type4: C9-2: 2, 2-back(value), 2-back(abs)
% dimension: (510)+36*6 = 726
for i = 1:8
    for j = i+1:9        
        p1_mean = v_add_33_arr(i)+v_add_33_arr(j);
        p1_vari = v_sqr_33_arr(i)+v_sqr_33_arr(j);
        p2_mean = (sum(v_add_33_arr(:)) - p1_mean)/7;
        p2_vari = (sum(v_sqr_33_arr(:)) - p1_vari)/7;
        p1_mean = p1_mean/2;
        p1_vari = p1_vari/2;
        p1_vari = p1_vari-(p1_mean)^2;
        p2_vari = p2_vari-(p2_mean)^2;
        p12_mean = p1_mean-p2_mean;
        p12_vari = p1_vari-p2_vari;
        ap12_mean = abs(p12_mean);
        ap12_vari = abs(p12_vari);
        Img_fv = [Img_fv p1_mean p1_vari p12_mean p12_vari ap12_mean ap12_vari];
    end
end
% type5: C9-3: 2-1(value), 2-1(abs)
% dimension: (726)+84*4=1062
for i = 1:7
    for j = i+1:8    
        for k = j+1:9
            p1_mean = (v_add_33_arr(i)+v_add_33_arr(j))/2;
            p1_vari = (v_sqr_33_arr(i)+v_sqr_33_arr(j))/2;
            p2_mean = v_add_33_arr(k);
            p2_vari = v_sqr_33_arr(k);
            p1_vari = p1_vari-(p1_mean)^2;
            p2_vari = p2_vari-(p2_mean)^2;
            p12_mean = p1_mean-p2_mean;
            p12_vari = p1_vari-p2_vari;
            ap12_mean = abs(p12_mean);
            ap12_vari = abs(p12_vari);
            Img_fv = [Img_fv p12_mean p12_vari ap12_mean ap12_vari];
        end
    end
end
% type6: C9-3: 3, 3-back(value), 3-back(abs)
% dimension: (1062)+84*6=1566
for i = 1:7
    for j = i+1:8    
        for k = j+1:9
            p1_mean = v_add_33_arr(i)+v_add_33_arr(j)+v_add_33_arr(k);
            p1_vari = v_sqr_33_arr(i)+v_sqr_33_arr(j)+v_sqr_33_arr(k);
            p2_mean = (sum(v_add_33_arr(:)) - p1_mean)/6;
            p2_vari = (sum(v_sqr_33_arr(:)) - p1_vari)/6;
            p1_mean = p1_mean/3;
            p1_vari = p1_vari/3;
            p1_vari = p1_vari-(p1_mean)^2;
            p2_vari = p2_vari-(p2_mean)^2;
            p12_mean = p1_mean-p2_mean;
            p12_vari = p1_vari-p2_vari;
            ap12_mean = abs(p12_mean);
            ap12_vari = abs(p12_vari);
            Img_fv = [Img_fv p1_mean p1_vari p12_mean p12_vari ap12_mean ap12_vari];
        end
    end
end
% type7: C9-4: 2-2(value), 2-2(abs)
% dimension: (1566)+126*4 = 2070
for i = 1:6
    for j = i+1:7    
        for k = j+1:8
            for m = k+1:9
                p1_mean = (v_add_33_arr(i)+v_add_33_arr(j))/2;
                p1_vari = (v_sqr_33_arr(i)+v_sqr_33_arr(j))/2;
                p2_mean = (v_add_33_arr(m)+v_add_33_arr(k))/2;
                p2_vari = (v_sqr_33_arr(m)+v_sqr_33_arr(k))/2;
                p1_vari = p1_vari-(p1_mean)^2;
                p2_vari = p2_vari-(p2_mean)^2;
                p12_mean = p1_mean-p2_mean;
                p12_vari = p1_vari-p2_vari;
                ap12_mean = abs(p12_mean);
                ap12_vari = abs(p12_vari);
                Img_fv = [Img_fv p12_mean p12_vari ap12_mean ap12_vari];
            end
        end
    end
end
% type8: C9-4: 4, 4-back(value), 4-back(abs)
% dimension: (2070)+126*6 = 2826
for i = 1:6
    for j = i+1:7    
        for k = j+1:8
            for m = k+1:9
                p1_mean = v_add_33_arr(i)+v_add_33_arr(j)+v_add_33_arr(m)+v_add_33_arr(k);
                p1_vari = v_sqr_33_arr(i)+v_sqr_33_arr(j)+v_sqr_33_arr(m)+v_sqr_33_arr(k);
                p2_mean = (sum(v_add_33_arr(:)) - p1_mean)/5;
                p2_vari = (sum(v_add_33_arr(:)) - p1_vari)/5;
                p1_mean = p1_mean/4;
                p1_vari = p1_vari/4;
                p1_vari = p1_vari-(p1_mean)^2;
                p2_vari = p2_vari-(p2_mean)^2;
                p12_mean = p1_mean-p2_mean;
                p12_vari = p1_vari-p2_vari;
                ap12_mean = abs(p12_mean);
                ap12_vari = abs(p12_vari);
                Img_fv = [Img_fv p1_mean p1_vari p12_mean p12_vari ap12_mean ap12_vari];
            end
        end
    end
end
% ---------- 2*2 composition ----------
add_22_arr = zeros(2,2);
sqr_22_arr = zeros(2,2);
for blk_i = 1:2
    for blk_j = 1:2
        add_22_arr(blk_i,blk_j) = mean(mean( add_66_arr(blk_i*3-2:blk_i*3, blk_j*3-2:blk_j*3) ));
        sqr_22_arr(blk_i,blk_j) = mean(mean( sqr_66_arr(blk_i*3-2:blk_i*3, blk_j*3-2:blk_j*3) ));
    end
end
v_add_22_arr = add_22_arr(:);
v_sqr_22_arr = sqr_22_arr(:);
% type9: C4-1: 1, 1-back(value), 1-back(abs)
% dimension: (2826)+16*6=2922
for blk_i = 1:4
    for blk_j = 1:4
        p1_mean = sum(sum( add_66_arr(blk_i:blk_i+2, blk_j:blk_j+2) ));
        p1_vari = sum(sum( sqr_66_arr(blk_i:blk_i+2, blk_j:blk_j+2) ));
        p2_mean = (sum(add_66_arr(:)) - p1_mean)/27;
        p2_vari = (sum(sqr_66_arr(:)) - p1_vari)/27;
        p1_mean = p1_mean/9;
        p1_vari = p1_vari/9;
        p1_vari = p1_vari-(p1_mean)^2;
        p2_vari = p2_vari-(p2_mean)^2;
        p12_mean = p1_mean-p2_mean;
        p12_vari = p1_vari-p2_vari;
        ap12_mean = abs(p12_mean);
        ap12_vari = abs(p12_vari);
        Img_fv = [Img_fv p1_mean p1_vari p12_mean p12_vari ap12_mean ap12_vari];
    end
end
% type10: C4-2: 1-1(value), 1-1(abs)
% dimension: (2922)+6*4 = 2946
for i = 1:3
    for j = i+1:4       
        p1_mean = v_add_22_arr(i);
        p1_vari = v_sqr_22_arr(i);
        p2_mean = v_add_22_arr(j);
        p2_vari = v_sqr_22_arr(j);
        p1_vari = p1_vari-(p1_mean)^2;
        p2_vari = p2_vari-(p2_mean)^2;
        p12_mean = p1_mean-p2_mean;
        p12_vari = p1_vari-p2_vari;
        ap12_mean = abs(p12_mean);
        ap12_vari = abs(p12_vari);
        Img_fv = [Img_fv p12_mean p12_vari ap12_mean ap12_vari];
    end
end
% type11: C4-2: 2, 2-back(value), 2-back(abs)
% dimension: (2946)+6*6 = 2982
for i = 1:3
    for j = i+1:4       
        p1_mean = v_add_22_arr(i)+v_add_22_arr(j);
        p1_vari = v_sqr_22_arr(i)+v_sqr_22_arr(j);
        p2_mean = (sum(v_add_22_arr(:)) - p1_mean)/2;
        p2_vari = (sum(v_add_22_arr(:)) - p1_vari)/2;
        p1_mean = p1_mean/2;
        p1_vari = p1_vari/2;
        p1_vari = p1_vari-(p1_mean)^2;
        p2_vari = p2_vari-(p2_mean)^2;
        p12_mean = p1_mean-p2_mean;
        p12_vari = p1_vari-p2_vari;
        ap12_mean = abs(p12_mean);
        ap12_vari = abs(p12_vari);
        Img_fv = [Img_fv p1_mean p1_vari p12_mean p12_vari ap12_mean ap12_vari];
    end
end
% type12: C4-3: 2-1(value), 2-1(abs)
% dimension: (2982)+4*4 = 2998
for i = 1:2
    for j = i+1:3     
        for k = j+1:4
            p1_mean = (v_add_22_arr(i)+v_add_22_arr(j))/2;
            p1_vari = (v_sqr_22_arr(i)+v_sqr_22_arr(j))/2;
            p2_mean = v_add_22_arr(k);
            p2_vari = v_sqr_22_arr(k);
            p1_vari = p1_vari-(p1_mean)^2;
            p2_vari = p2_vari-(p2_mean)^2;
            p12_mean = p1_mean-p2_mean;
            p12_vari = p1_vari-p2_vari;
            ap12_mean = abs(p12_mean);
            ap12_vari = abs(p12_vari);
            Img_fv = [Img_fv p12_mean p12_vari ap12_mean ap12_vari];
        end
    end
end
% --------- global composition --------
% type13: holistic
% dimension: (2998)+2 = 3000
p1_mean = sum(add_66_arr(:))/36;
p1_vari = sum(sqr_66_arr(:))/36;
p1_vari = p1_vari-(p1_mean)^2;
Img_fv = [Img_fv p1_mean p1_vari];
% tyep14: horizontal-global line
% dimension: (3000)+6*6 = 3036
for blk_i = 1:6
    p1_mean = sum(add_66_arr(blk_i,:));
    p1_vari = sum(sqr_66_arr(blk_i,:));
    p2_mean = (sum(add_66_arr(:)) - p1_mean)/30;
    p2_vari = (sum(sqr_66_arr(:)) - p1_vari)/30;
    p1_mean = p1_mean/6;
    p1_vari = p1_vari/6;
    p1_vari = p1_vari-(p1_mean)^2;
    p2_vari = p2_vari-(p2_mean)^2;
    p12_mean = p1_mean-p2_mean;
    p12_vari = p1_vari-p2_vari;
    ap12_mean = abs(p12_mean);
    ap12_vari = abs(p12_vari);
    Img_fv = [Img_fv p1_mean p1_vari p12_mean p12_vari ap12_mean ap12_vari];
end
% tyep15: vertical-global line
% dimension: (3036)+6*6 = 3072
for blk_j = 1:6
    p1_mean = sum(add_66_arr(:,blk_j));
    p1_vari = sum(sqr_66_arr(:,blk_j));
    p2_mean = (sum(add_66_arr(:)) - p1_mean)/30;
    p2_vari = (sum(sqr_66_arr(:)) - p1_vari)/30;
    p1_mean = p1_mean/6;
    p1_vari = p1_vari/6;
    p1_vari = p1_vari-(p1_mean)^2;
    p2_vari = p2_vari-(p2_mean)^2;
    p12_mean = p1_mean-p2_mean;
    p12_vari = p1_vari-p2_vari;
    ap12_mean = abs(p12_mean);
    ap12_vari = abs(p12_vari);
    Img_fv = [Img_fv p1_mean p1_vari p12_mean p12_vari ap12_mean ap12_vari];
end

end % end function