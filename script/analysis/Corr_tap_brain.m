%% calculate EEG.icaact
clear all
close all
clc
cd '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/sync'
dataDir = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/sync';
files = dir(fullfile(dataDir,'*.set'));
datasets = {files.name};
iS = 1;
datasetFile = datasets{iS};
EEG = pop_loadset('filename',datasetFile ,'filepath', dataDir);

times = EEG.times;
eegdata = reshape(EEG.data,204,size(EEG.data,2)*size(EEG.data,3));
icadata = EEG.icaweights*EEG.icasphere*eegdata;
icaact = reshape(icaact,size(icaact,1),size(EEG.data,2),size(EEG.data,3));
EEG.icaact = icaact;

%% ERP & async
figure; plot(EEG.times,squeeze(icaact(3,:,:)))
hold on
plot(EEG.times,mean(squeeze(icaact(3,:,:)),2),'Linewidth',3)

%% ERSP & async

%% plv & async

%% fft(tap) & fft(EEG)
clear
close all
clc
addpath(genpath('/Volumes/TOSHIBA EXT/Research/Imagined_beats/script'))
% Across frequency
cd('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/tap_brain/rawEEG')
%cd('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/tap_brain/peakcontrast')

load('f');
load('Duple_aICs_EEG');
load('Duple_mICs_EEG');
load('Triple_aICs_EEG');
load('Triple_mICs_EEG');

load('Duple_tapping');
load('Triple_tapping');

for nsub = 1:6
    for ncond = 1:4
        tempcoef = corrcoef(Duple_tapping(nsub,:),Duple_aICs_EEG(nsub,ncond,:));
        r_Duple_aICs(nsub,ncond) = tempcoef(1,2);
        rz_Duple_aICs(nsub,ncond) = fisherz(r_Duple_aICs(nsub,ncond));
    end
end

for nsub = 1:6
    for ncond = 1:4
        tempcoef = corrcoef(Duple_tapping(nsub,:),Duple_mICs_EEG(nsub,ncond,:));
        r_Duple_mICs(nsub,ncond) = tempcoef(1,2);
        rz_Duple_mICs(nsub,ncond) = fisherz(r_Duple_mICs(nsub,ncond));
    end
end

for nsub = 1:6
    for ncond = 1:4
        tempcoef = corrcoef(Triple_tapping(nsub,:),Triple_aICs_EEG(nsub,ncond,:));
        r_Triple_aICs(nsub,ncond) = tempcoef(1,2);
        rz_Triple_aICs(nsub,ncond) = fisherz(r_Triple_aICs(nsub,ncond));
    end
end

for nsub = 1:6
    for ncond = 1:4
        tempcoef = corrcoef(Triple_tapping(nsub,:),Triple_mICs_EEG(nsub,ncond,:));
        r_Triple_mICs(nsub,ncond) = tempcoef(1,2);
        rz_Triple_mICs(nsub,ncond) = fisherz(r_Triple_mICs(nsub,ncond));
    end
end

corr = [rz_Duple_aICs,rz_Duple_mICs,rz_Triple_aICs,rz_Triple_mICs];
%%
[H,P,CI,STATS] = ttest(r(:,1));

%% plot the tap 
figure;plot(f,Duple_tapping')
title('Duple')
gridx(1.2)
gridx(2.4)
legend('s01','s02','s03','s04','s05','s06','1.2 Hz','2.4 Hz')

figure;plot(f,Triple_tapping')
title('Triple')
gridx(0.8)
gridx(2.4)
legend('s01','s02','s03','s04','s05','s06','0.8 Hz','2.4 Hz')

%% plot the brain 4 x 2 x 2 = 16 plots
cond = {'BL','SBL','IM','tap'};
for ncond = 1:length(cond)
    figname = strcat('Duple-mICs-',cond(ncond));
    figure;plot(f,squeeze(Duple_mICs_EEG(:,ncond,31:300))) % BL, duple, mICs
    title(figname)
    gridx(1.2)
    gridx(2.4)
    legend('s01','s02','s03','s04','s05','s06','1.2 Hz','2.4 Hz')
%    print(figname{:},'-dpng');
end

for ncond = 1:length(cond)
    figname = strcat('Triple-mICs-',cond(ncond));
    figure;plot(f,squeeze(Triple_mICs_EEG(:,ncond,31:300))) % BL, duple, mICs
    title(figname)
    gridx(0.8)
    gridx(2.4)
    legend('s01','s02','s03','s04','s05','s06','0.8 Hz','2.4 Hz')
%    print(figname{:},'-dpng');
end

for ncond = 1:length(cond)
    figname = strcat('Duple-aICs-',cond(ncond));
    figure;plot(f,squeeze(Duple_aICs_EEG(:,ncond,31:300))) % BL, duple, mICs
    title(figname)
    gridx(1.2)
    gridx(2.4)
    legend('s01','s02','s03','s04','s05','s06','1.2 Hz','2.4 Hz')
%    print(figname{:},'-dpng');
end

for ncond = 1:length(cond)
    figname = strcat('Triple-aICs-',cond(ncond));
    figure;plot(f,squeeze(Triple_aICs_EEG(:,ncond,31:300))) % BL, duple, mICs
    title(figname)
    gridx(0.8)
    gridx(2.4)
    legend('s01','s02','s03','s04','s05','s06','0.8 Hz','2.4 Hz')
%    print(figname{:},'-dpng');
end

%% Across trials
cd('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/tap_brain/trial-by-trial')
load('power');
load('tapertrail');
for nsub = 1:size(power,1)
    for nmeter = 1:size(power,2)
        for ncond = 1:size(power,3)
            for nf = 1:size(power,5)
                tempcoef = corrcoef(squeeze(power(nsub,nmeter,ncond,:,nf)),squeeze(tapertrail(nsub,nmeter,:,nf)));
                beta(nsub,nmeter,ncond,nf) = fisherz(tempcoef(1,2));
            end
        end
    end
end

[H,P,CI,STATS] = ttest(squeeze(beta(:,1)));
figure;plot(f,squeeze(mean(beta(:,1,4,31:300),1)));
gridx(1.2,'r:')
hold on 
gridx(2.4,'r:')

figure;plot(f,squeeze(mean(beta(:,1,1,31:300),1)));
gridx(0.8,'r:')
hold on 
gridx(2.4,'r:')
