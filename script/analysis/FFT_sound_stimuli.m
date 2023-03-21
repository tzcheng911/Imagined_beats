%% Load the stimuli 
clear 
close all
addpath(genpath('/Volumes/TOSHIBA EXT/Research/Imagined_beats/script'))

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

stim = repmat(beat,12,1); % 12 unaccented beats 
stim_strong = repmat(strongbeat,12,1); % 12 accented beats 
stim_du = repmat(duple,6,1); % 6 accented and 6 unaccented beats: duple
stim_tri = repmat(triple,4,1); % 4 accented and 8 unaccented beats: triple

sim_beat = [beat;zeros(length(beat),1)];
sim_duple = [strongbeat;zeros(length(beat),1)];
sim_triple = [strongbeat;zeros(length(beat),1);zeros(length(beat),1)];
stim_sim_beat = repmat(sim_beat,6,1); % 6 unaccented beats
stim_sim_du = repmat(sim_duple,6,1); % 6 accented beats
stim_sim_tri = repmat(sim_triple,4,1); % 4 accented beats

%% plot the time domain signals
figure; plot(stim)
figure;
subplot(2,2,1)
plot(stim_du)
subplot(2,2,2)
plot(stim_tri)
subplot(2,2,3)
plot(stim_sim_du)
subplot(2,2,4)
plot(stim_sim_tri)

%% FFT them and plot the frequenyc spectrum
[Fnn, freq] = calc_fft(stim_sim_du, 1/fs); % change to stim, stim_du, stim_tri, stim_sim_du, stim_sim_tri
P2 = abs(Fnn/length(stim))*2;
figure;plot(freq,P2);xlim([0 5])
title('Meter + blank')