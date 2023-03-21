clear 
close all
clc
% eeglab

cd('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/cmcohere/EMG')
EMG_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/cmcohere/EMG';
EMG_files = dir(fullfile(EMG_path,'*EMGf.set'));
EMG_name = {EMG_files.name};
epoch_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/preprocessed/epoch/phases_no_bc/EMG';

%% Loop across subjects Epoch for PTB - 5 s
% Epoch BL, PB, IB, Tap phases in Duple and Triple conditions 
segmentation_path = EMG_path;
segmentation_files = dir(fullfile(segmentation_path,'*EMGf.set'));
segmentation_name = {segmentation_files.name};

% s11, s20 don't have tap trials 
for nsub = 1:length(segmentation_name)
    tempEEG = segmentation_name{nsub};
    parts = cellstr(split(tempEEG,'.'));
    EEG0 = pop_loadset('filename',tempEEG ,'filepath', segmentation_path);
    EEG_duple = pop_rmdat( EEG0, {'Duple'},[-2 26] ,0); % select the duple and triple events and do epoch on them, respectively
    EEG_triple = pop_rmdat( EEG0, {'Triple'},[-2 26] ,0);
    
    % Duple 
    EEG1 = pop_epoch( EEG_duple, {  'BL'  }, [-1 5]);
    EEG1.setname = char(strcat(parts(1),'_duple_BL_e'));
%    EEG1 = pop_rmbase( EEG1, [-50   0]);
    filename = EEG1.setname;
    EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',epoch_path);

    EEG2 = pop_epoch( EEG_duple, {  'PB'  }, [-1 5]);
    EEG2.setname = char(strcat(parts(1),'_duple_PB_e'));
%    EEG2 = pop_rmbase( EEG2, [-50   0]);
    filename = EEG2.setname;
    EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',epoch_path);
    
    EEG3 = pop_epoch( EEG_duple, {  'IB'  }, [-1 5]);
    EEG3.setname = char(strcat(parts(1),'_duple_IB_e'));
%    EEG3 = pop_rmbase( EEG3, [-50   0]);
    filename = EEG3.setname;
    EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',epoch_path);

    EEG4 = pop_epoch( EEG_duple, {  'IB'  }, [4 10]);
    EEG4.setname = char(strcat(parts(1),'_duple_tap_e'));
%    EEG4 = pop_rmbase( EEG4, [5000   5050]);
    filename = EEG4.setname;
    EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',epoch_path);
    
    clear EEG0 EEG1 EEG2 EEG3 EEG4
% Triple
    EEG1 = pop_epoch( EEG_triple, {  'BL'  }, [-1 5]);
    EEG1.setname = char(strcat(parts(1),'_triple_BL_e'));
%    EEG1 = pop_rmbase( EEG1, [-50   0]);
    filename = EEG1.setname;
    EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',epoch_path);

    EEG2 = pop_epoch( EEG_triple, {  'PB'  }, [-1 5]);
    EEG2.setname = char(strcat(parts(1),'_triple_PB_e'));
%    EEG2 = pop_rmbase( EEG2, [-50   0]);
    filename = EEG2.setname;
    EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',epoch_path);

    EEG3 = pop_epoch( EEG_triple, {  'IB'  }, [-1 5]);
    EEG3.setname = char(strcat(parts(1),'_triple_IB_e'));
%    EEG3 = pop_rmbase( EEG3, [-50   0]);
    filename = EEG3.setname;
    EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',epoch_path);

    EEG4 = pop_epoch( EEG_triple, {  'IB'  }, [4         10]);
    EEG4.setname = char(strcat(parts(1),'_triple_tap_e'));
%    EEG4 = pop_rmbase( EEG4, [5000   5050]);
    filename = EEG4.setname;
    EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',epoch_path);
    
    clear EEG1 EEG2 EEG3 EEG4 EEG_duple EEG_triple
end

%%
addpath(genpath('/Volumes/TOSHIBA/Research/Imagined_beats/script'))
sub = {'s02','s03','s04','s05','s06','s07','s08','s09','s10','s11','s12','s13','s14','s15'...
    ,'s16','s17','s18','s19','s20','s21','s22','s23','s24','s26','s27'};
data_path = epoch_path;
cond = {'BL','PB','IB','tap'};
meter = {'duple','triple'};

timewindow = 5;
df = 1/timewindow;
fs = 512; % EEG.srate
T = 1/fs;
L = timewindow*fs;
f = fs*(0:(L/2))/L;
dt = 1/fs;
sub_fbin = 2;

%% remove subjects here 
rmsub = {'s03','s08','s11','s20','s24'};
% rmsub = {'s08','s11','s20'};

for i = 1:length(rmsub)
    rmsub_idx(i) = find(strcmp(sub,rmsub{i}));
end
new_amIC(:,rmsub_idx) =[];
sub(rmsub_idx) =[];

%% Calculate fft on non-zero padding data
% Input: EMG data (channel, time, trial) of given subject, meter, conditions 
% Output: raw fft and normalized fft 
for nsub = 1:length(sub)
%    filepath = strcat('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/',sub(nsub),'/icapMA');
    for nmeter = 1:length(meter)
        for ncond = 1:length(cond) 
            data_name = strcat(sub(nsub),'_evtag_512_EMGf_',meter(nmeter),'_',cond(ncond),'_e.set'); % each epoch is 5.5879 s
            EMG = pop_loadset('filename',data_name,'filepath',data_path);
            EMG.data = squeeze(mean(EMG.data(1,:,:) - EMG.data(2,:,:),3));
            EMG_data(nsub,nmeter,ncond,:) = EMG.data;
%             [Y,freq] = calc_fft(EMG.data,dt); % dt = 1/fs related to your sampling rate
%             P2 = abs(Y/((EMG.xmax-EMG.xmin)*fs))*2; % Y/L*2
%             fft_out(nsub,nmeter,ncond,:) = P2; % unnecessary to do 1:L/2+1, calc_fft already done that
%             % "Normalize" step in Nozaradan
%             for n = sub_fbin+1:size(fft_out(nsub,nmeter,ncond,:),4)-sub_fbin-1
%                 fft_out_subt(nsub,nmeter,ncond,n) = fft_out(nsub,nmeter,ncond,n) - ...
%                 mean(fft_out(nsub,nmeter,ncond,[n-sub_fbin, n-sub_fbin+1, n+sub_fbin-1, n+sub_fbin]));
%             end
        end
    end
end

% rSSEP = fft_out; % 31:300 = 0.5:5 Hz fft(nsub,nmeter,ncond,freq)
% nSSEP = fft_out_subt; % 31:300 = 0.5:5 Hz
cd('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Main_task/motion')
times = EMG.times/1000;
save time_series_EMG_6s_e EMG_data times
% save rSSEP_EMG_no0pad_5s_N20 rSSEP freq

%%

EMG_data(rmsub_idx,:,:,:) = [];
times = times - 5;
hEMG = abs(hilbert(EMG_data)); % get the envelop 

figure; plot(times,squeeze(mean(hEMG_data(:,1,:,:),1)));
set(gca,'FontSize',18)
xlabel('Time (s)')
ylabel('Amplitude (uV)')
xlim([-1 5])
gridx(0,'k:')
legend('BL','PM','IM','Tap')


figure; plot(times,squeeze(mean(hEMG_data(:,2,:,:),1)));
set(gca,'FontSize',18)
xlabel('Time (s)')
ylabel('Amplitude (uV)')
xlim([-1 5])
gridx(0,'k:')
legend('BL','PM','IM','Tap')

figure; plot(times,squeeze(mean(hEMG(:,1,:,:),1))); ylim([0 70])
set(gca,'FontSize',18)
xlabel('Time (s)')
ylabel('Amplitude (uV)')
xlim([-1 5])
gridx(0,'k:')
legend('BL','PM','IM','Tap')

figure; plot(times,squeeze(mean(hEMG(:,2,:,:),1))); ylim([0 70])
set(gca,'FontSize',18)
xlabel('Time (s)')
ylabel('Amplitude (uV)')
xlim([-1 5])
gridx(0,'k:')
legend('BL','PM','IM','Tap')

%%
meanSSEP_duple = squeeze(mean(rSSEP(:,1,1:4,:),1));
meanSSEP_triple = squeeze(mean(rSSEP(:,2,1:4,:),1));

figure;
plot(freq,meanSSEP_duple,'LineWidth',2); 
xlim([0.7 3])
ylim([0 7e-3])
set(gca,'FontSize',18)
xlabel('Frequency (Hz)')
ylabel('Relative amplitude (uV)')
gridx([1.2 2.4],'k:')
%gridx([0.8 2.4],'k:')
legend('BL','PB','IB','Tap')

figure;
plot(freq,meanSSEP_triple,'LineWidth',2); 
xlim([0.7 3])
ylim([0 7e-3])
set(gca,'FontSize',18)
xlabel('Frequency (Hz)')
ylabel('Relative amplitude (uV)')
gridx([0.8 2.4],'k:')
legend('BL','PB','IB','Tap')
