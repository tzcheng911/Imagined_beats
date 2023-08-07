% 01_preprocessMocap  load XDF and preprocess mocap general skeleton
%  assumes an xdf file with at least BioSemi and PhaseSpace streams
%
% JRI (jiversen@ucsd.edu)
% Zoe modified at for IMB 8/3/2021
clear 
close all
clc

addpath(genpath('/data/projects/zoe/ImaginedBeats/script/analysis/'))
eeglab
%% set the subject and run you want to analyze here. This could be automated
sub = {'s02','s03','s04','s05','s06','s07','s08','s09','s10','s11','s12','s13','s14','s15'...
    ,'s16','s17','s18','s19','s20','s21','s22','s23','s24','s26','s27'};
epoch_path = '/data/projects/zoe/ImaginedBeats/real_exp/preprocessed/epoch/5sphases/MoCap';

% remove subjects here 
rmsub = {'s03','s08','s11','s20','s24'};
% rmsub = {'s08','s11','s20'};

for i = 1:length(rmsub)
    rmsub_idx(i) = find(strcmp(sub,rmsub{i}));
end
sub(rmsub_idx) =[];

for nsub = 1:length(sub)
    xdfDir = strcat('/data/projects/zoe/ImaginedBeats/real_exp/',sub(nsub),'/raw_data/');
    cd(xdfDir{1})
    xdfFile = dir('*.xdf').name;
    evtagDir = '/data/projects/zoe/ImaginedBeats/real_exp/evtag_raw_data';
    cd(evtagDir)
    evtag=File = strcat(sub(nsub),'_evtag_2048.set');
    EEG = pop_loadset(evtagFile);
    % for interactive use, to save time (since it can take a long time to load an pdf and
    %   we do not want to reload it every time, 
    %   only loads the xdf if we don't have one already loaded
    % So, to load a new one, you must first do '>> clear S'
    % Note: if running this in a loop over subjects, make sure to disable this
    if ~exist('S','var') || isempty(S)
        disp('loading...')
        S=load_xdf(xdfFile);
    end

    listStreams(S) %helper to quickly show streams in an XDF

%% create a single structure, xdf, from the streams, so each stream can be conveniently accessed by name. e.g. xdf.BioSemi
% (This is cleaner than looking up the index into S for the EEG stream, the PhaseSpace stream, etc)
clear xdf
for i = 1:length(S)
    sname = S{i}.info.name;
    xdf.(sname) = S{i};
end

%% adjust all stream timestamps relative to EEG, make the first EEG timestamp=0
t0 = xdf.BioSemi.time_stamps(1);
streams = fieldnames(xdf);
for iS = 1:length(streams)
    xdf.(streams{iS}).time_stamps = xdf.(streams{iS}).time_stamps - t0;
end

%% optionally resample mocap timeseries to match EEG sampling rate
doResample = true;
if doResample
    %resample mocap
    times = xdf.BioSemi.time_stamps;
    xdf.PhaseSpace.time_series = resamplePhasespace(xdf.PhaseSpace, times);
    xdf.PhaseSpace.time_stamps = times;
    xdf.PhaseSpace.info.effective_srate = xdf.BioSemi.info.effective_srate;
    xdf.PhaseSpace.info.nominal_srate = xdf.BioSemi.info.nominal_srate;
end

%% PROCESS MOCAP
times = xdf.PhaseSpace.time_stamps;
dt = times(2)-times(1); %assumes even sampling

% reformat mocap coordinates: {xyz} x channel x time
markerCoords = double(xdf.PhaseSpace.time_series);
mts = markerCoords;
mts(end,:) = []; %remove extra row
quality = mts(4:4:end,:); %extract quality
mts(4:4:end,:) = [];
nMark = size(mts,1)/3;
markerCoords = reshape(mts, [3 nMark size(mts,2)]);
markerCoords = permute(markerCoords,[1 3 2]); %reorganize to {xyz} x marker# x time
%arrange X (width), Y (depth--away from control roomx), Z (height)
markerCoords = markerCoords ([1 3 2],:,:);

%mask out bad quality data with nan
for iM = 1:nMark
   q = quality(iM,:);
   bad = (q < 0);
   markerCoords(:,bad,iM) = nan;
end

%identify any bad markers--those visible less than half the time
markerVisibility = sum(quality>0,2)/length(quality);
badMarker = markerVisibility < 0.5;

%% apply median filter to remove isolated points
for k=1:3
  markerCoords(k,:,iM) = medfilt1(double(markerCoords(k,:,iM))', 11, 'includenan')';
end

%% optionally interpolate missing data (per marker), using simple linear interpolation
% do not interpolate across long gaps, which tends to be highly
% inaccurte
doInterpolate = false;
noInterpThresholdSeconds = 6; %parameter to define gaps we do not want to interpolate
noInterpThresholdPoints = round(noInterpThresholdSeconds/dt);
uninterpMarkerCoords = markerCoords;
if doInterpolate
  for iM = 1:nMark
    
    missingIdx = find(isnan(markerCoords(1,:,iM)));
    validIdx = setdiff(1:size(markerCoords,2), missingIdx);
    if isempty(validIdx)
      continue
    end
    
    % dont interpolate long gaps
    interpMaxGap = noInterpThresholdPoints;
    gapStart = find(diff([1 missingIdx])>1);
    gapStartIdx = missingIdx(gapStart);
    gapEndIdx = missingIdx(gapStart(2:end)-1);
    dontInterpolate = [];
    for iGap = 1:length(gapStartIdx)-1
      gapLen = gapEndIdx(iGap) - gapStartIdx(iGap);
      if gapLen > interpMaxGap
        dontInterpolate = [dontInterpolate gapStartIdx(iGap):gapEndIdx(iGap)]; %#ok<AGROW>
      end
    end
    % missingIdx = setdiff(missingIdx,dontInterpolate);
    
    for k=1:3
      interpPos = interp1(validIdx, squeeze(markerCoords(k,validIdx,iM)), missingIdx);
      markerCoords(k,missingIdx,iM) = interpPos;
    end
  end
  % use interpolated values for remainder of processing
  interpMarkerCoords = markerCoords;
else
  interpMarkerCoords = [];
end

%%
markerCoords = permute(markerCoords,[1 3 2]); % make the MoCap xyz x marker x time (same as EEG)


for ncord = 1:3 % xyz

    %% Save MoCap to be EEG.data(xyz, time, marker) for further analysis
EEG.data = squeeze(markerCoords(ncord,:,:));
EEG.etc.MoCap.markerVisibility = markerVisibility;
EEG.etc.MoCap.badMarker = badMarker;
EEG.etc.MoCap.time_stamps = xdf.PhaseSpace.time_stamps;
EEG.setname = strcat(sub(nsub),'_MoCap_evtag_2048');

% epoch
%% Epoch for PTB - 5 s
% Epoch BL, PB, IB, Tap phases in Duple and Triple conditions 
    EEG0 = EEG;
    parts = strcat(EEG.setname,'_cord',num2str(ncord))
    EEG_duple = pop_rmdat( EEG0, {'Duple'},[-2 26] ,0); % select the duple and triple events and do epoch on them, respectively
    EEG_triple = pop_rmdat( EEG0, {'Triple'},[-2 26] ,0);
    
    % Duple 
    EEG1 = pop_epoch( EEG_duple, {  'BL'  }, [0 5]);
    EEG1.setname = char(strcat(parts,'_duple_BL_e'));
%    EEG1 = pop_rmbase( EEG1, [-50   0]);
    filename = EEG1.setname;
    EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',epoch_path);

    EEG2 = pop_epoch( EEG_duple, {  'PB'  }, [0 5]);
    EEG2.setname = char(strcat(parts,'_duple_PB_e'));
%    EEG2 = pop_rmbase( EEG2, [-50   0]);
    filename = EEG2.setname;
    EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',epoch_path);
    
    EEG3 = pop_epoch( EEG_duple, {  'IB'  }, [0 5]);
    EEG3.setname = char(strcat(parts,'_duple_IB_e'));
%    EEG3 = pop_rmbase( EEG3, [-50   0]);
    filename = EEG3.setname;
    EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',epoch_path);

    EEG4 = pop_epoch( EEG_duple, {  'IB'  }, [5 10]);
    EEG4.setname = char(strcat(parts,'_duple_tap_e'));
%    EEG4 = pop_rmbase( EEG4, [5000   5050]);
    filename = EEG4.setname;
    EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',epoch_path);
    
    clear EEG0 EEG1 EEG2 EEG3 EEG4
% Triple
    EEG1 = pop_epoch( EEG_triple, {  'BL'  }, [0 5]);
    EEG1.setname = char(strcat(parts,'_triple_BL_e'));
%    EEG1 = pop_rmbase( EEG1, [-50   0]);
    filename = EEG1.setname;
    EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',epoch_path);

    EEG2 = pop_epoch( EEG_triple, {  'PB'  }, [0 5]);
    EEG2.setname = char(strcat(parts,'_triple_PB_e'));
%    EEG2 = pop_rmbase( EEG2, [-50   0]);
    filename = EEG2.setname;
    EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',epoch_path);

    EEG3 = pop_epoch( EEG_triple, {  'IB'  }, [0 5]);
    EEG3.setname = char(strcat(parts,'_triple_IB_e'));
%    EEG3 = pop_rmbase( EEG3, [-50   0]);
    filename = EEG3.setname;
    EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',epoch_path);

    EEG4 = pop_epoch( EEG_triple, {  'IB'  }, [5         10]);
    EEG4.setname = char(strcat(parts,'_triple_tap_e'));
%    EEG4 = pop_rmbase( EEG4, [5000   5050]);
    filename = EEG4.setname;
    EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',epoch_path);
    
    clear EEG1 EEG2 EEG3 EEG4 EEG_duple EEG_triple
end
end


%% lowpass filter (useful to do when extracting derivatives)

%% Power Spectrum: you could do a PSD on each x,y,z coordinate


%% Example: extract coordinate timeseries for head, head orientation, and hand
% Note: You'll need to substitute the marker numbers you used for different
% body parts--this is just an example

% angles are in radians, mean and differencing must use circular
% coordinates

%% for head, find mean of midpoint of diagonal markers (1,4 & 2,3)
%ctr1 = squeeze(mean(markerCoords(:,:,2:3),3));
%valid1 = all(quality(2:3,:)>0,1);
%ctr2 = squeeze(mean(markerCoords(:,:,[1 4]),3));
%valid2 = all(quality([1 4],:)>0,1);
%headCenter = nanmean(cat(3,ctr1,ctr2),3);
