function featureVector = feature_extraction(img)
% function to perform feature extraction

featureVector = [];
if size(img,3) == 1
    img = cat(3, img, img, img);
end

% disp('bag of r feature extraction')
img_r = img(:,:,1);%0:255
[img_add, img_sqr] = Integral_Image(img_r);
[img_fv] = feature_extraction_value(img_add, img_sqr, 1, 1, size(img,1), size(img,2));
featureVector = [featureVector img_fv];

% disp('bag of g feature extraction')
img_g = img(:,:,2);%0:255
[img_add, img_sqr] = Integral_Image(img_g);
[img_fv] = feature_extraction_value(img_add, img_sqr, 1, 1, size(img,1), size(img,2));
featureVector = [featureVector img_fv];

% disp('bag of b feature extraction')
img_b = img(:,:,3);%0:255
[img_add, img_sqr] = Integral_Image(img_b);
[img_fv] = feature_extraction_value(img_add, img_sqr, 1, 1, size(img,1), size(img,2));
featureVector = [featureVector img_fv];

% disp('bag of h feature extraction')
hsv_img = rgb2hsv(img);
img_h = hsv_img(:,:,1);%0:1
img_h = floor(255*img_h);%0:255
img_h = uint8(img_h);
[img_add, img_sqr] = Integral_Image(img_h);
[img_fv] = feature_extraction_value(img_add, img_sqr, 1, 1, size(img,1), size(img,2));
featureVector = [featureVector img_fv];

% disp('bag of s feature extraction')
hsv_img = rgb2hsv(img);
img_s = hsv_img(:,:,2);%0:1
img_s = floor(255*img_s);%0:255
img_s = uint8(img_s);
[img_add, img_sqr] = Integral_Image(img_s);
[img_fv] = feature_extraction_value(img_add, img_sqr, 1, 1, size(img,1), size(img,2));
featureVector = [featureVector img_fv];

% disp('bag of v feature extraction')
hsv_img = rgb2hsv(img);
img_v = hsv_img(:,:,3);%0:1
img_v = floor(255*img_v);%0:255
img_v = uint8(img_v);
[img_add, img_sqr] = Integral_Image(img_v);
[img_fv] = feature_extraction_value(img_add, img_sqr, 1, 1, size(img,1), size(img,2));
featureVector = [featureVector img_fv];

% disp('bag of lbp feature extraction')
[img_lbp] = lbp(img);% output: uint8 image
[img_add, img_sqr] = Integral_Image(img_lbp);
[img_fv] = feature_extraction_value(img_add, img_sqr, 1, 1, size(img,1), size(img,2));
featureVector = [featureVector img_fv];

% disp('bag of edge feature extraction')
[ex, ey, e, angles] = edge_map(img);
[img_add, img_sqr] = Integral_Image(e);
[img_fv] = feature_extraction_value(img_add, img_sqr, 1, 1, size(img,1), size(img,2));
featureVector = [featureVector img_fv];

% disp('bag of ex feature extraction')
[img_add, img_sqr] = Integral_Image(ex);
[img_fv] = feature_extraction_value(img_add, img_sqr, 1, 1, size(img,1), size(img,2));
featureVector = [featureVector img_fv];

% disp('bag of ey feature extraction')
[img_add, img_sqr] = Integral_Image(ey);
[img_fv] = feature_extraction_value(img_add, img_sqr, 1, 1, size(img,1), size(img,2));
featureVector = [featureVector img_fv];

% disp('bag of angles feature extraction')
[img_add, img_sqr] = Integral_Image(angles);
[img_fv] = feature_extraction_value(img_add, img_sqr, 1, 1, size(img,1), size(img,2));
featureVector = [featureVector img_fv];

% disp('bag of Saliency feature extraction')
[master_map] = Saliency(img);
[img_add, img_sqr] = Integral_Image(master_map);
[img_fv] = feature_extraction_value(img_add, img_sqr, 1, 1, size(img,1), size(img,2));
featureVector = [featureVector img_fv];    
end
