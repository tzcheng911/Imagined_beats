%% Follow Nozaradan 2011 paper 20200410 - Zoe
% eeglab
clear 
close all
clc

%% Parameters 
cd('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Main_task/SSEP/AM4b')
addpath(genpath('/Volumes/TOSHIBA/Research/Imagined_beats/script'))
sub = {'s02','s03','s04','s05','s06','s07','s08','s09','s10','s11','s12','s13','s14','s15'...
    ,'s16','s17','s18','s19','s20','s21','s22','s23','s24','s26','s27'};
data_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/preprocessed/epoch/5sphases';
cond = {'BL','PB','IB','tap'};
meter = {'duple','triple'};

% Change IC to aIC or mIC
IC = str2num(input('Auditory or Motor IC? (e.g. 1: aIC, 2: mIC): ','s'));

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

% am selection 4c
% new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	6	4	1	1	5	8	4];
% new_amIC(2,:) = [8	1	11	11	10	11	7	4	13	4	15	7	18	8	16	21	12	36	4	17	6	4	24	21	8];

% other ICs
new_amIC(1,:) = randperm(25);
new_amIC(2,:) = 2*ones(1,25);


timewindow = 5;
df = 1/timewindow;
fs = 512; % EEG.srate
T = 1/fs;
L = timewindow*fs;
f = fs*(0:(L/2))/L;
dt = 1/fs;
sub_fbin = 2; % critical parameter follow Nozaradan 2011 parameter n - mean(n-5, n-4, n-3, n+3, n+4, n+5)

%% remove subjects here 
rmsub = {'s03','s08','s11','s20','s24'};
% rmsub = {'s08','s11','s20'};

for i = 1:length(rmsub)
    rmsub_idx(i) = find(strcmp(sub,rmsub{i}));
end
new_amIC(:,rmsub_idx) =[];
sub(rmsub_idx) =[];

%% Calculate fft on non-zero padding data
% Input: EEG data (IC, time, trial) of given subject, meter, conditions 
% Output: raw fft and normalized fft 
for nsub = 1:length(sub)
%    filepath = strcat('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/',sub(nsub),'/icapMA');
    for nmeter = 1:length(meter)
        for ncond = 1:length(cond)
            data_name = strcat(sub(nsub),'_evtag_512_clean_binica_dipfit_',meter(nmeter),'_',cond(ncond),'_e.set'); % each epoch is 5.5879 s
            EEG = pop_loadset('filename',data_name,'filepath',data_path);
            EEG = eeg_checkset(EEG,'ica');
            EEG.icaact = reshape((EEG.icaweights*EEG.icasphere)*reshape(EEG.data,[size(EEG.data,1),size(EEG.data,2)*size(EEG.data,3)]),[size(EEG.icaweights,1),size(EEG.data,2),size(EEG.data,3)]);            
            EEG.icaact = squeeze(mean(EEG.icaact(new_amIC(IC,nsub),1:4.5*fs,:),3)); % average across trial to reduce non-phase lock activities
            % EEG.icaact = repmat(EEG.icaact,[1,6]); % experiment about 
            [Y,freq] = calc_fft(EEG.icaact,dt); % dt = 1/fs related to your sampling rate
            P2 = abs(Y/((EEG.xmax-EEG.xmin)*fs))*2; % Y/L*2
            fft_out(nsub,nmeter,ncond,:) = P2; % unnecessary to do 1:L/2+1, calc_fft already done that
            % "Normalize" step in Nozaradan
%             for n = sub_fbin+1:size(fft_out(nsub,nmeter,ncond,:),4)-sub_fbin-1
%                 fft_out_subt(nsub,nmeter,ncond,n) = fft_out(nsub,nmeter,ncond,n) - ...
%                 mean(fft_out(nsub,nmeter,ncond,[n-sub_fbin, n-sub_fbin+1, n+sub_fbin-1, n+sub_fbin]));
%             end
        end
    end
end
rSSEP_aIC = fft_out; % 31:300 = 0.5:5 Hz fft(nsub,nmeter,ncond,freq)
nSSEP_aIC = fft_out_subt; % 31:300 = 0.5:5 Hz
rSSEP_mIC = fft_out; % 31:300 = 0.5:5 Hz fft(nsub,nmeter,ncond,freq)
nSSEP_mIC = fft_out_subt; % 31:300 = 0.5:5 Hz

% ff = f(31:300);
% save rSSEP_mIC_AM4b_no0pad_5s_N20 rSSEP_mIC sub_fbin freq

%
meanSSEP_duple = squeeze(mean(rSSEP_aIC(:,1,1:4,:),1));
meanSSEP_triple = squeeze(mean(rSSEP_aIC(:,2,1:4,:),1));
figure;
plot(freq,meanSSEP_triple,'LineWidth',2); 
xlim([0.5 3])
set(gca,'FontSize',18)
xlabel('Frequency (Hz)')
ylabel('Relative amplitude (uV)')
% gridx([1.2 2.4],'k:')
gridx([0.8 2.4],'k:')
legend('BL','PB','IB','Tap')
save rSSEP_mIC_AM4b_no0pad_4500ms_N20 rSSEP_aIC freq
%% Calculate fft on zero padding data
% Input: EEG data (IC, time, trial) of given subject, meter, conditions 
% Output: raw fft and normalized fft 
for nsub = 1:length(sub)
%    filepath = strcat('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/',sub(nsub),'/icapMA');
    for nmeter = 1:length(meter)
        for ncond = 1:length(cond)
            data_name = strcat(sub(nsub),'_evtag_512_clean_binica_dipfit_',meter(nmeter),'_',cond(ncond),'_e.set'); % each epoch is 5.5879 s
            EEG = pop_loadset('filename',data_name,'filepath',data_path);
            EEG = eeg_checkset(EEG);
            EEG.icaact = squeeze(mean(EEG.icaact,3)); % average across trial to reduce non-phase lock activities
            Y = calc_fft(EEG.icaact(new_amIC(IC,nsub),:),dt,L);
            fft_out = abs(Y/L);
            % "Normalize" step in Nozaradan
            for n = sub_fbin+1:size(fft_out(nsub,nmeter,ncond,:),4)-sub_fbin-1
                fft_out_subt(nsub,nmeter,ncond,n) = fft_out(nsub,nmeter,ncond,n) - ...
                mean(fft_out(nsub,nmeter,ncond,[n-sub_fbin, n-sub_fbin+1,n-sub_fbin+2, n+sub_fbin-2, n+sub_fbin-1, n+sub_fbin]));
            end
        end
    end
end
rSSEP_mIC = fft_out(:,:,:,31:300); % 31:300 = 0.5:5 Hz fft(nsub,nmeter,ncond,freq)
nSSEP_mIC = fft_out_subt(:,:,:,31:300); % 31:300 = 0.5:5 Hz
ff = f(31:300);

save rSSEP_mIC_AM4b_0pad_5s_N20 rSSEP_mIC sub_fbin
save nSSEP_mIC_AM4b_0pad_5s_N20 nSSEP_mIC sub_fbin

%% whole listen phases, including BL, PB, IB
for nsub = 1:length(sub)
    filepath = strcat('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/',sub(nsub));
    for nmeter = 1:length(meter) 
        filename = strcat(sub(nsub),'_IMB_cleaned_binica_dipfit_icapnoalpha_MA_',meter(nmeter),'.set');
        EEG = pop_loadset('filename',filename,'filepath',filepath{:});
        for ntrial = 1:size(EEG.icaact,3)
            Y(ntrial,:) = fft(EEG.icaact(aIC(nsub),:,ntrial),L);
        end
        P2 = abs(Y/L);
        P2 = mean(P2,1);
        fft_out(nsub,:) = P2(1:L/2+1);
        fft_out(nsub,2:end-1) = 2*fft_out(nsub,2:end-1);
        for n = 11:size(fft_out(nsub,:),2)-11
            fft_out_subt(nsub,n) = fft_out(nsub,n) - ...
            mean(fft_out(nsub,[n-10, n-9, n+9, n+10]));
        end
    end
end

%% Plot overall results 
addpath(genpath('/Volumes/TOSHIBA EXT/Research/Imagined_beats/script'))
cd('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/results/Main_task/SSEP/AM4b')
% load('nSSEP_aIC_AM4_N20.mat');
% load('rSSEP_aIC_AM4_N20.mat');
% load('nSSEP_mIC_AM4c_N20.mat');
% load('rSSEP_mIC_AM4c_N20.mat');
load('ff.mat');
load('rSSEP_aIC_AM4b_no0pad_5s_cat_N20.mat')
load('nSSEP_aIC_AM4b_no0pad_5s_cat_N20.mat')
load('rSSEP_mIC_AM4b_no0pad_5s_cat_N20.mat')
load('nSSEP_mIC_AM4b_no0pad_5s_cat_N20.mat')

pool_fbin = 5; % central frequency +- 2 
beatf = find(ff == 0.8); % change this to 2.4 Hz (beat freq), or 1.2, 0.8, 1.6 (meter freq)

%% rSSEP overall results 
% aIC duple
meanSSEP_aIC_duple = squeeze(mean(rSSEP_aIC(:,1,1:4,:),1));
errSSEP_aIC_duple = squeeze(std(rSSEP_aIC(:,1,1:4,:),1))./sqrt(size(rSSEP_aIC,1));

% aIC triple
meanSSEP_aIC_triple = squeeze(mean(rSSEP_aIC(:,2,1:4,:),1));
errSSEP_aIC_triple = squeeze(std(rSSEP_aIC(:,2,1:4,:),1))./sqrt(size(rSSEP_aIC,1));

% mIC duple
meanSSEP_mIC_duple = squeeze(mean(rSSEP_mIC(:,1,1:4,:),1));
errSSEP_mIC_duple = squeeze(std(rSSEP_mIC(:,1,1:4,:),1))./sqrt(size(rSSEP_mIC,1));

% mIC triple
meanSSEP_mIC_triple = squeeze(mean(rSSEP_mIC(:,2,1:4,:),1));
errSSEP_mIC_triple = squeeze(std(rSSEP_mIC(:,2,1:4,:),1))./sqrt(size(rSSEP_mIC,1));

%% new nSSEP overall results (performed on the raw data)
for nmeter = 1:size(rSSEP_mIC,2)
    for ncond = 1:size(rSSEP_mIC,3)
        tmp_spect_aIC = squeeze(rSSEP_aIC(:,nmeter,ncond,:));
        spect_sub_aIC = tmp_spect_aIC - mean(tmp_spect_aIC(:,3:16),2); % take 0.4 to 3 Hz as the mean 
        nSSEP_aIC(:,nmeter,ncond,:) = spect_sub_aIC;
        
        tmp_spect_mIC = squeeze(rSSEP_mIC(:,nmeter,ncond,:));
        spect_sub_mIC = tmp_spect_mIC - mean(tmp_spect_mIC(:,3:16),2); % take 0.4 to 3 Hz as the mean 
        nSSEP_mIC(:,nmeter,ncond,:) = spect_sub_mIC;
    end
end

%% nSSEP overall results  
% aIC duple
meanSSEP_aIC_duple = squeeze(mean(nSSEP_aIC(:,1,1:4,:),1));
errSSEP_aIC_duple = squeeze(std(nSSEP_aIC(:,1,1:4,:),1))./sqrt(size(nSSEP_aIC,1));

% aIC triple
meanSSEP_aIC_triple = squeeze(mean(nSSEP_aIC(:,2,1:4,:),1));
errSSEP_aIC_triple = squeeze(std(nSSEP_aIC(:,2,1:4,:),1))./sqrt(size(nSSEP_aIC,1));

% mIC duple
meanSSEP_mIC_duple = squeeze(mean(nSSEP_mIC(:,1,1:4,:),1));
errSSEP_mIC_duple = squeeze(std(nSSEP_mIC(:,1,1:4,:),1))./sqrt(size(nSSEP_mIC,1));

% mIC triple
meanSSEP_mIC_triple = squeeze(mean(nSSEP_mIC(:,2,1:4,:),1));
errSSEP_mIC_triple = squeeze(std(nSSEP_mIC(:,2,1:4,:),1))./sqrt(size(nSSEP_mIC,1));

%%
fs = 512;
df = 1/60;
figure;
plot(freq,meanSSEP_mIC_triple,'LineWidth',2); % change meanSSEP_aIC_duple to other three conditions

%plot(freq(1:size(meanSSEP_aIC_duple,2)),meanSSEP_aIC_duple,'LineWidth',2); % change meanSSEP_aIC_duple to other three conditions
%plot(ff,meanSSEP_mIC_duple,'LineWidth',2); % change meanSSEP_aIC_duple to other three conditions

% ylim([-0.1e-1 1])
xlim([0.5 3])
set(gca,'FontSize',18)
xlabel('Frequency (Hz)')
ylabel('Relative amplitude (mV)')
% gridx([1.2 2.4],'k:')
gridx([0.8 2.4],'k:')
% patchx(0.8-df*10,0.8+df*10,'k',0.1)
% patchx(1.2-df*10,1.2+df*10,'k',0.1)
% patchx(2.4-df*10,2.4+df*10,'k',0.1)
legend('BL','PB','IB','Tap')

%% Plot all subjects results 
meter = 2; % 1: duple; 2:triple
cond = 2; % 1:BL; 2:PB; 3:IB; 4:TAP

figure;
cmap = gray(25);
cmap = cmap(1:20,:);
set(gca, 'ColorOrder', cmap, 'NextPlot', 'replacechildren');
plot(freq(1:size(meanSSEP_mIC_duple,2)),squeeze(rSSEP_mIC(:,meter,cond,:)),'LineWidth',1); % could change it to rSSEP or nSSEP
% plot(ff,squeeze(rSSEP_aIC(:,meter,cond,:)),'LineWidth',1); % could change it to rSSEP or nSSEP
% hold on 
% plot(freq(1:size(meanSSEP_mIC_duple,2)),squeeze(rSSEP_mIC(:,meter,cond,:)),'LineWidth',1); % could change it to rSSEP or nSSEP
%plot(ff,squeeze(mean(rSSEP_aIC(:,meter,cond,:),1)),'LineWidth',3,'color','r'); % could change it to rSSEP or nSSEP
xlim([0.5 3])
% ylim([-0.1 2])
if meter == 1
    gridx([1.2 2.4],'r:')
    patchx(1.2-df*5,1.2+df*5,'k',0.1)

else 
    gridx([0.8 2.4],'r:')
    patchx(0.8-df*5,0.8+df*5,'k',0.1)
end
patchx(2.4-df*5,2.4+df*5,'k',0.1)
title('PB phase in triple meter - mIC')
%%
figure;
set(gca, 'ColorOrder', gray(20), 'NextPlot', 'replacechildren');
plot(ff,squeeze(rSSEP_mIC(:,meter,cond,:)),'LineWidth',1);
hold on 
plot(ff,squeeze(mean(rSSEP_mIC(:,meter,cond,:),1)),'LineWidth',3,'color','r');
xlim([0.5 3])
xlabel('Frequency (Hz)')
ylabel('Relative amplitude (uV)')
%ylim([-0.1 2])
if meter == 1
    gridx([1.2 2.4],'r:')
    patchx(1.2-df*5,1.2+df*5,'k',0.1)
else 
    gridx([0.8 2.4],'r:')
    patchx(0.8-df*5,0.8+df*5,'k',0.1)
end
patchx(2.4-df*5,2.4+df*5,'k',0.1)
title('IB phase in duple meter - mIC')

%% Plot the max bin method 
meter = 1; % 1: duple; 2:triple
pool_fbin = 5; % +- 5 bins around each freq

for nsub = 1:size(nSSEP_aIC,1)
    for nmeter = 1:size(nSSEP_aIC,2)
        for ncond = 1:size(nSSEP_aIC,3)
            for n = pool_fbin+1:size(nSSEP_aIC,4)- pool_fbin-1
                maxbin(nsub,nmeter,ncond,n) = max(rSSEP_aIC(nsub,nmeter,ncond,(n- pool_fbin):(n + pool_fbin))); % change to nSSEP_mIC
            end
        end
    end
end
figure;
plot(ff(1:size(maxbin,4)),squeeze(mean(maxbin(:,meter,1:4,:),1)),'LineWidth',2);
set(gca,'FontSize',18)
xlabel('Frequency (Hz)')
ylabel('Max amplitude (mV) in surounding 10 bins')
if meter == 1
    gridx([1.2 2.4],'r:')
    patchx(1.2-df*5,1.2+df*5,'k',0.1)
else 
    gridx([0.8 2.4],'r:')
    patchx(0.8-df*5,0.8+df*5,'k',0.1)
end
patchx(2.4-df*5,2.4+df*5,'k',0.1)
legend('BL','PB','IB','Tap')

%% stats analysis: reshape the data for excel, spss or R
pool_fbin = 10; % central frequency +- 5 (width: 0.167 Hz)
beatf = find(freq == 1.2); % change this to 2.4 Hz (beat freq), or 1.2, 0.8, 1.6 (meter freq)

% single point method 
beat = 5; % 5, 7, 13

method = input('Select a method: ');

switch method
    case 'single_point'
        beatf_duple_aIC = squeeze(nSSEP_aIC(:,1,:,beat));
        beatf_triple_aIC = squeeze(nSSEP_aIC(:,2,:,beat));

        beatf_duple_mIC = squeeze(nSSEP_mIC(:,1,:,beat));
        beatf_triple_mIC = squeeze(nSSEP_mIC(:,2,:,beat));
    case 'mean'
        beatf_duple_aIC = squeeze(mean(nSSEP_aIC(:,1,:,(beatf - pool_fbin):(beatf + pool_fbin)),4));
        beatf_triple_aIC = squeeze(mean(nSSEP_aIC(:,2,:,(beatf - pool_fbin):(beatf + pool_fbin)),4));

        beatf_duple_mIC = squeeze(mean(nSSEP_mIC(:,1,:,(beatf - pool_fbin):(beatf + pool_fbin)),4));
        beatf_triple_mIC = squeeze(mean(nSSEP_mIC(:,2,:,(beatf - pool_fbin):(beatf + pool_fbin)),4));
    case 'max'
        beatf_duple_aIC = squeeze(max(nSSEP_aIC(:,1,:,(beatf - pool_fbin):(beatf + pool_fbin)),[],4));
        beatf_triple_aIC = squeeze(max(nSSEP_aIC(:,2,:,(beatf - pool_fbin):(beatf + pool_fbin)),[],4));

        beatf_duple_mIC = squeeze(max(nSSEP_mIC(:,1,:,(beatf - pool_fbin):(beatf + pool_fbin)),[],4));
        beatf_triple_mIC = squeeze(max(nSSEP_mIC(:,2,:,(beatf - pool_fbin):(beatf + pool_fbin)),[],4));
end
a = [beatf_duple_aIC(:,1:4) beatf_triple_aIC(:,1:4)];
m = [beatf_duple_mIC(:,1:4) beatf_triple_mIC(:,1:4)];
