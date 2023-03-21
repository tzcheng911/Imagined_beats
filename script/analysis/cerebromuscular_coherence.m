%eeglab
clear 
close all
clc
addpath(genpath('/Volumes/TOSHIBA EXT/Research/Imagined_beats/script'))

%% Preprocessing 
rawdata_path = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/preprocessing';
rawdata_files = dir(fullfile(rawdata_path,'*512.set'));
rawdata_name = {rawdata_files.name};
for nsub = 1:length(rawdata_name)
    tempEEG = rawdata_name{nsub};
    parts_tempEEG = cellstr(split(tempEEG,'.'));
    EEG = pop_loadset('filename',tempEEG ,'filepath', rawdata_path);
    if nsub < 6
       EXG1 = EEG.nbchan - 40 + 5; % EXG5
       EXG2 = EEG.nbchan - 40 + 6; % EXG6
    elseif nsub > 5 && nsub < 9
       EXG1 = EEG.nbchan - 40 + 3; % EXG3
       EXG2 = EEG.nbchan - 40 + 4; % EXG4
    elseif nsub > 8
       EXG1 = EEG.nbchan - 40 + 7; % EXG7
       EXG2 = EEG.nbchan - 40 + 8; % EXG8
    end
    figure; plot(EEG.data(EXG1:EXG2,:)'); % verify if they are really the EMG data
    EEG = pop_select(EEG, 'channel', [EXG1 EXG2]); % delete other channels, only keep EXG1 and EXG2
    EEG = pop_eegfiltnew(EEG, 'locutoff',60); % 60 Hz high pass filter 
    EEG.setname = strcat(parts_tempEEG(1),'_EMGf');
    EEG.filename = EEG.setname;
    EEG = pop_saveset(EEG,'filename',char(EEG.setname),'filepath',rawdata_path);
end

%% Load the data
cd('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EMG')
load('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/preprocessed/all_brainic_0.4.mat');
EMG_path = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EMG';
EEG_path = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/preprocessed';
EMG_files = dir(fullfile(EMG_path,'*EMGf.set'));
EEG_files = dir(fullfile(EEG_path,'*dipfit.set'));
EMG_name = {EMG_files.name};
EEG_name = {EEG_files.name};

%% Loop across subjects
for nsub = 1:length(EMG_name)
    tempEMG = EMG_name{nsub};
    tempEEG = EEG_name{nsub};
    EMG = pop_loadset('filename',tempEMG ,'filepath', EMG_path);
    EMG.data = EMG.data(1,:) - EMG.data(2,:);
    EEG = pop_loadset('filename',tempEEG ,'filepath', EEG_path);
    if (EEG.pnts ~= EMG.pnts) % deal with the inconsistent data points between EMG and preprocessed EEG
        EMG.pnts
        EEG.pnts
        EMG.data = EMG.data([find(EEG.etc.clean_sample_mask == 1)]); % trim EMG to be the same as EEG
    else 
        EMG.data = EMG.data;
    end

% Set the parameters 
nch = EEG.nbchan;
Fs = EEG.srate;
WINDOW = EEG.srate*2;
NOVERLAP = EEG.srate/2;
NFFT = EEG.srate*10;
hEMG = abs(hilbert(EMG.data(:))); % get the envelop 
brainic = cell2mat(all_brainic(nsub));
% Calculate cross-coherence between channels and EMG
% for ch = 1:nch
%     chEEG = EEG.data(ch,:);
%     chEEG = chEEG(:); % make it to column
%     [msC_ch(nsub,:,ch), F] = mscohere(chEEG,hEMG,WINDOW,NOVERLAP,NFFT,Fs);
% end
% 
% cross-coherence between components and EMG
% for ic = 1:nic
%     icEEG = EEG.icaact(ic,:);
%     icEEG = icEEG(:); % make it to column
%     [msC_ic(nsub,:,ic), F] = mscohere(icEEG,hEMG,WINDOW,NOVERLAP,NFFT,Fs);
% end

% cross-coherence between brain components and EMG
    for nbic = 1:length(brainic)
        bicEEG = EEG.icaact(brainic(nbic),:);
        bicEEG = bicEEG(:); % make it to column
        [msC_bic(nsub,:,nbic), F] = mscohere(bicEEG,hEMG,WINDOW,NOVERLAP,NFFT,Fs);
    end
    clear brainic bicEEG EMG hEMG EEG
end

% save msC_ic msC_ic
save msC_bic msC_bic
save F F

%% Pull out the interested frequency band
% beatF = find(F == 2.4);
% dmeterF = find(F == 1.2);
% tmeterF = find(F == 0.8);
% 
% max_msC_ch = max(msC_ch(beatF,:));
% max_msC_ic = max(msC_ic(beatF,:));

%% Plot the coherence
clear 
close all
clc
cd('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EMG')
load('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/preprocessed/all_brainic_0.4.mat');
load('F.mat')
load('msC_bic.mat')
ntop = 3; % top n ICs

for sub = 1:25
    [~,I_ic(:,sub)] = sort(squeeze(msC_bic(sub,25,:)),'descend');
end

topic = I_ic(1:ntop,:);
% turn it to the original idx
for sub = 1:25
    brainic = cell2mat(all_brainic(sub));
    bicidx(:,sub) = brainic(topic(:,sub)); % bicidx is the index you should look at 
end
    
for sub = 1:25
    figure;
    plot(F,squeeze(msC_bic(sub,:,topic(:,sub))),'LineWidth',2)
    xlim([0 10])
    ylim([0 0.5])
end

%% Plot topos based on mscohere (working)
EEG_path = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/preprocessed';
EEG_files = dir(fullfile(EEG_path,'*dipfit.set'));
EEG_name = {EEG_files.name};
for nsub = 1:length(EEG_name)
    tempEEG = EEG_name{nsub};
    EEG = pop_loadset('filename',tempEEG ,'filepath', EEG_path);
    figure;
    [cmpvarorder,~,~,~,~,sortvar] = pop_envtopo(EEG, [-100  200],'subcomps',1,'compnums',...
        cell2mat(all_brainic(nsub)),'limcontrib',[0 100],'compsplot',...
        3,'sortvar' ,'pv','dispmaps','on');
end

%% Plot topos based on pvaf
top15ic = cmpvarorder_all(1:15,:);
EEG_path = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG';
EEG_files = dir(fullfile(EEG_path,'*dipfit.set'));
EEG_name = {EEG_files.name};
for nsub = 8:length(EEG_name)
    tempEEG = EEG_name{nsub};
    EEG = pop_loadset('filename',tempEEG ,'filepath', EEG_path);
    pop_viewprops( EEG, 0, [top15ic(:,nsub)'], {}, {}, 0, '' )
    clear EEG
end

%% only show the brain relevant ic
clear 
close all
clc

load('all_brainic.mat');
load('I_ic.mat');
for i = 1:size(I_ic,2)
    for j = 1:size(I_ic,1)
        if ~ismember(I_ic(j,i),all_brainic(:,i))
           I_ic(j,i) = 0;
        else I_ic(j,i) = I_ic(j,i);
        end
    end
    tmp = nonzeros(I_ic(:,i));
    bic(1:length(tmp),i) = tmp;
    clear tmp    
end
