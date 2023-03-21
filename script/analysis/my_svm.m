clear 
close all
clc

%% Load FFT of the tapping data 
cd('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/svm/IMB_tap/')
load('duple.mat')
load('triple.mat')
cd('/Users/t.z.cheng/Google_Drive/Research/Imaginedbeat/Analysis/svm/libsvm-3.24/matlab')

%% Parameters 
N = 2*size(duple,2);
svm_parameters = '-s 0 -t 0 -c 10 -q';
% svm_parameters = '-s 0 -t 0 -c 1 -b 0 -q'; % Philippe Albouy's 
nfold = 10;
group = 1:nfold;
ntrain = N - N/nfold;
ntest = N/nfold;

%% Transform data to the svm format
data = [duple,triple];
data = double(data);
data = squeeze(data(1,:,:)); % test in one sub for now
label = [zeros(45,1);ones(45,1)]; % 0: duple, 1: triple

%% Scaling the feature vs try to scale after train and test, try to scale to between 0 and 1 or -1 and 1
[data_z,MU,SIGMA] = zscore(data);
data_z = data_z./max(data_z);

%% Cross-validation
idx_shuffle = randperm(90); % follow the experiment presentation randomization order
data_shuffle = data_z(idx_shuffle,:);
label_shuffle = label(idx_shuffle);
data_shuf_reshape = reshape(data_shuffle,[9,10,270]);
label_shuf_reshape = reshape(label_shuffle,[9,10]);

%% run svm
for k = 1:nfold
    data_train = data_shuf_reshape(:,group(group ~= k),:);
    data_train = reshape(data_train,[ntrain,270]);
    data_test = squeeze(data_shuf_reshape(:,group(k),:));
    label_train = label_shuf_reshape(:,group(group ~= k));
    label_train = reshape(label_train,[ntrain,1]);
    label_test = label_shuf_reshape(:,group(k));
    tmpmodel = svmtrain(label_train, data_train, svm_parameters);
    [~, tmpaccuracy, ~] = svmpredict(label_test, data_test, tmpmodel); % test the training data
    accuracy(k) = tmpaccuracy(1);
    clear tmpmodel tmpaccuracy
end
mean(accuracy)

%%
