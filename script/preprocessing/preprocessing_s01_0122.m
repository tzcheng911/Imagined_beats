clear all
close all
clc
cd /data/projects/zoe/ImaginedBeats/real_exp/s01
datapath  = '/data/projects/zoe/ImaginedBeats/real_exp/s01';
%%
eeglab
rmpath('/data/common/matlab/eeglab/plugins/tmullen-cleanline-09d199104a42/external/bcilab_partial/dependencies/PropertyGrid-2010-09-16-mod/')
rmpath('/data/common/matlab/eeglab/plugins/measure_projection/dependency/propertyGrid/')                                                   % Shado
addpath('/data/projects/zoe/ImaginedBeats/script/preprocessing')
load('s011test.mat');
%% Tag the event codes by trigger pulses: only 0, 1 and 2
clear trials_event events tap_events trigger_events phases_event unaccs_events
    figure;
    plot(EEG.data(end-32+8,:)); % trigger pulse
    grid on
    title('Trigger pulse');
    figure;
    plot(EEG.data(end-32+7,:)); % tapping data
    grid on
    title('Tapping data');
    % Find peaks for all the triggers & tapping  

    trigger_threshold = input('trigger_threshold:','s');
    trigger_threshold = str2num(trigger_threshold);
    tap_threshold = input('tap_threshold:','s');
    tap_threshold = str2num(tap_threshold);
    IMB_start = input('IMB_start:','s');
    IMB_start = str2num(IMB_start);
    trigger_events = processIBTrigger_z(EEG.times/1000,EEG.data(end-32+8,:),'threshold'...
        ,trigger_threshold,'burstduration',.113,'eventtype',{'1','0'},'eventduration',[.13 .04]);
    tap_events = processIBTrigger_z(EEG.times/1000,EEG.data(end-32+7,:),'threshold',tap_threshold, ...
         'eventtype',{'2'});
     EEG.etc.triggerthreshold = trigger_threshold; % 1e5
     EEG.etc.tapthreshold = tap_threshold; % 1.9e5 sacrifice many localizer data

     events = [tap_events,trigger_events]; 
for j = 1:length(events)
    [events(j).type] =  char(events(j).type);
end

%% Tag the IMB part with other more detailed event code: BL, SBL, IM, Duple, Triple
    IMB_trigger_events = processIBTrigger_z(EEG.times/1000,EEG.data(end-32+8,IMB_start:end),'threshold'...
        ,trigger_threshold,'burstduration',.113,'eventtype',{'1','0'},'eventduration',[.13 .04]);
    for n = 1:length(IMB_trigger_events) 
        IMB_trigger_events(n).latency = IMB_trigger_events(n).latency + IMB_start;
    end
ntrial = length(result);
nphase = ntrial*3;
nunaccs = nphase*6; 
%Find the first peak of each trial
trials_event = struct();
trials_event.duration = 1;

count1 = 1;
for k = 1:ntrial
    switch result(k,1) 
        case 1
            trials_event(k).type = char({'Duple'});
        case 2
            trials_event(k).type = char({'Triple'});
    end
    trials_event(k).duration = 1;
    trials_event(k).latency = IMB_trigger_events(count1).latency;
    count1 = count1 +36;
end

phases_event = struct();
phases_event.duration = 1;
phases = [];
count2 = 1;
for l = 1:nphase
    switch mod(l,3)
        case 1
            phases_event(l).type = char({'BL'});
        case 2
            phases_event(l).type = char({'SBL'});
        case 0
            phases_event(l).type = char({'IM'});
    end
    phases_event(l).duration = 1;
    phases_event(l).latency = IMB_trigger_events(count2).latency;
    count2 = count2 +12;
end

%%
[EEG.event] = [events,trials_event,phases_event];
EEG = pop_saveset(EEG);

%% Preprocessing until trimoutlier
     EEG = pop_select( EEG, 'channel',{'A1' 'A2' 'A3' 'A4' 'A5' 'A6' 'A7' 'A8' 'A9' 'A10' 'A11' 'A12' 'A13' 'A14' 'A15' 'A16' 'A17' 'A18' 'A19' 'A20' 'A21' 'A22' 'A23' 'A24' 'A25' 'A26' 'A27' 'A28' 'A29' 'A30' 'A31' 'A32' 'B1' 'B2' 'B3' 'B4' 'B5' 'B6' 'B7' 'B8' 'B9' 'B10' 'B11' 'B12' 'B13' 'B14' 'B15' 'B16' 'B17' 'B18' 'B19' 'B20' 'B21' 'B22' 'B23' 'B24' 'B25' 'B26' 'B27' 'B28' 'B29' 'B30' 'B31' 'B32' 'C1' 'C2' 'C3' 'C4' 'C5' 'C6' 'C7' 'C8' 'C9' 'C10' 'C11' 'C12' 'C13' 'C14' 'C15' 'C16' 'C17' 'C18' 'C19' 'C20' 'C21' 'C22' 'C23' 'C24' 'C25' 'C26' 'C27' 'C28' 'C29' 'C30' 'C31' 'C32' 'D1' 'D2' 'D3' 'D4' 'D5' 'D6' 'D7' 'D8' 'D9' 'D10' 'D11' 'D12' 'D13' 'D14' 'D15' 'D16' 'D17' 'D18' 'D19' 'D20' 'D21' 'D22' 'D23' 'D24' 'D25' 'D26' 'D27' 'D28' 'D29' 'D30' 'D31' 'D32' 'E1' 'E2' 'E3' 'E4' 'E5' 'E6' 'E7' 'E8' 'E9' 'E10' 'E11' 'E12' 'E13' 'E14' 'E15' 'E16' 'E17' 'E18' 'E19' 'E20' 'E21' 'E22' 'E23' 'E24' 'E25' 'E26' 'E27' 'E28' 'E29' 'E30' 'E31' 'E32' 'F1' 'F2' 'F3' 'F4' 'F5' 'F6' 'F7' 'F8' 'F9' 'F10' 'F11' 'F12' 'F13' 'F14' 'F15' 'F16' 'F17' 'F18' 'F19' 'F20' 'F21' 'F22' 'F23' 'F24' 'F25' 'F26' 'F27' 'F28' 'F29' 'F30' 'F31' 'F32' 'G1' 'G2' 'G3' 'G4' 'G5' 'G6' 'G7' 'G8' 'G9' 'G10' 'G11' 'G12' 'G13'});
     EEG = pop_eegfiltnew(EEG, 45,0.1,16896,0,[],1);     
     EEG = pop_chanedit(EEG);
     EEG = pop_trimOutlier(EEG);
     EEG = pop_reref( EEG, []);
     EEG.setname = 's01_IMB_cleaned.set';
     EEG.filename = EEG.setname;
     EEG = pop_saveset(EEG,'filename',char(EEG.setname),'filepath',datapath);

%% Inspect the data: confirm the event markers is correct and the data is clean enough
%% Preprocessing after cleaning the data
     icadatasetFile = 's01_IMB_cleaned.set';
     parts = cellstr(split(icadatasetFile,'.'));
     EEG = pop_loadset('filename',icadatasetFile ,'filepath', datapath);
     EEG = eeg_checkset( EEG );    
     EEG1 = EEG;
     EEG = clean_rawdata(EEG1, 'off', 'off', 0.75, 'off', 5, 0.25);
     %EEG = pop_select( EEG, 'nochannel',{'C24'}); % remove the bad channels based on experiment notes
     EEG = pop_runica(EEG, 'icatype', 'binica', 'extended',1);
     EEG.setname = strcat(parts(1),'_binica');
     filename = char(EEG.setname);
     EEG = pop_saveset(EEG,'filename',filename,'filepath',datapath);
     EEG = pop_dipfit_settings( EEG, 'hdmfile','/data/common/matlab/eeglab/plugins/dipfit2.3/standard_BEM/standard_vol.mat',...
    'coordformat','MNI','mrifile','/data/common/matlab/eeglab/plugins/dipfit2.3/standard_BEM/standard_mri.mat','chanfile',...
    '/data/common/matlab/eeglab/plugins/dipfit2.3/standard_BEM/elec/standard_1005.elc','coord_transform',...
    [-0.015 -22 -15 0.34907 0 -1.571 1050 990.1 990.1165] ,'chansel',[1:EEG.nbchan] ); % change the parameters to better fit the channel and headmodel
     EEG = pop_multifit(EEG, [1:EEG.nbchan] ,'threshold',100,'plotopt',{'normlen' 'on'});
     EEG = pop_saveset( EEG, 'filename','s01_IMB_cleaned_binica_dipfit.set','filepath','/data/projects/zoe/ImaginedBeats/real_exp/s01');

%% Sementation
clear all
close all
clc

filepath = '/data/projects/zoe/ImaginedBeats/real_exp/s01';
EEG0 = pop_loadset('filename','s01_IMB_cleaned_binica_dipfit_icap.set' ,'filepath', filepath);

EEG1 = pop_select( EEG0, 'point',[1.2e4 1.1e5] );
EEG1.setname='s01_IMB_cleaned_binica_dipfit_tap1';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_select( EEG0, 'point',[1.429e5 2.441e5] );
EEG2.setname='s01_IMB_cleaned_binica_dipfit_rdlisten2';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_select( EEG0, 'point',[4.574e5 5.542e5] );
EEG3.setname='s01_IMB_cleaned_binica_dipfit_sync3';
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_select( EEG0, 'point',[5.64e5 1.72e5] );
EEG4.setname='s01_IMB_cleaned_binica_dipfit_PTB_4';
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

% tap
clear all
filepath = '/data/projects/zoe/ImaginedBeats/real_exp/s01/';
EEG = pop_loadset('filename','s01_IMB_cleaned_binica_dipfit_tap1.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '2'  }, [-0.3         0.5], 'newname', ...
    's01_IMB_cleaned_binica_dipfit_tap1_e', 'epochinfo', 'yes');
EEG.setname='s01_IMB_cleaned_binica_dipfit_tap1_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% rd listen
clear all
filepath = '/data/projects/zoe/ImaginedBeats/real_exp/s01/';
EEG = pop_loadset('filename','s01_IMB_cleaned_binica_dipfit_rdlisten2.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    's01_IMB_cleaned_binica_dipfit_rdlisten2_e', 'epochinfo', 'yes');
EEG.setname='s01_IMB_cleaned_binica_dipfit_rdlisten2_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - listen
clear all
filepath = '/data/projects/zoe/ImaginedBeats/real_exp/s01/';
EEG = pop_loadset('filename','s01_IMB_cleaned_binica_dipfit_sync3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    's01_IMB_cleaned_binica_dipfit_sync3listen_e', 'epochinfo', 'yes');
EEG.setname='s01_IMB_cleaned_binica_dipfit_sync3listen_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - tap
clear all
filepath = '/data/projects/zoe/ImaginedBeats/real_exp/s01/';
EEG = pop_loadset('filename','s01_IMB_cleaned_binica_dipfit_sync3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '2'  }, [-0.3         0.5], 'newname', ...
    's01_IMB_cleaned_binica_dipfit_sync3tap_e', 'epochinfo', 'yes');
EEG.setname='s01_IMB_cleaned_binica_dipfit_sync3tap_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);
     