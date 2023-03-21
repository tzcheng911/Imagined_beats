function [trialplv, swtimeplv,timeplv,compx] = Zoe_plv(eegData, srate, filtSpec, win)

% code modified from pn_eegPLV https://praneethnamburi.wordpress.com/2011/08/10/plv/
% Computes the Phase Locking Value (PLV) from time series and/or trials for an EEG dataset
% WITH normalization.

% Input parameters:
%   eegData is a 3D matrix numChannels x numTimePoints x numTrials
%   srate is the sampling rate of the EEG data
%   filtSpec is the filter specification to filter the EEG signal in the
%     desired frequency band of interest. It is a structure with two
%     fields, order and range. 
%       Range specifies the limits of the frequency
%     band, for example, put filtSpec.range = [35 45] for gamma band.
%       Specify the order of the FIR filter in filtSpec.order. A useful
%     rule of thumb can be to include about 4 to 5 cycles of the desired
%     signal. For example, filtSpec.order = 50 for eeg data sampled at
%     500 Hz corresponds to 100 ms and contains ~4 cycles of gamma band
%     (40 Hz).
%   win: how long is the sliding window (in second), the overlap is one
%   sample point 
%
% Output parameters:
%   trialplv is a 3D matrix - 
%     numTimePoints x numChannels x numChannels
%   timeplv is a 3D matrix (sliding time window) - 
%     numTimePoints x numChannels x numChannels

% Written by: 
% Zoe Cheng 07/07/2020

numChannels = size(eegData, 1);
numTrials = size(eegData, 3);
numTime = size(eegData, 2);
winsize = win*srate;

filtPts = fir1(filtSpec.order, 2/srate*filtSpec.range);
filteredData = filter(filtPts, 1, eegData, [], 2);

for channelCount = 1:numChannels
    filteredData_compx(channelCount, :, :) = hilbert(squeeze(filteredData(channelCount, :, :)));
    filteredData(channelCount, :, :) = angle(hilbert(squeeze(filteredData(channelCount, :, :))));
end

win_center = round(winsize/2)+1:numTime - round(winsize/2);
trialplv = zeros(numTime, numChannels, numChannels);
temptimeplv = zeros(length(win_center),numChannels,numChannels,numTrials);

swtimeplv = zeros(length(win_center), numChannels, numChannels);
tmpcompx = zeros(numTime,numTrials, numChannels, numChannels); % time x trial x ch1 x ch2

for channelCount = 1:numChannels-1
    channelData_compx = squeeze(filteredData_compx(channelCount, :, :));
    channelData = squeeze(filteredData(channelCount, :, :));
    for compareChannelCount = channelCount+1:numChannels
        compareChannelData_compx = squeeze(filteredData_compx(compareChannelCount, :, :));
        compareChannelData = squeeze(filteredData(compareChannelCount, :, :));
        phasediff = exp(1i*(channelData - compareChannelData));
        trialplv(:, channelCount, compareChannelCount)...
                = abs(sum(phasediff, 2))/numTrials;
        timeplv(:,channelCount, compareChannelCount)...
                = abs(sum(phasediff, 1))/numTime;
        tmpcompx(:,:,channelCount, compareChannelCount) = channelData_compx - compareChannelData_compx;
%         for ntrial = 1:numTrials
%             for nwin = win_center
%                 temptimeplv(nwin, channelCount, compareChannelCount,ntrial)...
%                      = abs(sum(phasediff(nwin-winsize/2:nwin+winsize/2,ntrial), 1))/winsize;
%                 if win == 0 
%                    temptimeplv(nwin, channelCount, compareChannelCount,ntrial)...
%                      = abs(sum(phasediff(nwin-winsize/2:nwin+winsize/2,ntrial), 1));
%                 end
%                     
%             end
%         end
    end
end
swtimeplv = squeeze(mean(temptimeplv,4));
compx = squeeze(mean(tmpcompx,2));
% meanbaseline = repmat(mean(trialplv(baseline*srate,:,:),1),1000,1);
% stdbaseline = repmat(std(trialplv(baseline*srate,:,:),1),1000,1);
% ntrialplv = (trialplv - meanbaseline)./stdbaseline;

return;