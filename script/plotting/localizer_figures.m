SMT_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SMT/';
sync_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/sync/';
rdlisten_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/rdlisten/';
SIFT_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SIFTs/';
addpath(genpath('/Volumes/TOSHIBA/Research/Imagined_beats/script'))

%% Figure 1: task diagram

%% Figure 2: std of the Tap localizer 
load(strcat(SMT_path,'ITI_stds.mat'));
figure;bar(sort(stds,'descend'));gridy(median(stds),'k:');xlabel('Subjects');ylabel('Time (ms)');set(gca,'FontSize',18)

%% Figure 3: relative phase of the stable and unstable tappers
stable_tapper = find(stds < median(stds)); % use std of ITI
unstable_tapper = find(stds > median(stds)); % use std of ITI

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
legend({'Unstable tappers','Stable tappers'})
xlabel('Relative phases')
ylabel('Frequency')
set(gca,'FontSize',18)

%% Figure 4 topo and ERP of the overall effect and stable vs. unstable tappers 

% topo has been output from the study
% ERP
ERP_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/rdlisten/';
SMT_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SMT/';

mIC_erp = load(strcat(SMT_path,'mIC_erp_SMT_lp60Hz.mat'));
aIC_erp = load(strcat(ERP_path,'aIC_erp_rdlisten2_lp60Hz.mat'));
mIC_erp.erps = -1* mIC_erp.erps; % reverse polarity for the motor IC ERP

load(strcat(SMT_path,'ITI_stds.mat'));
load(strcat(SMT_path,'ITI_means.mat'));
stable_tapper = find(stds < median(stds)); % use std of ITI
unstable_tapper = find(stds > median(stds)); % use std of ITI

figure;plot(aIC_erp.times,aIC_erp.erps);

figure;plotShadedError(aIC_erp.times,mean(aIC_erp.erps,1),std(aIC_erp.erps,[],1)./sqrt(25));xlim([-100 300])
set(gcf,'renderer','painters') % make the shaded part "Ai"able
gridx([0],'k:')
gridy([0],'k:')
% axis ij % for the motor IC
% expmulti(1, 'pdf', 'mIC_ERP', 600)

figure;plotShadedError(aIC_erp.times,mean(aIC_erp.erps(stable_tapper,:),1),std(aIC_erp.erps(stable_tapper,:),[],1)./sqrt(12),'b');xlim([-100 300])
set(gcf,'renderer','painters') % make the shaded part "Ai"able
hold on;plotShadedError(aIC_erp.times,mean(aIC_erp.erps(unstable_tapper,:),1),std(aIC_erp.erps(unstable_tapper,:),[],1)./sqrt(12),'r');xlim([-100 300])
set(gcf,'renderer','painters') % make the shaded part "Ai"able
gridx([0],'k:')
gridy([0],'k:')
% expmulti(1, 'pdf', 'mIC_ERP', 600)

figure;plotShadedError(mIC_erp.times,mean(mIC_erp.erps(stable_tapper,:),1),std(mIC_erp.erps(stable_tapper,:),[],1)./sqrt(12),'b');xlim([-100 150]) 
set(gcf,'renderer','painters') % make the shaded part "Ai"able
hold on;plotShadedError(mIC_erp.times,mean(mIC_erp.erps(unstable_tapper,:),1),std(mIC_erp.erps(unstable_tapper,:),[],1)./sqrt(12),'r');xlim([-100 150])
set(gcf,'renderer','painters') % make the shaded part "Ai"able
gridx([0],'k:')
gridy([0],'k:')
% ylim([-0.4 0.8])
% expmulti(1, 'pdf', 'mIC_ERP', 600)

%% Figure 5 ERSP of the tap, sound and SMS in stable vs. unstable group
%% Figure 6 ERSP bar plot
%% Figure 7 ERSP regression
%% Figure 8 Directional auditory-motor coupling
%% Figure 9 slope

% cartoon diagram made from Zoe_erpimage.m
% a stable tapper iS = 15, an unstable tapper iS = 17
load('/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/sync/aB_lm.mat')

figure;
jisubplot(3,4,0)
for nsub = 1:length(names)
    nextplot
    plot(times,slope(sort_ind(nsub),:),'LineWidth',2);xlim([-300 500]); gridx(0,'K:');title(strcat("iS =",num2str(sort_ind(nsub))))
end

startColor = 3*[0.25, 0.25, 0.25];
figure;
for nsub = 1:length(names)
    plot(times,slope(sort_ind(nsub),:), 'Color', startColor - (nsub-1) / 48,'LineWidth',2);xlim([-300 500]); gridx(0,'K:');
    hold on 
end

figure;
[l, s] = plotShadedError(times,mean(slope(sort_ind(1:12),:),1),std(slope(sort_ind(1:12),:),[],1)./sqrt(12));xlim([-300 500]);
gridy(0,'k:');gridx(0,'k:')
s.FaceAlpha =0.15

hold on;
[l, s] = plotShadedError(times,mean(slope(sort_ind(14:25),:),1),std(slope(sort_ind(14:25),:),[],1)./sqrt(12),'r');xlim([-300 500]);
gridy(0,'k:');gridx(0,'k:')
s.FaceAlpha =0.15
xlim([-300 450])
xlabel('Time (ms)')
ylabel('Beta (ms/uV)')
set(gca,'FontSize',18)
% title('slope of good tappers vs. bad tappers')

% t statistics
[H,P,CI,STATS] = ttest2(slope(sort_ind(1:12),:),slope(sort_ind(14:25),:));
% figure;plot(times,P,'LineWidth',2);gridy(0.05,'k:');title('p-value of slope in good vs. bad tappers');xlim([-300 500])
% [H,P,CI,STATS] = ttest(intercept(sort_ind(1:12),:),intercept(sort_ind(14:25),:));
% figure;plot(times,P,'LineWidth',2);gridy(0.05,'k:');title('p-value of intercept in good vs. bad tappers');xlim([-300 500])
sig_ind = find(P<0.05);
hold on; gridx(times(sig_ind),'y:')
set(gcf,'renderer','painters') % make the shaded part "Ai"able
