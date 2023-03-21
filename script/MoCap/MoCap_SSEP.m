clear 
close all
clc
% eeglab

addpath(genpath('/data/projects/zoe/ImaginedBeats/script/'))
addpath('/share/apps/MATLAB/R2020a/toolbox/matlab/strfun')

MoCap_path = '/data/projects/zoe/ImaginedBeats/real_exp/preprocessed/epoch/MoCap/6sphases/interpolation';
MoCap_files = dir(fullfile(MoCap_path,'*_e.set'));
MoCap_name = {MoCap_files.name};

% SSEP on each coordinates
cord = 1:3;
cond = {'BL','PB','IB','tap'};
meter = {'duple','triple'};
sub = {'s02','s03','s04','s05','s06','s07','s08','s09','s10','s11','s12','s13','s14','s15'...
    ,'s16','s17','s18','s19','s20','s21','s22','s23','s24','s26','s27'};

rmsub = {'s03','s08','s11','s20','s24'};
% rmsub = {'s08','s11','s20'};

for i = 1:length(rmsub)
    rmsub_idx(i) = find(strcmp(sub,rmsub{i}));
end
sub(rmsub_idx) =[];

% FFT parameters
timewindow = 5;
df = 1/timewindow;
fs = 100; % EEG.srate
T = 1/fs;
L = timewindow*fs;
f = fs*(0:(L/2))/L;
dt = 1/fs;
sub_fbin = 2;
%
for nsub = 1:length(sub)
    for ncord = 1:length(cord)
        for nmeter = 1:length(meter)
                for ncond = 1:length(cond) 
                    data_name = strcat(sub(nsub),'_MoCap_evtag_2048_interp_cord',num2str(ncord),'_',meter(nmeter),'_',cond(ncond),'_e.set'); % each epoch is 5.5879 s
                    EEG = pop_loadset('filename',data_name,'filepath',MoCap_path);
                    MoCap_data(nsub,ncord,nmeter,ncond,:,:) = squeeze(mean(EEG.data,3,'omitnan'));
%                     for nmarker = 1:10
%                          for ntrial = 1:size(EEG.data,3)
%                             [Y,freq] = calc_fft(squeeze(EEG.data(nmarker,:,ntrial)),dt); % dt = 1/fs related to your sampling rate
%                             P2 = abs(Y/((EEG.xmax-EEG.xmin)*fs))*2; % Y/L*2
%                             trial_fft(ntrial,:) = P2;
%                          end
%                          fft_out(nsub,ncord,nmeter,ncond,nmarker,:) = squeeze(mean(trial_fft,1)); % unnecessary to do 1:L/2+1, calc_fft already done that
%                         [Y,freq] = calc_fft(squeeze(mean(EEG.data(nmarker,:,:),3)),dt); % dt = 1/fs related to your sampling rate
%                         P2 = abs(Y/((EEG.xmax-EEG.xmin)*fs))*2; % Y/L*2
%                         fft_out(nsub,ncord,nmeter,ncond,nmarker,:) = P2;
%                     end
                end
        end
    end
end
cd('/data/projects/zoe/ImaginedBeats/real_exp/preprocessed/epoch/MoCap/6sphases/interpolation')
times = (EEG.times - 5000)/1000;
save time_series_MoCap_interpolation_6s_e MoCap_data times
% save SSEP_MoCap_interpolation_FFTerp fft_out freq

%%
clear all
close all
clc
cd('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Main_task/motion')
% load time series
load('time_series_MoCap_interpolation_6s_e.mat');
% visualize markers 
for i = 1:10
x = squeeze(MoCap_data(1,1,1,1,i,10))*-1;
y = squeeze(MoCap_data(1,2,1,1,i,10));
z = squeeze(MoCap_data(1,3,1,1,i,10));
plot3(x,y,z,'.')
hold on
end
grid on 
axis equal
nmarker = 6;

% deal with s01 different configuration
m4 = MoCap_data(1,:,:,:,4,:);
m6 = MoCap_data(1,:,:,:,6,:);
MoCap_data(1,:,:,:,4,:) = m6;
MoCap_data(1,:,:,:,6,:) = m4;

figure; plot(times,squeeze(mean(mean(MoCap_data(:,:,1,:,nmarker,:),1),2))*1000);
set(gca,'FontSize',18)
xlabel('Time (s)')
ylabel('Distance (mm)')
xlim([-1 5])
gridx(0,'k:')
legend('BL','PM','IM','Tap')


figure; plot(times,squeeze(mean(mean(MoCap_data(:,:,2,:,nmarker,:),1),2))*1000);
set(gca,'FontSize',18)
xlabel('Time (s)')
ylabel('Distance (mm)')
xlim([-1 5])
gridx(0,'k:')
legend('BL','PM','IM','Tap')

%% load freq domain
clear 
close all
clc
load('SSEP_MoCap_interpolation_fs100_4500ms.mat');

% deal with s01 different configuration
m4 = fft_out(1,:,:,:,4,:);
m6 = fft_out(1,:,:,:,6,:);
fft_out(1,:,:,:,4,:) = m6;
fft_out(1,:,:,:,6,:) = m4;
X = categorical({'BL','PM','IM','Tap'});

meanSSEP_duple = squeeze(mean(mean(fft_out(:,:,1,:,:,:),1),2))*1000;
meanSSEP_triple = squeeze(mean(mean(fft_out(:,:,2,:,:,:),1),2))*1000;

%% stats test against zero (confirm if BL, PM and IM are not different from zero -> no movement)
% fft_out(15,:,:,:,:,:) = [];

close all
meter_MoCap = 0.5*(squeeze(mean(fft_out(:,:,1,:,:,25),2))*1000 + squeeze(mean(fft_out(:,:,2,:,:,17),2))*1000); % average across 1.2 Hz and 0.8 Hz meter rates
beat_MoCap = squeeze(mean(mean(fft_out(:,:,:,:,:,49),2),3))*1000;

figure;bar(squeeze(mean(meter_MoCap,1))');title('Meter');set(gca,'FontSize',18);ylabel('Distance (mm)')...
    ;xticklabels({'1 Head','2 Head','3 Left elbow','4 Left hand','5 Right elbow', '6 Right index finger',...
    '7 Left knee','8 Left toe','9 Right knee','10 Right toe'});xtickangle(45)
figure;bar(squeeze(mean(beat_MoCap,1))'); title('Beat');set(gca,'FontSize',18);ylabel('Distance (mm)')...
    ;xticklabels({'1 Head','2 Head','3 Left elbow','4 Left hand','5 Right elbow', '6 Right index finger',...
    '7 Left knee','8 Left toe','9 Right knee','10 Right toe'});xtickangle(45)

%% compare BL and IM
[H,P,CI,STATS] = ttest(squeeze(meter_MoCap(:,1,:)),squeeze(meter_MoCap(:,3,:)));
correctedP = P*10;
figure;bar(correctedP);title('Bonferroni corrected pvalues Meter IM vs. BL');ylim([0 1])
gridy(0.05,'k:')
[H,P,CI,STATS] = ttest(squeeze(beat_MoCap(:,1,:)),squeeze(beat_MoCap(:,3,:)));
correctedP = P*10;
figure;bar(correctedP);title('Bonferroni corrected pvalues Beat IM vs. BL');ylim([0 1])
gridy(0.05,'k:')

%% compare IM and TAP
[H,P,CI,STATS] = ttest(squeeze(meter_MoCap(:,3,:)),squeeze(meter_MoCap(:,4,:)));
correctedP = P*10;
figure;bar(correctedP);title('Bonferroni corrected pvalues Meter IM vs. TAP')
gridy(0.05,'k:')

[H,P,CI,STATS] = ttest(squeeze(beat_MoCap(:,3,:)),squeeze(beat_MoCap(:,4,:)));
correctedP = P*10;
figure;bar(correctedP);title('Bonferroni corrected pvalues Beat IM vs. TAP')
gridy(0.05,'k:')
%%
for nmarker = 1:10
figure;bar(X,squeeze(meanSSEP_duple(:,nmarker,25)));set(gca,'FontSize',18);ylim([0 2]);axis off % 1.2 Hz
filename = strcat('duple_m',num2str(nmarker),'.pdf');
%saveas(gcf,filename)
figure;bar(X,squeeze(meanSSEP_duple(:,nmarker,17)));set(gca,'FontSize',18);ylim([0 2]);axis off % 0.8 Hz
filename = strcat('triple_m',num2str(nmarker),'.pdf');
%saveas(gcf,filename)

figure;
plot(freq,meanSSEP_duple,'LineWidth',2); 
xlim([0.7 3])
ylim([0 2])
set(gca,'FontSize',18)
xlabel('Frequency (Hz)')
ylabel('Distance (mm)')
gridx([1.2 2.4],'k:')
legend('BL','PM','IM','Tap')

figure;
plot(freq,meanSSEP_triple,'LineWidth',2); 
xlim([0.7 3])
ylim([0 2])
set(gca,'FontSize',18)
xlabel('Frequency (Hz)')
ylabel('Distance (mm)')
gridx([0.8 2.4],'k:')
legend('BL','PM','IM','Tap')
    
end


% plot for all subjs to find out who is moving
for nsub = 1:20
figure;
    plot(freqs,squeeze(mean(fft_out(nsub,:,1,1:4,4,:),2)),'LineWidth',2); 
    xlim([0.5 3])
    set(gca,'FontSize',18)
    xlabel('Frequency (Hz)')
    ylabel('Distance (mm)')
    gridx([1.2 2.4],'k:')
    legend('BL','PB','IB','Tap')
end

% plot for all subjs to find out who is moving
for nsub = 1:20
figure;
    plot(freq,squeeze(fft_out(nsub,2,1,1:4,4,:)),'LineWidth',2); 
    xlim([0.5 3])
    set(gca,'FontSize',18)
    xlabel('Frequency (Hz)')
    ylabel('Distance (mm)')
    gridx([1.2 2.4],'k:')
    legend('BL','PB','IB','Tap')
end