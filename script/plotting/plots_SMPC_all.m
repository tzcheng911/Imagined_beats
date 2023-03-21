clear 
close all
clc
addpath(genpath('/Volumes/TOSHIBA/Research/Imagined_beats/script/'))

%% fft(original sounds)
[y,fs] = audioread('/Users/tzu-hancheng/Google_Drive/Research/Imaginedbeat/materials/Socal_drumbeat.mp3'); 

Hz = 2.4;
IOI = 1/Hz;
pad = zeros(1,0.01*fs); %10 ms padding to start/end
beat = y(1:IOI*fs,1);
strongbeat = beat*10;

duple = [strongbeat;beat];
triple = [strongbeat;beat;beat];
stim = repmat(beat,12,1);
stim_du = repmat(duple,6,1);
stim_tri = repmat(triple,4,1);

[control,f] = calc_fft(stim,1/fs,60*fs);
figure;plot(f,(abs(control)/length(control))*2,'LineWidth',2);
xlim([0.5 3])
gridx(2.4)

[DUPLE,f] = calc_fft(stim_du,1/fs,60*fs);
figure;plot(f,(abs(DUPLE)/length(DUPLE))*2,'LineWidth',2);
xlim([0.5 3])
gridx([1.2,2.4])

[TRIPLE,f] = calc_fft(stim_tri,1/fs,60*fs);
figure;plot(f,(abs(TRIPLE)/length(TRIPLE))*2,'LineWidth',2);
xlim([0.5 3])
gridx([0.8,1.6,2.4])

% plot the sound time series
figure;plot(stim,2); 
figure;plot(stim_du,2); 
figure;plot(stim_tri,2); 

% plot the tap time series
EEG = pop_loadset('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/raw/s06/raw/s06_IMB_evtag.set');
figure; plot(EEG.data(end-32+7,:),'color','k');

%% fft(exp capped sounds)
[y1,fs] = audioread('/Users/t.z.cheng/Google_Drive/Research/Imaginedbeat/20190118exp/practice_duple.wav'); 
[y2,fs] = audioread('/Users/t.z.cheng/Google_Drive/Research/Imaginedbeat/20190118exp/practice_triple.wav'); 
figure; plot(y1)
figure; plot(y2)

stim_du = y1(6*fs:11*fs);
stim_tri = y2(6*fs:11*fs);
stim = y1(1*fs:6*fs);

[control,f] = calc_fft(stim,1/fs,60*fs);
figure;plot(f,(abs(control)/length(control))*2,'LineWidth',2);
xlim([0.5 3])
ylim([0 3.5e-4])
set(gca,'FontSize',18)
gridx(2.4,'k:')
xlabel('Frequency (Hz)')
ylabel('Relative Amplitude (uV)')

[DUPLE,f] = calc_fft(stim_du,1/fs,60*fs);
figure;plot(f,(abs(DUPLE)/length(DUPLE))*2,'LineWidth',2);
xlim([0.5 3])
ylim([0 3.5e-4])
set(gca,'FontSize',18)
gridx([1.2,2.4],'k:')
xlabel('Frequency (Hz)')
ylabel('Relative Amplitude (uV)')

[TRIPLE,f] = calc_fft(stim_tri,1/fs,60*fs);
figure;plot(f,(abs(TRIPLE)/length(TRIPLE))*2,'LineWidth',2);
xlim([0.5 3])
ylim([0 3.5e-4])
set(gca,'FontSize',18)
gridx([0.8,1.6,2.4],'k:')
xlabel('Frequency (Hz)')
ylabel('Relative Amplitude (uV)')
%% fft(taps)
% all
cd('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/tap_brain/peakcontrast')
load('f');
load('Duple_tapping');
load('Triple_tapping');

figure;plot(f,Duple_tapping(:,1:270)','LineWidth',2)
xlim([0.5 3])
ylim([0 650])
gridx([1.2,2.4])
legend('s01','s02','s03','s04','s05','s06','s07','s08','s09')

figure;plot(f,Triple_tapping(:,1:270)','LineWidth',2)
xlim([0.5 3])
ylim([0 650])
gridx([0.8,2.4])
legend('s01','s02','s03','s04','s05','s06','s07','s08','s09')

% single 
sub = {'s01','s02','s03','s04','s05','s06','s07','s08','s09'};
cond = {'tapbeh'};
meter = {'duple','triple'};
% duple
timewindow = 60;
fs = 512; % EEG.srate
T = 1/fs;
L = timewindow*fs;
f = fs*(0:(L/2))/L;
dt = 1/fs;

nsub = 1;
filepath = strcat('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/',sub(nsub),'/icapMA');
nmeter = 1;
ncond = 1;
filename = strcat(sub(nsub),'_evtag_',meter(nmeter),'_',cond(ncond),'.set');
EEG = pop_loadset('filename',filename,'filepath',filepath{:});
close;plot(squeeze(EEG.data(:,:,14)),'k');axis off
[DUPLE,f] = calc_fft(EEG.data(1,:,14),dt,L);
figure;plot(f,2*abs(DUPLE),'LineWidth',2);
xlim([0.5 3])
gridx([1.2,2.4])

% triple
nsub = 1;
filepath = strcat('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/',sub(nsub),'/icapMA');
nmeter = 2;
ncond = 1;
filename = strcat(sub(nsub),'_evtag_',meter(nmeter),'_',cond(ncond),'.set');
EEG = pop_loadset('filename',filename,'filepath',filepath{:});
close;plot(squeeze(EEG.data(:,:,41)),'k');axis off
[TRIPLE,f] = calc_fft(EEG.data(1,:,41),dt,L);
figure;plot(f,2*abs(TRIPLE),'LineWidth',2);
xlim([0.5 3])
gridx([0.8,1.6,2.4])

%% fft(EEG) 
clear 
close all
%cd('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/tap_brain/rawEEG')
cd('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/tap_brain/peakcontrast')

load('f');
load('Duple_mICs_EEG');
load('Triple_mICs_EEG');
load('Duple_aICs_EEG');
load('Triple_aICs_EEG');

Duple_mICs_EEG = Duple_mICs_EEG([1,2,4,5,6,7,9],:,:);
Triple_mICs_EEG = Triple_mICs_EEG([1,2,4,5,6,7,9],:,:);
Duple_aICs_EEG = Duple_aICs_EEG([1,2,4,5,6,7,9],:,:);
Triple_aICs_EEG = Triple_aICs_EEG([1,2,4,5,6,7,9],:,:);

figure;plot(f,squeeze(mean(Duple_aICs_EEG,1))','LineWidth',2);
%title('Duple-aICs')
xlim([0.5 3]) 
ylim([0 3e-3])
set(gca,'FontSize',18)
gridx([1.2,2.4]);legend('Control','Physical Beat','Imagined Beat');

figure;plot(f,squeeze(mean(Duple_mICs_EEG,1))','LineWidth',2);
%title('Duple-mICs')
xlim([0.5 3]) 
ylim([0 3e-3])
set(gca,'FontSize',18)
gridx([1.2,2.4]);legend('Control','Physical Beat','Imagined Beat');

figure;plot(f,squeeze(mean(Triple_aICs_EEG,1))','LineWidth',2);
%title('Triple-aICs')
xlim([0.5 3]) 
ylim([0 3e-3])
set(gca,'FontSize',18)
gridx([0.8,1.6,2.4]);legend('Control','Physical Beat','Imagined Beat');

figure;plot(f,squeeze(mean(Triple_mICs_EEG,1))','LineWidth',2);
%title('Triple-mICs')
xlim([0.5 3]) 
ylim([0 3e-3])
set(gca,'FontSize',18)
gridx([0.8,1.6,2.4]);legend('Control','Physical Beat','Imagined Beat');