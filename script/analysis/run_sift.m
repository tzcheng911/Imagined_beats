%% Modified from ScriptingExample.m 20200406 Zoe
clear 
close all
clc

%% Load the EEG files and cfg files 
addpath(genpath('/Volumes/TOSHIBA EXT/Research/Imagined_beats/script'))
sift_path = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/preprocessed/epoch';
% sift_path = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/localizer_trials/rdlisten/long';

output_path = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/results/Main_task/sift/AM3';
% output_path = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/sifts/SIFT_output/2020/rdlisten_localizer';

% cfg files saved from previous manual SIFT: check WindowLengthSec, WindowStepSizeSec
% and ModelOrder
cfg_path = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/sifts/SIFT_input/cfg';
cd(cfg_path)

cond = {'BL','PB','IB','tap'};
meter = {'duple','triple'};

load('newpre_prepData_cfg.mat'); 
load('newest_fitMVAR_cfg.mat');
load('newest_mvarConnectivity_cfg.mat');
% load('vis_TimeFreqGrid_cfg.mat') % each figrue is differed due to the
% setting and IC number etc. 
load('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/preprocessed/all_brainic_0.4.mat'); % load the brain ICs

% am selection 1
% amIC(1,:) = [6;8;13;9;8;3;7;5;2;9;32;3;8;6;6;3;5;3;7;4;6;4;5;3;4]; % representative auditory ICs
% amIC(2,:) = [11;4;11;11;10;11;10;4;29;16;15;7;18;8;16;21;12;18;17;17;11;9;14;21;8]; % representative motor ICs

% am selection 2
% new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	7	4	1	1	5	13	4];
% new_amIC(2,:) = [11	1	11	11	10	11	10	4	13	16	15	7	18	8	10	21	12	36	17	17	6	9	14	21	8];

% am selection 3 
new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	6	4	1	4	5	13	4];
new_amIC(2,:) = [11	1	11	11	10	11	7	4	29	6	15	7	18	8	16	21	11	36	17	17	6	1	14	17	8];

sub = {'s02','s03','s04','s05','s06','s07','s08','s09','s10','s11','s12','s13','s14','s15'...
    ,'s16','s17','s18','s19','s20','s21','s22','s23','s24','s26','s27'};
%% remove subjects here: make the sub number match the sift file names
rmsub = {'s03','s08','s11','s20','s24'};
% rmsub = {'s08','s11','s20'};

for i = 1:length(rmsub)
    rmsub_idx(i) = find(strcmp(sub,rmsub{i}));
end
new_amIC(:,rmsub_idx) =[];
sub(rmsub_idx) =[];
all_brainic(rmsub_idx) =[];

Morder = 30;
Winlen = 1;
Winstep = 0.1;
Seglen = 1;
Segstep = 0.1;
est_fitMVAR_cfg.morder = Morder;
est_fitMVAR_cfg.winlen = Winlen;
est_fitMVAR_cfg.winstep = Winstep;
pre_prepData_cfg.detrend.piecewise.seglength = Seglen;
pre_prepData_cfg.detrend.piecewise.stepsize = Segstep;
% est_mvarConnectivity_cfg.logfreqs = logspace(0.5,3.5,200);

%% Run SIFT IMB: preprocessing, model validation, connectivity, visualization
% WindowLengthSec   = 0.35; % sliding window length in seconds
% WindowStepSizeSec = 0.033; % sliding window step size in seconds
% ModelOrder = 20;

for nsub = 1:length(sub)
    for nmeter = 1:length(meter)
        for ncond = 1:length(cond)
            data_name = strcat(sub(nsub),'_evtag_512_clean_binica_dipfit_',meter(nmeter),'_',cond(ncond),'_e.set');
            parts_tempEEG = cellstr(split(data_name{:},'.'));
            EEG = pop_loadset('filename',data_name{:} ,'filepath', sift_path);
            EEG = pop_resample(EEG,128); % Downsample form 512 to 128 Hz for capturing low frequency
            EEG = pop_subcomp(EEG, new_amIC(:,nsub),0,1); % only keep the brain ICs
            % icap to keep the motor and auditory ICs
            [EEG,~] = pre_prepData('ALLEEG',EEG,pre_prepData_cfg);
            [EEG.CAT.MODEL,~] = est_fitMVAR('ALLEEG',EEG,est_fitMVAR_cfg);
            [EEG.CAT.Conn, ~] = est_mvarConnectivity('ALLEEG',EEG,'MODEL',EEG.CAT.MODEL,est_mvarConnectivity_cfg);
%    [figureHandles, ~] = vis_TimeFreqGrid('ALLEEG',EEG,'Conn',EEG.CAT.Conn,vis_TimeFreqGrid_cfg);
            EEG.setname = strcat(parts_tempEEG(1),'_newAM_sift');
            EEG.filename = EEG.setname;
            EEG = pop_saveset(EEG,'filename',char(EEG.setname),'filepath',output_path);
             clear EEG tempEEG parts_tempEEG figureHandles
        end
    end
end

%% Run SIFT localizer: preprocessing, model validation, connectivity, visualization
% WindowLengthSec   = 0.35; % sliding window length in seconds
% WindowStepSizeSec = 0.033; % sliding window step size in seconds
% ModelOrder = 20;

for nsub = 1:length(sub)
            data_name = strcat(sub(nsub),'_evtag_512_clean_binica_dipfit_rdlisten2','_e.set');
            parts_tempEEG = cellstr(split(data_name{:},'.'));
            EEG = pop_loadset('filename',data_name{:} ,'filepath', sift_path);
            EEG = pop_resample(EEG,128); % Downsample form 512 to 128 Hz for capturing low frequency
            EEG = pop_subcomp(EEG, new_amIC(:,nsub),0,1); % only keep the brain ICs
            % icap to keep the motor and auditory ICs
            [EEG,~] = pre_prepData('ALLEEG',EEG,pre_prepData_cfg);
            [EEG.CAT.MODEL,~] = est_fitMVAR('ALLEEG',EEG,est_fitMVAR_cfg);
            [EEG.CAT.Conn, ~] = est_mvarConnectivity('ALLEEG',EEG,'MODEL',EEG.CAT.MODEL,est_mvarConnectivity_cfg);
%    [figureHandles, ~] = vis_TimeFreqGrid('ALLEEG',EEG,'Conn',EEG.CAT.Conn,vis_TimeFreqGrid_cfg);
            EEG.setname = strcat(parts_tempEEG(1),'_newAM_sift');
            EEG.filename = EEG.setname;
            EEG = pop_saveset(EEG,'filename',char(EEG.setname),'filepath',output_path);
             clear EEG tempEEG parts_tempEEG figureHandles
end

%% Need to work on the following part %%
%% Compute Statistics (This step is slow) The output is stored in CAT.PConn and CAT.stats
NumPermutations = 200;

% reload each of the datasets in the exact same order they appear in ALLEEG
% (or use original, un-preprocessed copy)
for cnd=1:length(EEG)
    EEGfresh(cnd) = pop_loadset;
end

% first we obtain the bootstrap distributions for each condition
for cnd=1:length(EEG)
    PConn_boot(cnd) = pop_stat_surrogateGen('ALLEEG',EEGfresh(cnd),'configs',struct('prepData',prepcfg(1),'fitMVAR',modfitcfg,'mvarConnectivity',conncfg),'Mode',{'Bootstrap', 'NumPermutations', NumPermutations},'AutoSave',{'FileNamePrefix','SIFT_bootstrap','AutoSaveFrequency',10},'VerbosityLevel',2);
end

% replace connectivity object with estimate of bootstrap mean
for cnd=1:length(EEG)
    EEG(cnd).CAT.Conn = stat_getDistribMean(PConn_boot(cnd));
end
%% NOTE: we can also obtain the phase-randomized null distributions for each condition
for cnd=1:length(EEG)
    PConn_phase(cnd) = pop_stat_surrogateStats('ALLEEG',EEGfresh(cnd),'configs',struct('prepData',prepcfg(1),'fitMVAR',modfitcfg,'mvarConnectivity',conncfg),'Mode',{'PhaseRand', 'NumPermutations', NumPermutations},'AutoSave',{'FileNamePrefix','SIFT_bootstrap','AutoSaveFrequency',10},'VerbosityLevel',2);
end

%% next we compute p-values and confidence intervals
% (CHOOSE ONE OF THE FOLLOWING)

%% 1) Between-condition test:
%     For conditions A and B, the null hypothesis is either
%     A(i,j)<=B(i,j), for a one-sided test, or
%     A(i,j)=B(i,j), for a two-sided test
%     A p-value for rejection of the null hypothesis can be
%     obtained by taking the difference of the distributions
%     computing the probability
%     that a sample from the difference distribution is non-zero
StatsHab = stat_surrogateStats('BootstrapConnectivity',PConn_boot,'StatisticalTest',{'Hab'},'MultipleComparisonCorrection','none','ConfidenceIntervals',true,'Alpha',0.05,'VerbosityLevel',1);

%% 2) Devation from baseline test
%     For conditions A, the null hypothesis is
%     C(i,j)=baseline_mean(C). This is a two-sided test.
%     A p-value for rejection of the null hypothesis can be
%     obtained by obtaining the distribution of the difference from
%     baseline mean and computing the probability
%     that a sample from this distribution is non-zero
for cnd=1:length(EEG)
    StatsHbase(cnd) = stat_surrogateStats('BootstrapConnectivity',PConn_boot(cnd),'StatisticalTest',{'Hbase' 'Baseline', [-1 -0.25]},'MultipleComparisonCorrection','none','ConfidenceIntervals',true,'Alpha',0.05,'VerbosityLevel',1);
end

%% 3) Presence of absolute connectivity
%     We are testing with respect to a phase-randomized null
%     distribution. A p-value for rejection of the null hypothesis
%     can be obtained by computing the probability that the
%     observed connectivity is a random sample from the null distribution
for cnd=1:length(EEG)
    StatsHnull(cnd) = stat_surrogateStats('BootstrapConnectivity',EEG(cnd).CAT.Conn,'NullDistribution',PConn_phase(cnd),'StatisticalTest',{'Hnull'},'MultipleComparisonCorrection','none','ConfidenceIntervals',true,'Alpha',0.05,'VerbosityLevel',1);
end

%% OPTIONAL STEP 8b: Compute analytic statistics
% This computes analytic alpha-significance thresholds, p-values, and confidence
% intervals for select connectivity estimators (RPDC, nPDC).
% These are asymptotic estimators and may not be accurate for small sample
% sizes. However, they are very fast and usually a reasonable estimate.
StatsAnalytic = stat_analyticStats('ALLEEG',EEG,'Estimator',{'RPDC','nPDC'},'Alpha', 0.01,'verb',true);

%% Visualization
clear all
siftDir = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/sifts';
siftfiles = dir(fullfile(siftDir,'*sift.set'));
siftsets = {siftfiles.name};
load('cfg.mat');

for iS = 1:length(siftsets)
    siftsetsFile = siftsets{iS};
    EEG = pop_loadset('filename',siftsetsFile ,'filepath', siftDir);
    EEG.CAT.configs.vis_TimeFreqGrid = cfg;
    vis_TimeFreqGrid('ALLEEG',EEG, 'Conn',EEG.CAT.Conn,cfg);
    clear EEG
end


