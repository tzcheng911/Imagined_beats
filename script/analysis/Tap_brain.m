clear 
close all
clc

addpath(genpath('/Volumes/TOSHIBA/Research/Imagined_beats/script'))
cd('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/')

%% TAP and ERSP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/sync/mIC_averagebaslined_ersp_itc_sync3s.mat'); % mIC_averagebaslined_ersp.mat
load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/SMT/ITI_stds.mat')
load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/SMT/ITI_means.mat')
load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/sync/mean_relative_phase.mat')

ntop = 8;

% stability of ITI in SMT %%%%%% Significant %%%%%%
stable_tapper = find(stds < median(stds));
unstable_tapper = find(stds > median(stds));
[B,I] = sort(stds);
%stable_tapper = I(1:ntop); % ntop
%unstable_tapper = I(end-ntop+1:end); % nbottom
ersp_stable_tapper = ersp(stable_tapper,:,:);
ersp_unstable_tapper = ersp(unstable_tapper,:,:);

%%
figure;imagesc(times,freqs,10*log10(squeeze(mean(ersp,1)))); axis xy; colormap(jet);  colorbar
xlabel('Time (ms)'); ylabel('Frequency (Hz)'); caxis([-0.5 0.5]) % title('mIC, tap-locked, All subj ERSP')

figure;imagesc(times,freqs,squeeze(mean(ersp,1))); axis xy; colormap(jet);  colorbar
xlabel('Time (ms)'); ylabel('Frequency (Hz)'); % title('mIC, tap-locked, All subj ERSP')
%%
figure;imagesc(times,freqs,squeeze(mean(ersp_stable_tapper,1))); axis xy; colormap(jet);  colorbar
xlabel('Time (ms)'); ylabel('Frequency (Hz)'); title('Stable subj ERSP');caxis([0.9 1.1]); title('')
figure;imagesc(times,freqs,squeeze(mean(ersp_unstable_tapper,1))); axis xy; colormap(jet);  colorbar
xlabel('Time (ms)'); ylabel('Frequency (Hz)'); title('Unstable subj ERSP');caxis([0.9 1.1]); title('')
figure;imagesc(times,freqs,(squeeze(mean(ersp_stable_tapper,1))-squeeze(mean(ersp_unstable_tapper,1)))); axis xy; colormap(jet);  colorbar
xlabel('Time (ms)'); ylabel('Frequency (Hz)'); title('Stable subj ERSP');caxis([-0.15 0.151]); title('')

%% speed of ITI in SMT 
fast_tapper = find(means < median(means));
slow_tapper = find(means > median(means));
ersp_faster_tapper = ersp(fast_tapper,:,:);
ersp_slower_tapper = ersp(slow_tapper,:,:);

figure;imagesc(times,freqs,10*log10(squeeze(mean(ersp_faster_tapper,1)))); axis xy; colormap(jet);  colorbar
xlabel('Time (ms)'); ylabel('Frequency (Hz)'); title('Fast subj ERSP'); caxis([-0.5 0.5])
figure;imagesc(times,freqs,10*log10(squeeze(mean(ersp_slower_tapper,1)))); axis xy; colormap(jet);  colorbar
xlabel('Time (ms)'); ylabel('Frequency (Hz)'); title('Slow subj ERSP'); caxis([-0.5 0.5])

%% relphase between tap and sound stimuli in sync 
good_syncher = find(abs(mean_relative_phase) < median(abs(mean_relative_phase)));
bad_syncher = find(abs(mean_relative_phase) > median(abs(mean_relative_phase)));
ersp_good_syncher = ersp(good_syncher,:,:);
ersp_bad_syncher = ersp(bad_syncher,:,:);

figure;imagesc(times,freqs,10*log10(squeeze(mean(ersp_good_syncher,1)))); axis xy; colormap(jet);  colorbar
xlabel('Time (ms)'); ylabel('Frequency (Hz)'); title('Good syncher ERSP')
figure;imagesc(times,freqs,10*log10(squeeze(mean(ersp_bad_syncher,1)))); axis xy; colormap(jet);  colorbar
xlabel('Time (ms)'); ylabel('Frequency (Hz)'); title('Bad syncher ERSP')

%% stats test
% ttest on each measurement
figure
plot(times,squeeze(mean(mean(ersp_stable_tapper(:,5:9,:),2),1)))
hold on
plot(times,squeeze(mean(mean(ersp_unstable_tapper(:,5:9,:),2),1)))
legend('stable','unstable')
[h,p] = ttest(squeeze(mean(ersp_stable_tapper(:,5:9,:),2)),squeeze(mean(ersp_unstable_tapper(:,5:9,:),2)));
figure; plot(times,p); gridy([0.05],'k:'); title('uncorrected p-value')

%%
figure
plot(freqs,squeeze(mean(mean(ersp_stable_tapper,3),1)))
hold on
plot(freqs,squeeze(mean(mean(ersp_unstable_tapper,3),1)))
[h,p] = ttest(squeeze(mean(ersp_stable_tapper,3)),squeeze(mean(ersp_unstable_tapper,3)));
figure; plot(freqs,p); gridy([0.05],'k:'); title('uncorrected p-value')

%% regression 
tic
X = [stds; means; mean_relative_phase];
for nf = 1:size(ersp,2)
    for nt = 1:size(ersp,3)
        tmp = fitlm(X',squeeze(ersp(:,nf,nt))');
        lm{nf,nt} = tmp;
        pvalue{nf,nt} = tmp.Coefficients.pValue;
        estimate{nf,nt} = tmp.Coefficients.Estimate;
    end
end

save linear_reg_mIC_sync3s_ersp lm pvalue estimate
toc

%%
regressor = 2;
for nf = 1:size(ersp,2)
    for nt = 1:size(ersp,3)
        beta(nf,nt) = estimate{nf,nt}(regressor);
        pval(nf,nt) = pvalue{nf,nt}(regressor);
    end
end

figure;imagesc(times,freqs,beta); axis xy; colormap(jet);  colorbar
xlabel('Time (ms)'); ylabel('Frequency (Hz)'); title('sync3t aIC Beta value of ITI std')

figure;imagesc(times,freqs,beta.*(pval< 0.05)); axis xy; colormap(jet);  colorbar
xlabel('Time (ms)'); ylabel('Frequency (Hz)'); title('sync3t mIC significant pval < 0.05')

%% TAP and SIFT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear 
close all 
clc

load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/SIFTs/SIFTout_M30_sync3t.mat'); % could load sync3s, sync3t, rdlisten2 
load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/SMT/ITI_stds.mat')
load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/SMT/ITI_means.mat')
load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Localizers/sync/mean_relative_phase.mat')

time = SIFTout{1,1,1}.erWinCenterTimes;
freq = SIFTout{1,1,1}.freqs;

aIC = [1	2	1	1	1	1	1	2	1	2	1	1	1	1	1	1	1	1	2	1	1	1	1	1	1];
mIC = [2	1	2	2	2	2	2	1	2	1	2	2	2	2	2	2	2	2	1	2	2	2	2	2	2];

for nsub = 1:length(aIC)
    maflow(nsub,:,:) = squeeze(SIFTout{nsub}.dDTF08(aIC(nsub),mIC(nsub),:,:));
    amflow(nsub,:,:) = squeeze(SIFTout{nsub}.dDTF08(mIC(nsub),aIC(nsub),:,:));
end

FOIs = find(freq == 15); 
FOIe = find(freq == 45);

% figure;
% imagesc(time,freq(FOIs:FOIe),squeeze(mean(amflow(:,FOIs:FOIe,:),1)));axis xy; colormap(jet); 
% figure;
% imagesc(time,freq(FOIs:FOIe),squeeze(mean(maflow(:,FOIs:FOIe,:),1)));axis xy; colormap(jet);

% stability of ITI in SMT %%%%%% Marginal significance %%%%%%
stable_tapper = find(stds < median(stds));
unstable_tapper = find(stds > median(stds));
sift_stable_tapper = maflow(stable_tapper,:,:);
sift_unstable_tapper = maflow(unstable_tapper,:,:);

%% regression on time-averaged am and ma flow
mean_amflow = squeeze(mean(amflow,3));
mean_maflow = squeeze(mean(maflow,3));

tic
X = [stds; means; mean_relative_phase];
for nf = 1:size(freq,2)
        tmp_am = fitlm(X',squeeze(mean_amflow(:,nf))');
        lm_am{nf} = tmp_am;
        pvalue_am{nf} = tmp_am.Coefficients.pValue;
        estimate_am{nf} = tmp_am.Coefficients.Estimate;
        tmp_ma = fitlm(X',squeeze(mean_maflow(:,nf))');
        lm_ma{nf} = tmp_ma;
        pvalue_ma{nf} = tmp_ma.Coefficients.pValue;
        estimate_ma{nf} = tmp_ma.Coefficients.Estimate;
end

save linear_reg_sync3s_SIFT lm_am lm_ma pvalue_am pvalue_ma estimate_am estimate_ma
toc

%%
regressor = 2;
for nf = 1:size(lm_am,2)
    beta(nf) = estimate_am{nf}(regressor);
    pval(nf) = pvalue_am{nf}(regressor);
end

figure;plot(freq,beta,'LineWidth',2); 
xlabel('Frequency (Hz)'); ylabel('beta'); title('sync3s amflow')
figure;plot(freq,pval,'LineWidth',2); 
xlabel('Frequency (Hz)'); ylabel('pvalue'); title('sync3s amflow')

for nf = 1:size(lm_ma,2)
    beta(nf) = estimate_ma{nf}(regressor);
    pval(nf) = pvalue_ma{nf}(regressor);
end

hold on;plot(freq,beta,'LineWidth',2); 
xlabel('Frequency (Hz)'); ylabel('beta'); title('sync3s maflow')
figure;plot(freq,pval,'LineWidth',2); 
xlabel('Frequency (Hz)'); ylabel('pvalue'); title('sync3s maflow')

%% ma am flow
figure;plot(freq,squeeze(mean(mean_amflow,1)),'LineWidth',2);
hold on;plot(freq,squeeze(mean(mean_maflow,1)),'LineWidth',2);
[h,p] = ttest(mean_amflow,mean_maflow);
figure; plot(freq,p,'LineWidth',2); gridy([0.05],'k:'); title('uncorrected p-value')

%%
figure;imagesc(time,freq(FOIs:FOIe),squeeze(mean(sift_stable_tapper(:,FOIs:FOIe,:),1))); axis xy; colormap(jet);  colorbar
xlabel('Time (ms)'); ylabel('Frequency (Hz)'); title('Stable subj SIFT')
figure;imagesc(time,freq(FOIs:FOIe),squeeze(mean(sift_unstable_tapper(:,FOIs:FOIe,:),1))); axis xy; colormap(jet);  colorbar
xlabel('Time (ms)'); ylabel('Frequency (Hz)'); title('Unstable subj SIFT')

%%
figure
plot(freq,squeeze(mean(mean(sift_stable_tapper,3),1)),'LineWidth',2)
hold on
plot(freq,squeeze(mean(mean(sift_unstable_tapper,3),1)),'LineWidth',2)
[h,p] = ttest(squeeze(mean(sift_stable_tapper,3)),squeeze(mean(sift_unstable_tapper,3)));
figure; plot(freq,p); gridy([0.05],'k:'); title('uncorrected p-value')

%% relphase between tap and sound stimuli in sync %%%%%% Marginal significance %%%%%%
good_syncher = find(mean_relative_phase < median(mean_relative_phase));
bad_syncher = find(mean_relative_phase > median(mean_relative_phase));
sift_good_syncher = amflow(good_syncher,:,:);
sift_bad_syncher = amflow(bad_syncher,:,:);

figure;imagesc(time,freq(FOIs:FOIe),squeeze(mean(sift_good_syncher,1))); axis xy; colormap(jet);  colorbar
xlabel('Time (ms)'); ylabel('Frequency (Hz)'); title('Good syncher SIFT')
figure;imagesc(time,freq(FOIs:FOIe),squeeze(mean(sift_bad_syncher,1))); axis xy; colormap(jet);  colorbar
xlabel('Time (ms)'); ylabel('Frequency (Hz)'); title('Bad syncher SIFT')

%%
figure
plot(freq,squeeze(mean(mean(sift_good_syncher,3),1)))
hold on
plot(freq,squeeze(mean(mean(sift_bad_syncher,3),1)))
[h,p] = ttest(squeeze(mean(sift_good_syncher,3)),squeeze(mean(sift_bad_syncher,3)));
figure; plot(freq,p); gridy([0.05],'k:'); title('uncorrected p-value')

