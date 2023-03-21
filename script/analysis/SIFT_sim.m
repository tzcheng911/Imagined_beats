%%
% eeglab
clear
close all
clc

addpath(genpath('/Volumes/TOSHIBA/Research/Imagined_beats/script/'))
cfg_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/sifts/SIFT_input/cfg';
cd(cfg_path)

load('newpre_prepData_cfg.mat'); 
load('newest_fitMVAR_cfg.mat');
load('newest_mvarConnectivity_cfg.mat');

% Run SIFT
expr{1} = 'x1(t) = {2*exp(-1/10.000000)*cos(2*pi*2.0000000/100.000000)}*x1(t-1) + -exp(-2/10.000000)*x1(t-2) + e1(t)';
expr{2} = 'x2(t) = {2*exp(-1/2.000000)*cos(2*pi*2.0000000/100.000000)}*x2(t-1) + -exp(-2/2.000000)*x2(t-2) + -0.1*x1(t-2) + e2(t)';
expr{3} = 'x3(t) = {2*exp(-1/2.000000)*cos(2*pi*2.0000000/100.000000)}*x3(t-1) + -exp(-2/2.000000)*x3(t-2) + {0.3*sin(2*pi*t/100)+0.3}*x1(t-2) + e3(t)';

[EEG truth A C] = sim_varmodel('sim',{'Trivariate Coupled Oscillator' 'expr' expr 'morder' 100},...
    'simParams',{'srate' 100 'Nl' 5 'Nr' 100},...
    'makeEEGset',{'arg_direct' true 'arg_selection' true 'setname' 'Trivariate Coupled Oscillator' 'exportGroundTruth',...
    {'arg_selection' 1}}, 'plotData',false,'plotGraphicalModel',false);

%%
x1 = zeros(500,100);
x2 = zeros(500,100);
duration = 5;
fs = 100;
t = 0:1/fs:duration-1/fs;
f = 0.8;
a = -exp(-2/10.000000);
ndelay = 2;
ntr = 100;

for i = 1:ntr
% x1_temp = sin(2*pi*0.8*t) + sin(2*pi*2.4*t) + rand(1,duration*fs);
% x2_temp = sin(2*pi*0.8*t) + sin(2*pi*2.4*t) + a* [x1_temp(2:end) x1_temp([end])] + rand(1,duration*fs);
x1_temp = sin(2*pi*f*t) + rand(1,duration*fs);
x2_temp = sin(2*pi*f*t) + a* [x1_temp(ndelay:end) repmat(x1_temp(end),ndelay-1,1)] + rand(1,duration*fs);
x1(:,i) = x1_temp;
x2(:,i) = x2_temp;
clear x1_temp x2_temp
end

EEG.data(1,:,:) = x1;
EEG.data(2,:,:) = x2;

% EEG.data(1,:,:) = rand(duration*fs,ntr);
% EEG.data(2,:,:) = rand(duration*fs,ntr);

EEGf = pop_eegfiltnew(EEG0, [],0.1,16896,1,[],1); % high pass filter at 0.1 Hz
EEGf.CAT.srcdata = EEGf.data;
EEG0 = EEG;
%%
[Y,freq] = calc_fft(squeeze(mean(EEG.data(1,:,:),3)),1/EEG.srate);
figure;plot(freq,abs(Y))

%% Some parameters to decide
% Experiment 
Winlen = 3; % main
Seglen = 3; % main
Winstep = 0.1;
Segstep = 0.1;

for nmorder = 1:5:50
% Official parameter in the paper
Morder = nmorder;
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
est_mvarConnectivity_cfg.freqs = [0:0.1:49];
est_mvarConnectivity_cfg.spectraldecibels = 0;
% est_mvarConnectivity_cfg.logfreqs = logspace(0.5,3.5,200);

% [EEG,~] = pre_prepData('ALLEEG',EEG,pre_prepData_cfg);
[EEGf.CAT.MODEL,~] = est_fitMVAR('ALLEEG',EEG,est_fitMVAR_cfg);
[EEGf.CAT.Conn, ~] = est_mvarConnectivity('ALLEEG',EEG,'MODEL',EEGf.CAT.MODEL,est_mvarConnectivity_cfg);            
dDTF08(nmorder,:) = squeeze(mean(EEG.CAT.Conn.dDTF08(2,1,:,:),4));
end
freqs = EEG.CAT.Conn.freqs;
nmorder = 1:5:50;
figure;imagesc(freqs,nmorder,squeeze(dDTF08(nmorder,:)));axis xy; colormap(jet); xlim([0 15])

%% 
figure;imagesc(EEG.CAT.Conn.erWinCenterTimes,EEG.CAT.Conn.freqs,squeeze(EEGf.CAT.Conn.dDTF08(2,1,:,:)));axis xy;colormap(jet)
ylim([0 20])
xlabel('Time (s)')
ylabel('Frequency (Hz)')
%title('1 Hz Morder 50 Win 3s')
figure;plot(EEG.CAT.Conn.freqs,squeeze(mean(EEGf.CAT.Conn.dDTF08(2,1,:,:),4)))
xlabel('Hz')
ylabel('dDTF08')
%title('1.2 Hz Morder 50 Win 1s')

%% Test the real dataset with sweeping model order
% eeglab
clear
close all
clc

sift_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/preprocessed/epoch/phases_no_bc';
cfg_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/sifts/SIFT_input/cfg';
cd(cfg_path)

cond = {'BL','PB','IB','tap'};
meter = {'triple'};

load('newpre_prepData_cfg.mat'); 
load('newest_fitMVAR_cfg.mat');
load('newest_mvarConnectivity_cfg.mat');

% am selection 4b
new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	6	4	1	1	5	8	4];
new_amIC(2,:) = [8	1	11	11	10	11	8	4	13	4	15	7	18	8	16	21	12	36	4	17	6	9	14	21	8];

sub = {'s02','s03','s04','s05','s06','s07','s08','s09','s10','s11','s12','s13','s14','s15'...
    ,'s16','s17','s18','s19','s20','s21','s22','s23','s24','s26','s27'};

% remove subjects here: make the sub number match the sift file names
rmsub = {'s03','s08','s11','s20','s24'};
% rmsub = {'s08','s11','s20'};

for i = 1:length(rmsub)
    rmsub_idx(i) = find(strcmp(sub,rmsub{i}));
end
new_amIC(:,rmsub_idx) =[];
sub(rmsub_idx) =[];

% % Some parameters to decide
Winlen = 3; % main
Seglen = 3; % main
Winstep = 0.1;
Segstep = 0.1;

est_fitMVAR_cfg.winlen = Winlen;
est_fitMVAR_cfg.winstep = Winstep;
pre_prepData_cfg.detrend.piecewise.seglength = Seglen;
pre_prepData_cfg.detrend.piecewise.stepsize = Segstep;
est_mvarConnectivity_cfg.freqs = [0:0.1:49];
% est_mvarConnectivity_cfg.spectraldecibels = 0;

SIFTout = cell(length(sub),length(meter),length(cond));
nmeter = 1;

for nMorder = 1:5:300
est_fitMVAR_cfg.morder = nMorder;

% Run SIFT IMB: preprocessing, model validation, connectivity

    for nsub = 1:length(sub)
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
                ma_dDTF08(nMorder,nsub,ncond,:) = squeeze(mean(EEG.CAT.Conn.dDTF08(1,2,:,:),4));
                am_dDTF08(nMorder,nsub,ncond,:,:) = squeeze(mean(EEG.CAT.Conn.dDTF08(2,1,:,:),4));
                S(nMorder,nsub,ncond,:,:) = squeeze(mean(EEG.CAT.Conn.S(2,1,:,:),4));
                CAT = EEG.CAT;
                clear EEG tempEEG parts_tempEEG figureHandles
            end
    end
end

Morder = 1:5:300;
save morder_sweeping_1_300_real_duple_dDTF08_S ma_dDTF08 am_dDTF08 S CAT Morder
%% get the model order 30 and 300

for nMorder = [30,300]
    est_fitMVAR_cfg.morder = nMorder;
    for nsub = 1:length(sub)
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
                ma_dDTF08_30_300(nMorder,nsub,ncond,:) = squeeze(mean(EEG.CAT.Conn.dDTF08(1,2,:,:),4));
                am_dDTF08_30_300(nMorder,nsub,ncond,:,:) = squeeze(mean(EEG.CAT.Conn.dDTF08(2,1,:,:),4));
                S_30_300(nMorder,nsub,ncond,:,:) = squeeze(mean(EEG.CAT.Conn.S(2,1,:,:),4));
                clear EEG tempEEG parts_tempEEG figureHandles
                
            end
    end
end
save morder_30_300_real_triple_dDTF08_S ma_dDTF08_30_300 am_dDTF08_30_300 S_30_300 Morder

%%
clear
% close all
cd('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Main_task/sift/AM4b/morder_sweeping')
load('morder_30_300_real_duple_dDTF08_S.mat')
load('morder_sweeping_1_300_real_duple_dDTF08_S.mat')

%close all
conditions = {'Baseline','Physical Meter','Imagined Meter','Tap'};

nmorder = Morder;
freqs = CAT.Conn.freqs;

figure;
title('Meter')
for i = 1:4
% figure;
% imagesc(freqs,nmorder,squeeze(mean(am_dDTF08(nmorder,:,i,:),2)));axis xy; colormap(jet);
subplot(4,1,i)
plot(freqs,squeeze(mean(am_dDTF08(Morder,:,i,:),2)),'LineWidth',0.5)
hold on 
plot(freqs,squeeze(mean(am_dDTF08_30_300(30,:,i,:),2)),'LineWidth',2,'color','r')
hold on 
plot(freqs,squeeze(mean(am_dDTF08_30_300(300,:,i,:),2)),'LineWidth',2,'color','k')
xlim([0 15])
ylim([0 0.007])
if i == 4
    ylim([0 0.012])
end
%filename = strcat('Binary',conditions(i));
gridx([0.8, 1.2, 1.6,2.4],'k:')
set(gca,'fontsize', 18)
title(conditions(i))
% savefig(strcat(filename{1},'.fig'))
% subplot(1,4,i)
% plot(freqs,squeeze(mean(S(nmorder,:,i,:),2))); xlim([0 5])
% xlabel('Frequency (Hz)'); ylabel('Morder'); title(conditions(i))
% gridx([0.8, 1.2, 1.6,2.4],'k:')
% hold on;
% plot(freqs,squeeze(mean(mean(am_dDTF08(Morder,:,i,:),2),1)),'LineWidth',4)
% xlim([0 12])
% xlabel('Frequency (Hz)'); ylabel('Morder'); title(conditions(i))
% gridx([0.8, 1.2, 1.6,2.4],'k:')

end
xlabel('Frequency (Hz)'); ylabel('dDTF08')


