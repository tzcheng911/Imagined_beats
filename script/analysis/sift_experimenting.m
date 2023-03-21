%% This script is used for stepping through the SIFT codes
% eeglab
clear 
close all
clc

%% Load the EEG files and cfg files 
addpath(genpath('/Volumes/TOSHIBA/Research/Imagined_beats/script'))
% sift_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/SMT';
% sift_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/rdlisten/long';
sift_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/preprocessed/epoch/5sphases';
% sift_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/preprocessed/epoch/whole_trial';


% cfg files saved from previous manual SIFT: check WindowLengthSec, WindowStepSizeSec
% and ModelOrder
cfg_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/sifts/SIFT_input/cfg';
cd(cfg_path)

cond = {'BL','PB','IB','tap'};
meter = {'duple','triple'};

load('newpre_prepData_cfg.mat'); 
load('newest_fitMVAR_cfg.mat');
load('newest_mvarConnectivity_cfg.mat');

% am selection 4b
new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	6	4	1	1	5	8	4];
new_amIC(2,:) = [8	1	11	11	10	11	8	4	13	4	15	7	18	8	16	21	12	36	4	17	6	9	14	21	8];

sub = {'s02','s03','s04','s05','s06','s07','s08','s09','s10','s11','s12','s13','s14','s15'...
    ,'s16','s17','s18','s19','s20','s21','s22','s23','s24','s26','s27'};

%% remove subjects here: make the sub number match the sift file names
rmsub = {'s03','s08','s11','s20','s24'};

for i = 1:length(rmsub)
    rmsub_idx(i) = find(strcmp(sub,rmsub{i}));
end
new_amIC(:,rmsub_idx) =[];
sub(rmsub_idx) =[];

%% Some parameters to decide

% Experiment 
% Winlen = 10; % main
% %Winlen = 0.5; % localizer
% Seglen = 10; % main
% %Seglen = 0.5; % localizer
% Winstep = 0.1;
% Segstep = 0.1;

% Official parameter in the paper
Morder = 30;
Winlen = 1; % main
%Winlen = 0.5; % localizer
Winstep = 0.1;
Seglen = 1; % main
%Seglen = 0.5; % localizer
Segstep = 0.1;
est_fitMVAR_cfg.morder = Morder;
est_fitMVAR_cfg.winlen = Winlen;
est_fitMVAR_cfg.winstep = Winstep;
pre_prepData_cfg.detrend.piecewise.seglength = Seglen;
pre_prepData_cfg.detrend.piecewise.stepsize = Segstep;
% est_mvarConnectivity_cfg.logfreqs = logspace(0.5,3.5,200);

%% Run SIFT IMB: preprocessing, model validation, connectivity
SIFTout = cell(length(sub),length(meter),length(cond));

nsub = 1;
    for nmeter = 1:length(meter)
        for ncond = 1:length(cond)
            data_name = strcat(sub(nsub),'_evtag_512_clean_binica_dipfit_',meter(nmeter),'_',cond(ncond),'_e.set');
            parts_tempEEG = cellstr(split(data_name{:},'.'));
            EEG = pop_loadset('filename',data_name{:} ,'filepath', sift_path);
            EEG = pop_resample(EEG,128); % Downsample form 512 to 128 Hz for capturing low frequency
            EEG = pop_subcomp(EEG, new_amIC(:,nsub),0,1); % only keep the motor and auditory ICs
            % icap to keep the motor and auditory ICs
            [EEG,~] = pre_prepData('ALLEEG',EEG,pre_prepData_cfg);
            [EEG.CAT.MODEL,~] = est_fitMVAR('ALLEEG',EEG,est_fitMVAR_cfg);
            [EEG.CAT.Conn, ~] = est_mvarConnectivity('ALLEEG',EEG,'MODEL',EEG.CAT.MODEL,est_mvarConnectivity_cfg);            
            SIFTout{nsub,nmeter,ncond} = EEG.CAT.Conn;
             clear EEG tempEEG parts_tempEEG figureHandles
        end
    end
