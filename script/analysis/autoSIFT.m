% autorun SIFT preprocessing for all files
%
% modified from Makoto's code

ROImethod = 'median';
conditions = {'hand+saccade', 'hand_lift'};

%% loop  over subjects
datapath         = '/data/projects/EFRI/Pointing/pointing_ICA/Pointing_epoched_rs_STUDY/SIFT';
%sets = cellstr(pickfiles(fullfile(datapath,'SIFT',''), {'201','.set' ROImethod,'hand+saccade'},{},{'hand'}));
subjs = {'POINTING03','POINTING04','POINTING05','POINTING06','POINTING07'}; %subset of 5 cases which have proper events

for iS = 1:length(subjs);
    
    %load two conditions
    clear EEG
    for iC = 1:length(conditions),
      setname = sprintf('%s_201_%s_srcpot(%s)_epoched.set',subjs{iS}, conditions{iC}, ROImethod);
      EEG(iC) = pop_loadset('filename', setname, 'filepath', datapath);
    end
    
%     % cut data
%     if EEG.xmax > 299.998
%         EEG = pop_select( EEG,'time',[0 299.998] );
%     end
    
    % enter parameters for preprocessing
    WindowLengthSec   = 0.5; % sliding window length in seconds
    WindowStepSizeSec = 0.03; % sliding window step size in seconds
    ModelOrder = 15;
    
    % preprocess
    clear newEEG
    for iC = 1:length(conditions),
      [newEEG(iC), prepcfg] = pre_prepData('ALLEEG',EEG(iC),'VerbosityLevel',1, 'NormalizeData',{'Method',{'ensemble' 'time'}});
    end
    EEG = newEEG;
    
    % estimate and select model order (plus a little bit heuristic)
%     varargout  = pop_est_selModelOrder(EEG, 0, 'icselector', {'aic','fpe','sbc','hq','ris'},'morder', [1 30], 'winlen', WindowLengthSec, 'winstep', WindowStepSizeSec, 'prctWinToSample', 100, 'normalize',  {'temporal', 'ensemble'}, 'verb', 0);
%     EEG.CAT.IC = varargout{1,1};
%     clear varargout
%     moSbc = max(EEG.CAT.IC.sbc.popt);
%     moHq  = max(EEG.CAT.IC.hq.popt);
%     moRis = max(EEG.CAT.IC.ris.popt);
%     if     moHq < moSbc+moRis && moHq <= 16 % to prevent moHq becomes too large
%         ModelOrder = moHq;
%     elseif moSbc >= moRis && moSbc <= 16
%         ModelOrder = moSbc;
%     elseif moRis <= 16
%         ModelOrder = moRis;
%     else
%         error('ModelOrder is too large!')
%     end
    
    % estimate MVAR fit
    [EEG, modfitcfg] = pop_est_fitMVAR(EEG,'nogui','algorithm','Vieira-Morf','winlen',WindowLengthSec,...
      'winstep',WindowStepSizeSec,'morder',ModelOrder,'verb',1);

    % test the MVAR fit
%     ALLEEG = EEG;
%     %varargout = pop_est_validateMVAR(ALLEEG,0, 'prctWinToSample', 100, 'alpha', 0.05);
%     for iC = 1:length(conditions),
%       varargout = pop_est_validateMVAR(EEG{iC},0, 'prctWinToSample', 100, 'alpha', 0.05);
%       EEG(iC).CAT.validateMVAR = varargout;
%     end
%     clear varargout ALLEEG
    
    % estimate connectivity (new: log space)
     [EEG conncfg] = pop_est_mvarConnectivity(EEG,'verb',1,'freqs', 1:50 ,...
       'connmethods',{'dDTF08','nPDC', 'pCoh', 'S'},'absvalsq',true,'spectraldecibels',true);
    %[EEG conncfg] = pop_est_mvarConnectivity(EEG,'verb',false,'freqs', logspace(0,2.4,200) ,'connmethods',{'dDTF08','RPDC', 'pCoh', 'S'},'absvalsq',true,'spectraldecibels',true);
    % [EEG conncfg] = pop_est_mvarConnectivity(EEG,'verb',false,'freqs', logspace(0.30103,2.407,200) ,'connmethods',{'dDTF08','RPDC', 'pCoh', 'S'},'absvalsq',true,'spectraldecibels',true);
    
%     % run percent consistency test
%     EEG.CAT.validateMVAR.PC           = est_checkMVARConsistency(EEG,EEG.CAT.MODEL,0);
%     
%     % run stationarity test
%     EEG.CAT.validateMVAR.stationarity = est_checkMVARStability(  EEG,EEG.CAT.MODEL,0);
    
    % save data
    for iC = 1:length(conditions),
      setname = sprintf('%s_202_%s_srcpot(%s)_epoched_SIFT_%d.set',subjs{iS}, conditions{iC}, ROImethod,ModelOrder);
      EEG(iC) = pop_saveset( EEG(iC), 'filename', setname, 'filepath', datapath);
    end
    close all
end

%% postprocess and save
% this done after using gui because code above keeps erroring--seems not to handle arrays of EEG well
% standard preprocessing: Sources
% model fitting using order=15, window 0.5, step 0.03
% full validation
% connecitvity
%   then run the below to save results, then visualize. ** be sure to set iS!
% visualize partial, 99.9, no marginal, simple threshold 97.5, font size 10,9
iS = 5
for iC = 1:2,
  setname = sprintf('%s_202_%s_srcpot(%s)_epoched_SIFT_%d.set',subjs{iS}, conditions{iC}, ROImethod,ModelOrder)
  EEG(iC).setname = setname(1:end-4);
  % EEG(iC).CAT.curComponentNames = {  'Precentral_L'    'Precentral_R'    'Occipital_Inf_L'    'Occipital_Inf_R' ...
  %   'ACC'    'Parietal_L'    'Parietal_R'    'SMA'    'Precuneus'};
  EEG(iC).CAT.curComponentNames = {'lMot' 'rMot' 'lOcc' 'rOcc' 'ACC' 'lPar' 'rPar' 'SMA' 'precu'};
  EEG(iC) = pop_saveset( EEG(iC), 'filename', setname, 'filepath', datapath);
end
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
eeglab redraw

%pop_vis_TimeFreqGrid(EEG, 