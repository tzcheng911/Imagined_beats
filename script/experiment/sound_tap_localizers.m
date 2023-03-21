clear 
close all
clc

%% make sound stimuli
IOI = 0.1; % 300 bpm = 0.2 IOI or 200 bpm = 0.3 IOI
nbeat = 10; % how many beats in repeat

%[warningtone,wt_fs] = audioread('/Users/tzu-hancheng/Google_Drive/Academia/Swartz_center/imaginedbeats/stimuli/warningtone.wav');
[y,fs] = audioread('/Users/tzu-hancheng/Google_Drive/Research/Imaginedbeat/materials/SoCal_kickdrum_100bpm.mp3'); % SoCal_kickdrum_100bpm, TrapDoor_hihat_100bpm 

pad = zeros(1,0.01*fs); %10 ms padding to start/end
beat = y(1:IOI*fs,1);

figure(1);
plot(beat);

beats = repmat(beat,nbeat,1);
stim = [pad';beats];
figure(2);
plot(stim);
%aud = audioplayer (stim,fs);
%play(aud);

% make triggers (square pulse)
ceiling = max(beat);
t_beat_dur = ones(1,0.04*fs); % short trigger for unaccented beats :0.04 s
tail_beat = IOI*fs-length(t_beat_dur);
t_beat = [t_beat_dur*ceiling zeros(1,tail_beat)];
t_beats = repmat(t_beat',nbeat,1);
trigger_beat = [pad';t_beats];

% plot the sound and trigger 
figure(3);
plot(stim);
hold on 
plot(trigger_beat);

% save a sound file
sound_localizer = [stim trigger_beat];
filename = 'SoCal_kickdrum_600bpm.wav';
audiowrite(filename,sound_localizer,fs);

%% make sound file with randomized IOI from t to t*0.3
clear
close all
nbeat = 10;
IOI = 0.1; % 300 bpm = 0.2 IOI or 200 bpm = 0.3 IOI
pad = 0.01;
t = 0.3;

[y,fs] = audioread('/Users/tzu-hancheng/Google_Drive/Research/Imaginedbeat/materials/SoCal_kickdrum_600bpm.wav'); % SoCal_kickdrum_100bpm, TrapDoor_hihat_100bpm 
y0 = y; 
insert = @(newa, beat, endbeat)cat(1,  beat(1:endbeat,:), newa, beat(endbeat+1:end,:));
for n = nbeat:-1:1
    zeropadding = zeros(round(t*rand(1)*fs),2); % generate a duration randomized between 0 - 0.5 s
    y = insert(zeropadding, y, pad*fs+n*IOI*fs); % add the duration to the end of the nth beat
end

figure(1);
plot(y);

% save a sound file
filename = 'SoCal_kickdrum_300bpm_randomize.wav';
audiowrite(filename,y,fs);

%%
beats = repmat(beat,nbeat,1);
stim = [pad';beats];
figure(2);
plot(stim);