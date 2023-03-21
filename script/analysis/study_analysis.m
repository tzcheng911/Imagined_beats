%% Create a study for IMB main - Makoto methods
% Obtain all .set files which are pruned by ICA (only motor and auditory ICs)
% , store them in ALLEEG then use GUI to create a Study
clear 
close all
clc
eeglab
%addpath('/share/apps/MATLAB/R2020a/toolbox/matlab/strfun/')

targetFolder = '/data/projects/zoe/ImaginedBeats/real_exp/preprocessed/icap/localizer/AM4b/sync/sound';
allSetFiles = dir([targetFolder filesep '*.set']); % filesep inserts / or \ depending on your OS.
 
% Start the loop.
for setIdx = 1:length(allSetFiles)
 
    % Obtain the file names for loading.
    loadName = allSetFiles(setIdx).name; % subj123_group2.set
    parts_loadName = cellstr(split(loadName,'_'));
 
    % Load data. Note that 'loadmode', 'info' is to avoid loading .fdt file to save time and RAM.
    EEG = pop_loadset('filename', loadName, 'filepath', targetFolder, 'loadmode', 'info');
 
    % Enter EEG.subjuct.
    EEG.subject = parts_loadName{1}; 
 
    % Enter EEG.group.
    EEG.condition = strjoin({parts_loadName{7},'_',parts_loadName{8}}); 
 
    % Store the current EEG to ALLEEG.
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
end
eeglab redraw

%% Preprocessing study files 
[STUDY ALLEEG] = std_precomp(STUDY, ALLEEG, 'components',...
    'erp','on','erpparams',{'rmbase' [-100 -50] },...
    'scalp','on',...
    'spec','on','specparams',{'freqrange' [3 50] 'specmode' 'fft' 'logtrials' 'off'},...
    'ersp','on','erspparams',{'cycles' [3 0.8] 'nfreqs' 100 'ntimesout' 200},...
    'itc','on');
[STUDY ALLEEG] = std_preclust(STUDY, ALLEEG, [],...
        {'dipoles', 'weight', 1},...
        {'scalp', 'weight' 1, 'npca', 10, 'abso', 1});
[STUDY] = pop_clust(STUDY, ALLEEG, 'algorithm','kmeanscluster', 'clus_num', 2);
eeglab redraw

%% Load the precomputed and preclustered study file
[STUDY ALLEEG] = pop_loadstudy('filepath', '/data/projects/zoe/ImaginedBeats/real_exp/preprocessed/icap/localizer/AM4b/spontap/',...
    'filename','spontap_AM4b.study');

%% Plot the measures 
% Get screen size for compatibility
screen = get(0, 'ScreenSize');
cluster = 3; % 1: parent cluster 2: cluster2 3: cluster 3

% Plot scalp maps
std_topoplot(STUDY,ALLEEG, 'clusters', cluster, 'mode', 'apart', 'figure', 'off');
pos1 = [(screen(3)*0)/20 ((screen(4)*12)/20) ((screen(3)*2)/6) ((screen(4)*2.6)/6)];
set(gcf, 'Position', pos1);

% Plot dipoles
std_dipplot(STUDY,ALLEEG, 'clusters', cluster, 'figure', 'on', 'projlines', 'on');
pos2 = [((screen(3)*0)/20) ((screen(4)*0)) ((screen(3)*2)/6) ((screen(4)*2.8)/6)];
set(gcf,'Position',pos2);

% Plot ERP
[STUDY erpdata erptimes] = std_erpplot(STUDY,ALLEEG, 'clusters', cluster, 'plotconditions', 'apart','filter', 10);%,'conditionplotorder', plotorder);
std_plotcurve(erptimes,erpdata,'plotconditions','together','plotstderr','on','figure','on','plotsubjects','off');
h = findall(gcf, 'type', 'axes');

pos3 = [((screen(3)*2.06)/6) ((screen(4)*3)/2) ((screen(3)*3.2)/6) ((screen(4)*1.9)/7)];
set(gcf,'Position',pos3);
set(gca,'fontsize',18)

% Plot spectra
std_specplot(STUDY,ALLEEG, 'clusters', cluster, 'plotconditions', 'together', 'plotmode', 'normal','freqrange',[3 50]);
pos4 = [((screen(3)*1.9)/2) (screen(4)) (screen(3)/9) ((screen(4)*2)/7)];
set(gcf,'Position',pos4);
set(gca,'fontsize',7)

% Plot ERSP
std_erspplot(STUDY,ALLEEG, 'clusters', cluster, 'plotconditions', 'together', 'plotmode', 'normal','freqrange',[3 50]);
h = findall(gcf, 'type', 'axes');
%Draw axes for conditions
for i = 1:length(h)
    axes(h(i));
    gridx(0, 'b--');
end;
pos6 = [((screen(3)*2.06)/6) ((screen(4)*2)/6) ((screen(3)*3.2)/6) ((screen(4)*1.9)/7)];
set(gcf,'Position',pos6);

y = [5 10 15 20 30 40 50];
h = findall(gcf,'type','axes');
for i = 1:size(h,1) - 1
    axes(h(i));
    set(gca,'YTick',log(y));
    set(gca,'YTickLabel',y);
end;

% Plot ITC
std_itcplot(STUDY,ALLEEG, 'clusters', cluster, 'plotconditions', 'together', 'plotmode', 'normal', 'freqrange', [3 50]);
h = findall(gcf, 'type', 'axes');
%Draw axes for conditions
for i = 1:length(h)
    axes(h(i));
    str = get(get(gca, 'title'), 'string');
	if(strcmp(str, 'ITC'))
		continue;
	end;
    gridx(0,'b--');
end;
pos7 = [((screen(3)*2.06)/6) ((screen(4)*0)) ((screen(3)*3.2)/6) ((screen(4)*1.9)/7)];
set(gcf,'Position',pos7);
if strcmpi(opt.menu, 'off')
    set(gcf,'MenuBar','none');
end;
h = findall(gcf,'type','axes');
for i = 1:size(h,1)-1
    axes(h(i));
    set(gca,'YTick',log(y));
    set(gca,'YTickLabel',y);
end;