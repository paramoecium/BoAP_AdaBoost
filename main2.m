working_dir = '/tmp3/yuchen/BoAP_Adaboost/'
%% ====== loading lib. ======
addpath(genpath('/tmp3/yuchen/BoAP_Adaboost/gbvs'));
addpath(genpath('/tmp3/yuchen/BoAP_Adaboost/adaboost')); %unused

%% ====== extracting features ======
dim = 36864;

filename_cell_pos = struct2cell(rdir('/tmp3/yuchen/flickr_dataset/download_images/*.jpg'));
filename_cell_neg = struct2cell(rdir('/tmp3/yuchen/flickr_dataset/cropped_images/*.jpg'));
label = [repmat(1, 1, size(filename_cell_pos,2)) repmat(-1, 1, size(filename_cell_neg,2))];
filenames = [filename_cell_pos(1,:) filename_cell_neg(1,:)];
fileNum = size(filenames,2);
data = zeros(fileNum, dim);
for n = 1:fileNum
    disp(n)
    data(n,:) = feature_extraction(filenames{n});
end
train_fileNum = floor(0.9*fileNum/2);
disp()
train_data = [data(1:train_fileNum,:);data(fileNum/2+1:fileNum/2+train_fileNum,:)];
train_label = [label(1:train_fileNum);label(fileNum/2+1:fileNum/2+train_fileNum)];
test_data = [data(train_fileNum+1:fileNum/2,:);data(fileNum/2+1+train_fileNum:fileNum,:)];
test_label = [label(train_fileNum+1:fileNum/2);label(fileNum/2+1+train_fileNum:fileNum)];
save([working_dir 'data/train.mat'], 'train_data', 'train_label');
save([working_dir 'data/test.mat'], 'test_data', 'test_label');
%% ====== training AdaBoost ======
[classestimate, model, confidence]=adaboost('train', train_data, train_label, 200);
save([working_dir 'data/model.mat'], 'model');
%% ====== testing AdaBoost ======
load([working_dir 'data/model.mat'], 'model');
[pred_label, test_label2, confidence] = adaboost('apply', test_data, model);
% model dimension distribution
modeldim_distribution = [];
for i = 1:200
    modeldim_distribution = [modeldim_distribution model(i).dimension];
end
pred_label(pred_label(:)==-1)=2
test_label(test_label(:)==-1)=2
CP = classperf(test_label, pred_label);
CP.ErrorRate
