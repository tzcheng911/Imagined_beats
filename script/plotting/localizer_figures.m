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

mIC_erp = load(strcat(SMT_path,'mIC_erp_rdlisten2_lp60Hz.mat'));
aIC_erp = load(strcat(ERP_path,'aIC_erp_tap1_lp60Hz.mat'));
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
load(strcat(SMT_path,'ITI_stds.mat'));

stable_tapper = find(stds < median(stds));
unstable_tapper = find(stds > median(stds));

% load(strcat(rdlisten_path,'aIC_averagebaslined_ersp_itc_rdlisten2'));
 load(strcat(rdlisten_path,'mIC_averagebaslined_ersp_itc_rdlisten2'));
% load(strcat(SMT_path,'aIC_averagebaslined_ersp_itc_tap1'));
% load(strcat(SMT_path,'mIC_averagebaslined_ersp_itc_tap1'));
% load(strcat(sync_path,'aIC_averagebaslined_ersp_itc_sync3s'));
% load(strcat(sync_path,'mIC_averagebaslined_ersp_itc_sync3s'));
% load(strcat(sync_path,'aIC_averagebaslined_ersp_itc_sync3t'));
% load(strcat(sync_path,'mIC_averagebaslined_ersp_itc_sync3t'));

figure;imagesc(times,freqs,squeeze(mean(average_ERSP_mIC,1)));axis xy; colormap(jet);caxis([0.9 1.1]);  colorbar
% figure;imagesc(times,freqs,squeeze(mean(ersp(stable_tapper,:,:),1))); axis xy; colormap(jet);caxis([0.9 1.1]);  colorbar
% figure;imagesc(times,freqs,squeeze(mean(ersp(unstable_tapper,:,:),1))); axis xy; colormap(jet); caxis([0.9 1.1]); colorbar

%% Figure 6 ERSP bar plot
load('/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/ersp/ersps.mat')
load(strcat(SMT_path,'ITI_stds.mat'));

stable_tapper = find(stds < median(stds));
unstable_tapper = find(stds > median(stds));

% sort the order to match the paper figure
condition = condition([4,1,3,2,8,5,7,6,12,9,11,10,16,13,15,14]);
ersp_all = ersp_all(:,[4,1,3,2,8,5,7,6,12,9,11,10,16,13,15,14]);

% convert to % signal change
ersp_all = ersp_all-1;

n = length(stable_tapper);

stable_tapper_mean = mean(ersp_all(stable_tapper,:),1);
unstable_tapper_mean = mean(ersp_all(unstable_tapper,:),1);

stable_tapper_stderr = std(ersp_all(stable_tapper,:),1)/sqrt(n);
unstable_tapper_stderr = std(ersp_all(unstable_tapper,:),1)/sqrt(n);

bar_plot_mean = [];
bar_plot_stderr = [];

for i = 1:length(condition)
    bar_plot_mean = [bar_plot_mean;stable_tapper_mean(i),unstable_tapper_mean(i)];
    bar_plot_stderr = [bar_plot_stderr;stable_tapper_stderr(i),unstable_tapper_stderr(i)];
end 

% select the range to plot
result = [1:4;5:8;9:12;13:16];
nresult = 4; % change from 1 to 4
y_mean = bar_plot_mean(result(nresult,:),:); 
y_stderr = bar_plot_stderr(result(nresult,:),:);

% Find the number of groups and the number of bars in each group
[ngroups, nbars] = size(y_mean);

% Calculate the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));

figure;
bar(y_mean,'grouped'); 
hold on;

for i = 1:nbars
    % Calculate center of each bar
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, y_mean(:,i), y_stderr(:,i), 'k', 'linestyle', 'none');
end
hold off

xlabel('Tasks','FontSize', 18)
ylabel('Signal change (%)','FontSize', 18)
xticklabels({'Tap','Sound','SMS_{Tap}','SMS_{Sound}'})
% ylim([0.8 1.15])
legend('Stable','Unstable')

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
