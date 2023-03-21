%% load the file
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer';
filename = 'localizer_Madison_ds.set';
EEG = pop_loadset('filename',filename ,'filepath', filepath);
EEG.setname = 'localizer_Madison';
EEG.etc.old = EEG; % save the original file 
    figure(1);
    plot(EEG.data(end-32+8,:)); % trigger pulse
    grid on
    title('Trigger pulse');
    figure(2);
    plot(EEG.data(end-32+7,:)-min(EEG.data(end-32+7,:))); % tapping data substract the min to make it positive
    grid on
    title('Tapping data');
    % Find peaks for all the triggers & tapping  

    trigger_threshold = input('trigger_threshold:','s'); %1e5
    trigger_threshold = str2num(trigger_threshold); 
    tap_threshold = input('tap_threshold:','s'); % 4747
    tap_threshold = str2num(tap_threshold);
    trigger_events = processIBTrigger_z(EEG.times/1000,EEG.data(end-32+8,:),'threshold',trigger_threshold,'burstduration',.113,'eventtype',{'0'},'eventduration',[.04]);
    tap_events = processIBTrigger_z(EEG.times/1000,EEG.data(end-32+7,:)-min(EEG.data(end-32+7,:)),'threshold',tap_threshold, ...
         'eventtype',{'2'});
events = [tap_events,trigger_events]; 
for j = 1:length(events)
    [events(j).type] =  char(events(j).type);
end

[EEG.event] = [EEG.event,events];

%% Visualize how good the calculation
close all
test_tap = 50*ones(1,length(EEG.data(end-32+1,:)));
test_tap([tap_events.latency]) = tap_threshold;
test_trigger = 50*ones(1,length(EEG.data(end-32+8,:)));
test_trigger([trigger_events.latency]) = 11e4;
figure(1);
plot(EEG.data(end-32+7,:)-min(EEG.data(end-32+7,:))); % tapping data
hold on 
plot(test_tap);
figure(2);
plot(EEG.data(end-32+8,:)); % trigger data
hold on 
plot(test_trigger);

%% preprocessing
EEG = pop_select( EEG, 'channel',{'A1' 'A2' 'A3' 'A4' 'A5' 'A6' 'A7' 'A8' 'A9' 'A10' 'A11' 'A12' 'A13' 'A14' 'A15' 'A16' 'A17' 'A18' 'A19' 'A20' 'A21' 'A22' 'A23' 'A24' 'A25' 'A26' 'A27' 'A28' 'A29' 'A30' 'A31' 'A32' 'B1' 'B2' 'B3' 'B4' 'B5' 'B6' 'B7' 'B8' 'B9' 'B10' 'B11' 'B12' 'B13' 'B14' 'B15' 'B16' 'B17' 'B18' 'B19' 'B20' 'B21' 'B22' 'B23' 'B24' 'B25' 'B26' 'B27' 'B28' 'B29' 'B30' 'B31' 'B32' 'C1' 'C2' 'C3' 'C4' 'C5' 'C6' 'C7' 'C8' 'C9' 'C10' 'C11' 'C12' 'C13' 'C14' 'C15' 'C16' 'C17' 'C18' 'C19' 'C20' 'C21' 'C22' 'C23' 'C24' 'C25' 'C26' 'C27' 'C28' 'C29' 'C30' 'C31' 'C32' 'D1' 'D2' 'D3' 'D4' 'D5' 'D6' 'D7' 'D8' 'D9' 'D10' 'D11' 'D12' 'D13' 'D14' 'D15' 'D16' 'D17' 'D18' 'D19' 'D20' 'D21' 'D22' 'D23' 'D24' 'D25' 'D26' 'D27' 'D28' 'D29' 'D30' 'D31' 'D32' 'E1' 'E2' 'E3' 'E4' 'E5' 'E6' 'E7' 'E8' 'E9' 'E10' 'E11' 'E12' 'E13' 'E14' 'E15' 'E16' 'E17' 'E18' 'E19' 'E20' 'E21' 'E22' 'E23' 'E24' 'E25' 'E26' 'E27' 'E28' 'E29' 'E30' 'E31' 'E32' 'F1' 'F2' 'F3' 'F4' 'F5' 'F6' 'F7' 'F8' 'F9' 'F10' 'F11' 'F12' 'F13' 'F14' 'F15' 'F16' 'F17' 'F18' 'F19' 'F20' 'F21' 'F22' 'F23' 'F24' 'F25' 'F26' 'F27' 'F28' 'F29' 'F30' 'F31' 'F32' 'G1' 'G2' 'G3' 'G4' 'G5' 'G6' 'G7' 'G8' 'G9' 'G10' 'G11' 'G12' 'G13'});
EEG = pop_eegfiltnew(EEG, 45,1,1690,0,[],1);     
EEG = pop_chanedit(EEG, 'load',{'861_113018_56_ImaginedBeatClemens.sfp' 'filetype' 'autodetect'},'delete',206:213);
EEG = pop_trimOutlier(EEG);
EEG = pop_reref( EEG, []);
EEG = clean_rawdata(EEG, 5, [0.25 0.75], 0.85, 4, 5, 0.25);
%%
%EEG = pop_select( EEG, 'nochannel',{'C24'}); % remove the bad channels based on experiment notes
EEG = pop_runica(EEG, 'icatype', 'binica', 'extended',1);
EEG.setname = strcat(EEG.setname,'_binica');
filename_n = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename_n,'filepath',outputDir);