%eeglab
% clear
% clc

% File path 
addpath(genpath('/Volumes/TOSHIBA/Research/Imagined_beats/script'))
% EEG_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/sync'; 
% EEG_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/SMT'; 
EEG_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/rdlisten'; 
  
cd(EEG_path)
% files = dir(fullfile(EEG_path,'*sync3s_e.set')); 
% files = dir(fullfile(EEG_path,'*tap1_e.set')); 
files = dir(fullfile(EEG_path,'*rdlisten2_e.set')); 

names = {files.name};

% Parameters
% am selection 4b
new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	6	4	1	1	5	8	4];
new_amIC(2,:) = [8	1	11	11	10	11	8	4	13	4	15	7	18	8	16	21	12	36	4	17	6	9	14	21	8];

%% Extract localizer individual's ERP
IC = 2; % 1: aIC; 2: mIC

for nsub = 1:2
    tempEEG = names{nsub};
    parts_cleanEEG = cellstr(split(tempEEG,'.'));
    EEG = pop_loadset('filename',tempEEG ,'filepath', EEG_path); % epoched data
    erps(nsub,:) = squeeze(mean(EEG.icaact(new_amIC(IC,nsub),:,:),3));
%    topo{nsub} = {EEG.icawinv(:,new_amIC(IC,nsub)),EEG.chanlocs};
end
times = EEG.times;

figure;plot(times,erps);hold on;plot(times,mean(erps,1),'LineWidth',3,'color','k');xlim([-300 500])
% save mIC_erp_sync3s erps times
% save aIC_topo topo

%% load a much smaller file to save some time
% eeglab
clear
clc

SMT_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SMT/';
load(strcat(SMT_path,'ITI_stds.mat'));
load(strcat(SMT_path,'ITI_means.mat'));
stable_tapper = find(stds < median(stds)); % use std of ITI
unstable_tapper = find(stds > median(stds)); % use std of ITI

% File path 
addpath(genpath('/Volumes/TOSHIBA/Research/Imagined_beats/script'))
% EEG_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/preprocessed/icap/AM4b/rdlisten/all'; 
EEG_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/preprocessed/icap/AM4b/spontap/all'; 
  
cd(EEG_path)
% files = dir(fullfile(EEG_path,'*sync3s_e.set')); 
% files = dir(fullfile(EEG_path,'*tap1_e.set')); 
files = dir(fullfile(EEG_path,'*icapMA.set')); 

names = {files.name};

% Parameters
% am selection 4b
aIC = [1	2	1	1	1	1	1	2	1	2	1	1	1	1	1	1	1	1	2	1	1	1	1	1	1];
mIC = [2	1	2	2	2	2	2	1	2	1	2	2	2	2	2	2	2	2	1	2	2	2	2	2	2];

%% Extract localizer individual's ERP
reverse_polarity_aIC = [2 3 5 9 11 15 17 19 20 23 24]; % these are the right reverse as in STUDY
reverse_polarity_mIC = [2 3 19 20 23]; % these are the right reverse as in STUDY

for nsub = 1:length(names)
    tempEEG = names{nsub};
    parts_cleanEEG = cellstr(split(tempEEG,'.'));
    EEG = pop_loadset('filename',tempEEG ,'filepath', EEG_path); % epoched data
    EEG = pop_eegfiltnew(EEG, 'hicutoff',60); % Note: this is only perform on EEG.data but not EEG.icaact
    EEG.icaact = EEG.icaweights*EEG.icasphere*EEG.data(EEG.icachansind,:); 
    EEG = eeg_checkset( EEG );
    if ismember(nsub,reverse_polarity_mIC) 
        erps(nsub,:) = -1*squeeze(mean(EEG.icaact(mIC(nsub),:,:),3));
    else
        erps(nsub,:) = squeeze(mean(EEG.icaact(mIC(nsub),:,:),3));
    end
%    figure;topoplot(EEG.icawinv(:,mIC(nsub)),EEG.chanlocs)
%    title(strcat('sub = ',num2str(nsub)))
    
    times = EEG.times;
    clear EEG parts_cleanEEG tempEEG
end

save mIC_erp_tap1_lp60Hz erps times
figure;plot(times,erps);hold on;plot(times,mean(erps,1),'LineWidth',3,'color','k');xlim([-300 500])
figure;plot(times,mean(erps(stable_tapper,:),1),'LineWidth',2);hold on; plot(times,mean(erps(unstable_tapper,:),1),'LineWidth',3);
legend('Stable','Unstable')
xlim([-300 500])
ylabel('Amplitude')
xlabel('Time (ms)')

%%
%erps(23,:) = erps(23,:)*-1;

figure;plot(times,mean(erps(stable_tapper,:),1),'LineWidth',2);hold on; plot(times,mean(erps(unstable_tapper,:),1),'LineWidth',3);
legend('Stable','Unstable')
xlim([-300 500])
ylabel('Amplitude')
xlabel('Time (ms)')
