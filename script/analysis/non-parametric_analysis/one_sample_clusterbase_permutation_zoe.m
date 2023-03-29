% 03/27/2023 Zoe. Modified.
% 01/18/2022 Makoto. Used again. Modified a bit.
% 01/10/2022 Makoto. Modified. abs() was removed. Maximum statistics for min and max are stored (because it is a t-test)
% 12/26/2021 Zoe added one sample test
% 06/15/2021 Zoe modified and used.
% 02/12/2021 Makoto. Used.
% 12/25/2020 Makoto. Created.

%% for ERSP one sample ttest against 0
clear

cd('/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/sync')
addpath(genpath('/Volumes/TOSHIBA/Research/Imagined_beats/script'))
SMT_path = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SMT/';
load(strcat(SMT_path,'ITI_stds.mat'));
stable_tapper = find(stds < median(stds)); % use std of ITI
unstable_tapper = find(stds > median(stds)); % use std of ITI

datafile = '/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/SMT/aIC_averagebaslined_ersp_itc_tap1.mat';
load(datafile)

tic
numIter         = 500; % should change to 5000 later
nsub = size(ersp,1);
timeWindowOfInt = find(times > -500);
freqWindowOfInt = find(freqs > 0.5);
trueBlobs       = zeros(4, length(freqWindowOfInt), length(timeWindowOfInt));
t_or_F          = zeros(length(freqWindowOfInt), length(timeWindowOfInt));
pVals           = zeros(length(freqWindowOfInt), length(timeWindowOfInt));

% preprocessing 
ersp =  ersp -1; 

% FWER_posi  = zeros(4, numIter); % pValSteps, main effects + int, surro iter.
FWER_posi = zeros(1,numIter); % pValSteps, main effects + int, surro iter.
FWER_nega = zeros(1,numIter); % pValSteps, main effects + int, surro iter.
%     gFWER = zeros(4, numIter);
%    progress('init', 'Starting..');
for iterIdx = 1:numIter+1
    disp(sprintf('%d/%d...', iterIdx, numIter+1)) % 01/10/2022 Makoto.
    
    %        progress(iterIdx/(numIter+1), sprintf('Cluster %d/%d, iteration %d/%d', clusterIdx, length(icClusters), iterIdx, numIter+1));
    
    if iterIdx == 1 % True diff.
        
        % Generate true data.
        [tmpH,tmpP,tmpCI,tmpSTATS] = ttest(ersp);
        trueP = squeeze(tmpP);
        trueT = squeeze(tmpSTATS.tstat);
        clear tmpH tmpP tmpCI tmpSTATS
    else
        
        % Generate permutation data.
        surro_ersp = ersp(:,surroFIdx,surroTIdx);
        [tmpH,tmpP,tmpCI,tmpSTATS] = ttest(surro_ersp);
        surro_P = squeeze(tmpP);
        surro_T = squeeze(tmpSTATS.tstat);
        clear tmpH tmpP tmpCI tmpSTATS
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Compute blob statistics. %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pMask         = [];
    massOfCluster = [];
    
    if iterIdx == 1
        t_or_F = trueT;
        pVals  = trueP;
    else
        t_or_F = surro_T;
        pVals  = surro_P;
    end
    
%     for pThreshIdx = 1:4
%         
%         switch pThreshIdx
%             case 1
%                 pThresh = 0.05;
%             case 2
%                 pThresh = 0.01;
%             case 3
%                 pThresh = 0.005;
%             case 4
%                 pThresh = 0.001;
%         end
        pThresh = 0.05;   
        currentPvalMask = squeeze(pVals) < pThresh;
%         if any(currentPvalMask(:)) == 0
%             
%             % If this is the real blob test, record null result then continue.
%             if iterIdx == 1
%                 trueBlobs = currentPvalMask;
%             end
%             continue
%         end
        
        connectedComponentLabels = bwlabeln(currentPvalMask); % This requires image processing toolbox
        blobIdx  = nonzeros(unique(connectedComponentLabels)); % get the unique and nonzero (background) connected component index
        
        if iterIdx == 1
            trueBlobs = connectedComponentLabels;
            continue
        end
        
        massOfCluster = zeros(length(blobIdx),1);
        for blobIdxIdx = 1:length(blobIdx)
            currentMask = connectedComponentLabels==blobIdx(blobIdxIdx);
            %                    massOfCluster(blobIdxIdx) = sum(sum(squeeze(currentMask))); % number of pixel in the blob
            %                    massOfCluster(blobIdxIdx) = squeeze(sum(sum(currentMask.*abs(squeeze(t_or_F))))); % number of pixel weighted the stats in the blob
            massOfCluster(blobIdxIdx) = squeeze(sum(sum(currentMask.*squeeze(t_or_F)))); % number of pixel weighted the stats in the blob
        end
        
        [maxVal1, maxValIdx] = max(massOfCluster);
        [minVal1, minValIdx] = min(massOfCluster);
    
        FWER_posi(iterIdx) = maxVal1;
        FWER_nega(iterIdx) = minVal1;
        
%         [maxVal1, maxValIdx] = max(massOfCluster);
        %                massOfCluster(maxValIdx) = [];
        %                [maxVal2, maxValIdx] = max(massOfCluster);
%         FWER_posi(pThreshIdx, iterIdx) = maxVal1;
        %                gFWER(pThreshIdx, iterIdx) = maxVal2;
end
toc

%% calculate the significant blob
uncorrPval = [0.05,0.01,0.005,0.001];
uncorrPvalIdx = 1;
uncorrPval = uncorrPval(uncorrPvalIdx);

connectedComponentLabels = bwlabeln(squeeze(trueBlobs)); % This requires image processing toolbox
blobIdx = nonzeros(unique(connectedComponentLabels));
massOfCluster = zeros(length(blobIdx),1);

for blobIdxIdx = 1:length(blobIdx)
    currentMask = connectedComponentLabels==blobIdx(blobIdxIdx);
    %        massOfCluster(blobIdxIdx) = sum(sum(squeeze(currentMask))); % number of pixel in the blob
    massOfCluster(blobIdxIdx) = squeeze(sum(sum(currentMask.*trueT)));
end
figure;imagesc(times,freqs,connectedComponentLabels);axis xy; title('true blobs')

currentMassOfCluster = massOfCluster;
% criticalMOC = prctile(FWER_posi(uncorrPvalIdx,:), 100-uncorrPval*100);
criticalMOC = [prctile(FWER_nega, uncorrPval*100) prctile(FWER_posi, 100-uncorrPval*100)];

% survivedBlobIdx = find(currentMassOfCluster>criticalMOC);
survivedBlobIdx = find(currentMassOfCluster<criticalMOC(1) | currentMassOfCluster>criticalMOC(2))

%%
if isempty(survivedBlobIdx)
    warning('No blob survived.')
end
figure;hist(FWER_posi(uncorrPvalIdx,:),100); title('null distribution')
hold on;gridx(criticalMOC(1,2),'k:');
hold on; gridx(max(massOfCluster),'r:');

figure;hist(FWER_nega(uncorrPvalIdx,:),100); title('null distribution')
hold on;gridx(criticalMOC(1,1),'k:');
hold on; gridx(min(massOfCluster),'r:');

% get the significance mask
significanceMask = zeros(size(connectedComponentLabels));
for survivedBlobIdxIdx = 1:length(survivedBlobIdx)
    currentSignificanceMask = connectedComponentLabels == survivedBlobIdx(survivedBlobIdxIdx);
    significanceMask = significanceMask + currentSignificanceMask;
end

%  Apply the significance mask to obtain ERSP.
figure;imagesc(times,freqs,trueP);axis xy; colormap(jet);title('ERSP P value')

figure;imagesc(times,freqs,trueT);axis xy; colormap(jet);title('ERSP Beta value')
hold on
contour(times,freqs, significanceMask, 'k'); axis xy
caxis([-0.2 0.2])