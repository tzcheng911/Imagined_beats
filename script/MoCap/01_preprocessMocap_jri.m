% 01_preprocessMocap  load XDF and preprocess mocap general skeleton
%  assumes an xdf file with at least BioSemi and PhaseSpace streams
%
% JRI (jiversen@ucsd.edu)

addpath('/Volumes/TOSHIBA/Research/Imagined_beats/script/MoCap')
%% set the subject and run you want to analyze here. This could be automated
xdfDir = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/raw/s10/raw';
xdfFile = fullfile(xdfDir,'1494_ImaginedBeat_932.xdf');
subjRun = '824_F3';

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
% t0 = xdf.BioSemi.time_stamps(1); % no time_stamps in BioSemi stream
t0 = str2num(xdf.BioSemi.info.first_timestamp); 
streams = fieldnames(xdf);
for iS = 1:length(streams)
    xdf.(streams{iS}).time_stamps = xdf.(streams{iS}).time_stamps - t0;
end

%% optionally resample mocap timeseries to match EEG sampling rate
doResample = false;
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
  %% use interpolated values for remainder of processing
  interpMarkerCoords = markerCoords;
else
  interpMarkerCoords = [];
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
