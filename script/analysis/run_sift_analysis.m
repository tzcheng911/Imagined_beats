%% load data remember to load it with the subj order, otherwise the IC order will be wrong
% ALLEEG  duple*BL duple*IM duple*SBL triple*BL triple*IM triple*SBL
% s01     1        2        3         4         5         6
% s02     7        8        9         10        11        12 
% s03     13       14       15        16        17        18
% s04     19       20       21        22        23        24
% s05     25       26       27        28        29        30
% s06     31       32       33        34        35        36

clear
close all
clc

eeglab
targetFolder = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/results/Main_task/sift/AM3';
% targetFolder = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/sifts/SIFT_output/2020/rdlisten_localizer';

allSetFiles = dir([targetFolder filesep '*sift.set']); 
 
% Start the loop.
for setIdx = 1:length(allSetFiles)
 
    % Obtain the file names for loading.
    loadName = allSetFiles(setIdx).name;
    parts_loadName = cellstr(split(loadName,'_'));
 
    % Load data. Note that 'loadmode', 'info' is to avoid loading .fdt file to save time and RAM.
    EEG = pop_loadset('filename', loadName, 'filepath', targetFolder, 'loadmode', 'info');
 
    % Store the current EEG to ALLEEG.
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
end
eeglab redraw
c = 1;
for i = 1:20
    
figure(i); pop_topoplot(ALLEEG(c), 0, [1 2] ,'',[1 2] ,0,'electrodes','off'); % find out the auditory and motor ICs
c = c+8;
end 

%%
subj = 20; % should exclude s08

% cond = {'DupleBL', 'DupleIB', 'DuplePB','TripleBL', 'TripleIB', 'TriplePB'};
cond = {'DupleBL', 'DupleIB', 'DuplePB','DupleTap','TripleBL', 'TripleIB', 'TriplePB','TripleTap'};
% cond = {'TripleSBL', 'TripleBL','DupleSBL', 'DupleBL'};

% for new AM ICs for N = 20
aIC = [1;1;1;1;1;2;1;1;1;1;1;1;1;1;1;1;1;2;1;1];
mIC = [2;2;2;2;2;1;2;2;2;2;2;2;2;2;2;2;2;1;2;2];

time = ALLEEG(1).CAT.Conn.erWinCenterTimes;
IOI = [0,1,2,3,4,5,6,7,8,9,10,11]*1/2.4;
for nIOI = 1:length(IOI)
    [d,ix] = min(abs(IOI(nIOI)-time));
    time_idx(nIOI) = ix;
end

freq = EEG.CAT.Conn.freqs;

%% Extract motor and auditory ICs
% EEG.CAT.Conn.dDTF08(to IC, from IC, freq, time)
maflow = zeros(subj,length(cond),length(ALLEEG(1).CAT.Conn.freqs),length(ALLEEG(1).CAT.Conn.winCenterTimes)); 
amflow = zeros(subj,length(cond),length(ALLEEG(1).CAT.Conn.freqs),length(ALLEEG(1).CAT.Conn.winCenterTimes)); 
count = 0;
for nsubj = 1:subj
    for ncond = 1:length(cond)
        maflow (nsubj,ncond,:,:) = squeeze(ALLEEG(ncond+count).CAT.Conn.dDTF08(aIC(nsubj),mIC(nsubj),:,:));
        amflow (nsubj,ncond,:,:) = squeeze(ALLEEG(ncond+count).CAT.Conn.dDTF08(mIC(nsubj),aIC(nsubj),:,:));
    end
 count = count + 8;
end

%% localizer
for nsubj = 1:subj
    amflow(nsubj,:,:) = squeeze(ALLEEG(nsubj).CAT.Conn.dDTF08(mIC(nsubj), aIC(nsubj),:,:));
    maflow(nsubj,:,:) = squeeze(ALLEEG(nsubj).CAT.Conn.dDTF08(aIC(nsubj), mIC(nsubj),:,:));
end

%% ploting for localizer task
figure;
imagesc(time,freq,squeeze(mean(amflow,1)));axis xy; colormap(jet); 

figure;
imagesc(time,freq,squeeze(mean(maflow,1)));axis xy; colormap(jet); 

%high_var = [2 5	10 11 12 16 17 18 19 21 22 23];
%low_var = [1 3 4 6 7 8 9 13 14 15 20 24 25];

high_var = [2 5	10 12 16 17 18 19 21 22 23];
low_var = [1 4 6 7 8 9 13 14 15 20 24 25];



%% ploting for main task
%% amplow and maflow for pooled meter plus random listen condition
% amflow
figure;
imagesc(time,freq,squeeze(mean(mean(amflow(:,[1,5],:,:),1),2)));axis xy; colormap(jet); caxis([0 0.03]) % am BL
figure;
imagesc(time,freq,squeeze(mean(mean(amflow(:,[3,7],:,:),1),2)));axis xy; colormap(jet); caxis([0 0.03]) % am PB
figure;
imagesc(time,freq,squeeze(mean(mean(amflow(:,[2,6],:,:),1),2)));axis xy; colormap(jet); caxis([0 0.03]) % am IB
figure;
imagesc(time,freq,squeeze(mean(mean(amflow(:,[4,8],:,:),1),2)));axis xy; colormap(jet); caxis([0 0.03]) % am TAP
figure;
imagesc(time,freq,squeeze(mean(rd_am(:,:,:),1)));axis xy; colormap(jet); caxis([0 0.03]) % am rdlisten

% maflow
figure;
imagesc(time,freq,squeeze(mean(mean(maflow(:,[1,5],:,:),1),2)));axis xy; colormap(jet); caxis([0 0.03]) % ma BL
figure;
imagesc(time,freq,squeeze(mean(mean(maflow(:,[3,7],:,:),1),2)));axis xy; colormap(jet); caxis([0 0.03]) % ma PB
figure;
imagesc(time,freq,squeeze(mean(mean(maflow(:,[2,6],:,:),1),2)));axis xy; colormap(jet); caxis([0 0.03]) % ma IB
figure;
imagesc(time,freq,squeeze(mean(mean(maflow(:,[4,8],:,:),1),2)));axis xy; colormap(jet); caxis([0 0.03]) % ma TAP
figure;
imagesc(time,freq,squeeze(mean(rd_ma(:,:,:),1)));axis xy; colormap(jet); caxis([0 0.03]) % ma rdlisten


%% amflow and maflow
close all

% am flow
figure;subplot(2,4,1)
imagesc(time,freq,squeeze(mean(amflow(:,1,:,:),1)));axis xy; colormap(jet);title('duple-BL'); caxis([0 3e-3])
subplot(2,4,2)
imagesc(time,freq,squeeze(mean(amflow(:,3,:,:),1)));axis xy; colormap(jet);title('duple-PB'); caxis([0 3e-3])
subplot(2,4,3)
imagesc(time,freq,squeeze(mean(amflow(:,2,:,:),1)));axis xy; colormap(jet);title('duple-IB'); caxis([0 3e-3])
subplot(2,4,4)
imagesc(time,freq,squeeze(mean(amflow(:,4,:,:),1)));axis xy; colormap(jet);title('duple-tap'); caxis([0 3e-3])
subplot(2,4,5)
imagesc(time,freq,squeeze(mean(amflow(:,5,:,:),1)));axis xy; colormap(jet);title('triple-BL'); caxis([0 3e-3])
subplot(2,4,6)
imagesc(time,freq,squeeze(mean(amflow(:,7,:,:),1)));axis xy; colormap(jet);title('triple-PB'); caxis([0 3e-3])
subplot(2,4,7)
imagesc(time,freq,squeeze(mean(amflow(:,6,:,:),1)));axis xy; colormap(jet);title('triple-IB'); caxis([0 3e-3])
subplot(2,4,8)
imagesc(time,freq,squeeze(mean(amflow(:,8,:,:),1)));axis xy; colormap(jet);title('triple-tap'); caxis([0 3e-3])

% maflow
figure;subplot(2,4,1)
imagesc(time,freq,squeeze(mean(maflow(:,1,:,:),1)));axis xy; colormap(jet);title('duple-BL'); caxis([0 3e-3])
subplot(2,4,2)
imagesc(time,freq,squeeze(mean(maflow(:,3,:,:),1)));axis xy; colormap(jet);title('duple-PB'); caxis([0 3e-3])
subplot(2,4,3)
imagesc(time,freq,squeeze(mean(maflow(:,2,:,:),1)));axis xy; colormap(jet);title('duple-IB'); caxis([0 3e-3])
subplot(2,4,4)
imagesc(time,freq,squeeze(mean(maflow(:,4,:,:),1)));axis xy; colormap(jet);title('duple-tap'); caxis([0 3e-3])
subplot(2,4,5)
imagesc(time,freq,squeeze(mean(maflow(:,5,:,:),1)));axis xy; colormap(jet);title('triple-BL'); caxis([0 3e-3])
subplot(2,4,6)
imagesc(time,freq,squeeze(mean(maflow(:,7,:,:),1)));axis xy; colormap(jet);title('triple-PB'); caxis([0 3e-3])
subplot(2,4,7)
imagesc(time,freq,squeeze(mean(maflow(:,6,:,:),1)));axis xy; colormap(jet);title('triple-IB'); caxis([0 3e-3])
subplot(2,4,8)
imagesc(time,freq,squeeze(mean(maflow(:,8,:,:),1)));axis xy; colormap(jet);title('triple-tap'); caxis([0 3e-3])

%% amflow and maflow for each subject
close all

% am flow
for n  = 1:size(amflow,1)
figure;subplot(2,4,1)
imagesc(squeeze(amflow(n,1,:,:)));axis xy; colormap(jet);title('duple-BL'); caxis([0 0.03])
subplot(2,4,2)
imagesc(squeeze(amflow(n,3,:,:)));axis xy; colormap(jet);title('duple-PB'); caxis([0 0.03])
subplot(2,4,3)
imagesc(squeeze(amflow(n,2,:,:)));axis xy; colormap(jet);title('duple-IB'); caxis([0 0.03])
subplot(2,4,4)
imagesc(squeeze(amflow(n,4,:,:)));axis xy; colormap(jet);title('duple-tap'); caxis([0 0.03])
subplot(2,4,5)
imagesc(squeeze(amflow(n,5,:,:)));axis xy; colormap(jet);title('triple-BL'); caxis([0 0.03])
subplot(2,4,6)
imagesc(squeeze(amflow(n,7,:,:)));axis xy; colormap(jet);title('triple-PB'); caxis([0 0.03])
subplot(2,4,7)
imagesc(squeeze(amflow(n,6,:,:)));axis xy; colormap(jet);title('triple-IB'); caxis([0 0.03])
subplot(2,4,8)
imagesc(squeeze(amflow(n,8,:,:)));axis xy; colormap(jet);title('triple-tap'); caxis([0 0.03])

% maflow
figure;subplot(2,4,1)
imagesc(squeeze(maflow(n,1,:,:)));axis xy; colormap(jet);title('duple-BL'); caxis([0 0.03])
subplot(2,4,2)
imagesc(squeeze(maflow(n,3,:,:)));axis xy; colormap(jet);title('duple-PB'); caxis([0 0.03])
subplot(2,4,3)
imagesc(squeeze(maflow(n,2,:,:)));axis xy; colormap(jet);title('duple-IB'); caxis([0 0.03])
subplot(2,4,4)
imagesc(squeeze(maflow(n,4,:,:)));axis xy; colormap(jet);title('duple-tap'); caxis([0 0.03])
subplot(2,4,5)
imagesc(squeeze(maflow(n,5,:,:)));axis xy; colormap(jet);title('triple-BL'); caxis([0 0.03])
subplot(2,4,6)
imagesc(squeeze(maflow(n,7,:,:)));axis xy; colormap(jet);title('triple-PB'); caxis([0 0.03])
subplot(2,4,7)
imagesc(squeeze(maflow(n,6,:,:)));axis xy; colormap(jet);title('triple-IB'); caxis([0 0.03])
subplot(2,4,8)
imagesc(squeeze(maflow(n,8,:,:)));axis xy; colormap(jet);title('triple-tap'); caxis([0 0.03])
end
%% average across frequency
FOIs = find(freq == 4);
FOIe = find(freq == 8);
FOI = [FOIs:FOIe]; % beat freq 2:3, theta 4:8, alpha 8:12, beta 12:30 

% IMB
mean_amflow = squeeze(mean(mean(amflow(:,:,FOI,:),4),3));
mean_maflow = squeeze(mean(mean(maflow(:,:,FOI,:),4),3));
mean_amflow = mean_amflow(:,[1,3,2,4,5,7,6,8]);
mean_maflow = mean_maflow(:,[1,3,2,4,5,7,6,8]);

% Localizer
% mean_amflow = squeeze(mean(mean(amflow(:,FOI,:),2),3));
% mean_maflow = squeeze(mean(mean(maflow(:,FOI,:),2),3));
