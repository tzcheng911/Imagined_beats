
%%
close all
clear all
clc

%% average ft_data
cd 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result'  %where the data is
addpath(genpath('D:\TH\0_MEEG_toolbox\tf_script\'))
addpath(genpath('D:\TH\0_MEEG_toolbox\fieldtrip\'))

%% average 
clear all
clc
        
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_01_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_02_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_03_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_04_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_05_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_06_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_07_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_08_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_09_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_10_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_11_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_12_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_13_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_14_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_15_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_16_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_17_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_18_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_19_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_20_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_21_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_22_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_23_result.mat'
load 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result\random_24_result.mat'

cfg = [];
cfg.keepindividual = 'yes' ;
random_tf_avg = ft_freqgrandaverage(cfg, random_01_result.data, random_02_result.data, random_03_result.data, random_04_result.data, random_05_result.data, random_06_result.data,random_07_result.data,random_08_result.data,random_09_result.data,random_10_result.data,random_11_result.data,random_12_result.data,random_13_result.data,random_14_result.data,random_15_result.data,random_16_result.data,random_17_result.data,random_18_result.data,random_19_result.data,random_20_result.data,random_21_result.data,random_22_result.data,random_23_result.data,random_24_result.data);
save random_tf_avg random_tf_avg

%% cluster-based permutation test
close all
clear all

cd 'H:\TH\EXP3\ft_permutation\GLM_power_difficulty\raw\result' 

rmpath(genpath('D:\TH\0_MEEG_toolbox\spm8'))
addpath(genpath('D:\TH\0_MEEG_toolbox\tf_script\'))
rmpath(genpath('D:\TH\0_MEEG_toolbox\fieldtrip\'))
addpath(genpath('D:\TH\0_MEEG_toolbox\fieldtrip-20140611\'))

%% cluster-based permutation test
clear all
clc

load block_tf_avg
load random_tf_avg

cfg = [];
cfg.method      = 'distance'; % try 'distance' as well
cfg.template    = 'D:\TH\0_MEEG_toolbox\fieldtrip-20140611\template\layout\easycap32ch-avg_neighb.mat';               % specify type of template
cfg.layout      = 'D:\TH\0_MEEG_toolbox\tf_script\bc_28channel_EEG.lay';   
cfg.feedback    = 'no';                             % show a neighbour plot 
neighbours      = ft_prepare_neighbours(cfg, block_tf_avg); % define neighbouring channels

cfg = [];
cfg.channel = {'EEG'};
cfg.latency  = [-0.1 0];
cfg.frequency = [9 11];
cfg.avgoverfreq      ='yes';
cfg.avgovertime      ='yes';
cfg.method = 'montecarlo';
cfg.statistic = 'ft_statfun_indepsamplesT';
cfg.correctm = 'cluster';
cfg.clusteralpha = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan = 3;
cfg.neighbours = neighbours;
cfg.tail = 0;
cfg.clustertail = 0;
cfg.alpha = 0.05;
cfg.numrandomization = 500;

subj = 24;
design = zeros(2,2*subj);
for i = 1:subj
  design(1,i) = i;
end
for i = 1:subj
  design(1,subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2;

cfg.design = design;
cfg.uvar  = 1;
cfg.ivar  = 2;

[stat] = ft_freqstatistics(cfg, block_tf_avg, random_tf_avg);
save stat_block_random stat

%%
cfg = [];
cfg.highlightsymbolseries = ['*','+','.','.','.'];
cfg.layout      =  'D:\TH\0_MEEG_toolbox\tf_script\bc_28channel_EEG.lay'; 
%cfg.colorbar = 'yes';
cfg.interactive = 'yes';
cfg.contournum = 0;
cfg.markersymbol = '.';
cfg.alpha = 0.05;
cfg.zlim = [-5 5];
cfg.zparam = 'stat';
ft_clusterplot(cfg,stat);