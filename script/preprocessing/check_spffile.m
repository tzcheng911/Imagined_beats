clear all
close all
clc

% Get list of subjects, parse out their condition and position
dataDir = '/data/projects/zoe/ImaginedBeats/pilot/xdffile/pilot_2';
outputDir = '/data/projects/zoe/ImaginedBeats/pilot/EEGdata/ica_before_epoch/pilot_2';
icaDir = '/data/projects/zoe/ImaginedBeats/pilot/EEGdata/ica_before_epoch/pilot_2';
matDir = '/data/projects/zoe/ImaginedBeats/pilot/matFiles/pilot_2';
%dataDir = '/users/Alex/Desktop/missingfundamental';
%files = dir(fullfile(dataDir,'*.xdf'));
files = dir(fullfile(dataDir,'*.set'));
icafiles = dir(fullfile(icaDir,'*cleaned.set'));
matfiles = dir(fullfile(matDir,'*.mat'));
%files = dir(fullfile(dataDir,'*.set'));
datasets = {files.name};
icadatasets = {icafiles.name};
cd '/data/projects/zoe/ImaginedBeats/pilot/xdffile/pilot_2';
iS = 1
    datasetFile = datasets{iS};
    parts = cellstr(split(datasetFile,'.'));
    %EEG = pop_loadxdf(datasetFile , 'streamtype', 'EEG', 'exclude_markerstreams', {});
    EEG = pop_loadset('filename',datasetFile ,'filepath', dataDir);
    EEG.setname = parts(1);
    if isempty(EEG.event)
    load('/data/projects/zoe/ImaginedBeats/pilot/matFiles/pilot_2/hihat.mat');
    nTrials = 40;
        for ntrial = 1:nTrials
            ninstrument = {'hihat';'puretone';'kickdrum'} ;% 
            ntempo = {'200';'300'};
            nmeter = {'duple';'triple'};
            condition{ntrial,:} = [ninstrument{result(ntrial,1)} '_' num2str(result(ntrial,2)) 'bpm_' nmeter{result(ntrial,3)} '.wav'];
        end
        for i = 1:40
        EEG.event(i).type = condition{i,:};
        EEG.event(i).duration = 1;
        end
    end
    EEG = pop_select( EEG, 'channel',{'A1' 'A2' 'A3' 'A4' 'A5' 'A6' 'A7' 'A8' 'A9' 'A10' 'A11' 'A12' 'A13' 'A14' 'A15' 'A16' 'A17' 'A18' 'A19' 'A20' 'A21' 'A22' 'A23' 'A24' 'A25' 'A26' 'A27' 'A28' 'A29' 'A30' 'A31' 'A32' 'B1' 'B2' 'B3' 'B4' 'B5' 'B6' 'B7' 'B8' 'B9' 'B10' 'B11' 'B12' 'B13' 'B14' 'B15' 'B16' 'B17' 'B18' 'B19' 'B20' 'B21' 'B22' 'B23' 'B24' 'B25' 'B26' 'B27' 'B28' 'B29' 'B30' 'B31' 'B32' 'C1' 'C2' 'C3' 'C4' 'C5' 'C6' 'C7' 'C8' 'C9' 'C10' 'C11' 'C12' 'C13' 'C14' 'C15' 'C16' 'C17' 'C18' 'C19' 'C20' 'C21' 'C22' 'C23' 'C24' 'C25' 'C26' 'C27' 'C28' 'C29' 'C30' 'C31' 'C32' 'D1' 'D2' 'D3' 'D4' 'D5' 'D6' 'D7' 'D8' 'D9' 'D10' 'D11' 'D12' 'D13' 'D14' 'D15' 'D16' 'D17' 'D18' 'D19' 'D20' 'D21' 'D22' 'D23' 'D24' 'D25' 'D26' 'D27' 'D28' 'D29' 'D30' 'D31' 'D32' 'E1' 'E2' 'E3' 'E4' 'E5' 'E6' 'E7' 'E8' 'E9' 'E10' 'E11' 'E12' 'E13' 'E14' 'E15' 'E16' 'E17' 'E18' 'E19' 'E20' 'E21' 'E22' 'E23' 'E24' 'E25' 'E26' 'E27' 'E28' 'E29' 'E30' 'E31' 'E32' 'F1' 'F2' 'F3' 'F4' 'F5' 'F6' 'F7' 'F8' 'F9' 'F10' 'F11' 'F12' 'F13' 'F14' 'F15' 'F16' 'F17' 'F18' 'F19' 'F20' 'F21' 'F22' 'F23' 'F24' 'F25' 'F26' 'F27' 'F28' 'F29' 'F30' 'F31' 'F32' 'G1' 'G2' 'G3' 'G4' 'G5' 'G6' 'G7' 'G8' 'G9' 'G10' 'G11' 'G12' 'G13'});
    EEG = pop_eegfiltnew(EEG, [],1,1690,1,[],1);
    EEG = pop_chanedit(EEG, 'load',{'/data/projects/zoe/ImaginedBeats/pilot/xdffile/pilot_2/861_080518_56_Imagined_Beats.sfp' 'filetype' 'autodetect'});
    EEG = pop_reref( EEG, []);
    EEG = pop_saveset(EEG,'filename',char(EEG.setname),'filepath',outputDir);
    
    %
eeglab
rmpath('/data/common/matlab/eeglab/plugins/tmullen-cleanline-09d199104a42/external/bcilab_partial/dependencies/PropertyGrid-2010-09-16-mod/')
rmpath('/data/common/matlab/eeglab/plugins/measure_projection/dependency/propertyGrid/')                                                   % Shado

%%
    EEG = pop_epoch( EEG, {  'hihat_200bpm_duple.wav'  'hihat_200bpm_triple.wav'  'hihat_300bpm_duple.wav'  'hihat_300bpm_triple.wav'  }, [-1  17], 'epochinfo', 'yes');
    EEG = eeg_checkset( EEG );
    EEG = pop_rmbase( EEG, [-600 -100] ,[],[]);
    %EEG.setname='p2_rawdata';
    EEG.setname='p2_cleandata';
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG,EEG);