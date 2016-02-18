working_dir = '/tmp3/yuchen/BoAP_Adaboost/'
%% ====== loading lib. ======
addpath(genpath('/tmp3/yuchen/BoAP_Adaboost/gbvs'));
addpath(genpath('/tmp3/yuchen/BoAP_Adaboost/adaboost')); %unused

%% ====== extracting features ======
filename_cell_train_pos = struct2cell(rdir('/tmp3/yuchen/software_code_shao-yi/Photonet/Train/Good/*.jpg'));
filename_cell_train_neg = struct2cell(rdir('/tmp3/yuchen/software_code_shao-yi/Photonet/Train/Bad/*.jpg'));
train_label = [repmat(1, 1, size(filename_cell_train_pos,2)) repmat(-1, 1, size(filename_cell_train_neg,2))];
filenames = [filename_cell_train_pos(1,:) filename_cell_train_neg(1,:)];
fileNum = size(filenames,2);
dim = 36864;
train_data = zeros(fileNum, dim);
for n = 1:fileNum
    n
    train_data(n,:) = feature_extraction(filenames{n});
end
save([working_dir 'data/feature.mat'], 'train_data', 'train_label')
%% ====== training AdaBoost ======
[classestimate,model,confidence]=adaboost('train', train_data, train_label, 200);
