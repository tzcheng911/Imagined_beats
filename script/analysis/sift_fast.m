eeglab
clear 
close all
clc

%% Load the EEG files and cfg files 
addpath(genpath('/Volumes/TOSHIBA/Research/Imagined_beats/script'))
% sift_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/SMT';
% sift_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/rdlisten/long';
sift_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/preprocessed/epoch/whole_trial';


% output_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/SIFTs';
output_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/sifts/SIFT_output/2020';

% cfg files saved from previous manual SIFT: check WindowLengthSec, WindowStepSizeSec
% and ModelOrder
cfg_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/sifts/SIFT_input/cfg';
cd(cfg_path)

cond = {'BL','PB','IB','tap'};
meter = {'duple','triple'};

load('newpre_prepData_cfg.mat'); 
load('newest_fitMVAR_cfg.mat');
load('newest_mvarConnectivity_cfg.mat');
% load('vis_TimeFreqGrid_cfg.mat')

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
new_amIC(2,:) = [8	1	11	11	10	11	8	4	13	4	15	7	18	8	16	21	12	36	4	17	6	9	14	21	8];

% am selection 4c
% new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	6	4	1	1	5	8	4];
% new_amIC(2,:) = [8	1	11	11	10	11	7	4	13	4	15	7	18	8	16	21	12	36	4	17	6	4	24	21	8];

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

%% Some parameters to decide

% Experiment 
Winlen = 10; % main
%Winlen = 0.5; % localizer
Seglen = 10; % main
%Seglen = 0.5; % localizer
Winstep = 0.1;
Segstep = 0.1;

% Official parameter in the paper
Morder = 30;
% Winlen = 1; % main
% %Winlen = 0.5; % localizer
% Winstep = 0.1;
% Seglen = 1; % main
% %Seglen = 0.5; % localizer
% Segstep = 0.1;
est_fitMVAR_cfg.morder = Morder;
est_fitMVAR_cfg.winlen = Winlen;
est_fitMVAR_cfg.winstep = Winstep;
pre_prepData_cfg.detrend.piecewise.seglength = Seglen;
pre_prepData_cfg.detrend.piecewise.stepsize = Segstep;
% est_mvarConnectivity_cfg.logfreqs = logspace(0.5,3.5,200);
cd(output_path)

%% Run SIFT IMB: preprocessing, model validation, connectivity
SIFTout = cell(length(sub),length(meter),length(cond));

for nsub = 1:length(sub)
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
end
save SIFTout_AM4b_M30_N20_no_bc SIFTout

%% Run SIFT localizer: preprocessing, model validation, connectivity
for nsub = 1:length(sub)
            data_name = strcat(sub(nsub),'_evtag_512_clean_binica_dipfit_tap1','_e.set');
            parts_tempEEG = cellstr(split(data_name{:},'.'));
            EEG = pop_loadset('filename',data_name{:} ,'filepath', sift_path);
            EEG = pop_resample(EEG,128); % Downsample form 512 to 128 Hz for capturing low frequency
            EEG = pop_subcomp(EEG, new_amIC(:,nsub),0,1); % only keep the brain ICs
            % icap to keep the motor and auditory ICs
            [EEG,~] = pre_prepData('ALLEEG',EEG,pre_prepData_cfg);
            [EEG.CAT.MODEL,~] = est_fitMVAR('ALLEEG',EEG,est_fitMVAR_cfg);
            [EEG.CAT.Conn, ~] = est_mvarConnectivity('ALLEEG',EEG,'MODEL',EEG.CAT.MODEL,est_mvarConnectivity_cfg);            
            SIFTout{nsub} = EEG.CAT.Conn;
             clear EEG tempEEG parts_tempEEG figureHandles
end
save SIFTout_M30_tap1 SIFTout

%% Run SIFT IMB whole trial: preprocessing, model validation, connectivity
SIFTout = cell(length(sub),length(meter),length(cond));

for nsub = 1:length(sub)
    for nmeter = 1:length(meter)
            data_name = strcat(sub(nsub),'_evtag_512_clean_binica_dipfit_',meter(nmeter),'_e.set');
            parts_tempEEG = cellstr(split(data_name{:},'.'));
            EEG = pop_loadset('filename',data_name{:} ,'filepath', sift_path);
            EEG = pop_resample(EEG,128); % Downsample form 512 to 128 Hz for capturing low frequency
            EEG = pop_subcomp(EEG, new_amIC(:,nsub),0,1); % only keep the motor and auditory ICs
            % icap to keep the motor and auditory ICs
            [EEG,~] = pre_prepData('ALLEEG',EEG,pre_prepData_cfg);
            [EEG.CAT.MODEL,~] = est_fitMVAR('ALLEEG',EEG,est_fitMVAR_cfg);
            [EEG.CAT.Conn, ~] = est_mvarConnectivity('ALLEEG',EEG,'MODEL',EEG.CAT.MODEL,est_mvarConnectivity_cfg);            
            SIFTout{nsub,nmeter} = EEG.CAT.Conn;
             clear EEG tempEEG parts_tempEEG figureHandles
    end
end
save SIFTout_AM4b_M30_N20_W25s SIFTout

%% Extract and plot the IMB data
%cd('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/sifts/SIFT_output/2020')
load('SIFTout_AM4b_M30_N20_W25s.mat')
time = SIFTout{1,1,1}.erWinCenterTimes;
freq = SIFTout{1,1,1}.freqs;

maflow0 = zeros(length(sub),length(meter),length(cond),length(freq),length(time));
amflow0 = zeros(length(sub),length(meter),length(cond),length(freq),length(time));

aIC = [1		1	1	1	1		2	1		1	1	1	1	1	1	1	1		1	1	1		1	1]; % follow the order of the index e.g. if aIC is 15 and mIC is 2 then new aIC = 2, mIC = 1
mIC = [2		2	2	2	2		1	2		2	2	2	2	2	2	2	2		2	2	2		2	2];

% double check aIC and mIC with topo plots
% for nsub = 1:length(sub)
%     data_name = strcat(sub(nsub),'_evtag_512_clean_binica_dipfit_',meter(1),'_',cond(1),'_e.set');
%     parts_tempEEG = cellstr(split(data_name{:},'.'));
%     EEG = pop_loadset('filename',data_name{:} ,'filepath', sift_path);
%     EEG = pop_subcomp(EEG, new_amIC(:,nsub),0,1); % only keep the motor and auditory ICs       
%     figure(nsub); pop_topoplot(EEG, 0, [1 2] ,'',[1 2] ,0,'electrodes','off'); % find out the auditory and motor ICs
% end

for nsub = 1:length(sub)
    for nmeter = 1:length(meter)
        for ncond = 1:length(cond)
            maflow0(nsub,nmeter,ncond,:,:) = squeeze(SIFTout{nsub,nmeter,ncond}.dDTF08(aIC(nsub),mIC(nsub),:,:));
            amflow0(nsub,nmeter,ncond,:,:) = squeeze(SIFTout{nsub,nmeter,ncond}.dDTF08(mIC(nsub),aIC(nsub),:,:));
        end
    end
end

maflow0 = permute(maflow0,[1 3 2 4 5]); % swap the order of cond and meter for extracting data
amflow0 = permute(amflow0,[1 3 2 4 5]);

maflow = reshape(maflow0,[length(sub) length(meter)*length(cond) length(freq) length(time)]);
amflow = reshape(amflow0,[length(sub) length(meter)*length(cond) length(freq) length(time)]);

%% Plot 
close all

FOIs = find(freq == 0.5); % beat freq 2:3, theta 4:8, alpha 8:12, beta 12:30 
FOIe = find(freq == 15); % beat freq 2:3, theta 4:8, alpha 8:12, beta 12:30 
cscale = [0 3e-3];

% tf plot am flow
figure;
for ncond = 1:8
    subplot(2,4,ncond)
    imagesc(time,freq(FOIs:FOIe),squeeze(mean(amflow(:,ncond,FOIs:FOIe,:),1)));axis xy; colormap(jet); caxis(cscale);
end
% tf plot maflow
figure;
for ncond = 1:8
    subplot(2,4,ncond)
    imagesc(time,freq(FOIs:FOIe),squeeze(mean(maflow(:,ncond,FOIs:FOIe,:),1)));axis xy; colormap(jet); caxis(cscale);
end

% Average across time 
% am flow
figure;
for ncond = 1:8
    subplot(2,4,ncond)
    mean_am = squeeze(mean(mean(amflow(:,ncond,FOIs:FOIe,:),4),1));
    std_am = squeeze(std(mean(amflow(:,ncond,FOIs:FOIe,:),4),[],1));
    plotShadedError(freq(FOIs:FOIe),mean_am,std_am);
end
% maflow
figure;
for ncond = 1:8
    subplot(2,4,ncond)
    mean_ma = squeeze(mean(mean(maflow(:,ncond,FOIs:FOIe,:),4),1));
    std_ma = squeeze(std(mean(maflow(:,ncond,FOIs:FOIe,:),4),[],1));
    plotShadedError(freq(FOIs:FOIe),mean_am,std_ma);
end

% Average across meter 
figure;
for ncond = 1:4
    subplot(1,5,ncond)
    imagesc(time,freq(FOIs:FOIe),squeeze(mean(mean(amflow0(:,ncond,:,FOIs:FOIe,:),1),3)));axis xy; colormap(jet); caxis(cscale)
end
subplot(1,5,5)
mean_am = squeeze(mean(mean(mean(amflow(:,ncond,FOIs:FOIe,:),4),1),2));
std_am = squeeze(std(mean(mean(amflow(:,ncond,FOIs:FOIe,:),4),2),[],1));
plotShadedError(freq(FOIs:FOIe),mean_am,std_am);
xlim([0.5 30])
view(90,90)
set(gca,'xdir','reverse')

figure;
for ncond = 1:4
    subplot(1,5,ncond)
    imagesc(time,freq(FOIs:FOIe),squeeze(mean(mean(maflow0(:,ncond,:,FOIs:FOIe,:),1),3)));axis xy; colormap(jet); caxis(cscale)
end
subplot(1,5,5)
mean_ma = squeeze(mean(mean(mean(maflow(:,ncond,FOIs:FOIe,:),4),1),2));
std_ma = squeeze(std(mean(mean(maflow(:,ncond,FOIs:FOIe,:),4),2),[],1));
plotShadedError(freq(FOIs:FOIe),mean_am,std_ma);
xlim([0.5 30])
view(90,90)
set(gca,'xdir','reverse')

% Average across freqs
mean_amflow = squeeze(mean(mean(amflow(:,:,FOIs:FOIe,:),4),3));
mean_maflow = squeeze(mean(mean(maflow(:,:,FOIs:FOIe,:),4),3));

%% Extract and plot the localizer data
load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/SIFTs/SIFTout_M30_sync3s.mat')
time = SIFTout{1,1,1}.erWinCenterTimes;
freq = SIFTout{1,1,1}.freqs;

aIC = [1	2	1	1	1	1	1	2	1	2	1	1	1	1	1	1	1	1	2	1	1	1	1	1	1];
mIC = [2	1	2	2	2	2	2	1	2	1	2	2	2	2	2	2	2	2	1	2	2	2	2	2	2];

for nsub = 1:length(sub)
    maflow(nsub,:,:) = squeeze(SIFTout{nsub}.dDTF08(aIC(nsub),mIC(nsub),:,:));
    amflow(nsub,:,:) = squeeze(SIFTout{nsub}.dDTF08(mIC(nsub),aIC(nsub),:,:));
end

%% tf plot am flow
FOIs = find(freq == 1); 
FOIe = find(freq == 35);
cscale = [0 3e-3];

figure;
imagesc(time,freq(FOIs:FOIe),squeeze(mean(amflow(:,FOIs:FOIe,:),1)));axis xy; colormap(jet); caxis(cscale);
figure;
imagesc(time,freq(FOIs:FOIe),squeeze(mean(maflow(:,FOIs:FOIe,:),1)));axis xy; colormap(jet); caxis(cscale);
figure;
mean_am = squeeze(mean(mean(amflow(:,FOIs:FOIe,:),1),3));
std_am = squeeze(std(mean(amflow(:,FOIs:FOIe,:),3),[],1));
plotShadedError(freq(FOIs:FOIe),mean_am,std_am);
xlim([0.5 30])
