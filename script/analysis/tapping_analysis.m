addpath('/Volumes/TOSHIBA/Research/Imagined_beats/script/analysis')
addpath('/Volumes/TOSHIBA/Research/Imagined_beats/script/JI_supporting_MatLabFiles')
addpath('/Volumes/TOSHIBA/Research/Imagined_beats/script/preprocessing')

%% Localizeer - TAP (spontaneous tapping) 
clear 
close all
clc

dataDir = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/SMT';
files = dir(fullfile(dataDir,'*tap1.set'));
datasets = {files.name};
tap = {};
ITI = {};

for iS = 1:length(datasets)
    datasetFile = datasets{iS};
    EEG = pop_loadset('filename',datasetFile ,'filepath', dataDir);
    for nt = 1:length(EEG.event)
        if string(EEG.event(nt).type) == 'Tap' % only extract the time point of the tap events  
            tempt(nt) = EEG.event(nt).latency/EEG.srate*1000; % convert from sample point to time 
        else tempt(nt) = 0;
        end
    end    
    tempITI = diff(tempt);
    tap{iS} = tempt;
    ITI0{iS} = tempITI;
    ITI{iS} = tempITI(find(isoutlier(tempITI,'median') == 0)); % Exclude the outliers 
    means(iS) = mean(ITI{iS});
    stds(iS) = std(ITI{iS}); 
    clear tempt EEG nt tempITI
end

% fast, slow tappers based on the means of ITI; stable and unstable tappers based
% on the stds of ITI
fast_tapper = find(means < median(means));
slow_tapper = find(means > median(means));
stable_tapper = find(stds < median(stds));
unstable_tapper = find(stds > median(stds));

% checking their tapping behaviors 
% load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/SMT/ITI_means.mat')
% load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/SMT/ITI_stds.mat')

figure;bar(means);title('Average of ITI');
figure;bar(stds);title('Variability of ITI');
gridy(median(stds),'r:')

figure;plot(ITI{2},'.') % plot the high var tappers
cd('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/trigger_channels/')
EEG = pop_loadset('s03_evtag_512_triggers.set');
figure;plot(EEG.times,EEG.data);title('tap triggers')

%% Localizer - SYNC (synchronize with beats in 600 ms)
clear
close all
clc
cd '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/sync'
dataDir = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/sync/';
files = dir(fullfile(dataDir,'*sync3s.set'));
datasets = {files.name};
for iS = 1:length(datasets)
    datasetFile = datasets{iS};
    EEG = pop_loadset('filename',datasetFile ,'filepath', dataDir);

    for n = 1:length(EEG.event)
        if string(EEG.event(n).type) == 'Tap'
           taps (n,1) = EEG.event(n).latency/EEG.srate*1000;
        elseif string(EEG.event(n).type) == 'WB'
           listens(n,1) = EEG.event(n).latency/EEG.srate*1000;
        end
    end
new_taps = taps(taps~=0);
new_listens = listens(listens~=0);
tap_results{iS} = calc_tap_z(new_taps, new_listens);
relative_phase{iS} = tap_results{iS}.rp(find(isoutlier(tap_results{iS}.rp,'median') == 0));
asynchrony{iS} = tap_results{iS}.async(find(isoutlier(tap_results{iS}.async,'median') == 0));
ITI{iS} = tap_results{iS}.iti(find(isoutlier(tap_results{iS}.iti,'median') == 0));
clear new_taps new_listens taps listens
mean_ITI(iS) = mean(ITI{iS});
stds(iS) = std(ITI{iS}); 
mean_asynchrony(iS) = mean(asynchrony{iS});
mean_relative_phase(iS) = nanmean(relative_phase{iS}); % use nanmean instead of mean to average across non nan 
end

%%
% fast, slow tappers based on the means of ITI; stable and unstable tappers based
% on the stds of ITI
fast_tapper = find(means < median(means));
slow_tapper = find(means > median(means));
stable_tapper = find(stds < median(stds));
unstable_tapper = find(stds > median(stds));

% load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/sync/mean_ITI.mat')
% load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/sync/stds.mat')
% load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/sync/mean_asynchrony.mat')
% load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/sync/mean_relative_phase.mat')

figure;bar(mean_ITI);title('Average of ITI');
figure;bar(mean_asynchrony);title('Average of asynchrony');
figure;bar(mean_relative_phase);title('Average of relative phase');

figure;plot(ITI{2},'.') % plot the high var tappers
cd('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/trigger_channels/')
EEG = pop_loadset('s03_evtag_512_triggers.set');
figure;plot(EEG.times,EEG.data);title('tap triggers')


%% plot the results in sync
figure; plot(tap_results{1}.t_rp,tap_results{1}.rp,'.')
title('Relative phase')
figure; plot(tap_results{1}.t_iti,tap_results{1}.iti,'.')
title('ITI')
figure; plot(tap_results{1}.t_async,tap_results{1}.async,'.')
title('Asynchrony')

%% Clasify ERP based on relphase(positive, negative, high, low)
EEG = pop_loadset('filename','s01_IMB_cleaned_binica_dipfit_sync3tap_e.set','filepath','/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/sync/');
EEG = pop_selectevent( EEG, 'omitepoch',[1:3 303] ,'deleteevents','off','deleteepochs','on','invertepochs','off');
load('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/sync/sync.mat')
relphase = sync{1}.rp;
relphase = relphase(1:298);
ind_pos = find(relphase >= 0);
ind_neg = find(relphase <0);
pos_async = squeeze(mean(mean(EEG.data(:,:,ind_pos),1),3));
neg_async = squeeze(mean(mean(EEG.data(:,:,ind_neg),1),3));
plot(EEG.times,pos_async,'LineWidth',2)
hold on 
plot(EEG.times,neg_async,'LineWidth',2)
legend('Positive rp','Negative rp')

ind_good = find(abs(relphase) >= median(abs(relphase)));
ind_bad = find(abs(relphase) < median(abs(relphase)));
good_async = squeeze(mean(mean(EEG.data(:,:,ind_good),1),3));
bad_async = squeeze(mean(mean(EEG.data(:,:,ind_bad),1),3));
figure;
plot(EEG.times,good_async,'LineWidth',2)
hold on 
plot(EEG.times,bad_async,'LineWidth',2)
legend('Good rp','Bad rp')

legend('Positive rp','Negative rp')

%% IMB Tapping performance fft - get the one tapping channel from the s0x_evtag_512.set file 
clear 
close all
clc
addpath(genpath('/Volumes/TOSHIBA EXT/Research/Imagined_beats/script'))
tapbeh_path = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/tapbeh/triple';
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
    for ntrial = 1:size(EEG.data,3)
        [TAP(ntrial,:),freq] = calc_fft(EEG.data(1,:,ntrial),dt,L);
    end
    size(TAP)
    P2 = abs(TAP/L)*2;
    P2 = mean(P2,1);
    fft_out(nsub,:) = P2;
%     fft_out(nsub,2:end-1) = 2*fft_out(nsub,2:end-1);
%     for n = 11:size(fft_out(nsub,:),2)-11
%         fft_out_subt(nsub,n) = fft_out(nsub,n) - ...
%         mean(fft_out(nsub,[n-5, n-4, n-3, n+3, n+4, n+5]));
%     end
end
all_subs = fft_out;
% ff = f(1:size((fft_out_subt(nsub,:)),2));
% all_subs = squeeze(fft_out_subt);
% all_subs(all_subs< 0) = 0; % force negative values to zero

%% Rewrite tap analysis based on the new freq analysis method 20201220 - Zoe
clear 
close all
clc
addpath(genpath('/Volumes/TOSHIBA EXT/Research/Imagined_beats/script'))
tapbeh_path = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/tapbeh/triple';
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

%%
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

%%
freq_s = find(freq == 0.4);
freq_e = find(freq == 3);
sub_to_plot = [1,3:nsub];
outliers = [2];
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
%gridx([1.2 2.4],'r:');
gridx([0.8 1.6 2.4],'r:');
xlabel('Frequency (Hz)')
ylabel('Relative Amplitude (uV)')

legend('s02','s03','s04','s05','s06','s07','s08','s09','s10','s11','s12','s13'...
    ,'s14','s15','s16','s17','s18','s19','s20','s21','s22','s23','s24','s26','s27');
