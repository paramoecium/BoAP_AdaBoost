% add path of feature extraction
addpath(genpath('/tmp3/yuchen/BoAP_Adaboost/gbvs'));
load('/tmp3/yuchen/BoAP_Adaboost/data/flickr_dataset/model.mat', 'model');
[id, url, x, y, w, h, vote] = textread('/tmp3/yuchen/flickr_dataset/crop/test_0.1.txt', '%u %s %u %u %u %u %u');

%[id, url, x0, y0, w0, h0, x1, y1, w1, h1, vote] = textread('/tmp3/yuchen/flickr_dataset/rank/test_1.txt', '%u %s %u %u %u %u %u %u %u %u %u');
dir_path = '/tmp3/yuchen/flickr_dataset/download_images/'
%for i=1:size(url,1)
for i=1:1
    i
    assert(vote(i)>=4);
    url_split = strsplit(url{i},'/');
    img_path = strjoin({dir_path, url_split{end}},'');
    bigImg = imread(img_path); %%change file name here

    up_test = y(i);
    dn_test = y(i)+h(i);
    lt_test = x(i);
    rt_test = x(i)+w(i);

    bounding_boxes = auto_crop(bigImg,model);
    [max_confidence, row_id] = max(bounding_boxes(:,1));
    best_bounding_box = num2cell(bounding_boxes(row_id,2:5));
    [up_pred, dn_pred, lt_pred, rt_pred] = deal(best_bounding_box{:});
    if up_test>dn_pred || dn_test<up_pred || lt_test>rt_pred || rt_test<lt_pred
        area_inter = 0;
    else
        area_inter = abs((min(rt_test,rt_pred)-max(lt_test,lt_pred))*(min(up_test,up_pred)-max(dn_test,dn_pred))); 
    end
    area_union = (dn_test-up_test)*(rt_test-lt_test) + (dn_pred-up_pred)*(rt_pred-lt_pred) - area_inter;
    overlapping_ratio = area_inter/area_union
    boundary_displacement = norm([up_test, dn_test, lt_test, rt_test] - [up_pred, dn_pred, lt_pred, rt_pred])
end
