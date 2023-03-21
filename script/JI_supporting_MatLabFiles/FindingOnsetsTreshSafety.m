function [onsets]=FindingOnsetsTreshSafety(thesignal,thresh,safetyzone,fs)
    %%% the signal is the continuous code channel
    %%% thresh is a threshold, it detects an onset whenever the signal goes
    %%% over threshold, but it doesn't count it as an onset if it happens
    %%% earlier than "safetyzone" after the last onset.
    %%% fs is the sampling rate, below is an example of how to use it
    threshdifer=thesignal>thresh;
    %%%%%%%%%% these lines create a safter zone of size saftetyzone (in order
    %%%%%%%%%% not to count doble mallet hits
    safetyzoneFs=safetyzone*fs; %% 200 ms
    timestampsaux=find(threshdifer>0);
    intertime=diff(timestampsaux);
    bigintertime=find(intertime>safetyzoneFs);
    timestamps=timestampsaux(bigintertime+1);
    onsets=timestamps;
    threshold=thresh;
end

% onsets=FindingOnsetsTreshSafety(EEG.data(10,:),8000,.1,2000);
% figure,plot(EEG.data(10,:));
% hold on,plot(onsets,8000,'r.')