%% Generate the figures and tables for R in IMB project Zoe 20210516
% Also see plots_SMPC_all.m for the sound and tap plots 

eeglab
clear 
close all
clc

cond = {'BL','PM','IM','tap'};
meter = {'duple','triple'};
sub = {'s02','s03','s04','s05','s06','s07','s08','s09','s10','s11','s12','s13','s14','s15'...
    ,'s16','s17','s18','s19','s20','s21','s22','s23','s24','s26','s27'};
rmsub = {'s03','s08','s11','s20','s24'};
for i = 1:length(rmsub)
    rmsub_idx(i) = find(strcmp(sub,rmsub{i}));
end

timewindow = 5;
df = 1/timewindow;

sub(rmsub_idx) =[];

%% Tap performance (tapbeh) don't need to rerun to get the plot, just load from /Volumes/TOSHIMA/Research/Imagined_beats/real_exp/results/Main_task/Tapping
addpath(genpath('/Volumes/TOSHIBA/Research/Imagined_beats/script'))
tapbeh_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/tapbeh/triple'; % change to duple to plot the duple or triple 
tapbeh_files = dir(fullfile(tapbeh_path,'*tapbeh.set'));
tapbeh_name = {tapbeh_files.name};
timewindow = 5;
fs = 512; % EEG.srate
T = 1/fs;
L = timewindow*fs;
f = fs*(0:(L/2))/L;
dt = 1/fs;

for nsub = 1:length(tapbeh_name)
    tempEEG = tapbeh_name{nsub};
    parts = cellstr(split(tempEEG,'_'));
    EEG = pop_loadset('filename',tempEEG,'filepath',tapbeh_path);
    data = squeeze(mean(EEG.data(1,1:timewindow*fs,:),3)); % calculate fft for the first xx sec based on the timewindow parameter
    [Y,freq] = calc_fft(data,dt);
    P2 = abs(Y/((EEG.xmax-EEG.xmin)*fs))*2; % Y/L*2
    fft_out(nsub,:) = P2;
end
save triple_tap_fft_out fft_out freq
%% find the outliers based on the peak loc 
load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Main_task/Tapping/triple_tap_fft_out')
mean_all_subs = mean(fft_out,1);
pool_fbin = 2; % central frequency +- 2 
beatf = find(freq == 0.8); % change this to 2.4 Hz (beat freq), or 1.2, 0.8, 1.6 (meter freq)

% max method
[peak peakfreq] = max(fft_out(:,(beatf - pool_fbin):(beatf + pool_fbin)),[],2);
peaks = freq(peakfreq+beatf - pool_fbin-1);
meanpeak = mean(peaks);
stdpeak = std(peaks);
isoutlier(peaks,'median')
isoutlier(peaks,'mean')
isoutlier(peaks,'quartiles')

%% Plot the fft of the tap
nsub = 25;
freq_s = find(freq == 0.4);
freq_e = find(freq == 3);
sub_to_plot = [1:nsub];
outliers = find(isoutlier(peaks,'quartiles')==1);
ff = freq;

figure;
set(gca, 'ColorOrder', gray(nsub), 'NextPlot', 'replacechildren');
plot(freq(freq_s:freq_e),fft_out(sub_to_plot,freq_s:freq_e),'LineWidth',1);
hold on 
plot(freq(freq_s:freq_e),fft_out(outliers,freq_s:freq_e),'LineWidth',2,'color','k');
hold on 
plot(freq(freq_s:freq_e),mean(fft_out(:,freq_s:freq_e),1),'LineWidth',3,'color','r');

xlim([0.5 3])
% ylim([-0.01 100])
title('Tapping performance')
set(gca,'FontSize',18)
gridx([1.2 2.4],'r:');
%gridx([0.8 1.6 2.4],'r:');
xlabel('Frequency (Hz)')
ylabel('Relative Amplitude (uV)')

legend('s02','s03','s04','s05','s06','s07','s08','s09','s10','s11','s12','s13'...
    ,'s14','s15','s16','s17','s18','s19','s20','s21','s22','s23','s24','s26','s27');
% print('BarPlot','-dpdf','-bestfit');

%% SSEP
% spectrum 
addpath(genpath('/Volumes/TOSHIBA/Research/Imagined_beats/script'))
cd('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Main_task/SSEP/AM4b')
load('rSSEP_aIC_AM4b_no0pad_5s_N20.mat')
load('rSSEP_mIC_AM4b_no0pad_5s_N20.mat')

% aIC duple
meanSSEP_aIC_duple = squeeze(mean(rSSEP_aIC(:,1,1:4,:),1));
% aIC triple
meanSSEP_aIC_triple = squeeze(mean(rSSEP_aIC(:,2,1:4,:),1));
% mIC duple
meanSSEP_mIC_duple = squeeze(mean(rSSEP_mIC(:,1,1:4,:),1));
% mIC triple
meanSSEP_mIC_triple = squeeze(mean(rSSEP_mIC(:,2,1:4,:),1));

%% plot the mean
figure;
plot(freq,meanSSEP_mIC_triple,'LineWidth',2); 
% title('ICrand-triple')
% title('meanSSEP_aIC_triple')
% change to meanSSEP_aIC_duple
% change to meanSSEP_mIC_duple
% change to meanSSEP_aIC_triple
% change to meanSSEP_mIC_triple
xlim([0.5 3])
ylim([0 0.089])
set(gca,'FontSize',18)
xlabel('Frequency (Hz)')
ylabel('Relative amplitude (uV)')
%gridx([1.2 2.4],'k:')
gridx([0.8 2.4],'k:')
legend('BL','PM','IM','Tap')

%% bar chart
% max method
beat1 = 5; % 5, 7, 13
beatf_duple_aIC = squeeze(rSSEP_aIC(:,1,:,beat1));
beatf_triple_aIC = squeeze(rSSEP_aIC(:,2,:,beat1));
beatf_duple_mIC = squeeze(rSSEP_mIC(:,1,:,beat1));
beatf_triple_mIC = squeeze(rSSEP_mIC(:,2,:,beat1));
a5 = [squeeze(rSSEP_aIC(:,1,:,beat1)), squeeze(rSSEP_aIC(:,2,:,beat1))];
m5 = [squeeze(rSSEP_mIC(:,1,:,beat1)), squeeze(rSSEP_mIC(:,2,:,beat1))];

beat2 = 7; % 5, 7, 13
a7 = [squeeze(rSSEP_aIC(:,1,:,beat2)), squeeze(rSSEP_aIC(:,2,:,beat2))];
m7 = [squeeze(rSSEP_mIC(:,1,:,beat2)), squeeze(rSSEP_mIC(:,2,:,beat2))];

beat3 = 13;
a13 = [squeeze(rSSEP_aIC(:,1,:,beat3)), squeeze(rSSEP_aIC(:,2,:,beat3))];
m13 = [squeeze(rSSEP_mIC(:,1,:,beat3)), squeeze(rSSEP_mIC(:,2,:,beat3))];

a = a7 - a5;
m = m7 - m5;
for i = 1:8
    [Ha(i),pa(i)] = ttest(a(:,i));
end

for i = 1:8
    [Hm(i),pm(i)] = ttest(m(:,i));
end
%%
a13(:,9) = squeeze(mean(a13(:,[1,5]),2)); % BL
a13(:,10) = squeeze(mean(a13(:,[2,6]),2)); % PM
a13(:,11) = squeeze(mean(a13(:,[3,7]),2)); % IM
a13(:,12) = squeeze(mean(a13(:,[4,8]),2)); % TAP
a13(:,13) = squeeze(mean(a13(:,1:4),2)); % Bi
a13(:,14) = squeeze(mean(a13(:,5:8),2)); % Ter

m13(:,9) = squeeze(mean(m13(:,[1,5]),2)); % BL
m13(:,10) = squeeze(mean(m13(:,[2,6]),2)); % PM
m13(:,11) = squeeze(mean(m13(:,[3,7]),2)); % IM
m13(:,12) = squeeze(mean(m13(:,[4,8]),2)); % TAP
m13(:,13) = squeeze(mean(m13(:,1:4),2)); % Bi
m13(:,14) = squeeze(mean(m13(:,5:8),2)); % Ter

T_a = array2table(a13); % convert array to table
T_a(:,15) = sub(:);
T_a.Properties.VariableNames(1:15) = {'Bi_BL','Bi_PM','Bi_IM','Bi_TAP',...
    'Ter_BL','Ter_PM','Ter_IM','Ter_TAP',...
    'BL','PM','IM','TAP','Bi','Ter','Subject'};
cd('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Main_task/R/Data/AM4b')
% writetable(T_a,'beatfreq_aIC.csv')

T_m = array2table(m13); % convert array to table
T_m(:,15) = sub(:);
T_m.Properties.VariableNames(1:15) = {'Bi_BL','Bi_PM','Bi_IM','Bi_TAP',...
    'Ter_BL','Ter_PM','Ter_IM','Ter_TAP',...
    'BL','PM','IM','TAP','Bi','Ter','Subject'};
cd('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Main_task/R/Data/AM4b')
% writetable(T_m,'beatfreq_mIC.csv')

%%
a13 = a;
m13 = m;
a13(:,9) = squeeze(mean(a13(:,[1,5]),2)); % BL
a13(:,10) = squeeze(mean(a13(:,[2,6]),2)); % PM
a13(:,11) = squeeze(mean(a13(:,[3,7]),2)); % IM
a13(:,12) = squeeze(mean(a13(:,[4,8]),2)); % TAP
a13(:,13) = squeeze(mean(a13(:,1:4),2)); % Bi
a13(:,14) = squeeze(mean(a13(:,5:8),2)); % Ter

m13(:,9) = squeeze(mean(m13(:,[1,5]),2)); % BL
m13(:,10) = squeeze(mean(m13(:,[2,6]),2)); % PM
m13(:,11) = squeeze(mean(m13(:,[3,7]),2)); % IM
m13(:,12) = squeeze(mean(m13(:,[4,8]),2)); % TAP
m13(:,13) = squeeze(mean(m13(:,1:4),2)); % Bi
m13(:,14) = squeeze(mean(m13(:,5:8),2)); % Ter

T_a = array2table(a13); % convert array to table
T_a(:,15) = sub(:);
T_a.Properties.VariableNames(1:15) = {'Bi_BL','Bi_PM','Bi_IM','Bi_TAP',...
    'Ter_BL','Ter_PM','Ter_IM','Ter_TAP',...
    'BL','PM','IM','TAP','Bi','Ter','Subject'};
cd('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Main_task/R/Data/AM4b')
writetable(T_a,'ampdiff_aIC.csv')

T_m = array2table(m13); % convert array to table
T_m(:,15) = sub(:);
T_m.Properties.VariableNames(1:15) = {'Bi_BL','Bi_PM','Bi_IM','Bi_TAP',...
    'Ter_BL','Ter_PM','Ter_IM','Ter_TAP',...
    'BL','PM','IM','TAP','Bi','Ter','Subject'};
cd('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Main_task/R/Data/AM4b')
writetable(T_m,'ampdiff_mIC.csv')

%% PLV
load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Main_task/PLV/AM4b/timeplvN20_AM4b_2560pnts.mat');
as = squeeze(timeplv(:,:,:,1,3));
ms = squeeze(timeplv(:,:,:,2,3));
am = squeeze(timeplv(:,:,:,1,2));

astimeplv = reshape(permute(as,[1,3,2]),[size(as,1),size(as,2)*size(as,3),1]); % Need to swap d2 amd d3 for the reshape
mstimeplv = reshape(permute(ms,[1,3,2]),[size(as,1),size(as,2)*size(as,3),1]); % Need to swap d2 amd d3 for the reshape
amtimeplv = reshape(permute(am,[1,3,2]),[size(as,1),size(as,2)*size(as,3),1]); % Need to swap d2 amd d3 for the reshape

astimeplv(:,9) = squeeze(mean(astimeplv(:,[1,5]),2)); % BL
astimeplv(:,10) = squeeze(mean(astimeplv(:,[2,6]),2)); %PM
astimeplv(:,11) = squeeze(mean(astimeplv(:,[3,7]),2)); % IM
astimeplv(:,12) = squeeze(mean(astimeplv(:,[4,8]),2)); % TAP
astimeplv(:,13) = squeeze(mean(astimeplv(:,1:4),2)); % Bi
astimeplv(:,14) = squeeze(mean(astimeplv(:,5:8),2)); % Ter

mstimeplv(:,9) = squeeze(mean(mstimeplv(:,[1,5]),2)); % BL
mstimeplv(:,10) = squeeze(mean(mstimeplv(:,[2,6]),2)); %PM
mstimeplv(:,11) = squeeze(mean(mstimeplv(:,[3,7]),2)); % IM
mstimeplv(:,12) = squeeze(mean(mstimeplv(:,[4,8]),2)); % TAP
mstimeplv(:,13) = squeeze(mean(mstimeplv(:,1:4),2)); % Bi
mstimeplv(:,14) = squeeze(mean(mstimeplv(:,5:8),2)); % Ter

amtimeplv(:,9) = squeeze(mean(amtimeplv(:,[1,5]),2)); % BL
amtimeplv(:,10) = squeeze(mean(amtimeplv(:,[2,6]),2)); %PM
amtimeplv(:,11) = squeeze(mean(amtimeplv(:,[3,7]),2)); % IM
amtimeplv(:,12) = squeeze(mean(amtimeplv(:,[4,8]),2)); % TAP
amtimeplv(:,13) = squeeze(mean(amtimeplv(:,1:4),2)); % Bi
amtimeplv(:,14) = squeeze(mean(amtimeplv(:,5:8),2)); % Ter

T_astimeplv = array2table(astimeplv); % convert array to table
T_astimeplv(:,15) = sub(:);
T_astimeplv.Properties.VariableNames(1:15) = {'Bi_BL','Bi_PM','Bi_IM','Bi_TAP',...
    'Ter_BL','Ter_PM','Ter_IM','Ter_TAP',...
    'BL','PM','IM','TAP','Bi','Ter','Subject'};
cd('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Main_task/R/Data/AM4b')
writetable(T_astimeplv,'astimeplv.csv')

T_mstimeplv = array2table(mstimeplv); % convert array to table
T_mstimeplv(:,15) = sub(:);
T_mstimeplv.Properties.VariableNames(1:15) = {'Bi_BL','Bi_PM','Bi_IM','Bi_TAP',...
    'Ter_BL','Ter_PM','Ter_IM','Ter_TAP',...
    'BL','PM','IM','TAP','Bi','Ter','Subject'};
cd('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Main_task/R/Data/AM4b')
writetable(T_mstimeplv,'mstimeplv.csv')

T_amtimeplv = array2table(amtimeplv); % convert array to table
T_amtimeplv(:,15) = sub(:);
T_amtimeplv.Properties.VariableNames(1:15) = {'Bi_BL','Bi_PM','Bi_IM','Bi_TAP',...
    'Ter_BL','Ter_PM','Ter_IM','Ter_TAP',...
    'BL','PM','IM','TAP','Bi','Ter','Subject'};
cd('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Main_task/R/Data/AM4b')
writetable(T_amtimeplv,'amtimeplv.csv')

%% SIFT
load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Main_task/sift/AM4b/SIFTout_AM4b_M270_N20_no_bc.mat')
time = SIFTout{1,1,1}.erWinCenterTimes;
freq = SIFTout{1,1,1}.freqs;

FOIs = find(freq == 0.5); % beat freq 2:3, theta 4:8, alpha 8:12, beta 12:30 
FOIe = find(freq == 5); % beat freq 2:3, theta 4:8, alpha 8:12, beta 12:30 
cscale = [0 3e-3];

maflow0 = zeros(length(sub),length(meter),length(cond),length(freq),length(time));
amflow0 = zeros(length(sub),length(meter),length(cond),length(freq),length(time));

aIC = [1		1	1	1	1		2	1		1	1	1	1	1	1	1	1		1	1	1		1	1]; % follow the order of the index e.g. if aIC is 15 and mIC is 2 then new aIC = 2, mIC = 1
mIC = [2		2	2	2	2		1	2		2	2	2	2	2	2	2	2		2	2	2		2	2];

for nsub = 1:length(sub)
    for nmeter = 1:length(meter)
        for ncond = 1:length(cond)
            maflow0(nsub,nmeter,ncond,:,:) = squeeze(SIFTout{nsub,nmeter,ncond}.dDTF08(aIC(nsub),mIC(nsub),:,:));
            amflow0(nsub,nmeter,ncond,:,:) = squeeze(SIFTout{nsub,nmeter,ncond}.dDTF08(mIC(nsub),aIC(nsub),:,:));
        end
    end
end

%
maflow0 = permute(maflow0,[1 3 2 4 5]); % swap the order of cond and meter for extracting data
amflow0 = permute(amflow0,[1 3 2 4 5]);
maflow = reshape(maflow0,[length(sub) length(meter)*length(cond) length(freq) length(time)]);
amflow = reshape(amflow0,[length(sub) length(meter)*length(cond) length(freq) length(time)]);

% tf plot amflow
figure;
for ncond = 1:8
    subplot(2,4,ncond)
    imagesc(time,freq(FOIs:FOIe),squeeze(mean(amflow(:,ncond,FOIs:FOIe,:),1)));axis xy; colormap(jet); caxis(cscale);
end
% tf plot maflow
figure;
for ncond = 1:8
    subplot(2,4,ncond)
    imagesc(time,freq(FOIs:FOIe),squeeze(mean(maflow(:,ncond,FOIs:FOIe,:),1)));axis xy; colormap(jet); caxis(cscale);
end

% Average across meter 
figure;
for ncond = 1:4
    subplot(1,5,ncond)
    imagesc(time,freq(FOIs:FOIe),squeeze(mean(mean(amflow0(:,ncond,:,FOIs:FOIe,:),1),3)));axis xy; colormap(jet); caxis(cscale)
end
subplot(1,5,5)
mean_am = squeeze(mean(mean(mean(amflow(:,ncond,FOIs:FOIe,:),4),1),2));
std_am = squeeze(std(mean(mean(amflow(:,ncond,FOIs:FOIe,:),4),2),[],1));
plotShadedError(freq(FOIs:FOIe),mean_am,std_am);
xlim([0.5 25])
view(90,90)
set(gca,'xdir','reverse')

figure;
for ncond = 1:4
    subplot(1,5,ncond)
    imagesc(time,freq(FOIs:FOIe),squeeze(mean(mean(maflow0(:,ncond,:,FOIs:FOIe,:),1),3)));axis xy; colormap(jet); caxis(cscale)
end
subplot(1,5,5)
mean_ma = squeeze(mean(mean(mean(maflow(:,ncond,FOIs:FOIe,:),4),1),2));
std_ma = squeeze(std(mean(mean(maflow(:,ncond,FOIs:FOIe,:),4),2),[],1));
plotShadedError(freq(FOIs:FOIe),mean_am,std_ma);
xlim([0.5 5])
view(90,90)
set(gca,'xdir','reverse')

% plot the color bar
figure;imagesc(time,freq(FOIs:FOIe),squeeze(mean(mean(amflow0(:,1,:,FOIs:FOIe,:),1),3)));axis xy; colormap(jet); caxis(cscale)
c = colorbar;
c.Location = 'northoutside';

%% bar plot for beat (20), meter rate (4, 8) dDTF08
% average duple triple together
beat_mean_amflow = squeeze(mean(mean(amflow0(:,:,:,20,:),3),5));
beat_mean_maflow = squeeze(mean(mean(maflow0(:,:,:,20,:),3),5));

meter_mean_amflow = squeeze(mean(mean(mean(amflow0(:,:,:,[4 8],:),3),4),5));
meter_mean_maflow = squeeze(mean(mean(mean(maflow0(:,:,:,[4 8],:),3),4),5));


beat_mean_amflow = squeeze(mean(amflow(:,:,20,:),4));
beat_mean_maflow = squeeze(mean(maflow(:,:,20,:),4));

meter08_mean_amflow = squeeze(mean(amflow(:,:,4,:),4));
meter08_mean_maflow = squeeze(mean(maflow(:,:,4,:),4));

meter12_mean_amflow = squeeze(mean(amflow(:,:,8,:),4));
meter12_mean_maflow = squeeze(mean(maflow(:,:,8,:),4));

am_ma_beat = [beat_mean_amflow beat_mean_maflow];
am_ma_meter08 = [meter08_mean_amflow meter08_mean_maflow];
am_ma_meter12 = [meter12_mean_amflow meter12_mean_maflow];
am_ma_meter = 0.5*(am_ma_meter08 + am_ma_meter12);

%% Average across freqs and times
FOIs = find(freq == 2); % beat freq 2:3, theta 4:8, alpha 8:12, beta 12:30 
FOIe = find(freq == 3); % beat freq 2:3, theta 4:8, alpha 8:12, beta 12:30 

mean_amflow = squeeze(mean(mean(amflow(:,:,FOIs:FOIe,:),4),3));
mean_maflow = squeeze(mean(mean(maflow(:,:,FOIs:FOIe,:),4),3));

%% Output the csv for R
FOIs = find(freq == 8); % beat freq 2:3, theta 4:8, alpha 8:12, beta 12:30 
FOIe = find(freq == 12); % beat freq 2:3, theta 4:8, alpha 8:12, beta 12:30 

% Average across freqs and times
mean_amflow = squeeze(mean(mean(amflow(:,:,FOIs:FOIe,:),4),3));
mean_maflow = squeeze(mean(mean(maflow(:,:,FOIs:FOIe,:),4),3));
%%
mean_amflow(:,9) = squeeze(mean(mean(mean(amflow(:,[1,5],FOIs:FOIe,:),4),3),2)); % BL
mean_amflow(:,10) = squeeze(mean(mean(mean(amflow(:,[2,6],FOIs:FOIe,:),4),3),2)); %PM
mean_amflow(:,11) = squeeze(mean(mean(mean(amflow(:,[3,7],FOIs:FOIe,:),4),3),2)); % IM
mean_amflow(:,12) = squeeze(mean(mean(mean(amflow(:,[4,8],FOIs:FOIe,:),4),3),2)); % TAP
mean_amflow(:,13) = squeeze(mean(mean(mean(amflow(:,1:4,FOIs:FOIe,:),4),3),2)); % Bi
mean_amflow(:,14) = squeeze(mean(mean(mean(amflow(:,5:8,FOIs:FOIe,:),4),3),2)); % Ter

mean_maflow(:,9) = squeeze(mean(mean(mean(maflow(:,[1,5],FOIs:FOIe,:),4),3),2)); % BL
mean_maflow(:,10) = squeeze(mean(mean(mean(maflow(:,[2,6],FOIs:FOIe,:),4),3),2)); %PM
mean_maflow(:,11) = squeeze(mean(mean(mean(maflow(:,[3,7],FOIs:FOIe,:),4),3),2)); % IM
mean_maflow(:,12) = squeeze(mean(mean(mean(maflow(:,[4,8],FOIs:FOIe,:),4),3),2)); % TAP
mean_maflow(:,13) = squeeze(mean(mean(mean(maflow(:,1:4,FOIs:FOIe,:),4),3),2)); % Bi
mean_maflow(:,14) = squeeze(mean(mean(mean(maflow(:,5:8,FOIs:FOIe,:),4),3),2)); % Ter

T_mean_amflow = array2table(mean_amflow); % convert array to table
T_mean_amflow(:,15) = sub(:);
T_mean_amflow.Properties.VariableNames(1:15) = {'Bi_BL','Bi_PM','Bi_IM','Bi_TAP',...
    'Ter_BL','Ter_PM','Ter_IM','Ter_TAP',...
    'BL','PM','IM','TAP','Bi','Ter','Subject'};
if FOIs == find(freq == 2)
    filename = 'amflow_2-3Hz.csv';
elseif FOIs == find(freq == 8)
    filename = 'amflow_8-12Hz.csv';
end
cd('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Main_task/R/Data/AM4b/')
writetable(T_mean_amflow,filename)

T_mean_maflow = array2table(mean_maflow);
T_mean_maflow(:,15) = sub(:);
T_mean_maflow.Properties.VariableNames(1:15) = {'Bi_BL','Bi_PM','Bi_IM','Bi_TAP',...
    'Ter_BL','Ter_PM','Ter_IM','Ter_TAP',...
    'BL','PM','IM','TAP','Bi','Ter','Subject'};
if FOIs == find(freq == 2)
    filename = 'maflow_2-3Hz.csv';
elseif FOIs == find(freq == 8)
    filename = 'maflow_8-12Hz.csv';
end
cd('/Volumes/TOSHIMA EXT/Research/Imagined_beats/real_exp/results/Main_task/R/Data/AM4b/')
writetable(T_mean_maflow,filename)

%% Plot channel projections from ICs 
addpath(genpath('/Volumes/TOSHIBA/Research/Imagined_beats/script'))
load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/figures/AM4b_20110513/illustrator/aICproj.mat')

proj = squeeze(mean(erpdata{1},2)).*hotspot;
% mean_proj = squeeze(mean(proj,2));
% std_proj = squeeze(std(proj,[],2));
% figure;
% plotShadedError(erptimes,mean_proj,std_proj);
figure;
plot(erptimes,proj,'LineWidth',2,'color','k')
gridx(0,'k:')
xlim([-100 300])
set(gca,'FontSize',18)
xlabel('Time (ms)')
ylabel('Relative amplitude (uV)')

%%
load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/figures/AM4b_20110513/illustrator/mICproj.mat')
proj = squeeze(mean(erpdata{1},2)).*coldspot;
% mean_proj = squeeze(mean(proj,2));
% std_proj = squeeze(std(proj,[],2));
% figure;
% plotShadedError(erptimes,mean_proj,std_proj);
figure;
plot(erptimes,proj,'LineWidth',2,'color','k')
gridx(0,'k:')
xlim([-100 150])
ylim([-0.5 0.1])
set(gca,'FontSize',18)
xlabel('Time (ms)')
ylabel('Relative amplitude (uV)')

%% R1 SIFT model sweeping
close all
conditions = {'BL','PM','IM','TAP'};

nmorder = Morder;
freqs = CAT.Conn.freqs;

for i = 1:4
figure;
plot(freqs,squeeze(mean(am_dDTF08(Morder,:,i,:),2)),'LineWidth',0.5)
hold on 
plot(freqs,squeeze(mean(am_dDTF08_30_300(30,:,i,:),2)),'LineWidth',4,'color','k')
hold on 
plot(freqs,squeeze(mean(am_dDTF08_30_300(300,:,i,:),2)),'LineWidth',4,'color','k')
xlim([0 12])
ylim([0 0.015])
filename = strcat('Binary',conditions(i));
xlabel('Frequency (Hz)'); ylabel('dDTF08'); title(filename)
gridx([0.8, 1.2, 1.6,2.4],'k:')
set(gca,'fontsize', 18)
end

%% R1 Mocap
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

%% deal with s01 different configuration
m4 = mocap_time_int(1,:,:,:,4,:);
m6 = mocap_time_int(1,:,:,:,6,:);
mocap_time_int(1,:,:,:,4,:) = m6;
mocap_time_int(1,:,:,:,6,:) = m4;

figure; plot(times,squeeze(mean(mean(mocap_time_int(:,:,1,:,nmarker,:),1),2))*1000);
set(gca,'FontSize',18)
xlabel('Time (s)')
ylabel('Distance (mm)')
xlim([-1 5])
gridx(0,'k:')
legend('BL','PM','IM','Tap')

figure; plot(times,squeeze(mean(mean(mocap_time_int(:,:,2,:,nmarker,:),1),2))*1000);
set(gca,'FontSize',18)
xlabel('Time (s)')
ylabel('Distance (mm)')
xlim([-1 5])
gridx(0,'k:')
legend('BL','PM','IM','Tap')

% load freq domain
load('SSEP_MoCap_new.mat');

% deal with s01 different configuration
m4 = fft_out(1,:,:,:,4,:);
m6 = fft_out(1,:,:,:,6,:);
fft_out(1,:,:,:,4,:) = m6;
fft_out(1,:,:,:,6,:) = m4;
X = categorical({'BL','PM','IM','Tap'});

meanSSEP_duple = squeeze(mean(mean(fft_out(:,:,1,:,:,:),1),2))*1000;
meanSSEP_triple = squeeze(mean(mean(fft_out(:,:,2,:,:,:),1),2))*1000;

for nmarker = 1:10
figure;bar(X,squeeze(meanSSEP_duple(:,nmarker,25)));set(gca,'FontSize',18);ylim([0 2]);axis off % 1.2 Hz
filename = strcat('duple_m',num2str(nmarker),'.pdf');
saveas(gcf,filename)
figure;bar(X,squeeze(meanSSEP_duple(:,nmarker,17)));set(gca,'FontSize',18);ylim([0 2]);axis off % 0.8 Hz
filename = strcat('triple_m',num2str(nmarker),'.pdf');
saveas(gcf,filename)

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
