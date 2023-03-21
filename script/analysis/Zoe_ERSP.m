%eeglab
clear
close all
clc

% File path 
addpath(genpath('/Volumes/TOSHIBA/Research/Imagined_beats/script'))
EEG_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/SMT'; % /Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/preprocessed/epoch/SB_WB
cd(EEG_path)
files = dir(fullfile(EEG_path,'*tap1_e.set')); % triple_SB_e.set
names = {files.name};

% Parameters
% am selection 4b
new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	6	4	1	1	5	8	4];
new_amIC(2,:) = [8	1	11	11	10	11	8	4	13	4	15	7	18	8	16	21	12	36	4	17	6	9	14	21	8];

FOI = [1 50];
ersp = zeros(length(names),12,200);

%% Extract localizer individual's ERSP ITC
IC = 2;

for nsub = 1:length(names)
    tempEEG = names{nsub};
    parts_cleanEEG = cellstr(split(tempEEG,'.'));
    EEG = pop_loadset('filename',tempEEG ,'filepath', EEG_path); % epoched data
    EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:); % fix the missing icaact
    figure; 
    [tmpersp,tmpitc,powbase,times,freqs,erspboot,itcboot] = ...
    newtimef( EEG.icaact(new_amIC(IC,nsub),:,:), EEG.pnts, [EEG.xmin EEG.xmax]*1000, EEG.srate,...
    [0 0], 'topovec', EEG.icawinv(:,new_amIC(IC,nsub)),'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo,...
    'caption', strcat('IC',num2str(new_amIC(IC,nsub))),'baseline',[EEG.xmin EEG.xmax]*1000, 'freqs', FOI, ...
    'timesout',200,'plotphase', 'off', 'padratio', 2,'trialbase','off','scale','abs','itctype','coher');
ersp(nsub,:,:) = tmpersp;
itc(nsub,:,:) = abs(tmpitc);
clear tmpersp EEG
end

%save ersp_itc_triple_SB_aIC_nb ersp_triple_SB_aIC_nb itc_triple_SB_aIC_nb times freqs
cd('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/SMT')
save mIC_averagebaslined_ersp_itc_tap1 ersp freqs times itc
figure;plot(freqs,squeeze(mean(mean(ersp,1),3)));
figure;imagesc(times,freqs,10*log10(squeeze(mean(ersp,1)))); axis xy; colormap(jet);  colorbar
figure;imagesc(times,freqs,squeeze(mean(itc,1))); axis xy; colormap(jet);  colorbar

x = 1000*(0:1/2.4:12/2.4-1/2.4); 

%% Extract individual's ERSP ITC
for nsub = 1:length(names)
    tempEEG = names{nsub};
    parts_cleanEEG = cellstr(split(tempEEG,'.'));
    EEG = pop_loadset('filename',tempEEG ,'filepath', EEG_path); % epoched data
    figure; 
    [tmpersp,itc,powbase,times,freqs,erspboot,itcboot] = ...
    newtimef( EEG.icaact(new_amIC(1,nsub),:,:), EEG.pnts, [EEG.xmin EEG.xmax]*1000, EEG.srate,...
    [0 0], 'topovec', EEG.icawinv(:,new_amIC(1,nsub)),'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo,...
    'caption', strcat('IC',num2str(new_amIC(1,nsub))),'baseline',NaN, 'freqs', FOI, ...
    'timesout',200,'plotphase', 'off', 'padratio', 2,'trialbase','off','scale','abs','itctype','coher');
ersp_triple_SB_aIC_nb(nsub,:,:) = tmpersp;
itc_triple_SB_aIC_nb(nsub,:,:) = abs(itc);
clear tmpersp EEG
end
save ersp_itc_triple_SB_aIC_nb ersp_triple_SB_aIC_nb itc_triple_SB_aIC_nb times freqs
figure;plot(freqs,squeeze(mean(mean(ersp_triple_SB_aIC_nb,1),3)));

x = 1000*(0:1/2.4:12/2.4-1/2.4); 
%% Plot averaged ERSP
figure;imagesc(times,freqs,10*log10(squeeze(mean(ersp_duple_SB_aIC_nb,1)))); axis xy; colormap(jet);  colorbar
figure;imagesc(times,freqs,squeeze(mean(itc_duple_SB_aIC_nb,1))); axis xy; colormap(jet);  colorbar

figure; subplot(2,1,1)
imagesc(times,freqs,10*log10(squeeze(mean(ersp_duple_SB_e,1)))); axis xy; colormap(jet); colorbar; gridx(x(1:3));
title('Duple ERSP - N=20')
subplot(2,1,2)
imagesc(times,freqs,10*log10(squeeze(mean(ersp_triple_SB_e,1)))); axis xy; colormap(jet); colorbar; gridx(x(1:3));
title('Triple ERSP - N=20')

figure; subplot(2,1,1)
imagesc(times,freqs,(squeeze(mean(itc_duple_SB_e,1)))); axis xy; colormap(jet); colorbar; gridx(x(1:3));
title('Duple ITC - N=20')
subplot(2,1,2)
imagesc(times,freqs,(squeeze(mean(itc_triple_SB_e,1)))); axis xy; colormap(jet); colorbar; gridx(x(1:3));
title('Triple ITC - N=20')

title('ersp-duple-PB');gridx(x);

%%
figure; plot(times,10*log10(squeeze(mean(mean(ersp_triple_SB_e(:,16:46,:),1),2))),'LineWidth',2)
gridx(x(1:3));
title('ersp_duple_BL');

%% test ERSP
IC = 6;
FOI = [5 40];
figure; 
    [tmpersp,itc,powbase,times,freqs,erspboot,itcboot] = ...
    newtimef( EEG.icaact(IC,:,:), EEG.pnts, [EEG.xmin EEG.xmax]*1000, EEG.srate,...
    [3 0.5], 'topovec', EEG.icawinv(:,IC),'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo,...
    'caption', strcat('IC',num2str(amIC(1,nsub))),'baseline', [-500 0], 'freqs', FOI, ...
    'timesout',200,'plotphase', 'off', 'padratio', 1,'trialbase','off','scale','log');

%% calculate crossf
% Parameters
aIC = 1;
mIC = 2;
cycle = 0;

% Get the sound env 
[stimuli,stimuli_fs] = audioread('/Users/t.z.cheng/Google_Drive/Research/Imaginedbeat/materials/Socal_drumbeat.mp3');
sound = stimuli(1:1/2.4*stimuli_fs,1); % create 1/2.4 IOI

for nsub = 1:length(names)
    tempEEG = names{nsub};
    parts_cleanEEG = cellstr(split(tempEEG,'.'));
    EEG = pop_loadset('filename',tempEEG ,'filepath', EEG_path); % epoched data
    
    trial_length = round(EEG.xmax);
    EEG_fs = EEG.srate;

    catsound = repmat(sound,[trial_length*2.4,1]); % repeat for 60 times (5 x 12) for the longest possible randomization
    env_catsound = abs(hilbert(catsound)); % get the envelop of the sound stimuli
    env_catsound_r = resample(env_catsound,EEG_fs,stimuli_fs); % downsample to match EEG signal

    soundtrial = repmat(env_catsound_r,[1,EEG.trials]);
    onset = find(EEG.times == 0);
    EEG.icaact(100,onset:end,:) = soundtrial(1:size(EEG.icaact,2)-onset+1,:); % assign the sound trials to IC100 starting from the onset
    
    figure; 
    [coh,mcoh,timesout,freqsout,cohboot,cohangles,allcoher,alltfX,alltfY]...
    = pop_newcrossf(EEG, 0, amIC(mIC,nsub), 100, [EEG.xmin*1000 EEG.xmax*1000], [cycle         0.5] ,...
    'type', 'phasecoher','padratio',4,'freqs',FOI,'baseline', NaN);
    am_coh_duple(nsub,:,:) = coh;
%    cohangle_duple(nsub,:,:) = cohangles;
    clear coh cohangles EEG
end
% save am_coh_duple_350_5cycle am_coh_duple timesout freqsout
figure;plot(freqsout,squeeze(mean(mean(am_coh_duple,1),3)));
