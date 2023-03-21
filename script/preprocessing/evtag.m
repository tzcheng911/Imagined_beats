%% Tag the event code for localizer (tap, listen, sync) and IMB experiment
% (duple, triple; BL, PB, IB; SB, WB; phantom tap)
% 1. Make sure the event codes are correct in the s0x_evtag file, then move on
% to the preprocessing and data analysis
% 2. Should do this step manually for each subject
% eeglab
clear
close all
clc

cd('/data/projects/zoe/ImaginedBeats/real_exp/s22/raw_data')
addpath(genpath('/data/projects/zoe/ImaginedBeats/script'))
EEG = pop_loadset('1514_ImaginedBeat_968.set');
load('s221test.mat');
% eeglab
% rmpath('/data/common/matlab/eeglab/plugins/tmullen-cleanline-09d199104a42/external/bcilab_partial/dependencies/PropertyGrid-2010-09-16-mod/')
% rmpath('/data/common/matlab/eeglab/plugins/measure_projection/dependency/propertyGrid/')                                                   % Shado
% addpath('/data/projects/zoe/ImaginedBeats/script/preprocessing')

%% Tag the event codes by trigger pulses: only 0, 1 and 2
% Extract trigger and tap AIB channels
AIB_tap = EEG.nbchan-32+1; % tap 
AIB_s = EEG.nbchan-32+2; % trigger
EEG.etc.tap = EEG.data(AIB_tap,:);    
EEG.etc.trigger = EEG.data(AIB_s,:); 
% s08
% noise_s = 1.31e6;
% noise_e = 1.315e6;
% EEG.data(AIB_s,noise_s:noise_e) = 0;

% s09
% noise_s = 1.495e6;
% noise_e = 1.93e6;
% EEG.data(AIB_s,noise_s:noise_e) = -9000;

% s10
% noise_s = 1.35e6;
% noise_e = 1.4e6;
% EEG.data(AIB_s,noise_s:noise_e) = 0;

% s12
% noise_s = 1.36e6;
% noise_e = 1.38e6;
% EEG.data(AIB_s,noise_s:noise_e) = 0;

% s13
% noise_s = 1.694e6;
% noise_e = 1.698e6;
% EEG.data(AIB_s,noise_s:noise_e) = 0;

% s16
% noise_s = 1.396e6;
% noise_e = 1.398e6;
% EEG.data(AIB_s,noise_s:noise_e) = 0;

% s17
% noise_s = 2.84e6;
% noise_e = 3.56e6;
% EEG.data(AIB_tap,noise_s:noise_e) = 9.9e4;
% EEG.data(AIB_tap,5e6:5.4e6) = 9.9e4;

% s22
% noise_s = 5e6;
% noise_e = 5.14e6;
% EEG.data(AIB_tap,noise_s:noise_e) = 9.9e4;
% EEG.data(AIB_tap,5e6:5.4e6) = 9.9e4;

figure;
plot(EEG.data(AIB_s,:)); % trigger pulse
title('Trigger pulse');
xlabel('Sample points')
grid on
figure;
subplot(2,1,1)
plot(EEG.data(AIB_tap,:)); % tap
title('Tap');
xlabel('Sample points')
subplot(2,1,2)
plot(diff(EEG.data(AIB_tap,:))); % diff tap 
grid on
title('diff - Tap');
xlabel('Sample points')

    % Find peaks for all the triggers & tapping  
    IMB_start = input('IMB_start:','s');
    IMB_start = str2num(IMB_start);
    EEG.etc.IMB_start = IMB_start;
    trigger_threshold = input('trigger_threshold:','s');
    trigger_threshold = str2num(trigger_threshold);
    tap_threshold = input('tap_threshold:','s');
    tap_threshold = str2num(tap_threshold);
    trigger_events = processIBTrigger_s05(EEG.times/1000,EEG.data(AIB_s,:),'threshold'...
        ,trigger_threshold,'eventtype',{'SB','WB'},'eventduration',[.13 .04]);
    diff_tap = diff(EEG.data(AIB_tap,:));
    diff_tap = [0,0, diff_tap]; % avoid the delay of the sample pnts
    diff_tap(diff_tap<0) = 0;
        tap_events = processIBTrigger_z(EEG.times/1000,diff_tap,'threshold',tap_threshold, ...
             'eventtype',{'Tap'}); % Use diff if the baseline shift drastically across the whole recording
%    temptaps = cell2mat({tap_events.latency});
%    close_taps_ind = find(diff(temptaps) < 100)
%    tap_events(close_taps_ind) = []; % exclude the taps that are too close
    EEG.etc.triggerthreshold = trigger_threshold; % 1e5
    EEG.etc.tapthreshold = tap_threshold; % 1.9e5 sacrifice many localizer data

%% Examine how good the event code capture the trigger pulse
% Check if there is double-events, missing-event, the precision of the event
% code
taps = cell2mat({tap_events.latency});
figure; plot(EEG.data(AIB_tap,:));
gridx(taps,'r:');
length(taps)

triggers = cell2mat({trigger_events.latency});
figure; plot(EEG.data(AIB_s,:));
gridx(triggers,'r:');
length(trigger_events) % should be 3690 in this experiment except for subj01

%% deal with unknown events manually -- usually the broken triggers, apply on the trigger events 
% Didn't fix the duration, only the latency and type - 20200401 zoe  
% FIx from the end of the unknown_idx
durTgt = [0.13; 0.04] * [0.9 1.1];  %+/- 10% around target value % Zoe 20200330 
type = string({trigger_events.type});
unknown_idx = find(type == 'unknown');
latency = cell2mat({trigger_events.latency});
duration = cell2mat({trigger_events.duration});

% correct the label to unknown for some wrong trials in s22 -> need to find
% out the "lonely" unknowns first
diff_unknown_idx = diff([0 unknown_idx]);
for ndiff = 1:length(diff_unknown_idx)-1
    if (diff_unknown_idx(ndiff+1) ~= 1) && (diff_unknown_idx(ndiff) ~= 1)
       temp_lonely_unknown(ndiff) = unknown_idx(ndiff);
    else temp_lonely_unknown(ndiff) = 0;
    end
end
lonely_unknown = temp_lonely_unknown(temp_lonely_unknown~=0);

% manually go through the lonle_unknown list
% write down the need-to-correct idx
need_correct_idx = [3381,3018,2652,2471,1829,1734,1531,1457,1376,1223,977,114];
for nlonely = 1:length(need_correct_idx)
    trigger_events(need_correct_idx(nlonely)).type = 'unknown';
end
    
% combine the durations and correct the type
type_new = string({trigger_events.type});
unknown_idx_new = find(type_new == 'unknown');
for n = length(unknown_idx_new):-2:1
    trigger_events(unknown_idx_new(n-1)).duration = duration(unknown_idx_new(n)) + duration(unknown_idx_new(n - 1));
    if trigger_events(unknown_idx_new(n-1)).duration < durTgt(1,2) && trigger_events(unknown_idx_new(n-1)).duration > durTgt(1,1)
       trigger_events(unknown_idx_new(n-1)).type = 'SB';
    elseif trigger_events(unknown_idx_new(n-1)).duration < durTgt(2,2) && trigger_events(unknown_idx_new(n-1)).duration > durTgt(2,1)
       trigger_events(unknown_idx_new(n-1)).type = 'WB';
    else
       trigger_events(unknown_idx_new(n-1)).type = 'warning';
    end 
       trigger_events(unknown_idx_new(n)) = [];
end


%% Tag the IMB part with other more detailed event code: BL, PB, IB, Duple, Triple, Phantom target
events = [tap_events,trigger_events]; 
for j = 1:length(events)
    [events(j).type] =  char(events(j).type);
end
IMB_start_ind = find([trigger_events.latency]>IMB_start,1);
IMB_trigger_events = trigger_events(IMB_start_ind:end);
IMB_trigger_latency = cell2mat({IMB_trigger_events.latency});

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
    trials_event(k).urevent = k; % doesn't matter, will be re-written at the end 
    trials_event(k).amplitude = 2.5e5;
    count1 = count1 +36;
end

phases_event = struct();
phases_event.duration = 1;
count2 = 1;
for l = 1:nphase
    switch mod(l,3)
        case 1
            phases_event(l).type = char({'BL'});
        case 2
            phases_event(l).type = char({'PB'});
        case 0
            phases_event(l).type = char({'IB'});
    end
    phases_event(l).duration = 1;
    phases_event(l).latency = IMB_trigger_events(count2).latency;
    phases_event(l).urevent = l; % doesn't matter, will be re-written at the end 
    phases_event(l).amplitude = 2.5e5;
    count2 = count2 +12;
end

phantom_event = struct();
gaps = diff(IMB_trigger_latency);
tap_idx = find(gaps > 5*EEG.srate); % find the taps (which is an empty gap at least 5 secs in trigger events)
tap_idx = [tap_idx length(gaps)+1]; % take the last tapping phase at trial 90
gaps = [gaps 1/2.4*EEG.srate*36];  % simulate a gap (36 beats) for trail 90

for m = 1:ntrial
    ntap = round(gaps(tap_idx(m))/(1/2.4*EEG.srate));
    for p = 1:ntap
        temp_latency{m,p} = IMB_trigger_latency(tap_idx(m)) + 853*p; % get phantom taps for each trial, 853 is the IOI
    end 
end
phantom_latency = reshape(temp_latency',1,size(temp_latency,1)*size(temp_latency,2));
phantom_latency = cell2mat(phantom_latency);
for n = 1:length(phantom_latency)
    phantom_event(n).type = char({'ptarget'});
    phantom_event(n).duration = 1;
    phantom_event(n).latency = phantom_latency(n);
    phantom_event(n).urevent = n; % doesn't matter, will be re-written at the end 
    phantom_event(n).amplitude = 2.5e5;
end

%% Examine the phantom events in IMB
phantoms = [phantom_event.latency];
figure; plot(EEG.data(end-32+1,:));
gridx(phantoms,'r:');

%% Add the urevent and Save the evtag files
[EEG.event] = [events,trials_event,phases_event,phantom_event];
[B,I] = sort([EEG.event.latency]); % Get the index of sorting 
EEG.event = EEG.event(I); % Sort all events by the latency first
for nurevent = 1:length(EEG.event)
    EEG.event(nurevent).urevent = nurevent; % add the ascending order urevent
end
EEG.urevent = EEG.event;

EEG.setname = 's22_evtag_2048.set';
EEG = pop_saveset(EEG,'filename','s22_evtag_2048.set');
EEG = pop_resample( EEG, 512);
EEG.setname = 's22_evtag_512.set';
EEG = pop_saveset(EEG,'filename','s22_evtag_512.set');

