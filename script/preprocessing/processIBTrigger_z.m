function events = processIBTrigger_z(t,sig, varargin)
% processAudioTrigger
%
% events = processGblnTrigger(t, data,'analysisrange',[start end],'burstduration',.040)
%
%   INPUTS
%   t     time axis for samples
%   sig   signal to extract triggers from
%
%   options
%       analysisrange       [start end] time range (s) to analyze for triggers
%       burstduration       length of longest trigger burts (s), default 0.050
%       threshold           triggering threshold, default 250
%       latency             latency offset of real event relative to trigger (s)
%       eventtype           one or list of types (see eventduration / eventamplitude)
%       eventduration       template duration for each event in eventtype list
%       eventfrequency      template frequency for each event in eventtype list
%       eventamplitude      template amplitude for each event in eventtype list
%
%   OUTPUTS
%   events          eeglab event object
%
% assumptions: each burst contains a series of pulses, defining a burst
%   frequency as well as an amplitude, both of which may code for event type
%   the first peak will be larger, and either of negative or positive
%   polarity indicating the stimulus polarity, but it's not used to
%   determine the event amplitude
%
% event = processGblnTrigger(EEG.times/1000,trigger,'threshold',1000, ...
%         'burstduration',.04,'latency',.04,'eventtype',{'standard','high','low'},'eventduration',[.01 .02 .03])
%
%   JRI 8/28/16, modified from processAudioTrigger


%% process options
opts.threshold = 250;
opts.burstduration = 0.050;
opts.IOI = [];
opts.plot = false;
opts.latency = 0;
opts.analysisrange = [-inf inf];
opts.excludeevents = [];
opts.baseline = [0 1];
opts.eventtype = 'unknown';
opts.eventduration = [];
opts.eventamplitude = [];
opts.eventfrequency = [];
if ~isempty(varargin)
    opts = parsepv(opts,varargin{:});
end

%warn about latency adjustment
if (opts.latency)
    fprintf(2,'NB: adjusting trigger times by %.2g ms\n',opts.latency*1000);
end

%% condition the signal, determine thresholds
triggerThreshold = opts.threshold;
signedSig = sig; %keep this so we can decide on polarity
%sig = abs(sig);
dt=mean(diff(t));


%% process threshold crossings, selecting those that are triggers
% before did abs and triggered, but that led to some cycles being missed
% instead, trigger twice, with both signs
% if 0
%   tzc = zerocrossing(t,abs(sig) - triggerThreshold, 1);
tzc_all = zerocrossing(t,abs(sig) - triggerThreshold);
  tzc = zerocrossing(t,abs(sig) - triggerThreshold,1);
  %tzc = zerocrossing(t,sig - triggerThreshold, 1);
% else
%   tzcp = zerocrossing(t,sig - triggerThreshold, 1);
%   tzcn = zerocrossing(t,-sig - triggerThreshold, 1);
%   tzc = sort([tzcp tzcn]);
% end

%find rising edge triggers
%tzc = zerocrossing(t,sig - triggerThreshold, 1);
%exclude peaks outside analysis range
tzc(tzc<opts.analysisrange(1)) = [];
tzc(tzc>opts.analysisrange(2)) = [];

%exclude 'double' triggers
% doubleThreshold = dt*2+eps;
% doubleIdx = find(diff(tzc) < doubleThreshold)+1; %within 0.5ms
% if ~isempty(doubleIdx)
%     fprintf(2,'%d doubles found\n',length(doubleIdx));
% end
% tzc(doubleIdx) = [];

%exclude stray events too far from others to possibly be cycles of sound
%burst
% orphanThreshold = 0.05; %50 ms--20 Hz, so assuming  tones are > than 20 Hz
% orphanIdx = find(diff(tzc) > orphanThreshold & diff([0 tzc(1:end-1)]) > orphanThreshold);
% if ~isempty(orphanIdx)
%     fprintf(2,'%d orphans found\n',length(orphanIdx));
% end
% tzc(orphanIdx) = [];

%find trigger burst starts
durTgt = opts.eventduration(:) * [0.9 1.1];  %+/- 10% around target value % Zoe 20200205 
t_length_all = diff(tzc_all);
t_length = t_length_all(1:2:end);
%t_length = find((t_length_all <= durTgt(1,2)) & (t_length_all >= durTgt(2,1)));
interval = diff([0 tzc]);
onsetIdx = find(interval > opts.burstduration);
onsets = tzc(onsetIdx);

%remove any onsest that don't conform with IOI (if specified)
% if ~isempty(opts.IOI)
%     badIdx = nan;
%     while ~isempty(badIdx)
%         interval = diff([0 onsets]);
%         badIdx = find(interval < (opts.IOI - opts.burstduration));
%         if ~isempty(badIdx)
%             onsets(badIdx(1)) = [];
%         end
%     end
% end

%build events array, by finding amplitude, sign and frequency of each burst
events = [];
for iE = 1:length(onsetIdx)
  %  show_progress(iE, length(onsetIdx), round(length(onsetIdx)/10), true)
    
    %extract triggers that are part of this burst
    s = onsetIdx(iE);
    if iE<length(onsetIdx)
        e=onsetIdx(iE+1)-1;
    else
        e=length(tzc);
    end
    thisTrigger = tzc(s:e);
    
    
    if length(thisTrigger)==1, thisTrigger = [thisTrigger thisTrigger+2*dt]; end %hack so single trigs will yield sensible answers

    %get amplitude and frequency of burst
    win = [thisTrigger(1)-5*dt thisTrigger(end)-5*dt]; %entire burst plus pad (NB 6/13/15, before second pad _added_ 10dt, which could cause overlap with next event!?)
    winIdx = findwin(win, t);
    tWin = t(winIdx);
    winsig = signedSig(winIdx);
    winsig = winsig + randn(size(winsig));
    [tPeak, aPeak] = jifindpeaks(tWin, winsig);
    ignorePeak = (abs(aPeak) < triggerThreshold);
    tPeak(ignorePeak) = [];
    aPeak(ignorePeak) = [];
    triggerAmplitude = mean(abs(aPeak(tPeak<thisTrigger(2))));
    %triggerAmplitude = mean(abs(aPeak(tPeak>thisTrigger(2))));
    %triggerFrequency = 1 / (2*mean(diff(tPeak)));
    triggerLength = t_length(iE); %Empirically, length is ~5% less than it should be--correct
    %triggerCycles = length(tPeak)/2;
    %triggerSign = sign(aPeak(1)); 

    adjustedTrigger = thisTrigger(1) + opts.latency;
    
    events(iE).type = opts.eventtype;
    events(iE).latency = jnearest(adjustedTrigger, t); %nearest sample
    events(iE).urevent = iE;
    %events(iE).time = adjustedTrigger;
    %events(iE).sign = triggerSign; %not used
    events(iE).amplitude = triggerAmplitude;
    %events(iE).frequency = 0; %not used
    events(iE).duration = triggerLength;
    %events(iE).cycles = triggerCycles; %not used
end %loop on triggers

%Event types are coded by amplitudes, but this may shift over time, so find
%   locally weighted zscores for each event

% if events have many cycles, amplitude is reliable measure, but if not,
% use sign (first peak amplitude)
% if mean([events.cycles])>=3
%     appearsOscillatory = true;
% else
%     disp('using first peak for zscoring--not enough cycles')
%     appearsOscillatory = false;
% end

% nE = length(events);
% for iE = 1:nE
%    idx = iE + [-7:7]; %event window
%    targetIdx = 8;
%    %keep window within data
%    if idx(1) < 1
%        offset = (1-idx(1));
%        idx = idx + offset;
%        targetIdx = targetIdx - offset;
%    elseif idx(end) > nE  
%        offset = (idx(end) - nE);
%        idx = idx - offset;
%        targetIdx = targetIdx + offset;
%    end
%    if appearsOscillatory
%        za = nanzscore([events(idx).amplitude]);
%    else
%        za = nanzscore(abs([events(idx).sign]));
%    end
%    events(iE).amplitudeLocalZ = za(targetIdx); %this is event iE
% end

%Event types may also be coded by frequency, so use that as an estimate as
%wellif we have enough cycles.
% if appearsOscillatory
%     zf = nanzscore([events.frequency]);
%     for iE = 1:nE
%         events(iE).frequencyZ = zf(iE);
%     end
% else
%     events(end).frequencyZ = nan;
% end

%% if specified multiple event types, assign
if iscell(opts.eventtype) && ( ~isempty(opts.eventduration) || ~isempty(opts.eventamplitude) || ~isempty(opts.eventfrequency) )
  %create amplitude/duration targets
  nType = length(opts.eventtype);
  durTgt = opts.eventduration(:) * [0.9 1.1];  %+/- 10% around target value 
  ampTgt = opts.eventamplitude(:) * [0.8 1.2]; %+/- 20% around target value
  freqTgt = opts.eventfrequency(:) * [0.85 1.05];% asymmetric window due to frequency estimation, which never overestimates frequency (see GBLN_oddball_mic_frequency_windows.pdf)
  if isempty(durTgt)
    durTgt = ones(nType,1) * [-inf inf];
  end
  if isempty(ampTgt)
    ampTgt = ones(nType,1) * [-inf inf];
  end
  if isempty(freqTgt)
    freqTgt = ones(nType,1) * [-inf inf];
  end
  
  for iE = 1:length(events)
    eventIdx = find(events(iE).duration>=(durTgt(:,1)) ...
      & events(iE).duration<=(durTgt(:,2)));
%      & events(iE).amplitude>=(ampTgt(:,1)) ...
%      & events(iE).amplitude<=(ampTgt(:,2)));
%      & events(iE).frequency>=(freqTgt(:,1)) ...
%      & events(iE).frequency<=(freqTgt(:,2)));
    
    if ~isempty(eventIdx) && length(eventIdx)==1
      events(iE).type = opts.eventtype{eventIdx};
    else
      events(iE).type = 'unknown';
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Aux Functions
function [zc, nearest] = zerocrossing(t,sig, filter)
% zerocrossing  Find zerocrossings of a time signal
%
%   zc = zerocrossing(t,sig, [filter])
%
%   filter is optional scalar. If +1, return only positive slope zero
%   crossings, if -1, only negative slope crossings. If unspecified,
%   returns all zerocrossings.
%
%   uses simple linear interpolation to estimate the actual time of zero
%   crossing, since it usually lies between two sample points
%
%   JRI 6/23/03 iversen@nsi.edu

if nargin==0
    eval(['help ' mfilename])
    return
end

sig = sig(:).'; %ensure row
t = t(:).';
dt = t(2)-t(1);
d = diff(sign(sig));
idx = find(abs(d) > 1); %index to first of two points spanning across zero

%simple linear interpolation
p1 = sig(idx); %p1 to p2 spans y=0
t1 = t(idx);
p2 = sig(idx+1);
dy = p2-p1;
u = -p1./dy;
zc = t1+u*dt;
slope = dy/dt;
%find index of nearest sample
p1d = zc-p1;
p2d = p2-zc;
p2close = sign(p1d-p2d); %+1 if p2 is closest, -1 if p1
%idx points to p1, so increase by one those cases when p2 is closer
nearest = idx + (p2close > 0);

%filter
if nargin > 2
    good_idx = (sign(slope) == sign(filter));
    zc = zc(good_idx);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [idx, d]=jnearest(point, collection)
% jnearest   find index into a collection of element nearest to a point
%
%       [idx, dist] = jnearest(point, collection)
%
%  INPUTS
%       point           1 x N, vector of points to individually lookup
%       collection      1 x M, vector to search  (must be sorted ascending)
%
%
%  OUTPUTS
%       idx             1 x N, nearest index into collection
%       distance	1 x N, distance to nearest point (optional)
%
%
% JRI 03/22/2006
% JRI 1/18/13 This was bogging down for very long time vectors. 
%   Use binary search (see filechachange closest_value.m, Benjamin Bernard)
%  For future, could consider using MEX binary search: http://www.mathworks.com/matlabcentral/fileexchange/30484-fast-binary-search
% 4/22/14 -- fix to reenable shortcut of calling with a vector of points to lookup in parallel.

if nargin==0
  eval(['help ' mfilename])
  return
end

from = 1;
to = length(collection);

nPoint = size(point,2);
idx = zeros(nPoint,1);
if nargout > 1, d = zeros(nPoint,1); end

if nPoint>1
  for iP = 1:nPoint
    if nargout > 1
      [idx(iP), d(iP)] = jnearest(point(iP),collection);
    else
      idx(iP) = jnearest(point(iP),collection);
    end
  end
  
else
  
  %binary search
  while to-from > 1
    mid = floor((from+to)/2);
    d = collection(mid) - point;
    if d == 0
      idx = mid;
      d = 0;
      return
    elseif d < 0
      from = mid;
    else
      to = mid;
    end
  end
  
  %tiebreaker
  if to-from==1 && (abs(collection(to) - point) < abs(collection(from) - point)),
    from=to;
  end
  
  idx = from;
  if nargout==2
    d = abs(collection(idx) - point);
  end
  return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [t_peak, a_peak, w_peak] = jifindpeaks(t,sig,sign)
% jifindpeaks  Find time of peaks of a signal (simplified version from
%jifindpeaks.m)
%
%   [t_peak, a_peak] = findpeaks(t,sig,sign)
%
%   finds peaks of signal sig. 
%       if sign unspecified, or 'all' finds both positive and negative peaks
%           sign can also be 'pos' or 'neg' to return only those peaks
%       sdthresh specifies an amplitude reject threshold at sdthresh*sd of signal 
%
%   method: finds interpolated zerocrossings of 1st derivative
%
%   t_peak = interpolated time of peak
%   a_peak = amplitude of peak
%
%   note--amplitude estimate suffers from being only linear--caveat emptor
%
%   JRI 6/23/03 iversen@nsi.edu


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% input parameters
if nargin >= 3
    if ischar(sign)
        switch lower(sign) %convert text to value of filter
            case 'all'
                filter = 0;
            case 'pos'
                filter = 1;
            case 'neg'
                filter = -1;
            otherwise
                error('invalid value for sign')
        end
    else
        filter = sign;
    end
end
if nargin < 4
    sdthresh = [];
end

%short circuit in case of degenerate signals
if length(sig) < 3
  t_peak = t(1);
  a_peak = sig(1);
  return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find peaks--interpolated zerocrossing of derivative
dt = t(2)-t(1);
tt = t(1:end-1)+dt/2; %points midway between samples
dy = diff(sig);
my = nanmean(sig);

if (nargin <3 || filter == 0)
    t_peak = zerocrossing2(tt,dy);
else %filter peaks
    t_peak = zerocrossing2(tt,dy, -filter); %pos peak is negative slope
end

%%new method for finding amplitude--find interpolated value using t_peak
a_peak = interp1(t,sig,t_peak, 'spline');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% special version of zerocrossing that fixes 'flattop' peaks for use with
% findpeaks
function [zc, nearest] = zerocrossing2(t,sig, filter)
% zerocrossing  Find zerocrossings of a time signal
%
%   zc = zerocrossing(t,sig, [filter])
%
%   filter is optional scalar. If +1, return only positive slope zero
%   crossings, if -1, only negative slope crossings. If unspecified,
%   returns all zerocrossings.
%
%   uses simple linear interpolation to estimate the actual time of zero
%   crossing, since it usually lies between two sample points
%
%   JRI 6/23/03 iversen@nsi.edu

fixflattop = true; %added 8/30/16 to fix findpeaks' missing of peaks due
    %to repeat sample, which leads to peaks of the form -1 0 1, which fail
    %the diff > 1 test below. Solution: for these (and these alone) fill in
    %the zero with the value to its right --> -1 1 1, meaning the peak will
    %be marked on the first point of the flat top.
if nargin==0
    eval(['help ' mfilename])
    return
end

sig = sig(:).'; %ensure row
t = t(:).';
dt = t(2)-t(1);
ss = sign(sig);
if fixflattop
    post = [ss(2:end) 0];
    pre = [0 ss(1:end-1)];
    toFix = find(ss==0 & (pre.*post)<0); %second test ensures this is a zero crossing
    ss(toFix) = ss(toFix+1);
end
d = diff(ss);
idx = find(abs(d) > 1); %index to first of two points spanning across zero


%simple linear interpolation
p1 = sig(idx); %p1 to p2 spans y=0
t1 = t(idx);
p2 = sig(idx+1);
dy = p2-p1;
u = -p1./dy;
zc = t1+u*dt;
slope = dy/dt;
%find index of nearest sample
p1d = zc-p1;
p2d = p2-zc;
p2close = sign(p1d-p2d); %+1 if p2 is closest, -1 if p1
%idx points to p1, so increase by one those cases when p2 is closer
nearest = idx + (p2close > 0);

%filter
if nargin > 2
    good_idx = (sign(slope) == sign(filter));
    zc = zc(good_idx);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [z,mu,sigma] = nanzscore(x,flag,dim)
%NANZSCORE Standardized z score -- JRI nan-proof version
%   Z = ZSCORE(X) returns a centered, scaled version of X, the same size as X.
%   For vector input X, Z is the vector of z-scores (X-MEAN(X)) ./ STD(X). For
%   matrix X, z-scores are computed using the mean and standard deviation
%   along each column of X.  For higher-dimensional arrays, z-scores are
%   computed using the mean and standard deviation along the first
%   non-singleton dimension.
%
%   The columns of Z have sample mean zero and sample standard deviation one
%   (unless a column of X is constant, in which case that column of Z is
%   constant at 0).
%
%   [Z,MU,SIGMA] = ZSCORE(X) also returns MEAN(X) in MU and STD(X) in SIGMA.
%
%   [...] = ZSCORE(X,1) normalizes X using STD(X,1), i.e., by computing the
%   standard deviation(s) using N rather than N-1, where N is the length of
%   the dimension along which ZSCORE works.  ZSCORE(X,0) is the same as
%   ZSCORE(X).
%
%   [...] = ZSCORE(X,FLAG,DIM) standardizes X by working along the dimension
%   DIM of X. Pass in FLAG==0 to use the default normalization by N-1, or 1
%   to use N.
%
%   See also MEAN, STD.

%   Copyright 1993-2006 The MathWorks, Inc. 


% [] is a special case for std and mean, just handle it out here.
if isequal(x,[]), z = []; return; end

if nargin < 2
    flag = 0;
end
if nargin < 3
    % Figure out which dimension to work along.
    dim = find(size(x) ~= 1, 1);
    if isempty(dim), dim = 1; end
end

% Compute X's mean and sd, and standardize it
mu = nanmean(x,dim);
sigma = nanstd(x,flag,dim);
sigma0 = sigma;
sigma0(sigma0==0) = 1;
z = bsxfun(@minus,x, mu);
z = bsxfun(@rdivide, z, sigma0);
