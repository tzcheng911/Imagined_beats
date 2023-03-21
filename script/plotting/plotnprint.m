%% Plot and print the graphs
clear all
close all
clc
dataDir = '/Users/tzu-hancheng/Google_Drive/Academia/Swartz_center/imaginedbeats/data/200bpm';
cd /Users/tzu-hancheng/Google_Drive/Academia/Swartz_center/imaginedbeats/data/200bpm
files = dir(fullfile(dataDir,'*.set'));
datasets = {files.name};
for iS = 1:length(datasets)
    datasetFile = datasets{iS};
    parts = cellstr(split(datasetFile,'.'));
    EEG = pop_loadset('filename',datasetFile ,'filepath', dataDir);    
figure
subplot(2,1,1)     
%pop_timtopo_zoe(EEG, [EEG.xmin*1000      EEG.xmax*1000],[], 'ERP data and scalp maps');
pop_timtopo(EEG, [EEG.xmin*1000      EEG.xmax*1000],[], 'ERP data and scalp maps');
subplot(2,1,2)      
%pop_envtopo(EEG, [EEG.xmin*1000      EEG.xmax*1000] ,'limcontrib',[45 250],'compsplot',[7],'title', 'Largest ERP components','electrodes','off');
pop_envtopo(EEG, [-50.7812      248.0469] ,'limcontrib',[-50.7812 248.0469],'compsplot',[7],'subcomps',[18, 19, 24:26, 33, 41, 47, 60, 61, 63, 67,...
    73, 76, 78, 81, 85, 86, 91, 92, 94, 99, 104, 105:108, 111:114, 118. 120:122, 124, 125, 127, 129, 131, 133:144, 148, 155, 156, 159, 163, 164, 167:175,...
    177:180, 183, 185:196, 199:202],'title', 'Largest ERP components of pilot2_200bpm_acc','electrodes','off');
expmulti('jpeg', char(parts(1)));
close all
end