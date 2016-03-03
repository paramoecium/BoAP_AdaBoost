working_dir = '/tmp3/yuchen/BoAP_Adaboost/'
%% ====== loading lib. ======
addpath(genpath('/tmp3/yuchen/BoAP_Adaboost/gbvs'));
addpath(genpath('/tmp3/yuchen/BoAP_Adaboost/adaboost')); %unused





dim = 36864;

filename_cell = struct2cell(rdir('/tmp3/yuchen/AVA_dataset/images/*/*.jpg'));
filenames = filename_cell(1,:);
fileNum = size(filenames,2);
%% ====== processing label ======
[serial, index, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, t1, t2, c1] = textread('/tmp3/yuchen/AVA_dataset/AVA_dataset/AVA.txt', '%u %u %u %u %u %u %u %u %u %u %u %u %u %u %u');
avg = zeros(size(index));
for n=1:size(index,1)
    vote_count = (r1(n)+r2(n)+r3(n)+r4(n)+r5(n)+r6(n)+r7(n)+r8(n)+r9(n)+r10(n));
    weighted_sum = r1(n)+r2(n)*2+r3(n)*3+r4(n)*4+r5(n)*5+r6(n)*6+r7(n)*7+r8(n)*8+r9(n)*9+r10(n)*10;
    avg(n) = (weighted_sum)/vote_count;
end
label_map = containers.Map(index,avg);
label = zeros(fileNum,1);
%% ====== extracting features ======
data = zeros(fileNum, dim);
for n = 1:fileNum
    path_cell = strsplit(filenames{n},'/');
    index_cell = strsplit(path_cell{end},'.jpg');
    current_index = str2num(index_cell{1});
    if ~isKey(label_map,current_index)
        continue;
    elseif label_map(current_index)<6 && label_map(current_index)>4
        continue;
    end
    label(n) = label_map(current_index);
    disp([n,current_index,label(n)])
    img = imread(filenames{n});
    data(n,:) = feature_extraction(img);
end

data_filtered = data(data(:,1)~=0,:);
label_filtered = label(data(:,1)~=0);

save([working_dir 'data/ava_dataset/train.mat'], 'train_data', 'train_label');
save([working_dir 'data/ava_dataset/test.mat'], 'test_data', 'test_label');
%% ====== training AdaBoost ======
[classestimate, model, confidence]=adaboost('train', train_data, train_label, 200);
save([working_dir 'data/ava_dataset/model.mat'], 'model');
%% ====== testing AdaBoost ======
load([working_dir 'data/ava_dataset/model.mat'], 'model');
[pred_label, test_label2, confidence] = adaboost('apply', test_data, model);
% model dimension distribution
modeldim_distribution = [];
for i = 1:200
    modeldim_distribution = [modeldim_distribution model(i).dimension];
end
pred_label(pred_label(:)==-1)=2;
test_label(test_label(:)==-1)=2;
CP = classperf(test_label, pred_label);
CP.ErrorRate
