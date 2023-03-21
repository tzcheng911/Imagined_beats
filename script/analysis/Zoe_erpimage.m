eeglab
clear
clc

% File path 
addpath(genpath('/Volumes/TOSHIBA/Research/Imagined_beats/script'))
EEG_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/sync'; % /Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/preprocessed/epoch/SB_WB
cd(EEG_path)
files = dir(fullfile(EEG_path,'*sync3s_e.set')); % triple_SB_e.set
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

load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/sync/aIC_averagebaslined_ersp_itc.mat'); % mIC_averagebaslined_ersp.mat
%save ersp_itc_triple_SB_aIC_nb ersp_triple_SB_aIC_nb itc_triple_SB_aIC_nb times freqs
figure;plot(freqs,squeeze(mean(mean(ersp,1),3)));
figure;imagesc(times,freqs,10*log10(squeeze(mean(ersp,1)))); axis xy; colormap(jet);  colorbar
figure;imagesc(times,freqs,squeeze(mean(itc,1))); axis xy; colormap(jet);  colorbar

x = 1000*(0:1/2.4:12/2.4-1/2.4); 
