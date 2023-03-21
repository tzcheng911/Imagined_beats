eeglab
clear
clc

%%
% File path 
SMT_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SMT/';
sync_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/sync/';

addpath(genpath('/Volumes/TOSHIBA/Research/Imagined_beats/script'))
load(strcat(SMT_path,'ITI_stds.mat'));
load(strcat(sync_path,'relative_phase.mat'));

EEG_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/sync'; % /Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/preprocessed/epoch/SB_WB
cd(EEG_path)
files = dir(fullfile(EEG_path,'*sync3s_e.set')); % triple_SB_e.set
names = {files.name};

% Parameters
% am selection 4b
new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	6	4	1	1	5	8	4];
new_amIC(2,:) = [8	1	11	11	10	11	8	4	13	4	15	7	18	8	16	21	12	36	4	17	6	9	14	21	8];

FOI = [13 25];

%% erpimage
IC = 2; % auditory or motor IC

sorted_by = stds; % stds or cv of the Tap Localizer or si (mean relphase) of the SMS, or trial number included
[~, sort_ind] = sort(sorted_by); 

figure;
jisubplot(3,4,0)

for nsub = 1:length(names)
    tempEEG = names{sort_ind(nsub)};
    parts_cleanEEG = cellstr(split(tempEEG,'.'));
    EEG = pop_loadset('filename',tempEEG ,'filepath', EEG_path); % epoched data
    nextplot
    [outdata,outvar,outtrials,limits,axhndls, ...
                         erp,amps,cohers,cohsig,ampsig,outamps,...
                         phsangls,phsamp,sortidx,erpsig] ...
                             = erpimage(squeeze(EEG.icaact(new_amIC(IC,sort_ind(nsub)),:,:)),eeg_getepochevent(EEG, {'Tap'},[],'latency'),...
                             linspace(EEG.xmin*1000, EEG.xmax*1000, EEG.pnts),strcat("iS=",num2str(sort_ind(nsub)),"ITI=",num2str(sorted_by(sort_ind(nsub)))), 40, 1,...
                             'cbar','on','caxis',[-4 4],'plotamps','on','coher',[13 25 0.05],'topo',...
                             { mean(EEG.icawinv(:,[new_amIC(IC,sort_ind(nsub))]),2) EEG.chanlocs EEG.chaninfo});
% figure; pop_erpimage(EEG,0, [21],[[]],'Comp. 21',40,1,{ 'Tap'},[],'latency' ,'yerplabel','','erp','on','cbar','on','plotamps','on','coher',[13 25 0.05] ,'topo', { mean(EEG.icawinv(:,[21]),2) EEG.chanlocs EEG.chaninfo } );
end

%% relationship between async and beta power 
sorted_by = stds; % stds or cv of the Tap Localizer or si (mean relphase) of the SMS, or trial number included
[~, sort_ind] = sort(sorted_by); 
IC = 2; % auditory or motor IC
intercept = zeros(25,410);

for nsub = 1:length(names)
    tempEEG = names{sort_ind(nsub)};
    parts_cleanEEG = cellstr(split(tempEEG,'.'));
    EEG = pop_loadset('filename',tempEEG ,'filepath', EEG_path); % epoched data
    nextplot
    [outdata,outvar,outtrials,limits,axhndls, ...
                         erp,amps,cohers,cohsig,ampsig,outamps,...
                         phsangls,phsamp,sortidx,erpsig] ...
                             = erpimage(squeeze(EEG.icaact(new_amIC(IC,sort_ind(nsub)),:,:)),eeg_getepochevent(EEG, {'Tap'},[],'latency'),...
                             linspace(EEG.xmin*1000, EEG.xmax*1000, EEG.pnts),strcat("iS=",num2str(sort_ind(nsub)),"ITI=",num2str(sorted_by(sort_ind(nsub)))), 40, 1,...
                             'cbar','on','caxis',[-4 4],'plotamps','on','coher',[13 25 0.05],'topo',...
                             { mean(EEG.icawinv(:,[new_amIC(IC,sort_ind(nsub))]),2) EEG.chanlocs EEG.chaninfo});

    for t = 1:size(outdata,1)
        [P,S] = polyfit(outvar,outdata(t,:),1); % put async as x and beta power as y is more interpretable with erspimage 
        slope(sort_ind(nsub),t) = P(1); % get the intercept P(1) or intercept P(2) of the linear fit % original order
        clear P
    end
    clear outdata outvar
end        
% save('/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/sync/aB_intercept.mat','intercept')

%% ploting 
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
set(gca,'FontSize',18)
% title('slope of good tappers vs. bad tappers')

% t statistics
[H,P,CI,STATS] = ttest2(slope(sort_ind(1:12),:),slope(sort_ind(14:25),:));
% figure;plot(times,P,'LineWidth',2);gridy(0.05,'k:');title('p-value of slope in good vs. bad tappers');xlim([-300 500])
% [H,P,CI,STATS] = ttest(intercept(sort_ind(1:12),:),intercept(sort_ind(14:25),:));
% figure;plot(times,P,'LineWidth',2);gridy(0.05,'k:');title('p-value of intercept in good vs. bad tappers');xlim([-300 500])
sig_ind = find(P<0.05);
hold on; gridx(times(sig_ind),'y:')

%% downsample/sliding window
count = 0;
for i = 1:10:410
ds_slope(:,count+1) = mean(slope(:,i:i+9),2);
count = count +1;
end

%% slope and the behavioral measures 
figure;plot(stds(sort_ind(1:12)),slope_neg100(sort_ind(1:12)),'r.')
hold on;plot(stds(sort_ind(14:25)),slope_neg100(sort_ind(14:25)),'b.')
legend('Good tappers','Bad tappers')
xlabel('SD(ITI) during free tapping')
ylabel('Slope between beta power and async')

figure;plot(cse(sort_ind(1:12)),slope_neg100(sort_ind(1:12)),'r.')
hold on;plot(cse(sort_ind(14:25)),slope_neg100(sort_ind(14:25)),'b.')
legend('Good tappers','Bad tappers')
xlabel('SD(relphase) during SMS')
ylabel('Slope between beta power and async')

figure;plot(theta(sort_ind(1:12)),slope_neg100(sort_ind(1:12)),'r.')
hold on;plot(theta(sort_ind(14:25)),slope_neg100(sort_ind(14:25)),'b.')
legend('Good tappers','Bad tappers')
xlabel('Mean(relphase) during SMS')
ylabel('Slope between beta power and async')