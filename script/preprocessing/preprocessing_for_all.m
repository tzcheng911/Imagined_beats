%eeglab
clear
close all
clc

%% Preprocessing until trimoutlier: select channels, notch filter, load digitized channel loc, trim channels, rereference
evtag_path = '/data/projects/zoe/ImaginedBeats/real_exp/preprocessing';
evtag_files = dir(fullfile(evtag_path,'*512.set'));
evtag_name = {evtag_files.name};

for nsub = 1:length(evtag_name)
    tempEEG = evtag_name{nsub};
    parts_tempEEG = cellstr(split(tempEEG,'.'));
    EEG = pop_loadset('filename',tempEEG ,'filepath', evtag_path);
    EEG = pop_select( EEG, 'channel',{'A1' 'A2' 'A3' 'A4' 'A5' 'A6' 'A7' 'A8' 'A9' 'A10' 'A11' 'A12' 'A13' 'A14' 'A15' 'A16' 'A17' 'A18' 'A19' 'A20' 'A21' 'A22' 'A23' 'A24' 'A25' 'A26' 'A27' 'A28' 'A29' 'A30' 'A31' 'A32' 'B1' 'B2' 'B3' 'B4' 'B5' 'B6' 'B7' 'B8' 'B9' 'B10' 'B11' 'B12' 'B13' 'B14' 'B15' 'B16' 'B17' 'B18' 'B19' 'B20' 'B21' 'B22' 'B23' 'B24' 'B25' 'B26' 'B27' 'B28' 'B29' 'B30' 'B31' 'B32' 'C1' 'C2' 'C3' 'C4' 'C5' 'C6' 'C7' 'C8' 'C9' 'C10' 'C11' 'C12' 'C13' 'C14' 'C15' 'C16' 'C17' 'C18' 'C19' 'C20' 'C21' 'C22' 'C23' 'C24' 'C25' 'C26' 'C27' 'C28' 'C29' 'C30' 'C31' 'C32' 'D1' 'D2' 'D3' 'D4' 'D5' 'D6' 'D7' 'D8' 'D9' 'D10' 'D11' 'D12' 'D13' 'D14' 'D15' 'D16' 'D17' 'D18' 'D19' 'D20' 'D21' 'D22' 'D23' 'D24' 'D25' 'D26' 'D27' 'D28' 'D29' 'D30' 'D31' 'D32' 'E1' 'E2' 'E3' 'E4' 'E5' 'E6' 'E7' 'E8' 'E9' 'E10' 'E11' 'E12' 'E13' 'E14' 'E15' 'E16' 'E17' 'E18' 'E19' 'E20' 'E21' 'E22' 'E23' 'E24' 'E25' 'E26' 'E27' 'E28' 'E29' 'E30' 'E31' 'E32' 'F1' 'F2' 'F3' 'F4' 'F5' 'F6' 'F7' 'F8' 'F9' 'F10' 'F11' 'F12' 'F13' 'F14' 'F15' 'F16' 'F17' 'F18' 'F19' 'F20' 'F21' 'F22' 'F23' 'F24' 'F25' 'F26' 'F27' 'F28' 'F29' 'F30' 'F31' 'F32' 'G1' 'G2' 'G3' 'G4' 'G5' 'G6' 'G7' 'G8' 'G9' 'G10' 'G11' 'G12' 'G13'});
    EEG = pop_eegfiltnew(EEG, [],0.1,16896,1,[],1); % high pass filter 
    EEG = pop_chanedit(EEG);
    EEG = pop_trimOutlier(EEG);
    EEG = pop_reref( EEG, []);
    EEG.setname = strcat(parts_tempEEG(1),'_clean');
    EEG.filename = char(EEG.setname);
    EEG = pop_saveset(EEG,'filename',EEG.setname,'filepath',evtag_path);
end

clear
%% Preprocessing after trimoutlier: clean raw data, ica
clean_path = '/data/projects/zoe/ImaginedBeats/real_exp/preprocessed';
clean_files = dir(fullfile(clean_path,'*clean.set'));
clean_name = {clean_files.name};

for nsub = 1:length(clean_name)
    tempEEG = clean_name{nsub};
    parts_cleanEEG = cellstr(split(tempEEG,'.'));
    EEG = pop_loadset('filename',tempEEG ,'filepath', clean_path);
    EEG = eeg_checkset( EEG );    
    EEG = clean_rawdata(EEG, 'off', 'off', 0.6, 'off', 5, 0.25);
    EEG = pop_runica(EEG, 'icatype', 'binica', 'extended',1);
    EEG.setname = strcat(parts_cleanEEG(1),'_binica');
    filename = char(EEG.setname);
    EEG = pop_saveset(EEG,'filename',filename,'filepath',clean_path);
    EEG = pop_dipfit_settings( EEG, 'hdmfile','/data/common/matlab/eeglab/plugins/dipfit2.3/standard_BEM/standard_vol.mat',...
    'coordformat','MNI','mrifile','/data/common/matlab/eeglab/plugins/dipfit2.3/standard_BEM/standard_mri.mat','chanfile',...
    '/data/common/matlab/eeglab/plugins/dipfit2.3/standard_BEM/elec/standard_1005.elc','coord_transform',...
    [-0.015 -22 -15 0.34907 0 -1.571 1050 990.1 990.1165] ,'chansel',[1:EEG.nbchan] ); % change the parameters to better fit the channel and headmodel
    EEG = pop_multifit(EEG, [1:EEG.nbchan] ,'threshold',100,'plotopt',{'normlen' 'on'});
    EEG.setname = strcat(parts_cleanEEG(1),'_binica_dipfit');
    filename = char(EEG.setname);
    EEG = pop_saveset(EEG,'filename',filename,'filepath',clean_path);
end

%% Run dipfit and finefit automatically and examine manually

%% Segmentation and epoch for raw tapping data
tapbeh_path = '/data/projects/zoe/ImaginedBeats/real_exp/preprocessing';
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/tapbeh';
tapbeh_files = dir(fullfile(tapbeh_path,'*512.set'));
tapbeh_name = {tapbeh_files.name};

for nsub = 1:length(tapbeh_name)
    tempEEG = EEG_name{nsub};
    parts = cellstr(split(tempEEG,'.'));
    EEG0 = pop_loadset('filename',tempEEG ,'filepath', tapbeh_path);
    EEG = eeg_checkset(EEG);
    EEG_duple = pop_rmdat( EEG0, {'Duple'},[-1 21] ,0); % select the duple and triple events and do epoch on them, respectively
    EEG_triple = pop_rmdat( EEG0, {'Triple'},[-1 21] ,0);
    EEGd.setname = strcat(parts(1),'_duple_tapbeh');
    filenamed = char(EEGd.setname);
    EEGd = pop_epoch( EEG_duple, {  'IM'  }, [5         11], 'newname', filename, 'epochinfo', 'yes');
    EEGd = pop_rmbase( EEGd, [5000   5050]);
    EEGd = pop_saveset(EEGd,'filename',filenamed,'filepath',filepath);
    EEGt.setname = strcat(parts(1),'_triple_tapbeh');
    filenamed = char(EEGt.setname);
    EEGt = pop_epoch( EEG_triple, {  'IM'  }, [5         11], 'newname', filename, 'epochinfo', 'yes');
    EEGt = pop_rmbase( EEGt, [5000   5050]);
    EEGt = pop_saveset(EEGt,'filename',filenamed,'filepath',filepath);
end

%% Segmentation and epoch for localizer
%%
% manually check the .dipfit files for timings
% from the evtag 512 Hz 
% tap1 = [1.2e4 1.1e5;3000 1e5;0 9.722e4;0 9.5e4;0 1e5;2800 1e5;2800 1e5;1000 1e5...
%     ;1500 1e5;400 9.93e4;1.9e4 12e4;1.09e4 1.052e5;7000 1e5;1e4 1.06e5;1.08e4 1.035e5;...
%     0.6e4 10.2e4;2200 9.45e4;3e4 1.3e5;2.1e4 1.19e5;5000 1e5;1000 9.5e4;4e4 1.4e5;...
%     1e4 1.2e5;3500 1e5;500 1e5; 6.4e4 1.59e5];
% rdlisten2 = [1.429e5 2.441e5;1e5 2e5;1e5 2e5;1e5 2.1e5;1e5 2.02e5;1e5 2e5;...
%     1.1e5 2.1e5;1e5 2e5;1e5 2e5;1.1e5 2.2e5;1e5 2.2e5;1e5 2.2e5;1.4e5 2.5e5;...
%     1.1e5 2.2e5;1e5 2.1e5;1e5 2.1e5;1e5 2.1e5;1.3e5 2.4e5;1.5e5 2.6e5;1.1e5 2.1e5;...
%     1.1e5 2.1e5;1.7e5 2.8e5;1.2e5 2.3e5;1e5 2.1e5;9.4e4 1.94e5; 1.65e5 2.7e5]; 
% sync3 = [4.574e5 5.542e5;2.04e5 2.96e5;2.15e5 3.1e5;2.2e5 3.16e5;2.1e5 3.1e5...
%     ;2.12e5 3.1e5;2.29e5 3.22e5;2.1e5 3.2e5;2.08e5 3.01e5;2.2e5 3.3e5;2.45e5 3.5e5;...
%     2.2e5 3.3e5;3e5 4.1e5;2.2e5 3.2e5;2.4e5 3.4e5;2.2e5 3.2e5; 2.1e5 3.1e5;2.4e5 3.4e5;...
%     2.7e5 3.7e5;2.1e5 3.2e5;2.1e5 3.1e5;2.9e5 3.9e5;2.3e5 3.3e5;2.1e5 3.2e5;...
%     2.2e5 3.2e5; 2.7e5 3.7e5];
% PTB4 = [5.64e5 1.72e6;3.29e5 1.48e6;3.575e5 1.531e6;3.5e5 1.5e6;3.34e5 1.45e6;...
%     3.3e5 1.5e6;3.5e5 1.56e6;3.4e5 1.6e6;5e5 1.75e6;3.8e5 1.52e6;3.7e5 1.59e6;...
%     3.5e5 1.47e6;4.3e5 1.62e6;3.8e5 1.67e6;3.95e5 1.6e6;3.6e5 1.52e6;3.4e5 1.72e6;...
%     3.7e5 1.59e6;4e5 1.62e6;3.5e5 1.57e6;3.5e5 1.63e6;4.1e5 1.68e6;3.6e5 1.6e6;...
%     3.6e5 1.72e6;3.4e5 1.512e6;4.1e5 1.61e6];

% key in the 4 index from the figure for each subject: it's the index for the latency but NOT the latency itself
% idx = [355,504,1029;433,583,1177;364,514,1073;720,870,1469;258,408,1012;379,529,1128;261,409,842;...
%     374,935,1377;357,507,1108;191,269,610;371,523,1130;341,495,1084;419,569,1168;474,624,1188;519,671,1259;...
%     454,604,1228;367,516,1106;272,421,946;225,360,875;367,516,1115;303,462,1049;239,389,989;343,493,1057;...
%     0,0,0;384,534,1134]; 

% Check the preprocessed data (clean_raw_data) and find the start and end of 
% the localizer trials for each participant
raw_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/preprocessing';
raw_files = dir(fullfile(raw_path,'*512.set'));
raw_name = {raw_files.name};

preprocessed_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/preprocessed';
segmentation_files = dir(fullfile(preprocessed_path,'*dipfit.set'));
segmentation_name = {segmentation_files.name};

for nsub = 1:length(segmentation_name)
    tempEEGp = segmentation_name{nsub};
    tempEEGr = raw_name{nsub};
    EEGp = pop_loadset('filename',tempEEGp ,'filepath', preprocessed_path);
    EEGr = pop_loadset('filename',tempEEGr ,'filepath', raw_path);
    EEGr.data = EEGr.data(:,[find(EEGp.etc.clean_sample_mask == 1)]);
    if nsub < 6
       sound = EEGr.nbchan - 32 + 7; % AIB7
       tap = EEGr.nbchan - 32 + 8; % AIB8
    elseif nsub > 5 && nsub < 9
       sound = EEGr.nbchan - 32 + 7; % AIB7
       tap = EEGr.nbchan - 32 + 5; % AIB5
    elseif nsub > 8
       sound = EEGr.nbchan - 32 + 2; % AIB2
       tap = EEGr.nbchan - 32 + 1; % AIB1
    end
    figure; plot(EEGr.data([sound,tap],:)')
end

%% get the tap data
% match data length after clean_rawdata to ensure that we are looking at
% the right signal
% be careful! other subfields in EEG do not really mean anything ONLY USE
% THE EEG.data and EEG.times to get the localizer series
clear 
close all
clc
tap1 = [2500 9e4;1000 1e5;1000 1e5;1000 9.8e4;2700 1e5;2.7e4 9.5e4;1000 7.2e4;...
    1000 1e5;1000 9.92e4;1000 6.5e4;1.07e4 1.05e5;7000 1.02e5;1e4 1.08e5;...
    1.08e4 1.04e5;1000 1.02e5;2200 9.42e4;3e4 1.2e5;1.46e4 1.01e5;1000 6.1e4;...
    1000 9.5e4;4e4 1.4e5;1e4 1.2e5;1000 1e5;1000 9.5e4;6.4e4 1.6e5];
sync3 = [1.8e5 2.624e5;2.16e5 3.1e5;2.22e5 3.16e5;2.13e5 3.07e5;2.1e5 3.1e5;...
    2.25e5 3.3e5;1.72e5 2.56e5;2e5 3.02e5;2.3e5 3.3e5;1.05e5 1.55e5;2.31e5 3.24e5;...
    3e5 3.94e5;2.265e5 3.2e5;2.43e5 3.36e5;2.22e5 3.18e5;2.16e5 3.1e5;2.2e5 3.2e5;...
    2.34e5 3.14e5;1.4e5 2.2e5;2.1e5 3.1e5;2.92e5 3.86e5;2.2e5 3.3e5;2.1e5 3.1e5;...
    2.2e5 3.2e5;2.7e5 3.7e5];

raw_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/trigger_channels';
raw_files = dir(fullfile(raw_path,'*triggers.set'));
raw_name = {raw_files.name};

preprocessed_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/preprocessed';
segmentation_files = dir(fullfile(preprocessed_path,'*dipfit.set'));
segmentation_name = {segmentation_files.name};

for nsub = 1:length(segmentation_name)
    tempEEGp = segmentation_name{nsub};
    tempEEGr = raw_name{nsub};
    EEGp = pop_loadset('filename',tempEEGp ,'filepath', preprocessed_path);
    EEGr = pop_loadset('filename',tempEEGr ,'filepath', raw_path);
    EEGr.data = EEGr.data(:,[find(EEGp.etc.clean_sample_mask == 1)]);
%     if nsub < 6
%        sound = EEGr.nbchan - 32 + 7; % AIB7
%        tap = EEGr.nbchan - 32 + 8; % AIB8
%     elseif nsub > 5 && nsub < 9
%        sound = EEGr.nbchan - 32 + 7; % AIB7
%        tap = EEGr.nbchan - 32 + 5; % AIB5
%     elseif nsub > 8
%        sound = EEGr.nbchan - 32 + 2; % AIB2
%        tap = EEGr.nbchan - 32 + 1; % AIB1
%     end
%    figure; plot(EEGr.data([sound,tap],:)')
    EEG_tap = pop_select(EEGr,'point',tap1(nsub,:));
    EEG_SMS = pop_select(EEGr,'point',sync3(nsub,:));
    Tap{nsub} = EEG_tap.data;
    Tap_t{nsub} = EEG_tap.times;
    SMS{nsub} = EEG_SMS.data;
    SMS_t{nsub} = EEG_SMS.times; 
    clear EEG_tap EEG_SMS EEGr EEGp tempEEGp tempEEGr
end
save Tap1 Tap Tap_t
save sync3 SMS SMS_t

%%
clear
close all

tap1 = [2500 9e4;1000 1e5;1000 1e5;1000 9.8e4;2700 1e5;2.7e4 9.5e4;1000 7.2e4;...
    1000 1e5;1000 9.92e4;1000 6.5e4;1.07e4 1.05e5;7000 1.02e5;1e4 1.08e5;...
    1.08e4 1.04e5;1000 1.02e5;2200 9.42e4;3e4 1.2e5;1.46e4 1.01e5;1000 6.1e4;...
    1000 9.5e4;4e4 1.4e5;1e4 1.2e5;1000 1e5;1000 9.5e4;6.4e4 1.6e5];
rdlisten2 = [9e4 1.8e5;1e5 2e5;1e5 2.1e5;1.05e5 2.05e5;1e5 2e5;1e5 2.1e5;...
    7.8e4 1.58e5;1e5 2e5;1.1e5 2.2e5;6.5e4 9.3e4;1.15e5 2.12e5;1.44e5 2.38e5;...
    1.14e5 2.12e5;1.13e5 2.1e5;1.08e5 2.06e5;1.06e5 2.06e5;1.2e5 2.2e5;...
    1.4e5 2.24e5;6.4e4 1.35e5;1.1e5 2.1e5;1.77e5 2.73e5;1.2e5 2.2e5;...
    1e5 2.1e5;9.5e4 1.93e5;1.6e5 2.7e5];
sync3 = [1.8e5 2.624e5;2.16e5 3.1e5;2.22e5 3.16e5;2.13e5 3.07e5;2.1e5 3.1e5;...
    2.25e5 3.3e5;1.72e5 2.56e5;2e5 3.02e5;2.3e5 3.3e5;1.05e5 1.55e5;2.31e5 3.24e5;...
    3e5 3.94e5;2.265e5 3.2e5;2.43e5 3.36e5;2.22e5 3.18e5;2.16e5 3.1e5;2.2e5 3.2e5;...
    2.34e5 3.14e5;1.4e5 2.2e5;2.1e5 3.1e5;2.92e5 3.86e5;2.2e5 3.3e5;2.1e5 3.1e5;...
    2.2e5 3.2e5;2.7e5 3.7e5];

%
segmentation_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/preprocessed';
segmentation_files = dir(fullfile(segmentation_path,'*dipfit.set'));
segmentation_name = {segmentation_files.name};
spontap_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/SMT';
rdlisten_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/rdlisten';
sync_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/sync';

for nsub = 1:length(segmentation_name)
    tempEEG = segmentation_name{nsub};
    parts = cellstr(split(tempEEG,'.'));
    EEG0 = pop_loadset('filename',tempEEG ,'filepath', segmentation_path);
    EEG0 = eeg_checkset(EEG0);
    
    EEG1 = pop_select(EEG0,'point',tap1(nsub,:));
    EEG1.setname = char(strcat(parts(1),'_tap1'));
    filename = EEG1.setname;
    EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',spontap_path);
    EEG1.setname = char(strcat(parts(1),'_tap1_e'));
    filename = EEG1.setname;
    EEG1 = pop_epoch( EEG1, {  'Tap'  }, [-0.3         0.5]);
    EEG1 = pop_rmbase( EEG1, [-100         -50]);
    EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',spontap_path);

%     EEG2 = pop_select(EEG0,'point',rdlisten2(nsub,:));
%     EEG2.setname = char(strcat(parts(1),'_rdlisten2'));
%     filename = EEG2.setname;
%     EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',rdlisten_path);
%     EEG2.setname = char(strcat(parts(1),'_rdlisten2_e'));
%     filename = EEG2.setname;
%     EEG2 = pop_epoch( EEG2, {  'WB'  }, [-0.3         0.5]);
%     EEG2 = pop_rmbase( EEG2, [-100          -50]);
%     EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',rdlisten_path);
%     
%     EEG3 = pop_select(EEG0,'point',sync3(nsub,:));
%     EEG3.setname = char(strcat(parts(1),'_sync3s'));
%     filename = EEG3.setname;
%     EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',sync_path);
%     EEG3.setname = char(strcat(parts(1),'_sync3s_e'));
%     filename = EEG3.setname;
%     EEG3 = pop_epoch( EEG3, {  'WB'  }, [-0.3         0.5]);
%     EEG3 = pop_rmbase(EEG3, [-100          -50]);
%     EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',sync_path);
%     
%     EEG4 = pop_select(EEG0,'point',sync3(nsub,:));
%     EEG4.setname = char(strcat(parts(1),'_sync3t'));
%     filename = EEG4.setname;
%     EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',sync_path);
%     EEG4.setname = char(strcat(parts(1),'_sync3t_e'));
%     filename = EEG4.setname;
%     EEG4 = pop_epoch( EEG4, {  'Tap'  }, [-0.3         0.5]);
%     EEG4 = pop_rmbase(EEG4, [-100          -50]);
%     EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',sync_path);
    clear latency tap1_e rdlisten_s rdlisten_e sync_s sync_e
end

%% Epoch for PTB
% Epoch BL, PB, IB, Tap phases in Duple and Triple conditions 
segmentation_path = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/preprocessed';
segmentation_files = dir(fullfile(segmentation_path,'*dipfit.set'));
segmentation_name = {segmentation_files.name};
epoch_path = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/preprocessed/epoch/phases_no_bc';

% s11, s20 don't have tap trials 
for nsub = 20:length(segmentation_name)
    tempEEG = segmentation_name{nsub};
    parts = cellstr(split(tempEEG,'.'));
    EEG0 = pop_loadset('filename',tempEEG ,'filepath', segmentation_path);
    EEG_duple = pop_rmdat( EEG0, {'Duple'},[-2 26] ,0); % select the duple and triple events and do epoch on them, respectively
    EEG_triple = pop_rmdat( EEG0, {'Triple'},[-2 26] ,0);
    
    EEG_duple_e = pop_epoch( EEG_duple, {  'Duple'  }, [-1         25]);
    EEG_duple_e.setname = char(strcat(parts(1),'_duple_e'));
    EEG_duple_e = pop_rmbase( EEG_duple_e, [-50   0]);
    filename = EEG_duple_e.setname;
    EEG_duple_e = pop_saveset(EEG_duple_e,'filename',filename,'filepath',epoch_path);
    
    EEG_triple_e = pop_epoch( EEG_triple, {  'Triple'  }, [-1         25]);
    EEG_triple_e.setname = char(strcat(parts(1),'_triple_e'));
    EEG_triple_e = pop_rmbase( EEG_triple_e, [-50   0]);
    filename = EEG_triple_e.setname;
    EEG_triple_e = pop_saveset(EEG_triple_e,'filename',filename,'filepath',epoch_path);
    
    % Duple 
    EEG1 = pop_epoch( EEG_duple, {  'BL'  }, [-0.6         4.99]);
    EEG1.setname = char(strcat(parts(1),'_duple_BL_e'));
%    EEG1 = pop_rmbase( EEG1, [-50   0]);
    filename = EEG1.setname;
    EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',epoch_path);

    EEG2 = pop_epoch( EEG_duple, {  'PB'  }, [-0.6         4.99]);
    EEG2.setname = char(strcat(parts(1),'_duple_PB_e'));
%    EEG2 = pop_rmbase( EEG2, [-50   0]);
    filename = EEG2.setname;
    EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',epoch_path);
    
    EEG3 = pop_epoch( EEG_duple, {  'IB'  }, [-0.6         4.99]);
    EEG3.setname = char(strcat(parts(1),'_duple_IB_e'));
%    EEG3 = pop_rmbase( EEG3, [-50   0]);
    filename = EEG3.setname;
    EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',epoch_path);

    EEG4 = pop_epoch( EEG_duple, {  'IB'  }, [4.4         9.99]);
    EEG4.setname = char(strcat(parts(1),'_duple_tap_e'));
%    EEG4 = pop_rmbase( EEG4, [5000   5050]);
    filename = EEG4.setname;
    EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',epoch_path);
    
    EEG5 = pop_epoch( EEG_duple, {  'IB'  }, [9.4         14.99]); % cut 5 seconds after the tapping 
    EEG5.setname = char(strcat(parts(1),'_duple_aftertap_e'));
%    EEG5 = pop_rmbase( EEG5, [10000   10050]);
    filename = EEG5.setname;
    EEG5 = pop_saveset(EEG5,'filename',filename,'filepath',epoch_path);
    clear EEG1 EEG2 EEG3 EEG4 EEG5
% Triple
    EEG1 = pop_epoch( EEG_triple, {  'BL'  }, [-0.6         4.99]);
    EEG1.setname = char(strcat(parts(1),'_triple_BL_e'));
%    EEG1 = pop_rmbase( EEG1, [-50   0]);
    filename = EEG1.setname;
    EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',epoch_path);

    EEG2 = pop_epoch( EEG_triple, {  'PB'  }, [-0.6         4.99]);
    EEG2.setname = char(strcat(parts(1),'_triple_PB_e'));
%    EEG2 = pop_rmbase( EEG2, [-50   0]);
    filename = EEG2.setname;
    EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',epoch_path);

    EEG3 = pop_epoch( EEG_triple, {  'IB'  }, [-0.6         4.99]);
    EEG3.setname = char(strcat(parts(1),'_triple_IB_e'));
%    EEG3 = pop_rmbase( EEG3, [-50   0]);
    filename = EEG3.setname;
    EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',epoch_path);

    EEG4 = pop_epoch( EEG_triple, {  'IB'  }, [4.4         9.99]);
    EEG4.setname = char(strcat(parts(1),'_triple_tap_e'));
%    EEG4 = pop_rmbase( EEG4, [5000   5050]);
    filename = EEG4.setname;
    EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',epoch_path);
    
    EEG5 = pop_epoch( EEG_triple, {  'IB'  }, [9.4         14.99]); % cut 5 seconds after the tapping 
    EEG5.setname = char(strcat(parts(1),'_triple_aftertap_e'));
%    EEG5 = pop_rmbase( EEG5, [10000   10050]);
    filename = EEG5.setname;
    EEG5 = pop_saveset(EEG5,'filename',filename,'filepath',epoch_path);
    clear EEG1 EEG2 EEG3 EEG4 EEG5
end

%% Epoch for PTB - 5 s
% Epoch BL, PB, IB, Tap phases in Duple and Triple conditions 
segmentation_path = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/preprocessed';
segmentation_files = dir(fullfile(segmentation_path,'*dipfit.set'));
segmentation_name = {segmentation_files.name};
epoch_path = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/preprocessed/epoch/5sphases';

% s11, s20 don't have tap trials 
for nsub = 1:length(segmentation_name)
    tempEEG = segmentation_name{nsub};
    parts = cellstr(split(tempEEG,'.'));
    EEG0 = pop_loadset('filename',tempEEG ,'filepath', segmentation_path);
    EEG_duple = pop_rmdat( EEG0, {'Duple'},[-2 26] ,0); % select the duple and triple events and do epoch on them, respectively
    EEG_triple = pop_rmdat( EEG0, {'Triple'},[-2 26] ,0);
    
    % Duple 
    EEG1 = pop_epoch( EEG_duple, {  'BL'  }, [0 5]);
    EEG1.setname = char(strcat(parts(1),'_duple_BL_e'));
%    EEG1 = pop_rmbase( EEG1, [-50   0]);
    filename = EEG1.setname;
    EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',epoch_path);

    EEG2 = pop_epoch( EEG_duple, {  'PB'  }, [0 5]);
    EEG2.setname = char(strcat(parts(1),'_duple_PB_e'));
%    EEG2 = pop_rmbase( EEG2, [-50   0]);
    filename = EEG2.setname;
    EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',epoch_path);
    
    EEG3 = pop_epoch( EEG_duple, {  'IB'  }, [0 5]);
    EEG3.setname = char(strcat(parts(1),'_duple_IB_e'));
%    EEG3 = pop_rmbase( EEG3, [-50   0]);
    filename = EEG3.setname;
    EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',epoch_path);

    EEG4 = pop_epoch( EEG_duple, {  'IB'  }, [5 10]);
    EEG4.setname = char(strcat(parts(1),'_duple_tap_e'));
%    EEG4 = pop_rmbase( EEG4, [5000   5050]);
    filename = EEG4.setname;
    EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',epoch_path);
    
    clear EEG0 EEG1 EEG2 EEG3 EEG4
% Triple
    EEG1 = pop_epoch( EEG_triple, {  'BL'  }, [0 5]);
    EEG1.setname = char(strcat(parts(1),'_triple_BL_e'));
%    EEG1 = pop_rmbase( EEG1, [-50   0]);
    filename = EEG1.setname;
    EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',epoch_path);

    EEG2 = pop_epoch( EEG_triple, {  'PB'  }, [0 5]);
    EEG2.setname = char(strcat(parts(1),'_triple_PB_e'));
%    EEG2 = pop_rmbase( EEG2, [-50   0]);
    filename = EEG2.setname;
    EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',epoch_path);

    EEG3 = pop_epoch( EEG_triple, {  'IB'  }, [0 5]);
    EEG3.setname = char(strcat(parts(1),'_triple_IB_e'));
%    EEG3 = pop_rmbase( EEG3, [-50   0]);
    filename = EEG3.setname;
    EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',epoch_path);

    EEG4 = pop_epoch( EEG_triple, {  'IB'  }, [5         10]);
    EEG4.setname = char(strcat(parts(1),'_triple_tap_e'));
%    EEG4 = pop_rmbase( EEG4, [5000   5050]);
    filename = EEG4.setname;
    EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',epoch_path);
    
    clear EEG1 EEG2 EEG3 EEG4 EEG_duple EEG_triple
end

%% Epoch for the strong beats 
clear
close all
clc
% Epoch SB, WB in both Duple and Triple conditions 
segmentation_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/preprocessed';
segmentation_files = dir(fullfile(segmentation_path,'*dipfit.set'));
segmentation_name = {segmentation_files.name};
epoch_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/preprocessed/epoch/SB_WB';

% s11, s20 don't have tap trials 
for nsub = 1:length(segmentation_name)
    tempEEG = segmentation_name{nsub};
    parts = cellstr(split(tempEEG,'.'));
    EEG0 = pop_loadset('filename',tempEEG ,'filepath', segmentation_path);
    EEG_d = pop_rmdat( EEG0, {'Duple'},[-1 25] ,0); % select the SB and WB only in duple trials 
    EEG_t = pop_rmdat( EEG0, {'Triple'},[-1 25] ,0); % select the SB and WB only in duple trials 

    EEG1 = pop_rmdat( EEG_d, {'PB'},[-1 6] ,0); % select the SB and WB only in PB phase    
    EEG1 = pop_epoch( EEG1, {  'SB'  }, [-0.5         1.5]);
    EEG1.setname = char(strcat(parts(1),'_duple_SB_e'));
%    EEG1 = pop_rmbase( EEG1, [-50   0]);
    filename = EEG1.setname;
    EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',epoch_path);
    
    EEG2 = pop_rmdat( EEG_t, {'PB'},[-1 6] ,0); % select the SB and WB only in PB phase    
    EEG2 = pop_epoch( EEG2, {  'SB'  }, [-0.5         1.5]);
    EEG2.setname = char(strcat(parts(1),'_triple_SB_e'));
%    EEG2 = pop_rmbase( EEG2, [-50   0]);
    filename = EEG2.setname;
    EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',epoch_path);
end

%% Change Epoch length for the localizer
clear
close all
clc

segmentation_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/SMT/old';
segmentation_files = dir(fullfile(segmentation_path,'*tap1.set'));
segmentation_name = {segmentation_files.name};
epoch_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/SMT';

% s11, s20 don't have tap trials 
for nsub = 1:length(segmentation_name)
    tempEEG = segmentation_name{nsub};
    parts = cellstr(split(tempEEG,'.'));
    EEG0 = pop_loadset('filename',tempEEG ,'filepath', segmentation_path);
    EEG = pop_epoch( EEG0, {  'Tap'  }, [-0.3         0.5]);
    EEG = pop_rmbase(EEG, [-100          -50]);
    EEG.setname = char(strcat(parts(1),'_e'));
    filename = EEG.setname;
    EEG = pop_saveset(EEG,'filename',filename,'filepath',epoch_path);
end