% 02/12/2021 Makoto. Used.
% 12/25/2020 Makoto. Created.

load /data/mobi/Tic/combinedSubjects2/p0330_Eyen1st2nd3rd/ticFreeSupp_Eyen2nd.mat

numIter         = 10000;
timeWindowOfInt = find(icClusters(1).epochTime<0);
freqWindowOfInt = find(icClusters(1).wtFreqs>1.5);
trueBlobs       = zeros(4, length(icClusters(1).latencyZeroEvents), length(freqWindowOfInt), length(timeWindowOfInt));
t_or_F          = zeros(length(icClusters(1).latencyZeroEvents), length(freqWindowOfInt), length(timeWindowOfInt));
pVals           = zeros(length(icClusters(1).latencyZeroEvents), length(freqWindowOfInt), length(timeWindowOfInt));
for clusterIdx = 1:length(icClusters)
    
    tic
    
    % Obtain group Idx.
    uniqueGroups = unique(icClusters(clusterIdx).group);
    controlIdx = find(strcmp(icClusters(clusterIdx).group, 'Control'));
    patientIdx = find(strcmp(icClusters(clusterIdx).group, 'Patient'));

    % Separate ERSPs.
    controlF = squeeze(icClusters(clusterIdx).meanErsp(controlIdx,1,freqWindowOfInt,timeWindowOfInt));
    controlS = squeeze(icClusters(clusterIdx).meanErsp(controlIdx,2,freqWindowOfInt,timeWindowOfInt));
    patientF = squeeze(icClusters(clusterIdx).meanErsp(patientIdx,1,freqWindowOfInt,timeWindowOfInt));
    patientS = squeeze(icClusters(clusterIdx).meanErsp(patientIdx,2,freqWindowOfInt,timeWindowOfInt));

    epochTime = icClusters(clusterIdx).epochTime;
    wtFreqs = icClusters(clusterIdx).wtFreqs;
    wtFreqInterval = round(length(wtFreqs)/6);
    wtFreqIdx = 1:wtFreqInterval:length(wtFreqs);
    selectedFreqBins = wtFreqs(wtFreqIdx);
    selectedFreqBins(selectedFreqBins<10)  = round(selectedFreqBins(selectedFreqBins<10)*10)/10;
    selectedFreqBins(selectedFreqBins>=10) = round(selectedFreqBins(selectedFreqBins>=10));
    
    % Re-correct baseline.
    baselineIdx = find(epochTime>= -5 & epochTime <= -4);
    controlF = permute(bsxfun(@minus, controlF, mean(controlF(:,:,baselineIdx),3)), [2 3 1]);
    controlS = permute(bsxfun(@minus, controlS, mean(controlS(:,:,baselineIdx),3)), [2 3 1]);
    patientF = permute(bsxfun(@minus, patientF, mean(patientF(:,:,baselineIdx),3)), [2 3 1]);
    patientS = permute(bsxfun(@minus, patientS, mean(patientS(:,:,baselineIdx),3)), [2 3 1]);

    combinedData = cat(3, controlF, controlS, patientF, patientS);
    data1OnsetIdx = 1;
    data1EndIdx   = size(controlF,3);
    data2OnsetIdx = data1EndIdx+1;
    data2EndIdx   = data2OnsetIdx+size(controlS,3)-1;
    data3OnsetIdx = data2EndIdx+1;
    data3EndIdx   = data3OnsetIdx+size(patientF,3)-1;
    data4OnsetIdx = data3EndIdx+1;
    data4EndIdx   = data4OnsetIdx+size(patientS,3)-1;
    
    FWER  = zeros(4, 3, numIter); % pValSteps, main effects + int, surro iter.
    gFWER = zeros(4, 3, numIter);
    progress('init', 'Starting..');
    for iterIdx = 1:numIter+1
        
        progress(iterIdx/(numIter+1), sprintf('Cluster %d/%d, iteration %d/%d', clusterIdx, length(icClusters), iterIdx, numIter+1));
        
        if iterIdx == 1 % Ture diff.
            
            % Generate true data.
            input1 = controlF;
            input2 = controlS;
            input3 = patientF;
            input4 = patientS;
                  
        else
            
            % Generate permutation data.
            surroIcIdx = randperm(size(combinedData,3));
            input1 = combinedData(:,:,surroIcIdx(data1OnsetIdx:data1EndIdx));
            input2 = combinedData(:,:,surroIcIdx(data2OnsetIdx:data2EndIdx));
            input3 = combinedData(:,:,surroIcIdx(data3OnsetIdx:data3EndIdx));
            input4 = combinedData(:,:,surroIcIdx(data4OnsetIdx:data4EndIdx));
        end
        
        % Perform stats.
        [stats, df, pvals] = statcond({input1 input2; input3 input4}, 'verbose', 'off');
        
        % [stats, df, pvals] = statcond({randn(1,20)+1 randn(1,20)+1; randn(1,25) randn(1,25)});
        % statcond()'s help is wrong. Output{1} is across columns! (12/27/2020)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Compute blob statistics. %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pMask         = [];
        massOfCluster = [];
        for statsTypeIdx = 1:3
            
            if iterIdx == 1
                t_or_F(statsTypeIdx,:,:) = stats{statsTypeIdx};
                pVals(statsTypeIdx,:,:)  = pvals{statsTypeIdx};
            end
            
            for pThreshIdx = 1:4
                
                switch pThreshIdx
                    case 1
                        pThresh = 0.05;
                    case 2
                        pThresh = 0.01;
                    case 3
                        pThresh = 0.005;
                    case 4
                        pThresh = 0.001;
                end
                
                currentPvalMask = pvals{statsTypeIdx} < pThresh;
                if any(currentPvalMask(:)) == 0
                    
                    % If this is the real blob test, record null result then continue.
                    if iterIdx == 1
                        trueBlobs(pThreshIdx,statsTypeIdx,:,:) = currentPvalMask;
                    end
                    continue
                end
                connectedComponentLabels = bwlabeln(currentPvalMask); % This requires image processing toolbox
                [entryCount, blobIdx]  = hist(connectedComponentLabels(:), unique(connectedComponentLabels(:)));
                
                if iterIdx == 1
                    trueBlobs(pThreshIdx,statsTypeIdx,:,:) = connectedComponentLabels;
                    continue
                end
                
                massOfCluster = zeros(length(blobIdx),1);
                for blobIdxIdx = 1:length(blobIdx)
                    currentMask = connectedComponentLabels==blobIdx(blobIdxIdx);
                    massOfCluster(blobIdxIdx) = sum(sum(currentMask.*abs(stats{statsTypeIdx})));
                end
                
                [maxVal1, maxValIdx] = max(massOfCluster);
                massOfCluster(maxValIdx) = [];
                [maxVal2, maxValIdx] = max(massOfCluster);
                FWER(pThreshIdx, statsTypeIdx, iterIdx) = maxVal1;
                gFWER(pThreshIdx, statsTypeIdx, iterIdx) = maxVal2;
            end
        end
    end
    
    icClusters(clusterIdx).stats.trueBlobs = single(trueBlobs);
    icClusters(clusterIdx).stats.pVals     = single(pVals);
    icClusters(clusterIdx).stats.t_or_F    = single(t_or_F);
    icClusters(clusterIdx).stats.FWER      = single(FWER(:,:,2:end));
    icClusters(clusterIdx).stats.gFWER     = single(gFWER(:,:,2:end));
    toc
end
        
save('/data/mobi/Tic/combinedSubjects2/p0330_Eyen1st2nd3rd/ticFreeSupp_Eyen3rd.mat', 'icClusters', '-v7.3', '-nocompression')






%%

% % load /data/mobi/Tic/combinedSubjects2/p0110_Eyen1st/eventRelatedTic_Eyen2nd.mat
% 
% for clusterIdx = 1:length(icClusters)
%     
%     % Obtain group Idx.
%     uniqueGroups = unique(icClusters(clusterIdx).group);
%     controlIdx = find(strcmp(icClusters(clusterIdx).group, 'Control'));
%     patientIdx = find(strcmp(icClusters(clusterIdx).group, 'Patient'));
% 
%     % Separate ERSPs.
% %     controlF = squeeze(icClusters(clusterIdx).meanErsp(controlIdx,1,:,:));
% %     controlS = squeeze(icClusters(clusterIdx).meanErsp(controlIdx,3,:,:));
% %     controlR = squeeze(icClusters(clusterIdx).meanErsp(controlIdx,2,:,:));
% %     patientF = squeeze(icClusters(clusterIdx).meanErsp(patientIdx,1,:,:));
% %     patientS = squeeze(icClusters(clusterIdx).meanErsp(patientIdx,3,:,:));
% %     patientR = squeeze(icClusters(clusterIdx).meanErsp(patientIdx,2,:,:));
% 
%     controlF = squeeze(icClusters(clusterIdx).robustErsp(controlIdx,1,:,:));
%     controlS = squeeze(icClusters(clusterIdx).robustErsp(controlIdx,3,:,:));
%     controlR = squeeze(icClusters(clusterIdx).robustErsp(controlIdx,2,:,:));
%     patientF = squeeze(icClusters(clusterIdx).robustErsp(patientIdx,1,:,:));
%     patientS = squeeze(icClusters(clusterIdx).robustErsp(patientIdx,3,:,:));
%     patientR = squeeze(icClusters(clusterIdx).robustErsp(patientIdx,2,:,:));
% 
%     epochTime = icClusters(clusterIdx).epochTime;
%     wtFreqs = icClusters(clusterIdx).wtFreqs;
%     wtFreqInterval = round(length(wtFreqs)/6);
%     wtFreqIdx = 1:wtFreqInterval:length(wtFreqs);
%     selectedFreqBins = wtFreqs(wtFreqIdx);
%     selectedFreqBins(selectedFreqBins<10)  = round(selectedFreqBins(selectedFreqBins<10)*10)/10;
%     selectedFreqBins(selectedFreqBins>=10) = round(selectedFreqBins(selectedFreqBins>=10));
%     
%     % Re-correct baseline.
%     baselineIdx = find(epochTime>= -5 & epochTime <= -4);
%     controlF = bsxfun(@minus, controlF, mean(controlF(:,:,baselineIdx),3));
%     controlS = bsxfun(@minus, controlS, mean(controlS(:,:,baselineIdx),3));
%     controlR = bsxfun(@minus, controlR, mean(controlR(:,:,baselineIdx),3));
%     patientF = bsxfun(@minus, patientF, mean(patientF(:,:,baselineIdx),3));
%     patientS = bsxfun(@minus, patientS, mean(patientS(:,:,baselineIdx),3));
%     patientR = bsxfun(@minus, patientR, mean(patientR(:,:,baselineIdx),3));
% 
%     figure
%     subplot(2,3,1)
%     imagesc(epochTime, 1:size(wtFreqs,2), squeeze(mean(controlF)), [-3 3]); axis xy; colormap('jet')
%     set(gca, 'ytick', wtFreqIdx, 'yticklabel', selectedFreqBins)
%     line([0 0], ylim, 'color', [0 0 0], 'linestyle', ':')
%     xlabel('Latency (s)')
%     ylabel('Frequency (Hz)')
%     
%     subplot(2,3,2)
%     imagesc(epochTime, 1:size(wtFreqs,2), squeeze(mean(controlS)), [-3 3]); axis xy; colormap('jet')
%     set(gca, 'ytick', wtFreqIdx, 'yticklabel', selectedFreqBins)
%     line([0 0], ylim, 'color', [0 0 0], 'linestyle', ':')
%     xlabel('Latency (s)')
%     ylabel('Frequency (Hz)')
%     
%     subplot(2,3,3)
%     imagesc(epochTime, 1:size(wtFreqs,2), squeeze(mean(controlR)), [-3 3]); axis xy; colormap('jet')
%     set(gca, 'ytick', wtFreqIdx, 'yticklabel', selectedFreqBins)
%     line([0 0], ylim, 'color', [0 0 0], 'linestyle', ':')
%     xlabel('Latency (s)')
%     ylabel('Frequency (Hz)')
%     
%     subplot(2,3,4)
%     imagesc(epochTime, 1:size(wtFreqs,2), squeeze(mean(patientF)), [-3 3]); axis xy; colormap('jet')
%     set(gca, 'ytick', wtFreqIdx, 'yticklabel', selectedFreqBins)
%     line([0 0], ylim, 'color', [0 0 0], 'linestyle', ':')
%     xlabel('Latency (s)')
%     ylabel('Frequency (Hz)')
%     
%     subplot(2,3,5)
%     imagesc(epochTime, 1:size(wtFreqs,2), squeeze(mean(patientS)), [-3 3]); axis xy; colormap('jet')
%     set(gca, 'ytick', wtFreqIdx, 'yticklabel', selectedFreqBins)
%     line([0 0], ylim, 'color', [0 0 0], 'linestyle', ':')
%     xlabel('Latency (s)')
%     ylabel('Frequency (Hz)')
%     
%     subplot(2,3,6)
%     imagesc(epochTime, 1:size(wtFreqs,2), squeeze(mean(patientR)), [-3 3]); axis xy; colormap('jet')
%     set(gca, 'ytick', wtFreqIdx, 'yticklabel', selectedFreqBins)
%     line([0 0], ylim, 'color', [0 0 0], 'linestyle', ':')
%     xlabel('Latency (s)')
%     ylabel('Frequency (Hz)')
%     
%     suptitle(sprintf('Cluster %d', clusterIdx))
% end

%% For stats.

% uncorrPval = 0.05;
% 
% for clusterIdx = 1:length(icClusters)
%     
%     % Obtain group Idx.
%     uniqueGroups = unique(icClusters(clusterIdx).group);
%     controlIdx = find(strcmp(icClusters(clusterIdx).group, 'Control'));
%     patientIdx = find(strcmp(icClusters(clusterIdx).group, 'Patient'));
% 
%     % Separate ERSPs.
%     controlF = squeeze(icClusters(clusterIdx).meanErsp(controlIdx,1,:,:));
%     controlS = squeeze(icClusters(clusterIdx).meanErsp(controlIdx,3,:,:));
%     controlR = squeeze(icClusters(clusterIdx).meanErsp(controlIdx,2,:,:));
%     patientF = squeeze(icClusters(clusterIdx).meanErsp(patientIdx,1,:,:));
%     patientS = squeeze(icClusters(clusterIdx).meanErsp(patientIdx,3,:,:));
%     patientR = squeeze(icClusters(clusterIdx).meanErsp(patientIdx,2,:,:));
% 
% %     controlF = squeeze(icClusters(clusterIdx).robustErsp(controlIdx,1,:,:));
% %     controlS = squeeze(icClusters(clusterIdx).robustErsp(controlIdx,3,:,:));
% %     controlR = squeeze(icClusters(clusterIdx).robustErsp(controlIdx,2,:,:));
% %     patientF = squeeze(icClusters(clusterIdx).robustErsp(patientIdx,1,:,:));
% %     patientS = squeeze(icClusters(clusterIdx).robustErsp(patientIdx,3,:,:));
% %     patientR = squeeze(icClusters(clusterIdx).robustErsp(patientIdx,2,:,:));
% 
%     epochTime = icClusters(clusterIdx).epochTime;
%     wtFreqs = icClusters(clusterIdx).wtFreqs;
%     wtFreqInterval = round(length(wtFreqs)/6);
%     wtFreqIdx = 1:wtFreqInterval:length(wtFreqs);
%     selectedFreqBins = wtFreqs(wtFreqIdx);
%     selectedFreqBins(selectedFreqBins<10)  = round(selectedFreqBins(selectedFreqBins<10)*10)/10;
%     selectedFreqBins(selectedFreqBins>=10) = round(selectedFreqBins(selectedFreqBins>=10));
%     
%     % Re-correct baseline.
%     baselineIdx = find(epochTime>= -5 & epochTime <= -4);
%     controlF = permute(bsxfun(@minus, controlF, mean(controlF(:,:,baselineIdx),3)), [2 3 1]);
%     controlS = permute(bsxfun(@minus, controlS, mean(controlS(:,:,baselineIdx),3)), [2 3 1]);
%     controlR = permute(bsxfun(@minus, controlR, mean(controlR(:,:,baselineIdx),3)), [2 3 1]);
%     patientF = permute(bsxfun(@minus, patientF, mean(patientF(:,:,baselineIdx),3)), [2 3 1]);
%     patientS = permute(bsxfun(@minus, patientS, mean(patientS(:,:,baselineIdx),3)), [2 3 1]);
%     patientR = permute(bsxfun(@minus, patientR, mean(patientR(:,:,baselineIdx),3)), [2 3 1]);
% 
%     % Perform stats.
%     [stats, df, pvals] = statcond({controlR controlF; patientR patientF});
%     
%     figure
%     subplot(1,3,1)
%     imagesc(epochTime, 1:size(wtFreqs,2), pvals{1}<uncorrPval, [-1 1]); axis xy; colormap('jet')
%     set(gca, 'ytick', wtFreqIdx, 'yticklabel', selectedFreqBins)
%     line([0 0], ylim, 'color', [0 0 0], 'linestyle', ':')
%     xlabel('Latency (s)')
%     ylabel('Frequency (Hz)')
%     title('Group')
%     
%     subplot(1,3,2)
%     imagesc(epochTime, 1:size(wtFreqs,2), pvals{2}<uncorrPval, [-1 1]); axis xy; colormap('jet')
%     set(gca, 'ytick', wtFreqIdx, 'yticklabel', selectedFreqBins)
%     line([0 0], ylim, 'color', [0 0 0], 'linestyle', ':')
%     xlabel('Latency (s)')
%     ylabel('Frequency (Hz)')
%     title('Supp')
% 
%     
%     subplot(1,3,3)
%     imagesc(epochTime, 1:size(wtFreqs,2), pvals{3}<uncorrPval, [-1 1]); axis xy; colormap('jet')
%     set(gca, 'ytick', wtFreqIdx, 'yticklabel', selectedFreqBins)
%     line([0 0], ylim, 'color', [0 0 0], 'linestyle', ':')
%     xlabel('Latency (s)')
%     ylabel('Frequency (Hz)')
%     title('Group x Supp')
%     
%     close
% end
        
        
%         % Select uncorr p-val for surroDistribution.
%         switch uncorrPval
%             case 0.05
%                 currentSurro = surroDistribution(:,:,clusterIdx,1);
%             case 0.01
%                 currentSurro = surroDistribution(:,:,clusterIdx,2);
%             case 0.005
%                 currentSurro = surroDistribution(:,:,clusterIdx,3);
%             case 0.001
%                 currentSurro = surroDistribution(:,:,clusterIdx,4);
%         end
%         
%         if statsTypeIdx == 1
%             criticalMOC = prctile(currentSurro(:,1), 100-corrPval*100);
%         else
%             criticalMOC = prctile(currentSurro(:,2), 100-corrPval*100);
%         end
%         
%         survivedBlobIdx = find(currentMassOfCluster>criticalMOC);
%         if isempty(survivedBlobIdx)
%             warning('No blob survived.')
%             continue
%         end
%         
%         significanceMask = zeros(size(connectedComponentLabels));
%         for survivedBlobIdxIdx = 1:length(survivedBlobIdx)
%             currentSignificanceMask = connectedComponentLabels == survivedBlobIdx(survivedBlobIdxIdx);
%             significanceMask = significanceMask + currentSignificanceMask;
%         end
%         
%     end
%     
%     % Apply the significance mask to obtain ERSP.
%     erspF_Ct_maskMean = squeeze(sum(sum(erspF_Ct.*significanceMask))/sum(significanceMask(:)));
%     erspV_Ct_maskMean = squeeze(sum(sum(erspV_Ct.*significanceMask))/sum(significanceMask(:)));
%     erspR_Ct_maskMean = squeeze(sum(sum(erspR_Ct.*significanceMask))/sum(significanceMask(:)));
%     erspF_Pt_maskMean = squeeze(sum(sum(erspF_Pt.*significanceMask))/sum(significanceMask(:)));
%     erspV_Pt_maskMean = squeeze(sum(sum(erspV_Pt.*significanceMask))/sum(significanceMask(:)));   
%     erspR_Pt_maskMean = squeeze(sum(sum(erspR_Pt.*significanceMask))/sum(significanceMask(:)));
% 
%     % Compute Supp-Free.
%     switch suppType
%         case 1
%             ct_SuppFree = erspV_Ct_maskMean - erspF_Ct_maskMean;
%             pt_SuppFree = erspV_Pt_maskMean - erspF_Pt_maskMean;
%         case 2
%             ct_SuppFree = erspR_Ct_maskMean - erspF_Ct_maskMean;
%             pt_SuppFree = erspR_Pt_maskMean - erspF_Pt_maskMean;
%         case 3
%             ct_SuppFree = (erspV_Ct_maskMean+erspR_Ct_maskMean)/2-erspF_Ct_maskMean;
%             pt_SuppFree = (erspV_Pt_maskMean+erspR_Pt_maskMean)/2-erspF_Pt_maskMean;
%         case 4
%             ct_SuppFree = erspR_Ct_maskMean - erspV_Ct_maskMean;
%             pt_SuppFree = erspR_Pt_maskMean - erspV_Pt_maskMean;
%     end
% end
