eeglab
clear 

SMT_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SMT/';
sync_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/sync/';
rdlisten_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/rdlisten/';
SIFT_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SIFTs/';
addpath(genpath('/Volumes/TOSHIBA/Research/Imagined_beats/script'))

%% Behavioral
load(strcat(SMT_path,'ITI_stds.mat'));
load(strcat(SMT_path,'ITI_means.mat'));
load(strcat(sync_path,'circular_relphase.mat'));
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

'Mean Relphase' 
rad2deg(circ_mean(theta'))
rad2deg(circ_std(theta'))

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

% Correlatoin between SMT ITI and Sync relphase
[r,p] = corrcoef(theta,stds) % could also see circular se and sd (cse, csd) and circular dispersion (i.e. delta)
[r,p] = corrcoef(theta,cv)

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

%% Correlatoin between log(cv) and SI: if exlcuding outliers 
isoutlier(log(cv))
cv = stds./means;
cv(2) = [];
si(2) = [];
[r,p] = corrcoef(si,log(cv))
figure;plot(log(cv), si, '.')

%% plot the stable and unstable relphase distribution
load(strcat(sync_path,'calc_tap_output'))
all_stable_relative_phase = [];
for i = 1:length(stable_tapper)
    tmp = relative_phase{stable_tapper(i)};
%    tmp = tap_results{1,stable_tapper(i)}.rp;
    all_stable_relative_phase = [all_stable_relative_phase,tmp];
%    figure;histogram(tmp,100,'Facecolor','red','FaceAlpha',0.5);gridx([0],'k:');xlim([-0.5 0.5])
    clear tmp
end

all_unstable_relative_phase = [];
for i = 1:length(unstable_tapper)
    tmp = relative_phase{unstable_tapper(i)};
%    tmp = tap_results{1,unstable_tapper(i)}.rp;
%    figure;histogram(tmp,100,'Facecolor','blue','FaceAlpha',0.5);gridx([0],'k:');xlim([-0.5 0.5])
    all_unstable_relative_phase = [all_unstable_relative_phase,tmp];
    clear tmp
end

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

[p,stats] = circ_wwtest(all_unstable_nonan*2*pi,all_stable_nonan*2*pi) % * difference between the group

%% Neural - ERP
ERP_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/rdlisten/';
SMT_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SMT/';

mIC_erp = load(strcat(SMT_path,'mIC_erp_SMT_lp60Hz.mat'));
aIC_erp = load(strcat(ERP_path,'aIC_erp_rdlisten2_lp60Hz.mat'));

load(strcat(SMT_path,'ITI_stds.mat'));
load(strcat(SMT_path,'ITI_means.mat'));
stable_tapper = find(stds < median(stds)); % use std of ITI
unstable_tapper = find(stds > median(stds)); % use std of ITI

aIC_stable_ERP = aIC_erp.erps(stable_tapper,:);
aIC_unstable_ERP = aIC_erp.erps(unstable_tapper,:);

mIC_stable_ERP = mIC_erp.erps(stable_tapper,:);
mIC_unstable_ERP = mIC_erp.erps(unstable_tapper,:);

[h,p,ci,stats] = ttest2(aIC_stable_ERP,aIC_unstable_ERP); % * difference between the group
figure;plot(aIC_erp.times,mean(aIC_stable_ERP,1));hold on; plot(aIC_erp.times,mean(aIC_unstable_ERP,1))
gridx(aIC_erp.times(p<0.05),'y:')

[h,p,ci,stats] = ttest2(mIC_stable_ERP,mIC_unstable_ERP); % * difference between the group
figure;plot(mIC_erp.times,mean(mIC_stable_ERP,1));hold on; plot(mIC_erp.times,mean(mIC_unstable_ERP,1))
gridx(mIC_erp.times(p<0.05),'y:')


%% Neural - ERSP
load(strcat(sync_path,'aIC_averagebaslined_ersp_itc_sync3s.mat'));
% ersp(outlier_ind,:,:) = []; % exclude outliers

FOI = [find(freqs == 13) find(freqs == 25,1)];
TOI = [72 174;226 327]; % [-100 100] ERD [200 400] ERS

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

%% cohen's d for each pixel: very slow 
d = [];
for nf = 1:size(ersp,2)
    for nt = 1:size(ersp,3)
        stable = squeeze(ersp(stable_tapper,nf,nt));
        unstable = squeeze(ersp(unstable_tapper,nf,nt));
%         sp = sqrt((var(stable)+var(unstable))/2);
%         d = (mean(stable)-mean(unstable))/sp;
        tmp = meanEffectSize(stable,unstable,'Effect' ,'cohen');
        d(nf,nt) = tmp.Effect; % corrected Hedge's g for small sample size 
        clear tmp
    end
    fprintf('Just finished iteration #%d\n', nf);
end
save cohenD_aIC_sync3s.mat freqs times d

%% between Tap and Sound localizer
aIC_rdlisten = load(strcat(rdlisten_path,'aIC_averagebaslined_ersp_itc_rdlisten2'));
mIC_rdlisten = load(strcat(rdlisten_path,'mIC_averagebaslined_ersp_itc_rdlisten2'));
aIC_tap = load(strcat(SMT_path,'aIC_averagebaslined_ersp_itc_tap1'));
mIC_tap = load(strcat(SMT_path,'mIC_averagebaslined_ersp_itc_tap1'));
aIC_sync3s = load(strcat(sync_path,'aIC_averagebaslined_ersp_itc_sync3s'));
mIC_sync3s = load(strcat(sync_path,'mIC_averagebaslined_ersp_itc_sync3s'));
aIC_sync3t = load(strcat(sync_path,'aIC_averagebaslined_ersp_itc_sync3t'));
mIC_sync3t = load(strcat(sync_path,'mIC_averagebaslined_ersp_itc_sync3t'));

% ERD TOI *** for the both aIC and mIC between localizer tasks
% overall aIC activity of Sound vs. Tap localizer 
aIC_rdlisten_avg = squeeze(mean(mean(aIC_rdlisten.ersp(:,FOI(1):FOI(end),TOI(1,1):TOI(1,2)),2),3));
aIC_tap_avg = squeeze(mean(mean(aIC_tap.ersp(:,FOI(1):FOI(end),TOI(1,1):TOI(1,2)),2),3));
[h,p,ci,stats] = ttest(aIC_rdlisten_avg-aIC_tap_avg)
meanEffectSize(aIC_rdlisten_avg-aIC_tap_avg,'Effect' ,'cohen')

% overall mIC activity of Sound vs. Tap localizer 
mIC_rdlisten_avg = squeeze(mean(mean(mIC_rdlisten.ersp(:,FOI(1):FOI(end),TOI(1,1):TOI(1,2)),2),3));
mIC_tap_avg = squeeze(mean(mean(mIC_tap.ersp(:,FOI(1):FOI(end),TOI(1,1):TOI(1,2)),2),3));
[h,p,ci,stats] = ttest(mIC_rdlisten_avg-mIC_tap_avg)
meanEffectSize(mIC_rdlisten_avg-mIC_tap_avg,'Effect' ,'cohen')

% ERS TOI *** for the both aIC and mIC between localizer tasks
% overall aIC activity of Sound vs. Tap localizer 
aIC_rdlisten_avg = squeeze(mean(mean(aIC_rdlisten.ersp(:,FOI(1):FOI(end),TOI(2,1):TOI(2,2)),2),3));
aIC_tap_avg = squeeze(mean(mean(aIC_tap.ersp(:,FOI(1):FOI(end),TOI(2,1):TOI(2,2)),2),3));
[h,p,ci,stats] = ttest(aIC_rdlisten_avg-aIC_tap_avg)
meanEffectSize(aIC_rdlisten_avg-aIC_tap_avg,'Effect' ,'cohen')

% overall mIC activity of Sound vs. Tap localizer 
mIC_rdlisten_avg = squeeze(mean(mean(mIC_rdlisten.ersp(:,FOI(1):FOI(end),TOI(2,1):TOI(2,2)),2),3));
mIC_tap_avg = squeeze(mean(mean(mIC_tap.ersp(:,FOI(1):FOI(end),TOI(2,1):TOI(2,2)),2),3));
[h,p,ci,stats] = ttest(mIC_rdlisten_avg-mIC_tap_avg)
meanEffectSize(mIC_rdlisten_avg-mIC_tap_avg,'Effect' ,'cohen')

% pairwise comparison aIC activity of Sound vs. Tap localizer in stable group
% ERD stable
aIC_rdlisten_s_avg = squeeze(mean(mean(aIC_rdlisten.ersp(stable_tapper,FOI(1):FOI(end),TOI(1,1):TOI(1,2)),2),3));
aIC_tap_s_avg = squeeze(mean(mean(aIC_tap.ersp(stable_tapper,FOI(1):FOI(end),TOI(1,1):TOI(1,2)),2),3));
[h,p,ci,stats] = ttest(aIC_rdlisten_s_avg-aIC_tap_s_avg)
meanEffectSize(aIC_rdlisten_s_avg-aIC_tap_s_avg,'Effect' ,'cohen')

% ERS stable
aIC_rdlisten_s_avg = squeeze(mean(mean(aIC_rdlisten.ersp(stable_tapper,FOI(1):FOI(end),TOI(2,1):TOI(2,2)),2),3));
aIC_tap_s_avg = squeeze(mean(mean(aIC_tap.ersp(stable_tapper,FOI(1):FOI(end),TOI(2,1):TOI(2,2)),2),3));
[h,p,ci,stats] = ttest(aIC_rdlisten_s_avg-aIC_tap_s_avg)
meanEffectSize(aIC_rdlisten_s_avg-aIC_tap_s_avg,'Effect' ,'cohen')

% ERD unstable
aIC_rdlisten_us_avg = squeeze(mean(mean(aIC_rdlisten.ersp(unstable_tapper,FOI(1):FOI(end),TOI(1,1):TOI(1,2)),2),3));
aIC_tap_us_avg = squeeze(mean(mean(aIC_tap.ersp(unstable_tapper,FOI(1):FOI(end),TOI(1,1):TOI(1,2)),2),3));
[h,p,ci,stats] = ttest(aIC_rdlisten_us_avg-aIC_tap_us_avg)

% ERS unstable
aIC_rdlisten_us_avg = squeeze(mean(mean(aIC_rdlisten.ersp(unstable_tapper,FOI(1):FOI(end),TOI(2,1):TOI(2,2)),2),3));
aC_tap_us_avg = squeeze(mean(mean(aIC_tap.ersp(unstable_tapper,FOI(1):FOI(end),TOI(2,1):TOI(2,2)),2),3));
[h,p,ci,stats] = ttest(aIC_rdlisten_us_avg-aIC_tap_us_avg)

% pairwise comparison mIC activity of Sound vs. Tap localizer in stable group
% ERD stable
mIC_rdlisten_s_avg = squeeze(mean(mean(mIC_rdlisten.ersp(stable_tapper,FOI(1):FOI(end),TOI(1,1):TOI(1,2)),2),3));
mIC_tap_s_avg = squeeze(mean(mean(mIC_tap.ersp(stable_tapper,FOI(1):FOI(end),TOI(1,1):TOI(1,2)),2),3));
[h,p,ci,stats] = ttest(mIC_rdlisten_s_avg-mIC_tap_s_avg)
meanEffectSize(mIC_rdlisten_s_avg-mIC_tap_s_avg,'Effect' ,'cohen')

% ERS stable
mIC_rdlisten_s_avg = squeeze(mean(mean(mIC_rdlisten.ersp(stable_tapper,FOI(1):FOI(end),TOI(2,1):TOI(2,2)),2),3));
mIC_tap_s_avg = squeeze(mean(mean(mIC_tap.ersp(stable_tapper,FOI(1):FOI(end),TOI(2,1):TOI(2,2)),2),3));
[h,p,ci,stats] = ttest(mIC_rdlisten_s_avg-mIC_tap_s_avg)
meanEffectSize(mIC_rdlisten_s_avg-mIC_tap_s_avg,'Effect' ,'cohen')

% ERD unstable
mIC_rdlisten_us_avg = squeeze(mean(mean(mIC_rdlisten.ersp(unstable_tapper,FOI(1):FOI(end),TOI(1,1):TOI(1,2)),2),3));
mIC_tap_us_avg = squeeze(mean(mean(mIC_tap.ersp(unstable_tapper,FOI(1):FOI(end),TOI(1,1):TOI(1,2)),2),3));
[h,p,ci,stats] = ttest(mIC_rdlisten_us_avg-mIC_tap_us_avg)

% ERS unstable
mIC_rdlisten_us_avg = squeeze(mean(mean(mIC_rdlisten.ersp(unstable_tapper,FOI(1):FOI(end),TOI(2,1):TOI(2,2)),2),3));
mIC_tap_us_avg = squeeze(mean(mean(mIC_tap.ersp(unstable_tapper,FOI(1):FOI(end),TOI(2,1):TOI(2,2)),2),3));
[h,p,ci,stats] = ttest(mIC_rdlisten_us_avg-mIC_tap_us_avg)

%% write them into data form then save to excel ersp_all.csv
SMT_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SMT/';
load(strcat(SMT_path,'ITI_stds.mat'));
cd('/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/ersp');
files = dir('**/*.mat');
names = {files.name};

stable_tapper = find(stds < median(stds));
unstable_tapper = find(stds > median(stds));

for nfile = 1:length(names)
    name  = names{nfile};
    data = load(name);
    
    FOI = [find(data.freqs == 13) find(data.freqs == 25,1)];
    TOI = [72 174;226 327]; % [-100 100] ERD [200 400] ERS
    for nt = 1:2
        parts_name = cellstr(split(name ,{'_','.'}));
        ersp(nfile,nt,:) = squeeze(mean(mean(data.ersp(:,FOI(1):FOI(end),TOI(nt,1):TOI(nt,2)),2),3));
        condition(nfile,nt) = string(strcat(parts_name{1},'.',parts_name{5},'.T',num2str(nt)));
    end
end
ersp_all = reshape(ersp,16,25)';
conditon = condition';

%% Regression 
load(strcat(sync_path,'linear_reg_mIC_sync3t_ersp.mat'))
regressor = 2;

for nt = 1:size(lm,1)
    for nf = 1:size(lm,2)
    beta(nt,nf) = estimate{nt,nf}(regressor);
    end
end

%% Pool regression of the pre-defined ROIs *** for the post-beta aIC sync3t, m* pre-beta mIC sync3s
clc
% load(strcat(rdlisten_path,'aIC_averagebaslined_ersp_itc_rdlisten2.mat'));
load(strcat(sync_path,'mIC_averagebaslined_ersp_itc_sync3s.mat'));
load(strcat(SMT_path,'ITI_stds.mat'));

FOI = [find(freqs == 13) find(freqs == 25,1)];
TOI = [72 174;226 327]; % [-100 100] ERD [200 400] ERS

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
    FOI = [find(freq == 13) find(freq == 25)];
    
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
FOI = [find(freqs == 13) find(freqs == 25,1)];
TOI = [72 174;226 327]; % [-100 100] ERD [200 400] ERS

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