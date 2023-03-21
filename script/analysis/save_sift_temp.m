% preprocess
EEG = pop_loadset('filename', setname, 'filepath', datapath);
WindowLengthSec   = 0.5; % sliding window length in seconds
WindowStepSizeSec = 0.033; % sliding window step size in seconds
ModelOrder = 15;
[EEG, prepcfg] = pre_prepData('ALLEEG',EEG(iC),'VerbosityLevel',1, 'NormalizeData',{'Method',{'ensemble' 'time'}});
[EEG, modfitcfg] = pop_est_fitMVAR(EEG,'nogui','algorithm','Vieira-Morf','winlen',WindowLengthSec,...
      'winstep',WindowStepSizeSec,'morder',ModelOrder,'verb',1);
[EEG conncfg] = pop_est_mvarConnectivity(EEG,'verb',1,'freqs', 1:50 ,...
       'connmethods',{'dDTF08','nPDC', 'pCoh', 'S'},'absvalsq',true,'spectraldecibels',true);
        
%%
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/insert_rbd/sift/output'; 
for n = 1:16
filename = strcat(ALLEEG(n).setname,'_sift');
ALLEEG(n) = pop_saveset(ALLEEG(n),'filename',filename,'filepath',filepath);
end

%% Visualization
clear all
siftDir = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/sifts';
siftfiles = dir(fullfile(siftDir,'*sift.set'));
siftsets = {siftfiles.name};
load('cfg.mat');
%length(siftsets)
for iS = 1:3
    siftsetsFile = siftsets{iS};
    EEG = pop_loadset('filename',siftsetsFile ,'filepath', siftDir);
    EEG.CAT.configs.vis_TimeFreqGrid = cfg;
    vis_TimeFreqGrid('ALLEEG',EEG, 'Conn',EEG.CAT.Conn,cfg);
    clear EEG
end

% [EEG cfg] = pop_vis_TimeFreqGrid(EEG);


