% 01/18/2022 Makoto. Used again. Modified a bit.
% 01/10/2022 Makoto. Modified. abs() was removed. Maximum statistics for min and max are stored (because it is a t-test)
% 12/26/2021 Zoe added one sample test
% 06/15/2021 Zoe modified and used.
% 02/12/2021 Makoto. Used.
% 12/25/2020 Makoto. Created.

%% The whole idea is to see if the cluster is "big" enough, by using the max statistic
% for ERSP two sample ttest
clear

cd('/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SMT')
addpath(genpath('/Volumes/TOSHIBA/Research/Imagined_beats/script'))

datafile = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SIFTs/sift_all.mat'; % already averaged across time 
load(datafile)

load /Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SMT/ITI_stds.mat
load /Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SMT/ITI_means.mat

group = 2;

numIter         = 5000;
%numIter         = 5000; % Instead of giving up p<0.01, increase the number here (01/10/2022 Makoto)
timeWindowOfInt = 1:size(amflow,3);
freqWindowOfInt = [find(freq == 13):find(freq == 25)];
%trueBlobs       = zeros(4, length(freqWindowOfInt), length(timeWindowOfInt));
trueBlobs       = zeros(length(freqWindowOfInt), length(timeWindowOfInt)); % Only compute p< 0.05(01/10/2022 Makoto)
t_or_F          = zeros(length(freqWindowOfInt), length(timeWindowOfInt));
pVals           = zeros(length(freqWindowOfInt), length(timeWindowOfInt));

% for clusterIdx = 1:length(icClusters) % combine auditory and motor

% Obtain group Idx for different grouping ways

group1_Idx = find(stds < median(stds)); % stable tapper
group2_Idx = find(stds > median(stds)); % unstable tapper

% group1_Idx = [4     8    15     3]; % top 4 stable tapper
% group2_Idx = [22    12    10     2]; % top 4 unstable tapper

%    group1_Idx = find(means < median(means)); % fast tapper
%    group2_Idx = find(means > median(means)); % slow tapper

%   group1_Idx = find(abs(mean_relative_phase) < median(abs(mean_relative_phase))); % good syncher
%   group2_Idx = find(abs(mean_relative_phase) > median(abs(mean_relative_phase))); % bad syncher

sift_out = amflow(:,freqWindowOfInt,:); % can change to maflow
group1_sift_out = sift_out(group1_Idx,:,:); 
group2_sift_out = sift_out(group2_Idx,:,:); 

% Prepare both positive and nagative max statistics (01/10/2022 Makoto).
%     FWER_posi = zeros(4, numIter); % pValSteps, main effects + int, surro iter.
%     FWER_nega = zeros(4, numIter); % pValSteps, main effects + int, surro iter.
FWER_posi = zeros(1,numIter); % pValSteps, main effects + int, surro iter.
FWER_nega = zeros(1,numIter); % pValSteps, main effects + int, surro iter.

%     gFWER = zeros(4, numIter); % For get about gFWER (01/10/2022 Makoto)
%    progress('init', 'Starting..');
for iterIdx = 1:numIter+1
    
    disp(sprintf('%d/%d...', iterIdx, numIter+1)) % 01/10/2022 Makoto.
    
    %        progress(iterIdx/(numIter+1), sprintf('Cluster %d/%d, iteration %d/%d', clusterIdx, length(icClusters), iterIdx, numIter+1));
    
    if iterIdx == 1 % Ture diff.
        
        % Generate true data.
        group1 = group1_sift_out; % or group1_amflow, group1_maflow
        group2 = group2_sift_out; % or group2_amflow, group2_maflow
        
    else
        
        % Generate permutation data.
        surroIcIdx = randperm(size(sift_out,1));
        input = sift_out(surroIcIdx,:,:);
        group1 = input(1:size(group1,1),:,:);
        group2 = input(end-size(group1,1)+1:end,:,:);
    end
    
    % Perform stats.
    %        [stats, df, pvals] = statcond({input1 input2; input3 input4}, 'verbose', 'off'); % can just use b/t group ttest
    [H, pvals, ~, stats] = ttest2(group1,group2,'dim',1);
    % [stats, df, pvals] = statcond({randn(1,20)+1 randn(1,20)+1; randn(1,25) randn(1,25)});
    % statcond()'s help is wrong. Output{1} is across columns! (12/27/2020)
    
    %{
    % Visually evaluate the results (01/18/2022 Makoto)
    figure
    tiledlayout(1,3)
    nexttile
    imagesc(squeeze(mean(group1,1))); axis xy; colormap('jet'); colorbar
    nexttile
    imagesc(squeeze(mean(group2,1))); axis xy; colormap('jet'); colorbar
    nexttile
    imagesc(squeeze(mean(group1,1))-squeeze(mean(group2,1))); axis xy; colormap('jet'); colorbar
    %}
        
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Compute blob statistics. %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    massOfCluster = [];
    
    if iterIdx == 1
        t_or_F = squeeze(stats.tstat);
        pVals  = squeeze(pvals);
    end
    
    %             for pThreshIdx = 1:4
    %
    %                 switch pThreshIdx
    %                     case 1
    %                         pThresh = 0.05;
    %                     case 2
    %                         pThresh = 0.01;
    %                     case 3
    %                         pThresh = 0.005;
    %                     case 4
    %                         pThresh = 0.001;
    %                 end
    
    % Fix the target p to 0.05 to save time (01/10/2022 Makoto)
    pThresh    = 0.05;
    
    currentPvalMask = squeeze(pvals) < pThresh;
    if any(currentPvalMask(:)) == 0 %%wrong code? should be any(currentPvalMask(:) == 0)
        
        % If this is the real blob test, record null result then continue.
        if iterIdx == 1
            trueBlobs = currentPvalMask;
        end
        continue
    end
    connectedComponentLabels = bwlabeln(currentPvalMask);  % This requires image processing toolbox
    blobIdx  = nonzeros(unique(connectedComponentLabels)); % get the unique and nonzero (background) connected component index
    
    if iterIdx == 1
        trueBlobs = connectedComponentLabels;
        continue
    end
    
    massOfCluster = zeros(length(blobIdx),1);
    for blobIdxIdx = 1:length(blobIdx)
        currentMask = connectedComponentLabels==blobIdx(blobIdxIdx);
        %                     massOfCluster(blobIdxIdx) = sum(sum(squeeze(currentMask))); % number of pixel in the blob
        %                     massOfCluster(blobIdxIdx) = squeeze(sum(sum(currentMask.*abs(squeeze(stats.tstat))))); % number of pixel weighted the stats in the blob
        massOfCluster(blobIdxIdx) = squeeze(sum(sum(currentMask.*squeeze(stats.tstat)))); % number of pixel weighted the stats in the blob
    end
    
    [maxVal1, maxValIdx] = max(massOfCluster);
    [minVal1, minValIdx] = min(massOfCluster);
    
    FWER_posi(iterIdx) = maxVal1;
    FWER_nega(iterIdx) = minVal1;
    
    %                 massOfCluster(maxValIdx) = [];
    % %                [maxVal2, maxValIdx] = max(massOfCluster);
    %                 FWER(pThreshIdx, iterIdx) = maxVal1;
    % %                gFWER(pThreshIdx, iterIdx) = maxVal2;
    %             end
end

%     icClusters(clusterIdx).stats.trueBlobs = single(trueBlobs);
%     icClusters(clusterIdx).stats.pVals     = single(pVals);
%     icClusters(clusterIdx).stats.t_or_F    = single(t_or_F);
%     icClusters(clusterIdx).stats.FWER      = single(FWER(:,:,2:end));
%     icClusters(clusterIdx).stats.gFWER     = single(gFWER(:,:,2:end));

% calculate the significant blob
% uncorrPval = [0.05,0.01,0.005,0.001];
% uncorrPvalIdx = 1;
% uncorrPval = uncorrPval(uncorrPvalIdx);
uncorrPval = 0.05;

%connectedComponentLabels = bwlabeln(squeeze(trueBlobs(uncorrPvalIdx,:,:))); % This requires image processing toolbox
connectedComponentLabels = bwlabeln(trueBlobs); % This requires image processing toolbox
blobIdx = nonzeros(unique(connectedComponentLabels));
for blobIdxIdx = 1:length(blobIdx)
    currentMask = connectedComponentLabels==blobIdx(blobIdxIdx);
    %        massOfCluster(blobIdxIdx) = sum(sum(squeeze(currentMask))); % number of pixel in the blob
    %     massOfCluster(blobIdxIdx) = squeeze(sum(sum(currentMask.*abs(t_or_F))));
    massOfCluster(blobIdxIdx) = squeeze(sum(sum(currentMask.*t_or_F)));
end
figure;imagesc(1:4,freq(freqWindowOfInt),connectedComponentLabels);axis xy; title('true blobs')

currentMassOfCluster = massOfCluster;
% criticalMOC = prctile(FWER_posi(uncorrPvalIdx,:), 100-uncorrPval*100);
criticalMOC = [prctile(FWER_nega, uncorrPval*100) prctile(FWER_posi, 100-uncorrPval*100)];

% survivedBlobIdx = find(currentMassOfCluster>criticalMOC);
survivedBlobIdx = find(currentMassOfCluster<criticalMOC(1) | currentMassOfCluster>criticalMOC(2));

if isempty(survivedBlobIdx)
    warning('No blob survived.')
end

figure;hist(FWER_posi(1,:),100); title('Positive null distribution')
hold on
gridx(criticalMOC(2),'k:')
hold on
gridx(max(currentMassOfCluster),'r-')

figure;hist(FWER_nega(1,:),100); title('Negative null distribution')
hold on
gridx(criticalMOC(1),'k:')
hold on
gridx(min(currentMassOfCluster),'r-')
    % This result seems weird. (01/10/2022 Makoto)
    %{
    figure
    tiledlayout(1,2)
    nexttile
    hist(FWER_nega,100); title('null distribution')
    nexttile
    hist(FWER_posi,100); title('null distribution')
    %}

% get the significance mask
significanceMask = zeros(size(connectedComponentLabels));
for survivedBlobIdxIdx = 1:length(survivedBlobIdx)
    currentSignificanceMask = connectedComponentLabels == survivedBlobIdx(survivedBlobIdxIdx);
    significanceMask = significanceMask + currentSignificanceMask;
end

%  Apply the significance mask to obtain ERSP.
% contrast_ersp = squeeze(mean(group1_ersp,1)) - squeeze(mean(group2_ersp,1));
% figure;imagesc(times,freqs,contrast_ersp);axis xy; colormap(jet);title('Contrast ERSP')
% hold on
% contour(times, freqs, significanceMask, 'k'); axis xy
% caxis([-0.2 0.2])

contrast_sift_out = squeeze(mean(group1_sift_out,1)) - squeeze(mean(group2_sift_out,1));
% figure
% tiledlayout(1,2)
% nexttile
% imagesc(times,freqs,contrast_ersp);axis xy; colormap(jet);title('Contrast ERSP')
% nexttile
% imagesc(times,freqs,contrast_ersp.*significanceMask);axis xy; colormap(jet);title('Contrast ERSP')

figure;
imagesc(timeWindowOfInt,freqWindowOfInt,squeeze(mean(group1_sift_out,1)));axis xy; colormap(jet);title('Stable tappers ERSP');caxis([0.8 1.1])

figure;
imagesc(timeWindowOfInt,freqWindowOfInt,squeeze(mean(group2_sift_out,1)));axis xy; colormap(jet);title('Unstable tappers ERSP');caxis([0.8 1.1])

figure;
imagesc(timeWindowOfInt,freqWindowOfInt,contrast_sift_out);axis xy; colormap(jet);title('Contrast ERSP')


%% Perform 2D permutation: bwlabel can do it on the 2D too!
% for ERSP two sample ttest
clear
close all

cd('/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SMT')
addpath(genpath('/Volumes/TOSHIBA/Research/Imagined_beats/script'))

datafile = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SIFTs/sift_all.mat';
load(datafile)

load /Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SMT/ITI_stds.mat
load /Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SMT/ITI_means.mat

group = 2;

numIter         = 5000;
%numIter         = 5000; % Instead of giving up p<0.01, increase the number here (01/10/2022 Makoto)
timeWindowOfInt = 1;
freqWindowOfInt = [find(freq == 13):find(freq == 30)];
%trueBlobs       = zeros(4, length(freqWindowOfInt), length(timeWindowOfInt));
trueBlobs       = zeros(length(freqWindowOfInt), length(timeWindowOfInt)); % Only compute p< 0.05(01/10/2022 Makoto)
t_or_F          = zeros(length(freqWindowOfInt), length(timeWindowOfInt));
pVals           = zeros(length(freqWindowOfInt), length(timeWindowOfInt));

% for clusterIdx = 1:length(icClusters) % combine auditory and motor

% Obtain group Idx for different grouping ways

group1_Idx = find(stds < median(stds)); % stable tapper
group2_Idx = find(stds > median(stds)); % unstable tapper

% group1_Idx = [4     8    15     3]; % top 4 stable tapper
% group2_Idx = [22    12    10     2]; % top 4 unstable tapper

%    group1_Idx = find(means < median(means)); % fast tapper
%    group2_Idx = find(means > median(means)); % slow tapper

%   group1_Idx = find(abs(mean_relative_phase) < median(abs(mean_relative_phase))); % good syncher
%   group2_Idx = find(abs(mean_relative_phase) > median(abs(mean_relative_phase))); % bad syncher

sift_out = squeeze(amflow(:,freqWindowOfInt,3)); % can change to maflow: 3rd dimension: rdlisten(1), sync3s(2), syncst(3), tap(4)
group1_sift_out = sift_out(group1_Idx,:); 
group2_sift_out = sift_out(group2_Idx,:); 

% Prepare both positive and nagative max statistics (01/10/2022 Makoto).
%     FWER_posi = zeros(4, numIter); % pValSteps, main effects + int, surro iter.
%     FWER_nega = zeros(4, numIter); % pValSteps, main effects + int, surro iter.
FWER_posi = zeros(1,numIter); % pValSteps, main effects + int, surro iter.
FWER_nega = zeros(1,numIter); % pValSteps, main effects + int, surro iter.

%     gFWER = zeros(4, numIter); % For get about gFWER (01/10/2022 Makoto)
%    progress('init', 'Starting..');
for iterIdx = 1:numIter+1
    
    disp(sprintf('%d/%d...', iterIdx, numIter+1)) % 01/10/2022 Makoto.
    
    %        progress(iterIdx/(numIter+1), sprintf('Cluster %d/%d, iteration %d/%d', clusterIdx, length(icClusters), iterIdx, numIter+1));
    
    if iterIdx == 1 % Ture diff.
        
        % Generate true data.
        group1 = group1_sift_out; % or group1_amflow, group1_maflow
        group2 = group2_sift_out; % or group2_amflow, group2_maflow
        
    else
        
        % Generate permutation data.
        surroIcIdx = randperm(size(sift_out,1));
        input = sift_out(surroIcIdx,:);
        group1 = input(1:size(group1,1),:);
        group2 = input(end-size(group1,1)+1:end,:);
    end
    
    % Perform stats.
    %        [stats, df, pvals] = statcond({input1 input2; input3 input4}, 'verbose', 'off'); % can just use b/t group ttest
    [H, pvals, ~, stats] = ttest2(group1,group2,'dim',1);
    % [stats, df, pvals] = statcond({randn(1,20)+1 randn(1,20)+1; randn(1,25) randn(1,25)});
    % statcond()'s help is wrong. Output{1} is across columns! (12/27/2020)
    
    %{
    % Visually evaluate the results (01/18/2022 Makoto)
    figure
    tiledlayout(1,3)
    nexttile
    imagesc(squeeze(mean(group1,1))); axis xy; colormap('jet'); colorbar
    nexttile
    imagesc(squeeze(mean(group2,1))); axis xy; colormap('jet'); colorbar
    nexttile
    imagesc(squeeze(mean(group1,1))-squeeze(mean(group2,1))); axis xy; colormap('jet'); colorbar
    %}
        
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Compute blob statistics. %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    massOfCluster = [];
    
    if iterIdx == 1
        t_or_F = squeeze(stats.tstat);
        pVals  = squeeze(pvals);
    end
    
    %             for pThreshIdx = 1:4
    %
    %                 switch pThreshIdx
    %                     case 1
    %                         pThresh = 0.05;
    %                     case 2
    %                         pThresh = 0.01;
    %                     case 3
    %                         pThresh = 0.005;
    %                     case 4
    %                         pThresh = 0.001;
    %                 end
    
    % Fix the target p to 0.05 to save time (01/10/2022 Makoto)
    pThresh    = 0.05;
    
    currentPvalMask = squeeze(pvals) < pThresh;
    if any(currentPvalMask(:)) == 0 %%wrong code? should be any(currentPvalMask(:) == 0)
        
        % If this is the real blob test, record null result then continue.
        if iterIdx == 1
            trueBlobs = currentPvalMask;
        end
        continue
    end
    connectedComponentLabels = bwlabeln(currentPvalMask);  % This requires image processing toolbox
    blobIdx  = nonzeros(unique(connectedComponentLabels)); % get the unique and nonzero (background) connected component index
    
    if iterIdx == 1
        trueBlobs = connectedComponentLabels;
        continue
    end
    
    massOfCluster = zeros(length(blobIdx),1);
    for blobIdxIdx = 1:length(blobIdx)
        currentMask = connectedComponentLabels==blobIdx(blobIdxIdx);
        %                     massOfCluster(blobIdxIdx) = sum(sum(squeeze(currentMask))); % number of pixel in the blob
        %                     massOfCluster(blobIdxIdx) = squeeze(sum(sum(currentMask.*abs(squeeze(stats.tstat))))); % number of pixel weighted the stats in the blob
        massOfCluster(blobIdxIdx) = squeeze(sum(currentMask.*squeeze(stats.tstat))); % number of pixel weighted the stats in the blob
    end
    
    [maxVal1, maxValIdx] = max(massOfCluster);
    [minVal1, minValIdx] = min(massOfCluster);
    
    FWER_posi(iterIdx) = maxVal1;
    FWER_nega(iterIdx) = minVal1;
    
    %                 massOfCluster(maxValIdx) = [];
    % %                [maxVal2, maxValIdx] = max(massOfCluster);
    %                 FWER(pThreshIdx, iterIdx) = maxVal1;
    % %                gFWER(pThreshIdx, iterIdx) = maxVal2;
    %             end
end

%     icClusters(clusterIdx).stats.trueBlobs = single(trueBlobs);
%     icClusters(clusterIdx).stats.pVals     = single(pVals);
%     icClusters(clusterIdx).stats.t_or_F    = single(t_or_F);
%     icClusters(clusterIdx).stats.FWER      = single(FWER(:,:,2:end));
%     icClusters(clusterIdx).stats.gFWER     = single(gFWER(:,:,2:end));

% calculate the significant blob
% uncorrPval = [0.05,0.01,0.005,0.001];
% uncorrPvalIdx = 1;
% uncorrPval = uncorrPval(uncorrPvalIdx);
uncorrPval = 0.05;

%connectedComponentLabels = bwlabeln(squeeze(trueBlobs(uncorrPvalIdx,:,:))); % This requires image processing toolbox
connectedComponentLabels = bwlabeln(trueBlobs); % This requires image processing toolbox
blobIdx = nonzeros(unique(connectedComponentLabels));
for blobIdxIdx = 1:length(blobIdx)
    currentMask = connectedComponentLabels==blobIdx(blobIdxIdx);
    %        massOfCluster(blobIdxIdx) = sum(sum(squeeze(currentMask))); % number of pixel in the blob
    %     massOfCluster(blobIdxIdx) = squeeze(sum(sum(currentMask.*abs(t_or_F))));
    massOfCluster(blobIdxIdx) = squeeze(sum(currentMask.*t_or_F));
end

figure;plot(freq(freqWindowOfInt),connectedComponentLabels);axis xy; title('true blobs')

currentMassOfCluster = massOfCluster;
% criticalMOC = prctile(FWER_posi(uncorrPvalIdx,:), 100-uncorrPval*100);
criticalMOC = [prctile(FWER_nega, uncorrPval*100) prctile(FWER_posi, 100-uncorrPval*100)];

% survivedBlobIdx = find(currentMassOfCluster>criticalMOC);
survivedBlobIdx = find(currentMassOfCluster<criticalMOC(1) | currentMassOfCluster>criticalMOC(2));

if isempty(survivedBlobIdx)
    warning('No blob survived.')
end

figure;hist(FWER_posi(1,:),100); title('Positive null distribution')
hold on
gridx(criticalMOC(2),'k:')
hold on
gridx(max(currentMassOfCluster),'r-')

figure;hist(FWER_nega(1,:),100); title('Negative null distribution')
hold on
gridx(criticalMOC(1),'k:')
hold on
gridx(min(currentMassOfCluster),'r-')
    % This result seems weird. (01/10/2022 Makoto)
    %{
    figure
    tiledlayout(1,2)
    nexttile
    hist(FWER_nega,100); title('null distribution')
    nexttile
    hist(FWER_posi,100); title('null distribution')
    %}

% get the significance mask
% significanceMask = zeros(size(connectedComponentLabels));
% for survivedBlobIdxIdx = 1:length(survivedBlobIdx)
%     currentSignificanceMask = connectedComponentLabels == survivedBlobIdx(survivedBlobIdxIdx);
%     significanceMask = significanceMask + currentSignificanceMask;
% end

%  Apply the significance mask to obtain ERSP.
% contrast_ersp = squeeze(mean(group1_ersp,1)) - squeeze(mean(group2_ersp,1));
% figure;imagesc(times,freqs,contrast_ersp);axis xy; colormap(jet);title('Contrast ERSP')
% hold on
% contour(times, freqs, significanceMask, 'k'); axis xy
% caxis([-0.2 0.2])


figure;
plot(freq(freqWindowOfInt),squeeze(mean(group1_sift_out,1)));axis xy; colormap(jet);title('Stable tappers');caxis([0.8 1.1])
hold on;
plot(freq(freqWindowOfInt),squeeze(mean(group2_sift_out,1)));axis xy; colormap(jet);title('Unstable tappers');caxis([0.8 1.1])

trueBlobs % is there any uncorrected significance for the ttest in real data? 