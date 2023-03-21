%% Kickdrum
clear all
close all
[y,fs] = audioread('/Users/t.z.cheng/Google_Drive/Research/Imaginedbeat/materials/Socal_drumbeat.mp3'); % SoCal_kickdrum_100bpm, TrapDoor_hihat_100bpm 
figure(1);
plot(y);

Hz = 2.4;
IOI = 1/Hz;
% IOI = 0.2; % 300 bpm = 0.2 IOI or 200 bpm = 0.3 IOI
pad = zeros(1,0.01*fs); %10 ms padding to start/end
beat = y(1:IOI*fs,1);
figure(2);
plot(beat);
strongbeat = beat*10;

duple = [strongbeat;beat];
triple = [strongbeat;beat;beat];
figure(3);
subplot(2,1,1);
plot(duple);
subplot(2,1,2);
plot(triple);

stim = repmat(beat,12,1);
stim_du = repmat(duple,6,1);
stim_tri = repmat(triple,4,1);

trial_du = [pad';stim;stim_du;stim];
trial_du = trial_du(1:(length(trial_du)-length(pad)));
trial_tri = [pad';stim;stim_tri;stim];
trial_tri = trial_tri(1:(length(trial_tri)-length(pad)));
figure(4);
subplot(2,1,1);
plot(trial_du);
subplot(2,1,2);
plot(trial_tri);

%aud = audioplayer (trial_du,fs);
%play(aud)

%% plot the trigger (square pulses)
ceiling = max(duple); % max(triple) will give us the same value
t_beat_dur = ones(1,0.13*fs); % long trigger for accented beats: 0.13 s
t_subbeat_dur = ones(1,0.04*fs); % short trigger for unaccented beats :0.04 s
tail_beat = IOI*fs-length(pad)-length(t_beat_dur);
tail_subbeat = IOI*fs-length(pad)-length(t_subbeat_dur);

t_subbeat = [pad t_subbeat_dur*ceiling zeros(1,tail_subbeat)];
t_beat = [pad t_beat_dur*ceiling zeros(1,tail_beat)];
t_duple = [t_beat t_subbeat];
t_triple = [t_beat t_subbeat t_subbeat];

trigger_du = [repmat(t_subbeat,1,12) repmat(t_duple,1,6) repmat(t_subbeat,1,12)];
trigger_tri = [repmat(t_subbeat,1,12) repmat(t_triple,1,4) repmat(t_subbeat,1,12)];

figure(5);
subplot(2,1,1);
plot(trial_du);
hold on 
plot(trigger_du);
subplot(2,1,2);
plot(trial_tri);
hold on 
plot(trigger_tri);


%% save a sound file
stimuli_duple = [trial_du trigger_du'];
stimuli_triple = [trial_tri trigger_tri'];

filename = 'stimuli_duple.wav';
audiowrite(filename,stimuli_duple,fs);

filename = 'stimuli_triple.wav';
audiowrite(filename,stimuli_triple,fs);
%% add warningtone & tapping time 
clear all
clc
[warningtone_h,fs] = audioread('/Users/t.z.cheng/Google_Drive/Research/Imaginedbeat/stimuli/warningtone_h.wav');
[warningtone_l,fs] = audioread('/Users/t.z.cheng/Google_Drive/Research/Imaginedbeat/stimuli/warningtone_l.wav');

[duple,fs_duple] = audioread('stimuli_duple.wav');
[triple,fs_triple] = audioread('stimuli_triple.wav');
tappingtime = zeros(fs*7.5,1); 

%%
s1 = [warningtone_h;duple(:,1);tappingtime;warningtone_l];
t1 = [zeros(length(warningtone_h),1);duple(:,2);tappingtime;zeros(length(warningtone_l),1)];
d = [s1 t1];
s2 = [warningtone_h;triple(:,1);tappingtime;warningtone_l];
t2 = [zeros(length(warningtone_h),1);triple(:,2);tappingtime;zeros(length(warningtone_l),1)];
t = [s2 t2];
audiowrite('d.wav',d,fs);
audiowrite('t.wav',t,fs);

ITI = 1;
ITI1 = zeros(round(ITI*rand(1)*fs),2);
ITI2 = zeros(round(ITI*rand(1)*fs),2);
ITI3 = zeros(round(ITI*rand(1)*fs),2);
ITI4 = zeros(round(ITI*rand(1)*fs),2);
ITI5 = zeros(round(ITI*rand(1)*fs),2);
ITI6 = zeros(round(ITI*rand(1)*fs),2);
ITI7 = zeros(round(ITI*rand(1)*fs),2);
ITI8 = zeros(round(ITI*rand(1)*fs),2);
ITI9 = zeros(round(ITI*rand(1)*fs),2);
ITI10 = zeros(round(ITI*rand(1)*fs),2);
ten1 = [d;ITI1;d;ITI2;t;ITI3;d;ITI4;t;ITI5;d;ITI6;t;ITI7;d;ITI8;t;ITI9;t;ITI10];

ITI1 = zeros(round(ITI*rand(1)*fs),2);
ITI2 = zeros(round(ITI*rand(1)*fs),2);
ITI3 = zeros(round(ITI*rand(1)*fs),2);
ITI4 = zeros(round(ITI*rand(1)*fs),2);
ITI5 = zeros(round(ITI*rand(1)*fs),2);
ITI6 = zeros(round(ITI*rand(1)*fs),2);
ITI7 = zeros(round(ITI*rand(1)*fs),2);
ITI8 = zeros(round(ITI*rand(1)*fs),2);
ITI9 = zeros(round(ITI*rand(1)*fs),2);
ITI10 = zeros(round(ITI*rand(1)*fs),2);
ten2 = [t;ITI1;d;ITI2;t;ITI3;t;ITI4;d;ITI5;d;ITI6;t;ITI7;t;ITI8;d;ITI9;d;ITI10];

ITI1 = zeros(round(ITI*rand(1)*fs),2);
ITI2 = zeros(round(ITI*rand(1)*fs),2);
ITI3 = zeros(round(ITI*rand(1)*fs),2);
ITI4 = zeros(round(ITI*rand(1)*fs),2);
ITI5 = zeros(round(ITI*rand(1)*fs),2);
ITI6 = zeros(round(ITI*rand(1)*fs),2);
ITI7 = zeros(round(ITI*rand(1)*fs),2);
ITI8 = zeros(round(ITI*rand(1)*fs),2);
ITI9 = zeros(round(ITI*rand(1)*fs),2);
ITI10 = zeros(round(ITI*rand(1)*fs),2);
ten3 = [d;ITI1;t;ITI2;d;ITI3;t;ITI4;t;ITI5;d;ITI6;t;ITI7;d;ITI8;t;ITI9;d;ITI10];

block1 = [ten1;ten2;ten3];
block2 = [ten2;ten3;ten1];
block3 = [ten3;ten1;ten2];

audiowrite('block1.wav',block1,fs);
audiowrite('block2.wav',block2,fs);
audiowrite('block3.wav',block3,fs);
