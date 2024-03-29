% eeglab
clear 
clc

SMT_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SMT/';
sync_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/sync/';
rdlisten_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/rdlisten/';
SIFT_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SIFTs/';
%% Behavioral
load(strcat(SMT_path,'ITI_stds.mat'));
load(strcat(SMT_path,'ITI_means.mat'));
% load(strcat(sync_path,'circular_relphase.mat'));
load(strcat(sync_path,'relative_phase.mat'));

% Outliers 
% outlier = 1;
% if outlier == 1
%     outlier_ind = find(isoutlier(stds,'quartiles')==1); % use quartiles to define outliers
% else
%    outlier_ind = 0;
% end
% mean_relative_phase(outlier_ind) = [];
% stds(outlier_ind) = [];

% 'Mean Relphase' 
% rad2deg(circ_mean(theta'))
% rad2deg(circ_std(theta'))

 cv = stds./means;
% stable_tapper = find(cv < median(cv)); % use cv of ITI
% unstable_tapper = find(cv > median(cv)); % use cv of ITI

stable_tapper = find(stds < median(stds)); % use std of ITI
unstable_tapper = find(stds > median(stds)); % use std of ITI

% Compare stable tappers with unstable tappers ***
[h,p,ci,stats] = ttest2(stds(stable_tapper),stds(unstable_tapper))
meanEffectSize(stds(stable_tapper),stds(unstable_tapper),'Effect' ,'cohen')

% Compare SMS performance (circmean relphase and circ std) between stable
% tappers with unstable tappers, mainly no difference
[h,p,ci,stats] = ttest2(theta(stable_tapper),theta(unstable_tapper))
meanEffectSize(theta(stable_tapper),theta(unstable_tapper), 'Effect' ,'cohen')
circ_mean(theta(stable_tapper)')
circ_mean(theta(unstable_tapper)')
rad2deg(circ_mean(theta(stable_tapper)'))
rad2deg(circ_mean(theta(unstable_tapper)'))

[p,stats] = circ_ktest(theta(stable_tapper),theta(unstable_tapper)) % test for the circ variance (concentration of the Von Mises dist): * diff
[p,stats] = circ_wwtest(theta(stable_tapper),theta(unstable_tapper)) % test for the cric mean (concentration of the Von Mises dist): no diff
[h,p,ci,stats] = ttest2(theta(stable_tapper),theta(unstable_tapper)) % regular t-test: no diff
[h,p,ci,stats] = ttest2(csd(stable_tapper),csd(unstable_tapper))
meanEffectSize(csd(stable_tapper),csd(unstable_tapper),'Effect' ,'cohen')

%% cross-correlation of ITI and async in SMS
load(strcat(SMT_path,'ITI_stds.mat'));
load(strcat(SMT_path,'ITI_means.mat'));
load(strcat(sync_path,'calc_tap_output.mat'));
load(strcat(sync_path,'relative_phase.mat'));

stable_tapper = find(stds < median(stds)); % use std of ITI
unstable_tapper = find(stds > median(stds)); % use std of ITI

% not seem to be correct: very large 
for i = 1:25
    autocorrAsync(i) = tap_results{i}.autocorrAsync(2);
    autocorrITI(i) = tap_results{i}.autocorrITI(2);
    figure; 
    plot(tap_results{i}.autocorrTau,tap_results{i}.autocorrAsync,'o');title('autocorrAsync'); xlabel('Tau')
    figure; 
    plot(tap_results{i}.autocorrTau,tap_results{i}.autocorrITI,'o');title('autocorrITI'); xlabel('Tau')
end
%%
mean(autocorrITI(stable_tapper))
mean(autocorrITI(unstable_tapper))
[h,p,ci,stats] = ttest2(autocorrITI(stable_tapper),autocorrITI(unstable_tapper))
[h,p,ci,stats] = ttest2(autocorrAsync(stable_tapper),autocorrAsync(unstable_tapper))

%% calculate by myself: still very big ac, why? -> not normalized can use 'coeff'
taps = 30; %number of lags to keep
autocorrAsync_all = nan(25,31);
autocorrITI_all = nan(25,31);

for i = 1:25
    tmp_async = relative_phase{i}*600;
    [ac,tau] = xcorr(tmp_async-nanmean(tmp_async),'coeff');
    im1 = find(tau==-1);
    i0 = im1+1;
    im = max(1,im1-taps+1);
    autocorrAsync = nan(taps+1,1);
    autocorrAsync(1:(i0-im+1)) = ac(i0:-1:im); %include 0 to lag -taps
    autocorrAsync_all(i,:) = autocorrAsync;
    
    [ac,tau] = xcorr(tap_results{i}.iti-nanmean(tap_results{i}.iti),'coeff');
    im1 = find(tau==-1);
    i0 = im1+1;
    im = max(1,im1-taps+1);
    autocorrITI = nan(taps+1,1);
    autocorrITI(1:(i0-im+1)) = ac(i0:-1:im); %include 0 to lag -taps
    autocorrITI_all(i,:) = autocorrITI;
    autocorrTau = tau(i0:-1:im);
    
    clear tmp_async
end
%% engineer the effect of synchronization: SDasync, SI
for i = 1:25
    stds_rp(i) = nanstd(relative_phase{i});
    mean_rp(i) = nanmean(relative_phase{i});
end
good_syncher = find(stds_rp < median(stds_rp)); % use std of ITI
bad_syncher = find(stds_rp > median(stds_rp)); % use std of ITI

%% calculate SI based on Fujii and Schlaug (2013)
n = 24;
M = 360/n;

for nsub = 1:25
    relphase = relative_phase{nsub}*360;
    N = length(relphase);

    count = 0;
    for i = 1:M
        p = length(find(relphase < (count+1)*n-180 & relphase >= count*n-180))/N;
        tmp_se(i) = p*log(p);
        clear p
        count = count + 1;
    end
    se(nsub) = -nansum(tmp_se);
    si(nsub) = 1 - se(nsub)/log(N);
    clear N relphase tmp_se
end

%% Correlatoin between log(cv) and SI
isoutlier(log(cv))
cv = stds./means;
% cv(2) = [];
% si(2) = [];
[r,p] = corrcoef(si,log(cv))
figure;plot(log(cv), si, '.')

[r,p] = corrcoef(si,log(stds))
figure;plot(log(stds), si, '.')

%% A bunch correlations between SMT and SMS: wow it is really not significant 
[r,p] = corrcoef(mean_rp,stds) % could also see circular se and sd (cse, csd) and circular dispersion (i.e. delta)
[r,p] = corrcoef(stds_rp,stds) % could also see circular se and sd (cse, csd) and circular dispersion (i.e. delta)
[r,p] = corrcoef(si,stds)

% if excluding stds outliers 
idex = find(~isoutlier(stds,'quartiles'));
[r,p] = corrcoef(mean_rp(idex),stds(idex)) % could also see circular se and sd (cse, csd) and circular dispersion (i.e. delta)
[r,p] = corrcoef(stds_rp(idex),stds(idex)) % could also see circular se and sd (cse, csd) and circular dispersion (i.e. delta)
[r,p] = corrcoef(si(idex),stds(idex))

% if log transform
[r,p] = corrcoef(mean_rp,log(stds)) % could also see circular se and sd (cse, csd) and circular dispersion (i.e. delta)
[r,p] = corrcoef(stds_rp,log(stds)) % could also see circular se and sd (cse, csd) and circular dispersion (i.e. delta)
[r,p] = corrcoef(si,log(stds))

[r,p] = corrcoef(mean_rp(idex),log(stds(idex))) % could also see circular se and sd (cse, csd) and circular dispersion (i.e. delta)
[r,p] = corrcoef(stds_rp(idex),log(stds(idex))) % could also see circular se and sd (cse, csd) and circular dispersion (i.e. delta)
[r,p] = corrcoef(si(idex),log(stds(idex)))

%% plot the stable and unstable relphase distribution
all_relative_phase = [];
for i = 1:length(relative_phase)
    tmp = relative_phase{i};
%    tmp = tap_results{1,unstable_tapper(i)}.rp;
%    figure;histogram(tmp,100,'Facecolor','blue','FaceAlpha',0.5);gridx([0],'k:');xlim([-0.5 0.5])
    all_relative_phase = [all_relative_phase,tmp];
    clear tmp
end

nanmean(all_relative_phase)*600 % times 600 to convert rp to ms
nanstd(all_relative_phase)*600
%%
% load(strcat(sync_path,'calc_tap_output')) % .rp is the same as the relative_phase
all_stable_relative_phase = [];
for i = 1:length(stable_tapper)
    tmp = relative_phase{stable_tapper(i)};
%    tmp = tap_results{1,stable_tapper(i)}.rp;
    all_stable_relative_phase = [all_stable_relative_phase,tmp];
%    figure;histogram(tmp,100,'Facecolor','red','FaceAlpha',0.5);gridx([0],'k:');xlim([-0.5 0.5])
    clear tmp
end
nanmean(all_stable_relative_phase)*600 % times 600 to convert rp to ms -> slightly different from nanmean for each individual since there is the nans (make the / different)
nanstd(all_stable_relative_phase)*600
%%
all_unstable_relative_phase = [];
for i = 1:length(unstable_tapper)
    tmp = relative_phase{unstable_tapper(i)};
%    tmp = tap_results{1,unstable_tapper(i)}.rp;
%    figure;histogram(tmp,100,'Facecolor','blue','FaceAlpha',0.5);gridx([0],'k:');xlim([-0.5 0.5])
    all_unstable_relative_phase = [all_unstable_relative_phase,tmp];
    clear tmp
end
nanmean(all_unstable_relative_phase)*600 % times 600 to convert rp to ms
nanstd(all_unstable_relative_phase)*600
%%
figure;histogram(all_unstable_relative_phase,'BinWidth',0.01,'Facecolor','red','FaceAlpha',0.5)
hold on;histogram(all_stable_relative_phase,'BinWidth',0.01,'Facecolor','blue','FaceAlpha',0.5)
gridx([0],'k:')
gridx([nanmean(all_stable_relative_phase)],'b:')
gridx([nanmean(all_unstable_relative_phase)],'r:')

legend({'Unstable tappers','Stable tappers'})
xlabel('Relative phases')
ylabel('Frequency')
set(gca,'FontSize',18)

%% significant 
[h,p,ci,stats] = ttest2(all_unstable_relative_phase,all_stable_relative_phase) % * difference between the group
meanEffectSize(all_unstable_relative_phase,all_stable_relative_phase, 'Effect' ,'cohen')

all_stable_nonan = all_stable_relative_phase(~isnan(all_stable_relative_phase));
all_unstable_nonan = all_unstable_relative_phase(~isnan(all_unstable_relative_phase));

[h,p,ci,stats] = ttest2(all_stable_nonan,all_unstable_nonan) % * difference between the group
[p,stats] = circ_wwtest(all_unstable_nonan*2*pi,all_stable_nonan*2*pi) % * difference between the group

%% Neural - ERP
ERP_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/rdlisten/';
SMT_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SMT/';

mIC_erp = load(strcat(SMT_path,'mIC_erp_tap1_lp60Hz.mat'));
aIC_erp = load(strcat(ERP_path,'aIC_erp_rdlisten2_lp60Hz.mat'));

load(strcat(SMT_path,'ITI_stds.mat'));
load(strcat(SMT_path,'ITI_means.mat'));
stable_tapper = find(stds < median(stds)); % use std of ITI
unstable_tapper = find(stds > median(stds)); % use std of ITI

figure;shadedErrorBar(aIC_erp.times,mean(aIC_erp.erps(stable_tapper,:),1),std(aIC_erp.erps(stable_tapper,:)./sqrt(12)),'-b',0);
hold on;shadedErrorBar(aIC_erp.times,mean(aIC_erp.erps(unstable_tapper,:),1),std(aIC_erp.erps(unstable_tapper,:)./sqrt(12)),'-r',0);
gridx
gridy
xlim([-100 300]) 
set(gca,'Fontsize',18)
xlabel('Time (ms)')

[h,p,ci,stats] = ttest2(aIC_erp.erps(stable_tapper,:),aIC_erp.erps(unstable_tapper,:)); % * difference between the group
hold on; gridx(aIC_erp.times(p<0.05),'y:')

% remember to reverse polarity for conventional motor potential
figure;shadedErrorBar(mIC_erp.times,mean(-1.*mIC_erp.erps(stable_tapper,:),1),std(-1.*mIC_erp.erps(stable_tapper,:)./sqrt(12)),'-b',0);
hold on;shadedErrorBar(mIC_erp.times,mean(-1.*mIC_erp.erps(unstable_tapper,:),1),std(-1.*mIC_erp.erps(unstable_tapper,:)./sqrt(12)),'-r',0);
gridx
gridy
xlim([-100 150])
set(gca,'Fontsize',18)
xlabel('Time (ms)')

[h,p,ci,stats] = ttest2(mIC_erp.erps(stable_tapper,:),mIC_erp.erps(unstable_tapper,:)); % * difference between the group
hold on; gridx(mIC_erp.times(p<0.05),'y:')

    
%% Neural - ERSP
%% write them into data form then save to excel ersp_all.csv
clear
cd('/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/ersp');
files = dir('**/*.mat'); % will give en error if ersps.mat is already in the folder
names = {files.name};

for nfile = 1:length(names)
    name  = names{nfile};
    data = load(name);
    
    FOI = [find(data.freqs == 13) find(data.freqs == 35,1)];
    TOI = [72 174;225 328]; % ~[-100 100] ERD ~[200 400] ERS
    for nt = 1:2
        parts_name = cellstr(split(name ,{'_','.'}));
        ersp(nfile,nt,:) = squeeze(mean(mean(data.ersp(:,FOI(1):FOI(2),TOI(nt,1):TOI(nt,2)),2),3));
        condition(nfile,nt) = string(strcat(parts_name{1},'.',parts_name{5},'.T',num2str(nt)));
    end
end
ersp_all = reshape(ersp,16,25)'; % make sure index is right!
condition = condition(:); % make sure index is right!

save ersps ersp_all condition

%%
load('/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/ersp/ersps.mat')
load(strcat(SMT_path,'ITI_stds.mat'));

stable_tapper = find(stds < median(stds));
unstable_tapper = find(stds > median(stds));

% sort the order to match the paper figure
condition = condition([4,1,3,2,8,5,7,6,12,9,11,10,16,13,15,14]);
ersp_all = ersp_all(:,[4,1,3,2,8,5,7,6,12,9,11,10,16,13,15,14]);

% convert to % signal change
ersp_all = ersp_all-1;

% do the one-sample, paired and two-sample ttests here 
% one-sample ttest against 0
[h,p,ci,stats] = ttest(ersp_all(stable_tapper,:))
[h,p,ci,stats] = ttest(ersp_all(unstable_tapper,:))

% paired ttest
[h,p,ci,stats] = ttest(ersp_all(stable_tapper,10)-ersp_all(stable_tapper,12))
[h,p,ci,stats] = ttest(ersp_all(unstable_tapper,10)-ersp_all(unstable_tapper,12))

% two sample ttests
[h,p,ci,stats] = ttest2(ersp_all(stable_tapper,1), ersp_all(unstable_tapper,1))
for i = 1:16
    [h,p,ci,stats] = ttest2(ersp_all(stable_tapper,i), ersp_all(unstable_tapper,i))
end
%%
load(strcat(sync_path,'mIC_averagebaslined_ersp_itc_sync3s.mat'));
% ersp(outlier_ind,:,:) = []; % exclude outliers

FOI = [find(freqs == 13) find(freqs == 35,1)];
TOI = [72 174;225 328]; % ~[-100 100] ERD ~[200 400] ERS
freqs(FOI)
times(TOI)
% median split between stable and unstable tappers: stds or cv
stable_tapper = find(stds < median(stds));
unstable_tapper = find(stds > median(stds));

% stable_tapper = find(cv < median(cv));
% unstable_tapper = find(cv > median(cv));

% unstable_tapper(6) = [];
% stable_tapper(6) = [];

% ERD TOI *** for the mIC sync3s and aIC sync3s
ersp_stable_tapper = squeeze(mean(mean(ersp(stable_tapper,FOI(1):FOI(end),TOI(1,1):TOI(1,2)),2),3));
ersp_unstable_tapper = squeeze(mean(mean(ersp(unstable_tapper,FOI(1):FOI(end),TOI(1,1):TOI(1,2)),2),3));
[h,p,ci,stats] = ttest2(ersp_stable_tapper,ersp_unstable_tapper)
meanEffectSize(ersp_stable_tapper,ersp_unstable_tapper,'Effect' ,'cohen')

% ERS TOI * for the mIC sync3s
ersp_stable_tapper = squeeze(mean(mean(ersp(stable_tapper,FOI(1):FOI(end),TOI(2,1):TOI(2,2)),2),3));
ersp_unstable_tapper = squeeze(mean(mean(ersp(unstable_tapper,FOI(1):FOI(end),TOI(2,1):TOI(2,2)),2),3));
[h,p,ci,stats] = ttest2(ersp_stable_tapper,ersp_unstable_tapper)
meanEffectSize(ersp_stable_tapper,ersp_unstable_tapper,'Effect' ,'cohen')

figure;imagesc(times,freqs,squeeze(mean(ersp,1)));axis xy; colormap(jet);caxis([0.9 1.1]);  colorbar
figure;imagesc(times,freqs,squeeze(mean(ersp(stable_tapper,:,:),1))); axis xy; colormap(jet);caxis([0.9 1.1]);  colorbar
figure;imagesc(times,freqs,squeeze(mean(ersp(unstable_tapper,:,:),1))); axis xy; colormap(jet); caxis([0.9 1.1]); colorbar

%% Pool regression of the pre-defined ROIs *** for the post-beta aIC sync3t, m* pre-beta mIC sync3s
clc
% load(strcat(rdlisten_path,'aIC_averagebaslined_ersp_itc_rdlisten2.mat'));
load(strcat(sync_path,'aIC_averagebaslined_ersp_itc_sync3t.mat'));
load(strcat(SMT_path,'ITI_stds.mat'));

FOI = [find(freqs == 13) find(freqs == 35,1)];
TOI = [72 174;225 328]; % ~[-100 100] ERD ~[200 400] ERS

ersp_ROI_pre = squeeze(mean(mean(ersp(:,FOI(1):FOI(end),TOI(1,1):TOI(1,2)),2),3)); % prestimulus beta
ersp_ROI_post = squeeze(mean(mean(ersp(:,FOI(1):FOI(end),TOI(2,1):TOI(2,2)),2),3)); % prestimulus beta

[r,p] = corrcoef(ersp_ROI_pre,stds)
[r,p] = corrcoef(ersp_ROI_post,stds)

%% mix model method
tableForLme = array2table([[ersp_ROI_pre(:)] [stds(:)] [1:25]'], 'variableNames', {'ERSP', 'stds', 'individualIdx'});
LME1 = fitlme(tableForLme, 'ERSP ~ stds');
LME2 = fitlme(tableForLme, 'ERSP ~ stds + (stds|individualIdx)'); % Identical t-stats.
compare(LME1, LME2) 

%% Neural - Connectivity (4 tasks x 2 directions x 2 tapping stabilities)
clear 
SIFT_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SIFTs/';
SIFT_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/sifts/SIFT_output/2020/';
SMT_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SMT/';
load(strcat(SMT_path,'ITI_stds.mat'));
cd(SIFT_path)
files = dir('*sync3t.mat');
names = {files.name};

aIC = [1	2	1	1	1	1	1	2	1	2	1	1	1	1	1	1	1	1	2	1	1	1	1	1	1];
mIC = [2	1	2	2	2	2	2	1	2	1	2	2	2	2	2	2	2	2	1	2	2	2	2	2	2];

stable_tapper = find(stds < median(stds));
unstable_tapper = find(stds > median(stds));

for nfile = 1:length(names)
    
    name  = names{nfile};
    load(name);
    parts_name = cellstr(split(name ,{'_','.'}));
    
    time = SIFTout{1,1,1}.erWinCenterTimes;
    freq = SIFTout{1,1,1}.freqs;
    FOI = [find(freq == 13) find(freq == 35)];
    
    for nsub = 1:length(aIC)
        tmp_maflow(nsub,:) = squeeze(mean(SIFTout{nsub}.dDTF08(aIC(nsub),mIC(nsub),:,:),4));
        tmp_amflow(nsub,:) = squeeze(mean(SIFTout{nsub}.dDTF08(mIC(nsub),aIC(nsub),:,:),4));
    end
   
    amflow(:,:,nfile) = tmp_amflow;
    maflow(:,:,nfile) = tmp_maflow;
    condition(nfile) = string(strcat(parts_name{3})); 
end
% save sift_all.mat amflow maflow freq condition

% amflow_all = reshape(amflow,25,446*4);
% maflow_all = reshape(maflow,25,446*4);
condition = {'M5','M10','M20','M30','M40','M50','M60'};


%% pool direction: stable vs. unstable tappers
info_flow = 0.5*(amflow + maflow);

for i = 1:4
    mean_stable_tapper = squeeze(info_flow(stable_tapper,:,i));
    mean_unstable_tapper = squeeze(info_flow(unstable_tapper,:,i));
    figure;shadedErrorBar(freq,mean_stable_tapper,{@mean,@std},'-b');
    hold on;shadedErrorBar(freq,mean_unstable_tapper,{@mean,@std},'-r');
    title()
    [h,p] = ttest2(mean_stable_tapper,mean_unstable_tapper);
    uncorrect_sig = find(p < 0.05);
    gridx(freq([uncorrect_sig]),'y-')
    title(condition{i})
    clear mean_stable_tapper mean_unstable_tapper h p
    xlim([13 30])
end

%% amflow: stable vs. unstable tappers
for i = 1:size(amflow,3)
    figure;shadedErrorBar(freq,squeeze(amflow(stable_tapper,:,i)),{@mean,@std},'-b',1);
    hold on;shadedErrorBar(freq,squeeze(amflow(unstable_tapper,:,i)),{@mean,@std},'-r',1);
    title(condition{i})
    mean_amflow_stable_tapper = squeeze(mean(amflow(stable_tapper,:,i),3));
    mean_amflow_unstable_tapper = squeeze(mean(amflow(unstable_tapper,:,i),3));
    [h,p] = ttest2(mean_amflow_stable_tapper,mean_amflow_unstable_tapper);
    uncorrect_sig = find(p < 0.05);
    gridx(freq([uncorrect_sig]),'y-')
    title(condition{i})
    clear mean_amflow_stable_tapper mean_amflow_unstable_tapper h p
    xlim([13 30])
    set(gca,'Fontsize',18)
    xlabel('Frequency (Hz)')
    ylim([-0.5e-3 2.5e-3])
end

%% maflow: stable vs. unstable tappers
for i = 1:size(amflow,3)
    figure;shadedErrorBar(freq,squeeze(maflow(stable_tapper,:,i)),{@mean,@std},'-b',1);
    hold on;shadedErrorBar(freq,squeeze(maflow(unstable_tapper,:,i)),{@mean,@std},'-r',1);
    title(condition{i})
    mean_maflow_stable_tapper = squeeze(mean(maflow(stable_tapper,:,i),3));
    mean_maflow_unstable_tapper = squeeze(mean(maflow(unstable_tapper,:,i),3));
    [h,p] = ttest2(mean_maflow_stable_tapper,mean_maflow_unstable_tapper);
    uncorrect_sig = find(p < 0.05);
    gridx(freq([uncorrect_sig]),'y-')
    title(condition{i})
    clear mean_maflow_stable_tapper mean_maflow_unstable_tapper h p
    xlim([13 30])
    set(gca,'Fontsize',18)
    xlabel('Frequency (Hz)')
%    ylim([-5e-4 25e-4])
end

%% Get the correlations 
for i = 1:size(amflow,3)
    for freqs = 1:size(amflow,2)
        [r(i,freqs,:), p(i,freqs,:)] = corr(stds',squeeze(amflow(:,freqs,i)));
    end
end

figure;plot(freq,p,'LineWidth',2)
legend('M5','M10','M20','M30','M40','M50','M60');
xlabel('Frequency (Hz)')
ylabel('Pearson correlation coefficient')
title('maflow')

%% stable tappers: amflow vs. maflow
for i = 1:4
    figure;shadedErrorBar(freq,squeeze(amflow(stable_tapper,:,i)),{@mean,@std},'-r',1);
    hold on;shadedErrorBar(freq,squeeze(maflow(stable_tapper,:,i)),{@mean,@std},'-k',1);
    title(condition{i})
    mean_amflow_stable_tapper = squeeze(mean(amflow(stable_tapper,:,i),3));
    mean_maflow_stable_tapper = squeeze(mean(maflow(stable_tapper,:,i),3));
    [h,p] = ttest2(mean_amflow_stable_tapper,mean_maflow_stable_tapper);
    uncorrect_sig = find(p < 0.05);
    gridx(freq([uncorrect_sig]),'y-')
    title(condition{i})
    clear mean_maflow_stable_tapper mean_maflow_unstable_tapper h p
end

% unstable tappers: amflow vs. maflow
for i = 1:4
    figure;shadedErrorBar(freq,squeeze(amflow(unstable_tapper,:,i)),{@mean,@std},'-r',1);
    hold on;shadedErrorBar(freq,squeeze(maflow(unstable_tapper,:,i)),{@mean,@std},'-k',1);
    title(condition{i})
    mean_amflow_unstable_tapper = squeeze(mean(amflow(unstable_tapper,:,i),3));
    mean_maflow_unstable_tapper = squeeze(mean(maflow(unstable_tapper,:,i),3));
    [h,p] = ttest2(mean_amflow_unstable_tapper,mean_maflow_unstable_tapper);
    uncorrect_sig = find(p < 0.05);
    gridx(freq([uncorrect_sig]),'y-')
    title(condition{i})
    clear mean_maflow_stable_tapper mean_maflow_unstable_tapper h p
end

% 4 tasks x 2 directions
figure;plot(freq,squeeze(mean(amflow(stable_tapper,:,:),1)));title('amflow of stable tappers');legend(condition)
figure;plot(freq,squeeze(mean(maflow(stable_tapper,:,:),1)));title('maflow of stable tappers');legend(condition)

figure;plot(freq,squeeze(mean(amflow(unstable_tapper,:,:),1)));title('amflow of unstable tappers');legend(condition)
figure;plot(freq,squeeze(mean(maflow(unstable_tapper,:,:),1)));title('maflow of unstable tappers');legend(condition)

% all tapper: rdlisten vs. sync3s amflow
figure;shadedErrorBar(freq,squeeze(amflow(:,:,1)),{@mean,@std},'-r',1);
hold on;shadedErrorBar(freq,squeeze(amflow(:,:,2)),{@mean,@std},'-k',1);
[h,p] = ttest(squeeze(amflow(:,:,1)),squeeze(amflow(:,:,2)));
uncorrect_sig = find(p < 0.05);
gridx(freq([uncorrect_sig]),'y-')

% all tapper: rdlisten vs. sync3s amflow
figure;shadedErrorBar(freq,squeeze(amflow(:,:,3)),{@mean,@std},'-r',1);
hold on;shadedErrorBar(freq,squeeze(amflow(:,:,4)),{@mean,@std},'-k',1);
[h,p] = ttest(squeeze(amflow(:,:,3)),squeeze(amflow(:,:,4)));
uncorrect_sig = find(p < 0.05);
gridx(freq([uncorrect_sig]),'y-')

% all tapper: rdlisten vs. sync3s maflow
figure;shadedErrorBar(freq,squeeze(maflow(:,:,1)),{@mean,@std},'-r',1);
hold on;shadedErrorBar(freq,squeeze(maflow(:,:,2)),{@mean,@std},'-k',1);
[h,p] = ttest(squeeze(maflow(:,:,1)),squeeze(maflow(:,:,2)));
uncorrect_sig = find(p < 0.05);
gridx(freq([uncorrect_sig]),'y-')

% all tapper: rdlisten vs. sync3s maflow
figure;shadedErrorBar(freq,squeeze(maflow(:,:,3)),{@mean,@std},'-r',1);
hold on;shadedErrorBar(freq,squeeze(maflow(:,:,4)),{@mean,@std},'-k',1);
[h,p] = ttest(squeeze(maflow(:,:,3)),squeeze(maflow(:,:,4)));
uncorrect_sig = find(p < 0.05);
gridx(freq([uncorrect_sig]),'y-')

% stable tapper: rdlisten vs. sync3s amflow
figure;shadedErrorBar(freq,squeeze(amflow(stable_tapper,:,1)),{@mean,@std},'-r',1);
hold on;shadedErrorBar(freq,squeeze(amflow(stable_tapper,:,2)),{@mean,@std},'-k',1);
[h,p] = ttest(squeeze(amflow(stable_tapper,:,1)),squeeze(amflow(stable_tapper,:,2)));
uncorrect_sig = find(p < 0.05);
gridx(freq([uncorrect_sig]),'y-')

% stable tapper: tap vs. sync3t amflow
figure;shadedErrorBar(freq,squeeze(amflow(stable_tapper,:,3)),{@mean,@std},'-r',1);
hold on;shadedErrorBar(freq,squeeze(amflow(stable_tapper,:,4)),{@mean,@std},'-k',1);
[h,p] = ttest(squeeze(amflow(stable_tapper,:,3)),squeeze(amflow(stable_tapper,:,4)));
uncorrect_sig = find(p < 0.05);
gridx(freq([uncorrect_sig]),'y-')

% stable tapper: rdlisten vs. sync3s maflow
figure;shadedErrorBar(freq,squeeze(maflow(stable_tapper,:,1)),{@mean,@std},'-r',1);
hold on;shadedErrorBar(freq,squeeze(maflow(stable_tapper,:,2)),{@mean,@std},'-k',1);
[h,p] = ttest(squeeze(maflow(stable_tapper,:,1)),squeeze(maflow(stable_tapper,:,2)));
uncorrect_sig = find(p < 0.05);
gridx(freq([uncorrect_sig]),'y-')

% stable tapper: tap vs. sync3t amflow
figure;shadedErrorBar(freq,squeeze(maflow(stable_tapper,:,3)),{@mean,@std},'-r',1);
hold on;shadedErrorBar(freq,squeeze(maflow(stable_tapper,:,4)),{@mean,@std},'-k',1);
[h,p] = ttest(squeeze(maflow(stable_tapper,:,3)),squeeze(maflow(stable_tapper,:,4)));
uncorrect_sig = find(p < 0.05);
gridx(freq([uncorrect_sig]),'y-')

%% correlatoin *** for the sync3s am and sync3t am & ma
clear
clc
close all

SMT_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SMT/';
load('sift_all.mat')
load(strcat(SMT_path,'ITI_stds.mat'));

for ncond = 1:size(amflow,3)
    for nf = 1:size(amflow,2)
        [tmp_r_am, tmp_p_am] = corrcoef(squeeze(amflow(:,nf,ncond)),stds);
        r_am(ncond,nf) = tmp_r_am(1,2);
        p_am(ncond,nf) = tmp_p_am(1,2);
        [tmp_r_ma, tmp_p_ma] = corrcoef(squeeze(maflow(:,nf,ncond)),stds);
        r_ma(ncond,nf) = tmp_r_ma(1,2);
        p_ma(ncond,nf) = tmp_p_ma(1,2);
        clear tmp_r_am tmp_p_am tmp_r_ma tmp_p_ma
    end
end

figure;plot(freq,r_am);hold on; plot(freq,r_ma)
figure;plot(freq,p_am);hold on; plot(freq,p_ma)

%% visualization for individual ERSP, SIFT, ERP, topo 
% load ERSP
load(strcat(sync_path,'mIC_averagebaslined_ersp_itc_sync3s.mat'));
load(strcat(sync_path,'mIC_averagebaslined_ersp_itc_sync3t.mat'));

load(strcat(SMT_path,'mIC_averagebaslined_ersp_itc_tap1.mat'));
load(strcat(SMT_path,'aIC_averagebaslined_ersp_itc_tap1.mat'));

load(strcat(rdlisten_path,'mIC_averagebaslined_ersp_itc_rdlisten2.mat'));
load(strcat(rdlisten_path,'aIC_averagebaslined_ersp_itc_rdlisten2.mat'));

% load behavioral
load(strcat(SMT_path,'ITI_stds.mat'));
load(strcat(sync_path,'circular_relphase.mat'));

%% ERSP: stable vs. unstable
figure;imagesc(times,freqs,squeeze(mean(ersp,1)));axis xy; colormap(jet);caxis([0.9 1.1]);  colorbar
figure;imagesc(times,freqs,squeeze(mean(ersp(stable_tapper,:,:),1))); axis xy; colormap(jet);caxis([0.9 1.1]);  colorbar
figure;imagesc(times,freqs,squeeze(mean(ersp(unstable_tapper,:,:),1))); axis xy; colormap(jet); caxis([0.9 1.1]); colorbar

% ERSP: individual plot
figure;
jisubplot(3,4,0)

for i = 1:12
    nextplot
    imagesc(times,freqs,squeeze(ersp(stable_tapper(i),:,:))); axis xy; colormap(jet);  jicolorbar
    title(strcat('s0',num2str(stable_tapper(i))))
end

figure;
jisubplot(3,4,0)
for i = 1:12
    nextplot
    imagesc(times,freqs,squeeze(ersp(unstable_tapper(i),:,:))); axis xy; colormap(jet);  jicolorbar
    title(strcat('s0',num2str(unstable_tapper(i))))
end

%% ERSP: individual plot sorted by ITI of the Tap localizer or relphase of the SMS
sorted_by = stds; % stds or cv of the Tap Localizer or si (mean relphase) of the SMS, or trial number included
[~, sort_ind] = sort(sorted_by); 

%%
figure;
jisubplot(3,4,0)

for i = 1:24
    nextplot
    imagesc(times,freqs,squeeze(ersp(sort_ind(i),:,:))); axis xy; colormap(jet); caxis([0.8 1.4]); jicolorbar
    title(strcat('iS = ',num2str(sort_ind(i)),' tap =',num2str(sorted_by(sort_ind(i)))))
end
% jisuptitle('Tap-locked')

%% topo: individual plot sorted by ITI of the Tap localizer or relphase of the SMS
load(strcat(sync_path,'mIC_topo.mat'))
load(strcat(sync_path,'aIC_topo.mat'))

figure;
jisubplot(3,4,0)

for i = 1:24
    nextplot
    topoplot(topo{sort_ind(i)}{1},topo{sort_ind(i)}{2});
    title(strcat('iS = ',num2str(sort_ind(i)),' tap =',num2str(sorted_by(sort_ind(i)))))
end
jisuptitle('Tap-locked')

%% erp: individual plot sorted by ITI of the Tap localizer or relphase of the SMS
load(strcat(sync_path,'aIC_erp_sync3s.mat'))
load(strcat(sync_path,'aIC_erp_sync3t.mat'))
load(strcat(sync_path,'mIC_erp_sync3s.mat'))
load(strcat(sync_path,'mIC_erp_sync3t.mat'))

%% Tap localizer 
load(strcat(SMT_path,'aIC_erp_tap1.mat'))
load(strcat(SMT_path,'mIC_erp_tap1.mat'))

figure;
jisubplot(3,4,0)

for i = 1:24
    nextplot
    plot(times,erps(sort_ind(i),:),'LineWidth',2);xlim([-50 100]);ylim([-0.8 0.8]);gridx(0,'k:')
    title(strcat('iS = ',num2str(sort_ind(i)),' tap =',num2str(sorted_by(sort_ind(i)))))
end
jisuptitle('Tap-locked')

%% Sound localizer
load(strcat(rdlisten_path,'aIC_erp_rdlisten2.mat'))
load(strcat(rdlisten_path,'mIC_erp_rdlisten2.mat'))

figure;
jisubplot(3,4,0)

for i = 1:24
    nextplot
    plot(times,erps(sort_ind(i),:),'LineWidth',2);xlim([-100 300]);gridx(0,'k:')
    title(strcat('iS = ',num2str(sort_ind(i)),' tap =',num2str(sorted_by(sort_ind(i)))))
end
jisuptitle('Sound-locked')

%% top 4 vs. bottom 4 
FOI = [find(freqs == 13) find(freqs == 35,1)];
TOI = [72 174;225 328]; % ~[-100 100] ERD ~[200 400] ERS

% ERD TOI *** for the mIC sync3s and mIC sync3t
ersp_top4_stable_tapper = squeeze(mean(mean(ersp(sort_ind(1:4),FOI(1):FOI(end),TOI(1,1):TOI(1,2)),2),3));
ersp_top4_unstable_tapper = squeeze(mean(mean(ersp(sort_ind(end-3:end),FOI(1):FOI(end),TOI(1,1):TOI(1,2)),2),3));
[h,p,ci,stats] = ttest2(ersp_top4_stable_tapper,ersp_top4_unstable_tapper);

% ERS TOI *** for the mIC sync3s but not for mIC sync3t
ersp_top4_stable_tapper = squeeze(mean(mean(ersp(sort_ind(1:4),FOI(1):FOI(end),TOI(2,1):TOI(2,2)),2),3));
ersp_top4_unstable_tapper = squeeze(mean(mean(ersp(sort_ind(end-3:end),FOI(1):FOI(end),TOI(2,1):TOI(2,2)),2),3));
[h,p,ci,stats] = ttest2(ersp_top4_stable_tapper,ersp_top4_unstable_tapper);

%% erpimage
sorted_by = trials; % stds or cv of the Tap Localizer or -theta (mean relphase) of the SMS
[~, sort_ind] = sort(sorted_by); 

%% File path 
addpath(genpath('/Volumes/TOSHIBA/Research/Imagined_beats/script'))
EEG_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/sync'; % /Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/preprocessed/epoch/SB_WB
cd(EEG_path)
files = dir(fullfile(EEG_path,'*sync3s_e.set')); % triple_SB_e.set
names = {files.name};
names = names(sort_ind);

% Parameters
% am selection 4b
new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	6	4	1	1	5	8	4];
new_amIC(2,:) = [8	1	11	11	10	11	8	4	13	4	15	7	18	8	16	21	12	36	4	17	6	9	14	21	8];

IC = 2;
figure;
jisubplot(3,4,0)

for nsub = 1:length(names)
    tempEEG = names{nsub};
    parts_cleanEEG = cellstr(split(tempEEG,'.'));
    EEG = pop_loadset('filename',tempEEG ,'filepath', EEG_path); % epoched data
    nextplot
    [outdata,outvar,outtrials,limits,axhndls, ...
                         erp,amps,cohers,cohsig,ampsig,outamps,...
                         phsangls,phsamp,sortidx,erpsig] ...
                             = erpimage(squeeze(EEG.icaact(new_amIC(IC,nsub),:,:)),eeg_getepochevent(EEG, {'Tap'},[],'latency'),...
                             linspace(EEG.xmin*1000, EEG.xmax*1000, EEG.pnts),strcat('iS = ',num2str(sort_ind(nsub)),' tap =',num2str(sorted_by(sort_ind(nsub)))), 40, 1,...
                             'cbar','off','caxis',[-4 4],'plotamps','on','coher',[13 25 0.05],'baselinedb',[EEG.xmin*1000 EEG.xmax*1000]);
end

%% linear regression
load(strcat(sync_path,'linear_reg_mIC_sync3t_ersp.mat'),'estimate')
load(strcat(sync_path,'mIC_averagebaslined_ersp_itc_sync3s.mat'));
regressor = 2;

for nt = 1:size(estimate,1)
    for nf = 1:size(estimate,2)
        beta(nt,nf) = estimate{nt,nf}(regressor);
    end
end

figure;imagesc(times,freqs,beta*-1);axis xy; colormap(jet); colorbar % reverse polarity (tapping variability -> tapping stability)
caxis([-2e-3 2e-3])