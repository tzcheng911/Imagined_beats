%% Set up parameters and the paths
%eeglab
clear 
close all
clc

% parameters
AM = 4; % IC selection (AM2, AM3, AM4)
% AM2: find the top aIC and mIC from the brain ICs > 0.4 to explain all
% signal; AM3: find the top aIC and mIC from the brain ICs > 0.4 to explain 
% only the brain signal; AM4: remove the artifact ICs > 0.4 then find the
% aIC and mIC from the brain ICs > 0.4 to explain the artifact-free signals
aICormIC = 'mIC'; % calculating for auditory or motor IC
bic_th = 0.4; % threshold percentage
bic_class = 1; % brain ICs
ntop = 5;

if aICormIC == 'aIC'
    localizer_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/rdlisten'; % for rdlisten2 files 
    save_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/rdlisten';
    localizer_files = dir(fullfile(localizer_path,'*rdlisten2_e.set')); % for rdlisten2 files
    epoch_window = [-100  300]; % for auditory ICs
    weight_window = [50 250]; % for auditory ICs

elseif aICormIC == 'mIC'
    localizer_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/SMT'; % for tap1 files 
    save_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/SMT';
    localizer_files = dir(fullfile(localizer_path,'*tap1_e.set')); % for tap1 files 
    epoch_window = [-100  200]; % for motor ICs
    weight_window = [-50 100]; % for motor ICs 4a[0 100] or 4b[-50 100]
end

localizer_name = {localizer_files.name};
nsub = length(localizer_name);
load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/preprocessed/all_brainic_0.4.mat'); % brain ic index (classified by IClabel across the whole exp)
load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/preprocessed/all_artifacts_0.4.mat'); % artifacts (muscle, eye, heart, line noise, channel noise, classified by IClabel across the whole exp)
load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/preprocessed/artifactfree_brainic.mat'); % artifacts (muscle, eye, heart, line noise, channel noise, classified by IClabel across the whole exp)

cd(localizer_path)

%% Use pop_envtopo to find out the pvaf and top ICs for each subject 
for sub = 1:nsub
    tempfile = localizer_name{sub};
    EEG = pop_loadset('filename',tempfile ,'filepath', localizer_path);
    EEG.icaact = EEG.icaweights*EEG.icasphere*EEG.data(EEG.icachansind,:);

    if AM == 2
       figure;[cmpvarorder,~,~,~,~,sortvar] = pop_envtopo(EEG, epoch_window,'compnums',...
           all_brainic{sub},'limcontrib',weight_window,'compsplot',...
           1,'sortvar' ,'pv','dispmaps','on'); 
    elseif AM == 3
        EEG = pop_subcomp(EEG, all_brainic{sub}, 0, 1);
        EEG = eeg_checkset(EEG); % recalculate icaact
        figure;[cmpvarorder0,~,~,~,~,sortvar] = pop_envtopo(EEG, epoch_window,'limcontrib',weight_window,'compsplot',...
            1,'sortvar' ,'pv','dispmaps','on'); 
        cmpvarorder(nic) = all_brainic{sub}(cmpvarorder0); % convert the index after subcomp to original IC index in the dipfit files
    elseif AM == 4
        icremove = [artifact{sub,1};artifact{sub,2};artifact{sub,3};artifact{sub,4};artifact{sub,5}];
        tempind = 1:size(EEG.icaact,1);
        tempind(icremove) = []; % remove the artifact IC indexes
        ind(sub) = {tempind}; % get the original IC index with all retaining ICs
        EEG = pop_subcomp(EEG, icremove, 0, 0);
        EEG = eeg_checkset(EEG); % recalculate icaact
        figure;[cmpvarorder0,~,~,~,~,sortvar] = pop_envtopo(EEG, epoch_window,'compnums',...
            artifactfree_brainic{sub},'limcontrib',weight_window,'compsplot',...
            1,'sortvar' ,'pv','dispmaps','on'); % get the pvaf and order from all ICs
        cmpvarorder = tempind(cmpvarorder0); % convert the index after subcomp to original IC index in the dipfit files
    else disp('Waring: Please define which AM selection criteria to use')
    end
    cmpvarorder_all(sub) = {cmpvarorder}; % get the order
    pvaf_all(sub) = {sort(sortvar,'Descend')}; % get the pvaf(need to sort from large to small)
    clear icremove cmpvarorder sortvar tempind
end

%% save IC pvaf order and value of aIC and mIC
cd(save_path)
savecmpvaro = strcat('cmpvarorder_all_','AM',num2str(AM),'_',aICormIC);
savepvaf = strcat('pvaf_all_','AM',num2str(AM),'_',aICormIC);
savebrain = strcat('brainic','AM',num2str(AM),'_',aICormIC);
save(savecmpvaro,'cmpvarorder_all')
save(savepvaf,'pvaf_all')
save(savebrain,'brainic')
save ind_subcomp ind

%% Extract top ICs and their pvafs
% rdlisten aIC
cd('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/rdlisten')
load('cmpvarorder_all_AM4_aIC.mat');
load('pvaf_all_AM4_aIC.mat');

% spontap mIC
cd('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/SMT')
load('cmpvarorder_all_AM4_mIC.mat');
load('pvaf_all_AM4_mIC.mat');

% Get the top IC index
for n = 1:25
    tmp_order = cell2mat(cmpvarorder_all(n));
    tmp_pvaf = cell2mat(pvaf_all(n));
    top_IC(n,1:3) = tmp_order(1:3);
    top_IC(n,4:6) = tmp_pvaf(1:3);
    clear tmp_order tmp_pvaf
end
top_IC(:,7) = 1:25;
% same = (top_mIC == top_aIC);
% find(same == 1)

%% Visualization: run the "Set up parameters and the paths" first
%% plot individal envtopo
% see the comparison between cmpvarorder0 and cmpvarorder to check the IC index
sub = 12;

tempfile = localizer_name{sub};
EEG = pop_loadset('filename', tempfile,'filepath', localizer_path);
EEG = eeg_checkset(EEG); % if this won't recalculate EEG.icaact, run the next line
EEG.icaact = EEG.icaweights*EEG.icasphere*EEG.data(EEG.icachansind,:);
EEG = pop_eegfiltnew(EEG, 'hicutoff',60); % 60 Hz low pass filter 
if AM == 2
       figure;[cmpvarorder,~,~,~,~,sortvar] = pop_envtopo(EEG, epoch_window,'compnums',...
           all_brainic{sub},'limcontrib',weight_window,'compsplot',...
           ntop,'sortvar' ,'pv','dispmaps','on'); 
    elseif AM == 3
        EEG = pop_subcomp(EEG, all_brainic{sub}, 0, 1);
        EEG = eeg_checkset(EEG); % recalculate icaact
        figure;[cmpvarorder0,~,~,~,~,sortvar] = pop_envtopo(EEG, epoch_window,'limcontrib',weight_window,'compsplot',...
            ntop,'sortvar' ,'pv','dispmaps','on'); 
        cmpvarorder = all_brainic{sub}(cmpvarorder0); % convert the index after subcomp to original IC index in the dipfit files
    elseif AM == 4
        icremove = [artifact{sub,1};artifact{sub,2};artifact{sub,3};artifact{sub,4};artifact{sub,5}];
        tempind = 1:size(EEG.icaact,1);
        tempind(icremove) = []; % remove the artifact IC indexes
        ind(sub) = {tempind}; % get the original IC index with all retaining ICs
        EEG = pop_subcomp(EEG, icremove, 0, 0);
        EEG = eeg_checkset(EEG); % recalculate icaact
        figure;[cmpvarorder0,~,~,~,~,sortvar] = pop_envtopo(EEG, epoch_window,'compnums',...
            artifactfree_brainic{sub},'limcontrib',weight_window,'compsplot',...
            ntop,'sortvar' ,'pv','dispmaps','on'); % get the pvaf and order from all ICs
        cmpvarorder = tempind(cmpvarorder0); % convert the index after subcomp to original IC index in the dipfit files
        sort(sortvar,'Descend')
    else disp('Waring: Please define which AM selection criteria to use')
end

%% Topo of all ICs for each participants
for i = 1:nsub
    tempfile = localizer_name{sub};
    EEG = pop_loadset('filename', tempfile,'filepath', localizer_path);
    figure(i); pop_topoplot(EEG, 0, [1 30] ,'',[5 6] ,0,'electrodes','off'); % plot the first 30 ICs
    clear EEG tempfile
end

%% Plot the pvaf of the top 3 aICs or mICs
for i = 1:nsub
    figure;plot(top_aIC(i,4:6),'-o','LineWidth',2)
end
for i = 1:nsub
    figure;plot(top_mIC(i,4:6),'-o','LineWidth',2)
end