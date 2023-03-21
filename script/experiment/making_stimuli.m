%% making a warning tone
clear all
close all
clc

fs = 44100; % sampling rate
dur = 0.05; % duration
toldur = 1; % duration of the whole warning tone
f0 = 400;
pad = zeros(1,0.01*fs); %10 ms padding to start/end

nt = 0:1/fs:dur-1/fs;
N = length(nt);
Y_unramp = cos(2*pi*f0*nt);
rampDur_f = floor(0.005 *fs) - 1;
rampDur_b = floor(0.005 *fs) - 1;
ramp_f = linspace(0, 1, rampDur_f);
ramp_b = linspace(1, 0, rampDur_b);
window = [ramp_f ones(1, N-2*rampDur_f) ramp_b];
Y = Y_unramp.* window;

warningtone = [Y zeros(1,fs*(0.1-dur)) Y zeros(1,fs*(toldur-2*dur-(0.1-dur)))];
warningtone2 = [Y zeros(1,fs*(0.1-dur)) Y zeros(1,fs*(toldur-2*dur-(0.1-dur)))];

%% make a pure tone
clear all
close all
clc

fs = 44100; %sampling rate
dur = 0.05; %duration
f0 = 200;
IOI = 1; % 300 bpm = 0.2 IOI or 200 bpm = 0.3 IOI
pad = zeros(1,0.01*fs); %10 ms padding to start/end

nt = 0:1/fs:dur-1/fs;
N = length(nt);
Y_unramp = cos(2*pi*f0*nt);
rampDur_f = floor(0.005 *fs) - 1;
rampDur_b = floor(0.005 *fs) - 1;
ramp_f = linspace(0, 1, rampDur_f);
ramp_b = linspace(1, 0, rampDur_b);
window = [ramp_f ones(1, N-2*rampDur_f) ramp_b];
Y = Y_unramp.* window;

% figure; plot(nt,x); plot(abs(fft(x)))
% way1
% soundsc(x, fs); %normalize audioplayer
% sound(x,fs);

IOIN = fs*IOI - length(Y); % how many IOI
beat = [Y zeros(1,IOIN)];
subbeat = beat*0.1; 
duple = [beat subbeat];
triple = [beat subbeat subbeat];
%cyclesub = cycle*0.1;

accented_du = repmat(duple,1,6);
accented_tri = repmat(triple,1,4);
unaccented = repmat(subbeat,1,12);
trial_du = [unaccented accented_du unaccented];
trial_tri = [unaccented accented_tri unaccented];
aud = audioplayer (trial_du,fs);
play(aud)

%% Other instruments
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

% aud = audioplayer (trial_du,fs);
% play(aud)

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


%%
aud = audioplayer (stim,fs);
play(aud);
pause(aud);

%% add warningtone & tapping time 

[warningtone,fs] = audioread('/Users/tzu-hancheng/Google_Drive/Research/Proposals/stimuli/warningtone.wav');
tappingtime = zeros(fs*5,1); % make here variable 

[hihat_200bpm_duple,fs_hihat_200bpm_duple] = audioread('hihat_200bpm_duple.wav');
[hihat_300bpm_duple,fs_hihat_300bpm_duple] = audioread('hihat_300bpm_duple.wav');
[hihat_200bpm_triple,fs_hihat_200bpm_triple] = audioread('hihat_200bpm_triple.wav');
[hihat_300bpm_triple,fs_hihat_300bpm_triple] = audioread('hihat_300bpm_triple.wav');
[kickdrum_200bpm_duple,fs_kickdrum_200bpm_duple] = audioread('kickdrum_200bpm_duple.wav');
[kickdrum_300bpm_duple,fs_kickdrum_300bpm_duple] = audioread('kickdrum_300bpm_duple.wav');
[kickdrum_200bpm_triple,fs_kickdrum_200bpm_triple] = audioread('kickdrum_200bpm_triple.wav');
[kickdrum_300bpm_triple,fs_kickdrum_300bpm_triple] = audioread('kickdrum_300bpm_triple.wav');
[puretone_200bpm_duple,fs_puretone_200bpm_duple] = audioread('puretone_200bpm_duple.wav');
[puretone_300bpm_duple,fs_puretone_300bpm_duple] = audioread('puretone_300bpm_duple.wav');
[puretone_200bpm_triple,fs_puretone_200bpm_triple] = audioread('puretone_200bpm_triple.wav');
[puretone_300bpm_triple,fs_puretone_300bpm_triple] = audioread('puretone_300bpm_triple.wav');
%%
s1 = [warningtone;hihat_200bpm_duple(:,1);tappingtime];
t1 = [zeros(length(warningtone),1);hihat_200bpm_duple(:,2);tappingtime];
hihat_200bpm_duple = [s1 t1];
audiowrite('hihat_200bpm_duple.wav',hihat_200bpm_duple,fs);

s2 = [warningtone;hihat_300bpm_duple(:,1);tappingtime];
t2 = [zeros(length(warningtone),1);hihat_300bpm_duple(:,2);tappingtime];
hihat_300bpm_duple = [s2 t2];
audiowrite('hihat_300bpm_duple.wav',hihat_300bpm_duple,fs);

s3 = [warningtone;hihat_200bpm_triple(:,1);tappingtime];
t3 = [zeros(length(warningtone),1);hihat_200bpm_triple(:,2);tappingtime];
hihat_200bpm_triple = [s3 t3];
audiowrite('hihat_200bpm_triple.wav',hihat_200bpm_triple,fs);

s4 = [warningtone;hihat_300bpm_triple(:,1);tappingtime];
t4 = [zeros(length(warningtone),1);hihat_300bpm_triple(:,2);tappingtime];
hihat_300bpm_triple = [s4 t4];
audiowrite('hihat_300bpm_triple.wav',hihat_300bpm_triple,fs);

s5 = [warningtone;kickdrum_200bpm_duple(:,1);tappingtime];
t5 = [zeros(length(warningtone),1);kickdrum_200bpm_duple(:,2);tappingtime];
kickdrum_200bpm_duple = [s5 t5];
audiowrite('kickdrum_200bpm_duple.wav',kickdrum_200bpm_duple,fs);

s6 = [warningtone;kickdrum_300bpm_duple(:,1);tappingtime];
t6 = [zeros(length(warningtone),1);kickdrum_300bpm_duple(:,2);tappingtime];
kickdrum_300bpm_duple = [s6 t6];
audiowrite('kickdrum_300bpm_duple.wav',kickdrum_300bpm_duple,fs);

s7 = [warningtone;kickdrum_200bpm_triple(:,1);tappingtime];
t7 = [zeros(length(warningtone),1);kickdrum_200bpm_triple(:,2);tappingtime];
kickdrum_200bpm_triple = [s7 t7];
audiowrite('kickdrum_200bpm_triple.wav',kickdrum_200bpm_triple,fs);

s8 = [warningtone;kickdrum_300bpm_triple(:,1);tappingtime];
t8 = [zeros(length(warningtone),1);kickdrum_300bpm_triple(:,2);tappingtime];
kickdrum_300bpm_triple = [s8 t8];
audiowrite('kickdrum_300bpm_triple.wav',kickdrum_300bpm_triple,fs);
%%
s9 = [warningtone;puretone_200bpm_duple(:,1);tappingtime];
t9 = [zeros(length(warningtone),1);puretone_200bpm_duple(:,2);tappingtime];
puretone_200bpm_duple = [s9 t9];
audiowrite('puretone_200bpm_duple.wav',puretone_200bpm_duple,fs);

s10 = [warningtone;puretone_300bpm_duple(:,1);tappingtime];
t10 = [zeros(length(warningtone),1);puretone_300bpm_duple(:,2);tappingtime];
puretone_300bpm_duple = [s10 t10];
audiowrite('puretone_300bpm_duple.wav',puretone_300bpm_duple,fs);

s11 = [warningtone;puretone_200bpm_triple(:,1);tappingtime];
t11 = [zeros(length(warningtone),1);puretone_200bpm_triple(:,2);tappingtime];
puretone_200bpm_triple = [s11 t11];
audiowrite('puretone_200bpm_triple.wav',puretone_200bpm_triple,fs);

s12 = [warningtone;puretone_300bpm_triple(:,1);tappingtime];
t12 = [zeros(length(warningtone),1);puretone_300bpm_triple(:,2);tappingtime];
puretone_300bpm_triple = [s12 t12];
audiowrite('puretone_300bpm_triple.wav',puretone_300bpm_triple,fs);

%% rms correction
clear all
close all
[hihat,hihat_fs] = audioread('/Users/tzu-hancheng/Google_Drive/Research/Proposals/materials/TrapDoor_hihat_100bpm.mp3'); % SoCal_kickdrum_100bpm, TrapDoor_hihat_100bpm 
[kickdrum,kickdrum_fs] = audioread('/Users/tzu-hancheng/Google_Drive/Research/Proposals/materials/SoCal_kickdrum_100bpm.mp3'); % SoCal_kickdrum_100bpm, TrapDoor_hihat_100bpm 
fs = 44100; %sampling rate
dur = 0.05; %duration
f0 = 200;
IOI = 0.2; % 300 bpm = 0.2 IOI or 200 bpm = 0.3 IOI
pad = zeros(1,0.01*fs); %10 ms padding to start/end

nt = 0:1/fs:dur-1/fs;
N = length(nt);
Y_unramp = cos(2*pi*f0*nt);
rampDur_f = floor(0.005 *fs) - 1;
rampDur_b = floor(0.005 *fs) - 1;
ramp_f = linspace(0, 1, rampDur_f);
ramp_b = linspace(1, 0, rampDur_b);
window = [ramp_f ones(1, N-2*rampDur_f) ramp_b];
Y = Y_unramp.* window;

% figure; plot(nt,x); plot(abs(fft(x)))
% way1
% soundsc(x, fs); %normalize audioplayer
% sound(x,fs);

IOIN = fs*IOI - length(Y); % how many IOI
puretone_beat = [Y zeros(1,IOIN)];
puretone_subbeat = puretone_beat*0.1; 

hihat_1beat = hihat(1:IOI*hihat_fs,1);
kickdrum_1beat = kickdrum(1:IOI*kickdrum_fs,1);

beat = (rms(puretone_subbeat)./rms(hihat_1beat))*hihat_1beat;

rms(beat)
rms(puretone_subbeat)
%%
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

ceiling = max(duple); % max(triple) will give us the same value
t_beat_dur = ones(1,0.13*fs); % long trigger for accented beats: 0.13 s
t_subbeat_dur = ones(1,0.04*fs); % short trigger for unaccented beats :0.4 s
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

hihat_duple = [trial_du trigger_du'];
filename = 'hihat_300bpm_duple.wav';
audiowrite(filename,hihat_duple,fs);

hihat_triple = [trial_tri trigger_tri'];
filename = 'hihat_300bpm_triple.wav';
audiowrite(filename,hihat_triple,fs);

%%
aud = audioplayer (trial_du,fs);
play(aud)
