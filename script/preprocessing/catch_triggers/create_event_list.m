clear all
close all
clc
%% make an event list (accented:1 & unaccented:0 & tapping:2)
EEG = pop_loadset('filename','1403_ImaginedBeat_897_hihat.set','filepath','/Users/tzu-hancheng/Google_Drive/Research/Proposals/data/pilot_3');
%%
figure(1);
plot(EEG.data(end-32+8,:)); % trigger pulse
figure(2);
plot(EEG.data(end-32+1,:)); % tapping data

%% Find peaks for all the triggers & tapping  
trigger_threshold = 8e4;
tap_threshold = 60;
trigger_events = processIBTrigger(EEG.times/1000,EEG.data(end-32+8,:),'threshold',trigger_threshold,'burstduration',.113,'eventtype',{'1','0'},'eventduration',[.13 .04]);
tap_events = processIBTrigger(EEG.times/1000,EEG.data(end-32+1,:),'threshold',tap_threshold, ...
         'eventtype',{'2'});
events = [tap_events,trigger_events]; 
for i = 1:length(events)
    [events(i).type] =  char(events(i).type);
end

% dsample = num2cell([events.latency]*250/512);
% [events.latency] =  dsample{:};
%% Find the first peak of each trial
trials = [];
n = 1;
for i = 1:40
    trials(i) = trigger_events(n).latency;
    n = n +36;
end
trials = num2cell(trials);
[EEG.event.latency] = trials{:};
[EEG.event] = [EEG.event,events];
%% Another way (more stupid) to find the onset of each trial
trigger_peaks = findpeaks(EEG.data(end-32+8,:),trigger_threshold);
    for i = 1:length(trigger_peaks.loc)
        if i == length(trigger_peaks.loc)
           trigger(i) = 0;
        else
           trigger(i) = trigger_peaks.loc(i+1)-trigger_peaks.loc(i);
        end
    end

    t_ind = find (trigger>1000);
    latency = num2cell([trigger_peaks.loc(1);trigger_peaks.loc(t_ind+1)]);
    [EEG.event.latency] = latency{:};
    
% Test the similartiry between two ways to find the peak: differ in 0-2
% time points(< 3.9 ms)
first_ts = [];
n = 1;
for i = 1:40
    first_ts(i) = trigger_events(n).latency;
    n = n +36;
end
first_ts = first_ts';
latency = cell2mat(latency);
isequal(first_ts,latency)

%% Test how good is the calculation: plot
close all
test_tap = 50*ones(1,length(EEG.data(end-32+1,:)));
test_tap([tap_events.latency]) = tap_threshold;
test_trigger = 50*ones(1,length(EEG.data(end-32+8,:)));
test_trigger([trigger_events.latency]) = 11e4;
figure(1);
plot(EEG.data(end-32+1,:)); % tapping data
hold on 
plot(test_tap);
figure(2);
plot(EEG.data(end-32+8,:)); % trigger data
hold on 
plot(test_trigger);