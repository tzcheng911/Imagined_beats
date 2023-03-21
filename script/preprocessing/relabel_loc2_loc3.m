%% load the file
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer3';
filename = 'localizer_Madison_binica_dipfit.set'; 
EEG = pop_loadset('filename',filename ,'filepath', filepath);

figure(1);
plot(EEG.etc.old.data(end-32+8,:)); % trigger pulse
grid on
title('Trigger pulse');
figure(2);
plot(EEG.etc.old.data(end-32+7,:)); % tapping data: substract the min to make it positive
grid on
title('Tapping data');
%trigger_threshold = 1e5; % manually search for the proper threshold based on figure 1 
%tap_threshold = 4747; % manually search for the proper threshold based on figure 2 

    trigger_threshold = input('trigger_threshold:','s'); % enter the trigger threshold based on figure 1
    trigger_threshold = str2num(trigger_threshold); 
    tap_threshold = input('tap_threshold:','s'); % enter the tap threshold based on figure 2
    tap_threshold = str2num(tap_threshold);

trigger_events = processIBTrigger_z(EEG.etc.old.times/1000,EEG.etc.old.data(end-32+8,:),'threshold',1e5,...
    'burstduration',.113,'eventtype',{'0'},'eventduration',[.04]); % extract trigger events, coded as '0'
tap_events = processIBTrigger_z(EEG.etc.old.times/1000,EEG.etc.old.data(end-32+7,:),'threshold',...
    1.95e5, 'eventtype',{'2'}); % extract tap events, coded as '2'
events = [tap_events,trigger_events]; 
for j = 1:length(events)
    [events(j).type] =  char(events(j).type);
end

EEG.event = [];
[EEG.event] = [events]; % store the events to EEG.event
EEG.setname = 'localizer_Madison_binica_dipfit_relabel';
EEG = pop_saveset( EEG, 'filename','localizer_Madison_binica_dipfit_relabel.set','filepath','/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer3/');

