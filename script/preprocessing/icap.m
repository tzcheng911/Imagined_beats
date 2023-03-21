eeglab 
clear
close 
clc

%% Do Iclabel across the whole recording
preprocessed_path = '/data/projects/zoe/ImaginedBeats/real_exp/preprocessed';
preprocessed_files = dir(fullfile(preprocessed_path,'*dipfit.set'));
preprocessed_name = {preprocessed_files.name};
icap_path = '/data/projects/zoe/ImaginedBeats/real_exp/preprocessed/icap';
icap_files = dir(fullfile(icap_path,'*icap.set'));
icap_name = {icap_files.name};
cd(icap_path)

%% Set the parameters
bic_th = 0.4; % threshold percentage
bic_class = 1; % brain ICs

%% Get the brain ICs > 0.4
for nsub = 1:length(preprocessed_name)
    tempEEG = preprocessed_name{nsub};
    parts = cellstr(split(tempEEG,'.'));
    EEG = pop_loadset('filename',tempEEG ,'filepath', preprocessed_path);
    EEG = iclabel(EEG); % only caluclate the analysis on brain related ICs based on iclabel
    tempbrainic = find(EEG.etc.ic_classification.ICLabel.classifications(:,bic_class) > bic_th); % find brain ICs > 0.6 percent
    all_brainic(nsub) = {tempbrainic};
%    EEG = pop_subcomp(EEG, [tempbrainic],0,1); % only keep the brain ICs
%    EEG.setname = strcat(parts(1),'_icap');
    EEG.setname = strcat(parts(1),'_iclabel');
    EEG.filename = EEG.setname;
    EEG = pop_saveset(EEG,'filename',char(EEG.setname),'filepath',icap_path);
clear EEG
end

% save all_brainic all_brainic

%% Get the artifacts ICs > 0.4
for nsub = 1:length(icap_name)
    tempEEG = icap_name{nsub};
    parts = cellstr(split(tempEEG,'.'));
    EEG = pop_loadset('filename',tempEEG ,'filepath', icap_path);
    for nart = 1:5
        tempartic = find(EEG.etc.ic_classification.ICLabel.classifications(:,nart+1) > bic_th); 
        artifact(nsub,nart) = {tempartic};
    end
    
clear EEG
end
% save all_artifacts_0.4.mat artifact

%% Get the artifact-free brain ICs 
load('all_artifacts_0.4.mat')
for sub = 1:length(preprocessed_name)
    tempEEG = preprocessed_name{sub};
    parts = cellstr(split(tempEEG,'.'));
    EEG = pop_loadset('filename',tempEEG ,'filepath', preprocessed_path);
    icremove = [artifact{sub,1};artifact{sub,2};artifact{sub,3};artifact{sub,4};artifact{sub,5}];
    EEG = pop_subcomp(EEG, icremove, 0, 0);
    EEG = eeg_checkset(EEG); % recalculate icaact
    EEG = iclabel(EEG); % run IClabel on whole experiment after removing the artifact ICs
    tempbrainic = find(EEG.etc.ic_classification.ICLabel.classifications(:,bic_class) > bic_th); % find brain ICs > 0.6 percent
    all_brainic(sub) = {tempbrainic};
    clear icremove cmpvarorder sortvar tempbrainic tempind EEG
end

save artifactfree_brainic all_brainic

%% View the individual envtopo
nsub = 20;
parts = cellstr(split(localizer_name{nsub},'.'));
filename = strcat(parts(1),'_icap.set');
EEG = pop_loadset('filename', filename,'filepath', localizer_path);
EEG = pop_eegfiltnew(EEG, 'hicutoff',60); % 60 Hz high pass filter 

figure;
pop_prop_extended(EEG,0,[1:size(icaact,1)])

%% Only leave the motor and auditory ICs or all brain relevant ICs (threshold > 0.4)
clear
close all
clc

% am selection 1
% amIC(1,:) = [6;8;13;9;8;3;7;5;2;9;32;3;8;6;6;3;5;3;7;4;6;4;5;3;4]; % representative auditory ICs
% amIC(2,:) = [11;4;11;11;10;11;10;4;29;16;15;7;18;8;16;21;12;18;17;17;11;9;14;21;8]; % representative motor ICs

% am selection 2
% new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	7	4	1	1	5	13	4];
% new_amIC(2,:) = [11	1	11	11	10	11	10	4	13	16	15	7	18	8	10	21	12	36	17	17	6	9	14	21	8];

% am selection 3 
% new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	6	4	1	4	5	13	4];
% new_amIC(2,:) = [11	1	11	11	10	11	7	4	29	6	15	7	18	8	16	21	11	36	17	17	6	1	14	17	8];

% am selection 4
% new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	6	4	1	1	5	8	4];
% new_amIC(2,:) = [8	1	11	11	24	11	8	4	13	4	15	7	18	8	16	21	12	36	4	17	6	4	14	17	8];

% am selection 4b
new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	6	4	1	1	5	8	4];
new_amIC(2,:) = [8	1	11	11	10	11	7	4	13	4	15	7	18	8	16	21	12	36	4	17	6	9	14	21	8];

% load('/data/projects/zoe/ImaginedBeats/real_exp/preprocessed/icap/all_brainic.mat')
preprocessed_path = '/data/projects/zoe/ImaginedBeats/real_exp/localizer_trials/sync';
preprocessed_files = dir(fullfile(preprocessed_path,'*sync3t_e.set'));
preprocessed_name = {preprocessed_files.name};
icap_path = '/data/projects/zoe/ImaginedBeats/real_exp/preprocessed/icap/localizer/AM4b/sync/tap';
cd(icap_path)

for nsub = 1:length(preprocessed_name)
    tempEEG = preprocessed_name{nsub};
    parts = cellstr(split(tempEEG,'.'));
    EEG = pop_loadset('filename',tempEEG ,'filepath', preprocessed_path);
    EEG = pop_subcomp(EEG, new_amIC(:,nsub),0,1); % only keep the motor and auditory ICs
%    EEG = pop_subcomp(EEG, all_brainic{:,nsub},0,1); % only brain ICs
    EEG.setname = strcat(parts(1),'_icapMA');
    EEG.filename = EEG.setname;
    EEG = pop_saveset(EEG,'filename',char(EEG.setname),'filepath',icap_path);
end