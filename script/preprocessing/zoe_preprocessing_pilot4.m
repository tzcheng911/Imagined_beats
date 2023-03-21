clear all
close all
clc

%%
eeglab
rmpath('/data/common/matlab/eeglab/plugins/tmullen-cleanline-09d199104a42/external/bcilab_partial/dependencies/PropertyGrid-2010-09-16-mod/')
rmpath('/data/common/matlab/eeglab/plugins/measure_projection/dependency/propertyGrid/')                                                   % Shado

%% Get list of subjects, parse out their condition and position
dataDir = '/data/projects/zoe/ImaginedBeats/pilot/xdffile/pilot_4';
%outputDir = '/data/projects/zoe/ImaginedBeats/pilot/EEGdata/ica_before_epoch/pilot_4/ica';
outputDir = '/data/projects/zoe/ImaginedBeats/pilot/setfile';

icaDir = '/data/projects/zoe/ImaginedBeats/pilot/EEGdata/ica_before_epoch/pilot_4/ica';
matDir = '/data/projects/zoe/ImaginedBeats/pilot/matFiles/pilot_4';
sfpDir = '/data/projects/zoe/ImaginedBeats/pilot/sfpfile';

files = dir(fullfile(dataDir,'*.set'));
icafiles = dir(fullfile(icaDir,'*cleaned.set'));
matfiles = dir(fullfile(matDir,'*.mat'));
sfpfiles = dir(fullfile(sfpDir,'*.sfp'));

datasets = {files.name};
icadatasets = {icafiles.name};
matsets = {matfiles.name};
sfpsets = {sfpfiles.name};
cd '/data/projects/zoe/ImaginedBeats/pilot/xdffile/pilot_4';

%% Preprocessing until trimoutlier (require interactive decisions)
for iS = 1:length(datasets)
    datasetFile = datasets{iS};
    parts = cellstr(split(datasetFile,'.'));
    %EEG = pop_loadxdf(datasetFile , 'streamtype', 'EEG', 'exclude_markerstreams', {});
    EEG = pop_loadset('filename',datasetFile ,'filepath', dataDir);
    EEG.setname = parts(1);
    % Add event markers if the LSL marker stream is missing 
    if isempty(EEG.event)
    %load('/data/projects/zoe/ImaginedBeats/pilot/matFiles/pilot_4/kickdrum.mat');
    load(fullfile(matDir,matsets{iS}));
    nTrials = 40;
        for ntrial = 1:nTrials
            ninstrument = char(parts(1));
            ntempo = {'200';'300'};
            nmeter = {'duple';'triple'};
            condition{ntrial,:} = [ninstrument '_' num2str(result(ntrial,2)) 'bpm_' nmeter{result(ntrial,3)} '.wav'];
        end
        for i = 1:40
        EEG.event(i).type = condition{i,:};
        EEG.event(i).duration = 1;
        end
    end
    figure(1);
    plot(EEG.data(end-32+8,:)); % trigger pulse
    grid on
    title('Trigger pulse');
    figure(2);
    plot(EEG.data(end-32+1,:)); % tapping data
    grid on
    title('Tapping data');
    % Find peaks for all the triggers & tapping  

    trigger_threshold = input('trigger_threshold:','s');
    trigger_threshold = str2num(trigger_threshold);
    tap_threshold = input('tap_threshold:','s');
    tap_threshold = str2num(tap_threshold);
    trigger_events = processIBTrigger(EEG.times/1000,EEG.data(end-32+8,:),'threshold',trigger_threshold,'burstduration',.113,'eventtype',{'1','0'},'eventduration',[.13 .04]);
    tap_events = processIBTrigger(EEG.times/1000,EEG.data(end-32+1,:),'threshold',tap_threshold, ...
         'eventtype',{'2'});
events = [tap_events,trigger_events]; 
for j = 1:length(events)
    [events(j).type] =  char(events(j).type);
end

ntrial = length(EEG.event);
nphase = ntrial*3;
nunaccs = nphase*6; 
% Find the first peak of each trial
trials_event = [];
count1 = 1;
for k = 1:ntrial
    trials_event(k) = trigger_events(count1).latency;
    count1 = count1 +36;
end
trials_event = num2cell(trials_event);
[EEG.event.latency] = trials_event{:};

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
    phases_event(l).latency = trigger_events(count2).latency;
    count2 = count2 +12;
end

unaccs_events = [];
count3 = 2;
for m = 1:nunaccs
    unaccs_events(m).type = char('00');
    unaccs_events(m).latency = trigger_events(count3).latency;
    unaccs_events(m).duration = 1;
    count3 = count3 +2;
end

[EEG.event] = [EEG.event,events,phases_event,unaccs_events];
EEG = pop_saveset(EEG,'filename',['pilot4_' char(EEG.setname)],'filepath',outputDir);
end

%%
     EEG = pop_select( EEG, 'channel',{'A1' 'A2' 'A3' 'A4' 'A5' 'A6' 'A7' 'A8' 'A9' 'A10' 'A11' 'A12' 'A13' 'A14' 'A15' 'A16' 'A17' 'A18' 'A19' 'A20' 'A21' 'A22' 'A23' 'A24' 'A25' 'A26' 'A27' 'A28' 'A29' 'A30' 'A31' 'A32' 'B1' 'B2' 'B3' 'B4' 'B5' 'B6' 'B7' 'B8' 'B9' 'B10' 'B11' 'B12' 'B13' 'B14' 'B15' 'B16' 'B17' 'B18' 'B19' 'B20' 'B21' 'B22' 'B23' 'B24' 'B25' 'B26' 'B27' 'B28' 'B29' 'B30' 'B31' 'B32' 'C1' 'C2' 'C3' 'C4' 'C5' 'C6' 'C7' 'C8' 'C9' 'C10' 'C11' 'C12' 'C13' 'C14' 'C15' 'C16' 'C17' 'C18' 'C19' 'C20' 'C21' 'C22' 'C23' 'C24' 'C25' 'C26' 'C27' 'C28' 'C29' 'C30' 'C31' 'C32' 'D1' 'D2' 'D3' 'D4' 'D5' 'D6' 'D7' 'D8' 'D9' 'D10' 'D11' 'D12' 'D13' 'D14' 'D15' 'D16' 'D17' 'D18' 'D19' 'D20' 'D21' 'D22' 'D23' 'D24' 'D25' 'D26' 'D27' 'D28' 'D29' 'D30' 'D31' 'D32' 'E1' 'E2' 'E3' 'E4' 'E5' 'E6' 'E7' 'E8' 'E9' 'E10' 'E11' 'E12' 'E13' 'E14' 'E15' 'E16' 'E17' 'E18' 'E19' 'E20' 'E21' 'E22' 'E23' 'E24' 'E25' 'E26' 'E27' 'E28' 'E29' 'E30' 'E31' 'E32' 'F1' 'F2' 'F3' 'F4' 'F5' 'F6' 'F7' 'F8' 'F9' 'F10' 'F11' 'F12' 'F13' 'F14' 'F15' 'F16' 'F17' 'F18' 'F19' 'F20' 'F21' 'F22' 'F23' 'F24' 'F25' 'F26' 'F27' 'F28' 'F29' 'F30' 'F31' 'F32' 'G1' 'G2' 'G3' 'G4' 'G5' 'G6' 'G7' 'G8' 'G9' 'G10' 'G11' 'G12' 'G13'});
     %EEG = pop_resample( EEG, 250);
     EEG = pop_eegfiltnew(EEG, 45,1,1690,0,[],1);     
     EEG = pop_chanedit(EEG, 'load',{fullfile(sfpDir,sfpsets{2}) 'filetype' 'autodetect'});
     EEG0 = EEG;
     EEG = pop_trimOutlier(EEG);
     EEG = pop_reref( EEG, []);
     %EEG = pop_eegplot(EEG); % reject data by eyes
     EEG.setname = strcat(parts(1),'_cleaned');
     EEG = pop_saveset(EEG,'filename',char(EEG.setname),'filepath',outputDir);


%% Inspect the data: confirm the event markers is correct and the data is clean enough
%% Preprocessing after cleaning the data
cd /data/projects/zoe/ImaginedBeats/pilot/EEGdata/ica_before_epoch/pilot_4/ica
for iF = 1:length(icadatasets)
     icadatasetFile = icadatasets{iF};
     parts = cellstr(split(icadatasetFile,'.'));
     EEG = pop_loadset('filename',icadatasetFile ,'filepath', icaDir);
     EEG = eeg_checkset( EEG );    
     EEG1 = EEG;
     EEG = clean_rawdata(EEG1, 'off', 'off', 0.75, 'off', 5, 0.25);
     %EEG = pop_select( EEG, 'nochannel',{'C24'}); % remove the bad channels based on experiment notes
     EEG = pop_runica(EEG, 'icatype', 'binica', 'extended',1);
     EEG.setname = strcat(parts(1),'_binica');
     filename = char(EEG.setname);
     EEG = pop_saveset(EEG,'filename',filename,'filepath',outputDir);
end 
%%
     epoch_filename = strcat(parts(1),'binica_epoch');
     EEG = pop_epoch( EEG, {  }, [-1  16], 'newname', epoch_filename, 'epochinfo', 'yes');
     EEG = pop_rmbase( EEG, [-600 -100] ,[],[]);
     % EEG = pop_selectevent if need to remove any epoch
     EEG.setname = epoch_filename;
     EEG = pop_saveset(EEG,'filename',epoch_filename,'filepath',outputDir);
     