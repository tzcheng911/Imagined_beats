% 06/02/2021 Makoto. Joe suggested the absolute number of tics may be investigated in the correlation analysis. 
% 05/05/2021 Makoto. https://urldefense.proofpoint.com/v2/url?u=https-3A__www.mathworks.com_matlabcentral_answers_363832-2Dsome-2Dfigures-2Dnot-2Dsaving-2Das-2Dvector-2Dgraphics-2Dsvg&d=DwIGAg&c=-35OiAkTchMrZOngvJPOeA&r=jSbmOsDn0WrBAJAH8fPBdg&m=G2ssJ1Dhb02i4dBCxadTNr590W5hTt6XPqQsIiUlnSk&s=cYx7mK7wM3PLK_dLDAoB-XuhncXF43rEg3rc3rO3O2o&e= 
% 05/03/2021 Makoto. Used.
% 12/30/2020 Makoto. Used to generate final figures for the paper.
% 12/26/2020 Makoto. Created.

statsIdx      = 3; % 1-Main effect Supp; 2-Main effect Group; 3-Interaction Supp x Group.
useRobustFlag = 0;

addpath('/data/projects/makoto/Tools/cbrewer/cbrewer')
addpath('/data/projects/makoto/Tools/RainCloudPlots-master/tutorial_matlab')
addpath('/data/projects/makoto/Tools/eeglab14_1_2b/plugins/Eyen/external/Talairach')
addpath(genpath('/data/projects/makoto/Tools/Robust_Statistical_Toolbox-master'))

% {'SubjID' 'isPatient' 'TicFreely' 'VSupp' 'RSupp' 'DuringANT' 'BlockLengthS'}
load('/data/projects/Sandy/tic/2021/p0300_countBlintic/normalizedBlinticCounts.mat')
subjNameList = arrayfun(@num2str, normalizedBlinticCounts(:,1), 'uniformoutput', false);

% figure; hist(normalizedBlinticCounts(:,5),50)

%{
% Select which data to load.
% Elapsed time is 2345.020792 seconds (03/05/2021)
tic
load('/data/projects/Sandy/tic/2021/p0100_Eyen3rd/ticFreeSupp_Eyen3rd.mat')
toc
%}

timeWindowOfInt = find(icClusters(1).epochTime<0);
freqWindowOfInt = find(icClusters(1).wtFreqs>1.5);
corrCoeffPvalMatrix = zeros(length(icClusters),2);
for clusterIdx = 1:length(icClusters)
    
    meanXyz = mean(icClusters(clusterIdx).posxyz);
    [structuresFinal, probabilitiesFinal] = std_dipoleDensity_eeg_lookup_talairach(meanXyz, 20);
    
    trueBlobs = icClusters(clusterIdx).stats.trueBlobs;
    t_or_F = icClusters(clusterIdx).stats.t_or_F;
    
    
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     %%% Plot dipole density. %%%
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     Eyen_visDipoleDensity(icClusters(clusterIdx).posxyz, 20)
    %     print(sprintf('/data/projects/Sandy/tic/2021/p0200_erspWithRainCloudPlots_separateErsp/dipDensity_Cls%d', clusterIdx), '-djpeg98', '-r300');
    %     close
    
    
    for pValIdx = 1 %1:4
        switch pValIdx
            case 1
                corrPval = 0.05;
            case 2
                corrPval = 0.01;
            case 3
                corrPval = 0.005;
            case 4
                corrPval = 0.001;
        end
        
        
        switch statsIdx
            case 1
                conditionName = 'Main effect of Suppression';
            case 2
                conditionName = 'Main effect of Group';
            case 3
                conditionName = 'Interaction Supp x Group';
        end
        
        
        connectedComponentLabels = squeeze(trueBlobs(pValIdx,statsIdx,:,:));
        [entryCount, blobIdx]  = hist(connectedComponentLabels(:), unique(connectedComponentLabels(:)));
        
        massOfCluster = zeros(length(blobIdx),1);
        for blobIdxIdx = 1:length(blobIdx)
            currentMask = connectedComponentLabels==blobIdx(blobIdxIdx);
            massOfCluster(blobIdxIdx) = sum(sum(currentMask.*abs(squeeze(t_or_F(statsIdx,:,:)))));
        end
        massOfCluster = massOfCluster(2:end);
        
        criticalMOC = prctile(squeeze(icClusters(clusterIdx).stats.FWER(pValIdx,statsIdx,:)), 100-corrPval*100);
        %criticalMOC = prctile(squeeze(icClusters(clusterIdx).stats.gFWER(pValIdx,statsIdx,:)), 100-corrPval*100);
        
        survivedBlobIdx = find(massOfCluster>criticalMOC);
        if isempty(survivedBlobIdx)
            continue
        end
        
        significanceMask = zeros(size(currentMask));
        for survivedBlobIdxIdx = 1:length(survivedBlobIdx)
            currentSignificanceMask = connectedComponentLabels == survivedBlobIdx(survivedBlobIdxIdx);
            significanceMask = significanceMask + currentSignificanceMask;
        end
        
        % Obtain group Idx.
        uniqueGroups = unique(icClusters(clusterIdx).group);
        controlIdx = find(strcmp(icClusters(clusterIdx).group, 'Control'));
        patientIdx = find(strcmp(icClusters(clusterIdx).group, 'Patient'));
        
        % Obatin uinique subjects.
        uniqueCtNames = unique(icClusters(clusterIdx).subjName(controlIdx));
        uniquePtNames = unique(icClusters(clusterIdx).subjName(patientIdx));
        
        % Display the number of unique subjects and ICs.
        disp(sprintf('%d Ct (%d ICs), %d Pt (%d ICs)', ...
            length(uniqueCtNames), length(controlIdx), ...
            length(uniquePtNames), length(patientIdx)))
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Mean or Robust mean? %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if useRobustFlag == 0
            controlF = squeeze(icClusters(clusterIdx).meanErsp(controlIdx,1,freqWindowOfInt,timeWindowOfInt));
            controlS = squeeze(icClusters(clusterIdx).meanErsp(controlIdx,2,freqWindowOfInt,timeWindowOfInt));
            patientF = squeeze(icClusters(clusterIdx).meanErsp(patientIdx,1,freqWindowOfInt,timeWindowOfInt));
            patientS = squeeze(icClusters(clusterIdx).meanErsp(patientIdx,2,freqWindowOfInt,timeWindowOfInt));
        else
            controlF = squeeze(icClusters(clusterIdx).robustErsp(controlIdx,1,freqWindowOfInt,timeWindowOfInt));
            controlS = squeeze(icClusters(clusterIdx).robustErsp(controlIdx,2,freqWindowOfInt,timeWindowOfInt));
            patientF = squeeze(icClusters(clusterIdx).robustErsp(patientIdx,1,freqWindowOfInt,timeWindowOfInt));
            patientS = squeeze(icClusters(clusterIdx).robustErsp(patientIdx,2,freqWindowOfInt,timeWindowOfInt));
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Re-correct baseline. %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        epochTime = icClusters(clusterIdx).epochTime;
        baselineIdx = find(epochTime>= -5 & epochTime <= -4);
        controlF = permute(bsxfun(@minus, controlF, mean(controlF(:,:,baselineIdx),3)), [2 3 1]);
        controlS = permute(bsxfun(@minus, controlS, mean(controlS(:,:,baselineIdx),3)), [2 3 1]);
        patientF = permute(bsxfun(@minus, patientF, mean(patientF(:,:,baselineIdx),3)), [2 3 1]);
        patientS = permute(bsxfun(@minus, patientS, mean(patientS(:,:,baselineIdx),3)), [2 3 1]);
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Segment the mask. %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%
        controlF_mean = vec(squeeze(mean(bsxfun(@times, controlF, significanceMask),3)));
        controlS_mean = vec(squeeze(mean(bsxfun(@times, controlS, significanceMask),3)));
        patientF_mean = vec(squeeze(mean(bsxfun(@times, patientF, significanceMask),3)));
        patientS_mean = vec(squeeze(mean(bsxfun(@times, patientS, significanceMask),3)));
        nonzeroIdx = find(logical(significanceMask));
        forClustering = [controlF_mean(nonzeroIdx) controlS_mean(nonzeroIdx) patientF_mean(nonzeroIdx) patientS_mean(nonzeroIdx)];
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Optimize the cluster number. %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % If significant cluster should not be subdivided, use clusterIdx == clusterIdx.
        if clusterIdx == clusterIdx
            clear evalClustSil_km
            evalClustSil_km.OptimalK = 1;
            segmentedMask = significanceMask;
            
        else
            maxNumClusters = 5;
            kmeansClusters  = zeros(size(forClustering,1), maxNumClusters);
            numClusters = 1:maxNumClusters;
            for kclustIdx = 1:length(numClusters)
                kmeansClusters(:,kclustIdx) = kmeans(forClustering, kclustIdx, 'emptyaction', 'singleton', 'maxiter', 10000, 'replicate', 100);
            end
            
            % Use Matlab function evalclusters().
            evalClustSil_km   = evalclusters(forClustering, kmeansClusters, 'Silhouette');
            optimalClusterIdx = kmeansClusters(:,evalClustSil_km.OptimalK);
            originalMask1D = vec(zeros(size(significanceMask)));
            originalMask1D(nonzeroIdx) = optimalClusterIdx;
            segmentedMask = reshape(originalMask1D, size(significanceMask));
        end
        
        
        %%%%%%%%%%%%%%%%%%
        %%% Plot ERSP. %%%
        %%%%%%%%%%%%%%%%%%
        for segmentIdx = 1:evalClustSil_km.OptimalK
            
            currentSegmentMask = segmentedMask==segmentIdx;
            
            erspHandle = figure;
            for conditionIdx = 1:4
                switch conditionIdx
                    case 1
                        data = controlF;
                        titleString = 'Ct No Supp';
                    case 2
                        data = controlS;
                        titleString = 'Ct Supp';
                    case 3
                        data = patientF;
                        titleString = 'Pt No Supp';
                    case 4
                        data = patientS;
                        titleString = 'Pt Supp';
                end
                
                % Plot ERSP.
                subplot(2,2,conditionIdx);
                imagesc(epochTime(timeWindowOfInt), 1:size(data,1), mean(data,3), [-1.5 1.5]); colormap('jet');
                hold on;
                contour(epochTime(timeWindowOfInt), 1:size(data,1), currentSegmentMask, 'k'); axis xy
                
                % Set axes.
                wtFreqs = icClusters(clusterIdx).wtFreqs(freqWindowOfInt);
                wtFreqInterval = round(length(wtFreqs)/9);
                wtFreqIdx = 1:wtFreqInterval:length(wtFreqs);
                selectedFreqBins = wtFreqs(wtFreqIdx);
                selectedFreqBins(selectedFreqBins<10)  = round(selectedFreqBins(selectedFreqBins<10)*10)/10;
                selectedFreqBins(selectedFreqBins>=10) = round(selectedFreqBins(selectedFreqBins>=10));
                set(gca, 'ytick', wtFreqIdx, 'yticklabel', selectedFreqBins)
                line([0 0], ylim, 'color', [0 0 0], 'linestyle', ':')
                xlabel('Latency to tic/blink (s)')
                ylabel('Frequency (Hz)')
                title(titleString)
                colorbarHandle = colorbar;
                set(get(colorbarHandle, 'title'), 'string', 'dB')
                set(findall(gcf, '-property', 'fontsize'), 'fontsize', 20)
                
                %                     if conditionIdx == 6
                %                         currentPosition = get(gca, 'position');
                %                         colorbarHandle = colorbar;
                %                         set(get(colorbarHandle, 'title'), 'string', 'dB')
                %                         set(gca,'position', currentPosition)
                %                     end
            end
            set(gcf, 'position', [1 1 1858 929])
            print(erspHandle, sprintf('/data/projects/Sandy/tic/2021/p0200_erspWithRainCloudPlots_separateErsp/ERSP_Cls%d_Stats%d_pval%d', clusterIdx, statsIdx, pValIdx), '-dsvg', '-painters');
            set(gca, 'xticklabel', [], 'yticklabel', [])
            
            % Suptitle
            %                 suptitle(sprintf('%s (p < 0.05, wFWER), %d Ss, %d ICs\n%s (%.2f), %s (%.2f), %s (%.2f).',...
            %                     conditionName, length(unique(icClusters(clusterIdx).subjIdx)), length(icClusters(clusterIdx).icIdx),...
            %                     structuresFinal{1}, probabilitiesFinal(1),...
            %                     structuresFinal{2}, probabilitiesFinal(2),...
            %                     structuresFinal{3}, probabilitiesFinal(3)));
            
            % Extract mask values.
            controlF_mean = squeeze(mean(mean(bsxfun(@times, controlF, currentSegmentMask))));
            controlS_mean = squeeze(mean(mean(bsxfun(@times, controlS, currentSegmentMask))));
            patientF_mean = squeeze(mean(mean(bsxfun(@times, patientF, currentSegmentMask))));
            patientS_mean = squeeze(mean(mean(bsxfun(@times, patientS, currentSegmentMask))));
            
            %                 [H1,P1,CI1,STATS1] = ttest2(controlF_mean, controlV_mean);
            %                 [H2,P2,CI2,STATS2] = ttest2(controlF_mean, controlR_mean);
            %                 [H3,P3,CI3,STATS3] = ttest2(controlV_mean, controlR_mean);
            %                 [H4,P4,CI4,STATS4] = ttest2(patientF_mean, patientV_mean);
            %                 [H5,P5,CI5,STATS5] = ttest2(patientF_mean, patientR_mean);
            %                 [H6,P6,CI6,STATS6] = ttest2(patientV_mean, patientR_mean);
            %                 pValFdr = fdr([P1 P2 P3 P4 P5 P6]);
            
            % Perform t-test.
            [H1,P1,CI1,STATS1] = ttest2(controlF_mean, patientF_mean);
            [H2,P2,CI2,STATS2] = ttest2(controlS_mean, patientS_mean);
            [H3,P3,CI3,STATS3] = ttest2(controlF_mean, controlS_mean);
            [H4,P4,CI4,STATS4] = ttest2(patientF_mean, patientS_mean);
            pValFdr = fdr([P1 P2 P3 P4]);
            
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Perform regression analysis for Control. %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            currentCtrNames = icClusters(clusterIdx).subjName(controlIdx);
            currentCtrNamesShort = cellfun(@(x) x(8:11), currentCtrNames, 'uniformoutput', false);
            suppRateListCtrIdx = find(normalizedBlinticCounts(:,2)==0);
            suppRateListCtrNames = subjNameList(suppRateListCtrIdx);
            correspondingIdx = zeros(length(currentCtrNames),1);
            for subjIdx = 1:length(currentCtrNames)
                correspondingIdx(subjIdx) = find(contains(suppRateListCtrNames, currentCtrNamesShort(subjIdx)));
            end
            suppRateCtr = normalizedBlinticCounts(correspondingIdx,5);
            
            % Select unique control subjects.
            [C,IA,IC] = unique(correspondingIdx);
            ctrlSuppRateMatrix = zeros(length(C), 3); % suppRate, F, S.
            for uniqueIdx = 1:length(C)
                averagingIdx = find(correspondingIdx == C(uniqueIdx));
                ctrlSuppRateMatrix(uniqueIdx,:) = [unique(suppRateCtr(averagingIdx)) mean(controlF_mean(averagingIdx)) mean(controlS_mean(averagingIdx))];
            end
            
            % Identify control subject index.
            uniqueCtrlIdx   = unique(correspondingIdx);
            uniqueCtrlNames = normalizedBlinticCounts(uniqueCtrlIdx,1);
            
            
            
            regressionPlotHandle = figure;
            
            scatterHandle = subplot(2,3,1);
            scatter(ctrlSuppRateMatrix(:,1), ctrlSuppRateMatrix(:,2), 25, [0.45 0.45 0.67], 'filled'); xlim([0 8])
            %[B,BINT,R,RINT,STATS] = regress(ctrlSuppRateMatrix(:,2), [ones(length(C),1) ctrlSuppRateMatrix(:,1)]);
            [R1,P1,RLO1,RUP1] = corrcoef(ctrlSuppRateMatrix(:,2), ctrlSuppRateMatrix(:,1));
            % Bootstrap test.
            [bootstat,bootsam] = bootstrp(2000,@corr,ctrlSuppRateMatrix(:,2),ctrlSuppRateMatrix(:,1));
            subplotPosition = get(gca,'position');
            insetRelativePosition = [0.6 0.2 0.35 0.2]; % SouthEast. 
            deltax = subplotPosition(3)*insetRelativePosition(1);
            deltay = subplotPosition(4)*insetRelativePosition(2);
            insetPosition = [subplotPosition(1:2) 0 0] + [deltax deltay subplotPosition(3:4).*insetRelativePosition(3:4)];
            axes('Position',insetPosition)
            box on
            histogram(bootstat, 'edgecolor', 'none', 'facecolor', [0.45 0.45 0.67])
            xlim([-1 1]); ylim([0 400])
            xlabel('Bootstrp r')
            ylabel('Counts')
            title(scatterHandle, sprintf('Control NoSupp r=%.2f, p=%.3f', R1(2,1), P1(2,1)))
            xlabel(scatterHandle, 'Supp ratio')
            ylabel(scatterHandle, 'Power modulation (dB)')
            lsLineHandle = lsline(scatterHandle);
            set(lsLineHandle, 'linewidth', 1, 'color', [0.9 0.4 0.4])
            
            
            
            scatterHandle = subplot(2,3,2);
            scatter(ctrlSuppRateMatrix(:,1), ctrlSuppRateMatrix(:,3), 25, [0.45 0.45 0.67], 'filled'); xlim([0 8])
            %[B,BINT,R,RINT,STATS] = regress(ctrlSuppRateMatrix(:,3), [ones(length(C),1) ctrlSuppRateMatrix(:,1)]);
            [R2,P2,RLO2,RUP2] = corrcoef(ctrlSuppRateMatrix(:,3), ctrlSuppRateMatrix(:,1));
            % Bootstrap test.
            [bootstat,bootsam] = bootstrp(2000,@corr,ctrlSuppRateMatrix(:,3),ctrlSuppRateMatrix(:,1));
            subplotPosition = get(gca,'position');
            insetRelativePosition = [0.6 0.2 0.35 0.2]; % SouthEast. 
            deltax = subplotPosition(3)*insetRelativePosition(1);
            deltay = subplotPosition(4)*insetRelativePosition(2);
            insetPosition = [subplotPosition(1:2) 0 0] + [deltax deltay subplotPosition(3:4).*insetRelativePosition(3:4)];
            axes('Position',insetPosition)
            box on
            histogram(bootstat, 'edgecolor', 'none', 'facecolor', [0.45 0.45 0.67])
            xlim([-1 1]); ylim([0 400])
            xlabel('Bootstrp r')
            ylabel('Counts')
            title(scatterHandle, sprintf('Control Supp r=%.2f, p=%.3f', R2(2,1), P2(2,1)))
            xlabel(scatterHandle, 'Supp ratio')
            ylabel(scatterHandle, 'Power modulation (dB)')
            lsLineHandle = lsline(scatterHandle);
            set(lsLineHandle, 'linewidth', 1, 'color', [0.9 0.4 0.4])
            

            
            scatterHandle = subplot(2,3,3);
            scatter(ctrlSuppRateMatrix(:,1), ctrlSuppRateMatrix(:,3)-ctrlSuppRateMatrix(:,2), 25, [0.45 0.45 0.67], 'filled'); xlim([0 8])
            %[B,BINT,R,RINT,STATS] = regress(ctrlSuppRateMatrix(:,3)-ctrlSuppRateMatrix(:,2), [ones(length(C),1) ctrlSuppRateMatrix(:,1)]);
            [R3,P3,RLO3,RUP3] = corrcoef(ctrlSuppRateMatrix(:,3)-ctrlSuppRateMatrix(:,2), ctrlSuppRateMatrix(:,1));
            % Bootstrap test.
            [bootstat,bootsam] = bootstrp(2000,@corr,ctrlSuppRateMatrix(:,3)-ctrlSuppRateMatrix(:,2),ctrlSuppRateMatrix(:,1));
            subplotPosition = get(gca,'position');
            insetRelativePosition = [0.6 0.2 0.35 0.2]; % SouthEast. 
            deltax = subplotPosition(3)*insetRelativePosition(1);
            deltay = subplotPosition(4)*insetRelativePosition(2);
            insetPosition = [subplotPosition(1:2) 0 0] + [deltax deltay subplotPosition(3:4).*insetRelativePosition(3:4)];
            axes('Position',insetPosition)
            box on
            histogram(bootstat, 'edgecolor', 'none', 'facecolor', [0.45 0.45 0.67])
            xlim([-1 1]); ylim([0 400])
            xlabel('Bootstrp r')
            ylabel('Counts')
            title(scatterHandle, sprintf('Control NoSupp-Supp r=%.2f, p=%.3f', R3(2,1), P3(2,1)))
            xlabel(scatterHandle, 'Supp ratio')
            ylabel(scatterHandle, 'Power modulation (dB)')
            lsLineHandle = lsline(scatterHandle);
            set(lsLineHandle, 'linewidth', 1, 'color', [0.9 0.4 0.4])
            
            corrCoeffPvalMatrix(clusterIdx, 1) = P3(2,1);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Perform regression analysis for Patient. %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            currentPatientNames = icClusters(clusterIdx).subjName(patientIdx);
            currentPatientNamesShort = cellfun(@(x) x(8:11), currentPatientNames, 'uniformoutput', false);
            suppRateListPatientIdx = find(normalizedBlinticCounts(:,2)==1);
            suppRateListPatientNames = subjNameList(suppRateListPatientIdx);
            correspondingIdx = zeros(length(currentPatientNames),1);
            for subjIdx = 1:length(currentPatientNames)
                correspondingIdx(subjIdx) = find(contains(suppRateListPatientNames, currentPatientNamesShort(subjIdx)));
            end
            suppRatePatient = normalizedBlinticCounts(suppRateListPatientIdx(correspondingIdx),5);
            
            % Joe's suggestion. (06/02/2021 Makoto.)
            numBlinticsPerMin = normalizedBlinticCounts(suppRateListPatientIdx(correspondingIdx),3:4);

            % Select unique control subjects.
            [C,IA,IC] = unique(correspondingIdx);
            patientSuppRateMatrix = zeros(length(C), 5); % suppRate, F, S, numBlinticPerMinNoSupp, numBlinticPerMinSupp
            for uniqueIdx = 1:length(C)
                averagingIdx = find(correspondingIdx == C(uniqueIdx));
                patientSuppRateMatrix(uniqueIdx,:) = [unique(suppRatePatient(averagingIdx)) mean(patientF_mean(averagingIdx)) mean(patientS_mean(averagingIdx)) mean(numBlinticsPerMin(averagingIdx,:),1)];
            end
            
            % Identify control subject index.
            uniquePatientIdx   = unique(correspondingIdx);
            uniquePatientNames = normalizedBlinticCounts(uniquePatientIdx,1);
            
            scatterHandle = subplot(2,3,4);
            scatter(patientSuppRateMatrix(:,1), patientSuppRateMatrix(:,2), 25, [0.45 0.45 0.67], 'filled'); xlim([0 8])
            %[B,BINT,R,RINT,STATS] = regress(patientSuppRateMatrix(:,2), [ones(length(C),1) patientSuppRateMatrix(:,1)]);
            [R4,P4,RLO4,RUP4] = corrcoef(patientSuppRateMatrix(:,2), patientSuppRateMatrix(:,1));
            % Bootstrap test.
            [bootstat,bootsam] = bootstrp(2000,@corr,patientSuppRateMatrix(:,2),patientSuppRateMatrix(:,1));
            subplotPosition = get(gca,'position');
            insetRelativePosition = [0.6 0.2 0.35 0.2]; % SouthEast. 
            deltax = subplotPosition(3)*insetRelativePosition(1);
            deltay = subplotPosition(4)*insetRelativePosition(2);
            insetPosition = [subplotPosition(1:2) 0 0] + [deltax deltay subplotPosition(3:4).*insetRelativePosition(3:4)];
            axes('Position',insetPosition)
            box on
            histogram(bootstat, 'edgecolor', 'none', 'facecolor', [0.45 0.45 0.67])
            xlim([-1 1]); ylim([0 400])
            xlabel('Bootstrp r')
            ylabel('Counts')
            title(scatterHandle, sprintf('Patient NoSupp r=%.2f, p=%.3f', R4(2,1), P4(2,1)))
            xlabel(scatterHandle, 'Supp ratio')
            ylabel(scatterHandle, 'Power modulation (dB)')
            lsLineHandle = lsline(scatterHandle);
            set(lsLineHandle, 'linewidth', 1, 'color', [0.9 0.4 0.4])

            
            scatterHandle = subplot(2,3,5);
            scatter(patientSuppRateMatrix(:,1), patientSuppRateMatrix(:,3), 25, [0.45 0.45 0.67], 'filled'); xlim([0 8])
            %[B,BINT,R,RINT,STATS] = regress(patientSuppRateMatrix(:,3), [ones(length(C),1) patientSuppRateMatrix(:,1)]);
            [R5,P5,RLO5,RUP5] = corrcoef(patientSuppRateMatrix(:,3), patientSuppRateMatrix(:,1));
            % Bootstrap test.
            [bootstat,bootsam] = bootstrp(2000,@corr,patientSuppRateMatrix(:,3),patientSuppRateMatrix(:,1));
            subplotPosition = get(gca,'position');
            insetRelativePosition = [0.6 0.2 0.35 0.2]; % SouthEast. 
            deltax = subplotPosition(3)*insetRelativePosition(1);
            deltay = subplotPosition(4)*insetRelativePosition(2);
            insetPosition = [subplotPosition(1:2) 0 0] + [deltax deltay subplotPosition(3:4).*insetRelativePosition(3:4)];
            axes('Position',insetPosition)
            box on
            histogram(bootstat, 'edgecolor', 'none', 'facecolor', [0.45 0.45 0.67])
            xlim([-1 1]); ylim([0 400])
            xlabel('Bootstrp r')
            ylabel('Counts')
            title(scatterHandle, sprintf('Patient NoSupp r=%.2f, p=%.3f', R5(2,1), P5(2,1)))
            xlabel(scatterHandle, 'Supp ratio')
            ylabel(scatterHandle, 'Power modulation (dB)')
            lsLineHandle = lsline(scatterHandle);
            set(lsLineHandle, 'linewidth', 1, 'color', [0.9 0.4 0.4])
            
            
            
            scatterHandle = subplot(2,3,6);
            scatter(patientSuppRateMatrix(:,1), patientSuppRateMatrix(:,3)-patientSuppRateMatrix(:,2), 25, [0.45 0.45 0.67], 'filled'); xlim([0 8])
            %[B,BINT,R,RINT,STATS] = regress(patientSuppRateMatrix(:,3)-patientSuppRateMatrix(:,2), [ones(length(C),1) patientSuppRateMatrix(:,1)]);
            [R6,P6,RLO6,RUP6] = corrcoef(patientSuppRateMatrix(:,3)-patientSuppRateMatrix(:,2), patientSuppRateMatrix(:,1));
            % Bootstrap test.
            [bootstat,bootsam] = bootstrp(2000,@corr,patientSuppRateMatrix(:,3)-patientSuppRateMatrix(:,2), patientSuppRateMatrix(:,1));
            subplotPosition = get(gca,'position');
            insetRelativePosition = [0.6 0.2 0.35 0.2]; % SouthEast. 
            deltax = subplotPosition(3)*insetRelativePosition(1);
            deltay = subplotPosition(4)*insetRelativePosition(2);
            insetPosition = [subplotPosition(1:2) 0 0] + [deltax deltay subplotPosition(3:4).*insetRelativePosition(3:4)];
            axes('Position',insetPosition)
            box on
            histogram(bootstat, 'edgecolor', 'none', 'facecolor', [0.45 0.45 0.67])
            xlim([-1 1]); ylim([0 400])
            xlabel('Bootstrp r')
            ylabel('Counts')
            title(scatterHandle, sprintf('Patient NoSupp-Supp r=%.2f, p=%.3f', R6(2,1), P6(2,1)))
            xlabel(scatterHandle, 'Supp ratio')
            ylabel(scatterHandle, 'Power modulation (dB)')
            lsLineHandle = lsline(scatterHandle);
            set(lsLineHandle, 'linewidth', 1, 'color', [0.9 0.4 0.4])
            
            corrCoeffPvalMatrix(clusterIdx, 2) = P6(2,1);

            set(findall(regressionPlotHandle, '-property', 'fontsize'), 'fontsize', 16)
            set(regressionPlotHandle, 'position', [1 1 1986 1001]);
            print(regressionPlotHandle, sprintf('/data/projects/Sandy/tic/2021/p0200_erspWithRainCloudPlots_separateErsp/regression_Cls%d_Stats%d', clusterIdx, statsIdx), '-dsvg', '-painters');
            close(regressionPlotHandle)
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Joe's additional analysis suggested %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             additionalFigureHandle = figure;
%             
%             scatter(patientSuppRateMatrix(:,4), patientSuppRateMatrix(:,3)-patientSuppRateMatrix(:,2), 25, [0.45 0.45 0.67], 'filled'); xlim([0 8])
%             lsLineHandle = lsline;
%             set(lsLineHandle, 'linewidth', 1, 'color', [0.9 0.4 0.4])
%             [R7,P7,RLO7,RUP7] = corrcoef(patientSuppRateMatrix(:,4), patientSuppRateMatrix(:,3)-patientSuppRateMatrix(:,2));
%             title(sprintf('r=%.2f, p=%.4f', R7(2,1), P7(2,1)))
%             xlabel('Num Tics per Minute during Tic Freely')
%             ylabel('Delta ERSP')
%             
%             close(additionalFigureHandle)
            
            additionalFigureHandle = figure;
            
            scatter(patientSuppRateMatrix(:,4), patientSuppRateMatrix(:,1), 25, [0.45 0.45 0.67], 'filled'); xlim([0 8])
            lsLineHandle = lsline;
            set(lsLineHandle, 'linewidth', 1, 'color', [0.9 0.4 0.4])
            [R8,P8,RLO8,RUP8] = corrcoef(patientSuppRateMatrix(:,4), patientSuppRateMatrix(:,1));
            title(sprintf('r=%.2f, p=%.4f', R8(2,1), P8(2,1)))
            xlabel('Supp Ratio')
            ylabel('Tic severity')
            title(sprintf('SuppRatio vs. TicSeverity, r=%.2f, p=%.4f', R8(2,1), P8(2,1)))
            print(additionalFigureHandle, sprintf('/data/projects/Sandy/tic/2021/p0200_erspWithRainCloudPlots_separateErsp/ticSeverity_Cls%d_Stats%d', clusterIdx), '-djpeg95', '-r96');
            close(additionalFigureHandle)
            
            
            
            
            
            %%%%%%%%%%%%%%%%%%%%%%%
            %%% Raincloud plot. %%%
            %%%%%%%%%%%%%%%%%%%%%%%
            barHandle = figure;
            set(barHandle, 'position', [1133 1 722 596]);
            inputData = [{controlF_mean} {patientF_mean}
                         {controlS_mean} {patientS_mean}];
            [cb] = cbrewer('qual', 'Set3', 12, 'pchip');
            cl(1, :) = cb(1, :);
            cl(2, :) = cb(4, :);
            
            h = rm_raincloud(inputData, cl, 0, 'ks');
            
            set(h.s{1,1}, 'SizeData', 30, 'MarkerEdgeColor', [0.5 0.5 0.5])
            set(h.s{1,2}, 'SizeData', 30, 'MarkerEdgeColor', [0.5 0.5 0.5])
            set(h.s{2,1}, 'SizeData', 30, 'MarkerEdgeColor', [0.5 0.5 0.5])
            set(h.s{2,2}, 'SizeData', 30, 'MarkerEdgeColor', [0.5 0.5 0.5])
            
            set(h.m(1,1), 'SizeData', 100, 'MarkerEdgeColor', [0 0 0])
            set(h.m(1,2), 'SizeData', 100, 'MarkerEdgeColor', [0 0 0])
            set(h.m(2,1), 'SizeData', 100, 'MarkerEdgeColor', [0 0 0])
            set(h.m(2,2), 'SizeData', 100, 'MarkerEdgeColor', [0 0 0])
            
            legend([h.l(1,1) h.l(1,2)], {'Control' 'Patient'}, 'location', 'NorthWest')
            set(gca, 'yticklabel', {'Supp' 'No Supp'})
            xlabel('10*log10 Power (dB)')
            set(findall(gcf, '-property', 'fontsize'), 'fontsize', 16)
            
            allDataToPlot = [controlF_mean; patientF_mean; controlS_mean; patientS_mean];
            xlim3SDs = [mean(allDataToPlot)-3*std(allDataToPlot) mean(allDataToPlot)+3*std(allDataToPlot)];
            xlim(xlim3SDs)
            
            print(barHandle,  sprintf('/data/projects/Sandy/tic/2021/p0200_erspWithRainCloudPlots_separateErsp/RainCloud_Cls%d_Stats%d_pval%d', clusterIdx, statsIdx , pValIdx), '-dsvg', '-painters');
            
            % h.p{i,j} is the handle to the density plot from data{i,j}
            % h.s{i,j} is the handle to the 'raindrops' (individual datapoints) from data{i,j}
            % h.m(i,j) is the handle to the single, large dot that represents mean(data{i,j})
            % h.l(i,j) is the handle for the line connecting h.m(i,j) and h.m(i+1,j)
            
            close([erspHandle, barHandle])
            
            %             figure; imagesc(significanceMask)
            %             title(sprintf('Cluster %d Pval %d Stats %d', clusterIdx, pValIdx, statsIdx)); axis xy
            %             close
        end
    end
end
disp('Finished!')