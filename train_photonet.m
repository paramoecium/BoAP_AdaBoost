working_dir = '/tmp3/yuchen/BoAP_Adaboost/'
%% ====== loading lib. ======
addpath(genpath('/tmp3/yuchen/BoAP_Adaboost/gbvs'));
addpath(genpath('/tmp3/yuchen/BoAP_Adaboost/adaboost')); %unused

%% ====== extracting features ======
dim = 36864;

filename_cell_train_pos = struct2cell(rdir('/tmp3/yuchen/software_code_shao-yi/Photonet/Train/Good/*.jpg'));
filename_cell_train_neg = struct2cell(rdir('/tmp3/yuchen/software_code_shao-yi/Photonet/Train/Bad/*.jpg'));
train_label = [repmat(1, 1, size(filename_cell_train_pos,2)) repmat(-1, 1, size(filename_cell_train_neg,2))];
filenames_train = [filename_cell_train_pos(1,:) filename_cell_train_neg(1,:)];
fileNum_train = size(filenames_train,2);
train_data = zeros(fileNum_train, dim);
for n = 1:fileNum_train
    disp(n)
    img = imread(filenames_train{n});
    train_data(n,:) = feature_extraction(img);
end
save([working_dir 'data/Photonet_dataset/train.mat'], 'train_data', 'train_label');

filename_cell_test_pos = struct2cell(rdir('/tmp3/yuchen/software_code_shao-yi/Photonet/Test/Good/*.jpg'));
filename_cell_test_neg = struct2cell(rdir('/tmp3/yuchen/software_code_shao-yi/Photonet/Test/Bad/*.jpg'));
test_label = [repmat(1, 1, size(filename_cell_test_pos,2)) repmat(-1, 1, size(filename_cell_test_neg,2))];
filenames_test = [filename_cell_test_pos(1,:) filename_cell_test_neg(1,:)];
fileNum_test = size(filenames_test,2);
test_data = zeros(fileNum_test, dim);
for n = 1:fileNum_test
    disp(n)
    img = imread(filenames_test{n});
    test_data(n,:) = feature_extraction(img);
end
save([working_dir 'data/Photonet_dataset/test.mat'], 'test_data', 'test_label');
%% ====== training AdaBoost ======
[classestimate, model, confidence]=adaboost('train', train_data, train_label, 200);
save([working_dir 'data/Photonet_dataset/model.mat'], 'model');
%% ====== testing AdaBoost ======
load([working_dir 'data/Photonet_dataset/model.mat'], 'model');
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
