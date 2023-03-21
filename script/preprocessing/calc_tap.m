function tap = calc_tap(t_down, target_times,adjust_tactus, tactus_multiplier, keepEarlyTaps)
% calc_tap  Calculate iti and async, after correcting for missing and double taps
%
%
%   tap = calc_tap(t_down, target_times,[adjust_tactus],[tactus_multiplier]);
%
%     INPUTS
%       t_down      	  Raw data of tap times for entire trial
%       target_times    if scalar=IOI, if vector = actual target times
%       adjust_tactus   optional. If true, will adjust tactus to multiple that
%                           fits best with ITI--useful for BAT test
%       tactus_multiplier   if specified, uses this to adjust the tactus.
%                       default 1
%       keepEarlyTaps   for BAT tapping, default false
%
%     OUTPUTS
%       tap.   %output structure with the following fields:
%
%       valid_t_down    Tap times with double taps removed
%       tactus_target_times  Target times (optionally adjusted to tactus of taps)
%       beat_isi        mean ISI
%       isi             ISI time series
%       t_isi           time axis
%       iti             ITIs during sequence (long missing-tap ITIs removed)
%       t_iti           time axis for ITI values (time of all taps following valid intervals)
%       iti_target_no   Index of t_iti in complete target vector
%       async           Asynchronies during sequence
%       t_async         time axis for async values
%       async_target_times  Targets used for calculating async (targets with no associated tap deleted)
%       async_target_no Index of async_target_times in complete target vector
%       rp, t_rp, rp_unwrapped relative phase
%       imiss           Index of original targets with missing taps
%       idbl            Index of double taps
%       pct_missed      percent of taps missed
%       adjust_tactus   if tactus was adjusted
%       tapTargRatio    the ratio used to adjust the tactus
%       autocorrAsync   autocorrelation of asynchrony
%       autocorrITI     autocorrelation of ITI
%       autocorrTau     lags (reordered as lag 0 to -25)
%
%   JRI 2004
%
%
%
%	|	|	|	|	|
%      o       o       o o               o 
%			dbl     miss

% old form (for backwards compatibility)
%   [valid_t_down, iti, t_iti, async, t_async, first_seq_tap, imiss, idbl, ...
%       even_iti, even_async, async_target_times] = calc_tap(t_down, target_times)

% CHANGES: 7/20/15 found rare  cases where async calculation was
% failing, so created a more robust version.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% handle inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0,
    eval(['help ' mfilename])
    return
end

DEBUG=false; %if true, will print information about missed taps and also present
              %diagnostic plots

%catch calls for old version
if nargin==1,
    error('use calc_tap_orig instead')
end

if nargin < 3,
    adjust_tactus = false;
end

if nargin < 4 || isempty(tactus_multiplier),
    tactus_multiplier = 1;
end

if nargin < 5,
  keepEarlyTaps = false;
end

%if scalar passed as target, generate target timeseries
if length(target_times)==1,
    IOI = target_times;
    max_time = max(t_down);
    target_times = 0:IOI:(max_time+IOI);
end

%make inputs row vectors
t_down = t_down(:)';
target_times = target_times(:)';


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Adjust tactus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%find ISI
beat_isi = mean(diff(target_times));

%find ITI (initial pass, filter out very short & long, to make tactus calc more robust)
keep_iti = [10 beat_isi*1.5]; %standard keep range
if adjust_tactus,
  keep_iti = [10 beat_isi*4.5]; %if we're adjusting tactus, keep a larger range as they may have tapped every 2, 3 or 4 beats
end
tmp_iti = diff(t_down);
ikeep = find(tmp_iti > min(keep_iti) & tmp_iti < max(keep_iti));
tmp_iti = tmp_iti(ikeep);
tap_iti = mean(tmp_iti);

%NEW situation (5/2008, w/ bat test): taps & targets may be at different
%metrical levels. If taps slower, delete every other target; If taps
%faster, interpolate targets
tapTargRatio = beat_isi/tap_iti;

if tactus_multiplier ~= 1,
  if DEBUG,
    disp('adjusting tactus.')
  end
  tapTargRatio = tapTargRatio * tactus_multiplier;
end

l2 = round(log2(tapTargRatio));

orig_target_times = target_times; %original, no tactus adjustment
   
%set to 0 will do nothing below
if ~adjust_tactus,
    l2 = 0;
end

%handle tapping at 2, 3, 4x & 1/2, 1/4 times stimulus
switch l2,
    case 0,
      %no change
        
    case 1, %more taps, add targets
    %interpolate--add targets midway between existing targets
    int_target_times = (target_times(1:end-1) + target_times(2:end) ) /2;
    target_times = sort([target_times int_target_times]);
    
    case 2,
        %3 or 4?
        posRat = [3 4];
        rat = posRat(jnearest(tapTargRatio,posRat));
        switch rat,
            
            case 3, %divide into three
                int_target_times = (2/3)*target_times(1:end-1) + (1/3)*target_times(2:end);
                int_target_times2 = (1/3)*target_times(1:end-1) + (2/3)*target_times(2:end);
                target_times = sort([target_times int_target_times int_target_times2]);
            case 4, %subdivide twice
                int_target_times = (target_times(1:end-1) + target_times(2:end) ) /2;
                target_times = sort([target_times int_target_times]);
                int_target_times = (target_times(1:end-1) + target_times(2:end) ) /2;
                target_times = sort([target_times int_target_times]);
    
        end
    
    case -1, %more targets
    %decimate targets, pick phase closest to taps
    %brute force-check each posibility
    iFirst = jnearest(t_down(1),target_times);
    p1 = target_times(iFirst:2:end);
    p2 = target_times(iFirst+1:2:end);
    len = min([length(p1) length(p2) length(t_down)]);
    d1 = sum( (t_down(1:len)-p1(1:len)).^2 );
    d2 = sum( (t_down(1:len)-p2(1:len)).^2 );
    if d1<d2,
        target_times = p1;
    else
        target_times = p2;
    end
    
    case -2,
        iFirst = jnearest(t_down(1),target_times);
        p=[];d=[];
        len = length(t_down);
        for k = 1:4,
            p{k} = target_times(iFirst+(k-1):4:end);
            len = min(len,length(p{k}));
        end
        for k = 1:4,
            d(k) = sum( (t_down(1:len)-p{k}(1:len)).^2 );
        end
        
        [junk, iMin] = min(d);
        target_times = p{iMin};        
    
    otherwise,
        dbstop if error
        error('taps more than 4x faster or 4x slower than targets')
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% filter out double/missing taps, find ITI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%sequential target number (ends up associated with async_target_times / t_async)
target_no = 1:length(target_times);

tactus_target_times = target_times; %rename to reflect that we may have adjusted to tactus

beat_isi = mean(diff(target_times)); %(2:end))); %why omitted first before 2/2/18?
%calculate target timeseries isi (added 2/2/18)
isi = diff(target_times);
t_isi = target_times(2:end);

%discard taps occurring before first target
if ~keepEarlyTaps,
  earlytaps =  t_down < (min(target_times) - 0.55*beat_isi) ;
  t_down(earlytaps) = [];
end

%data sometimes contain taps after last beat, remove these
latetaps =  t_down > (max(target_times) + beat_isi*0.55) ;
t_down(latetaps) = [];

%discard initial targets that did not lead to taps
earlytargets = target_times < min(t_down) - beat_isi*0.55;
target_times( earlytargets ) = [];
target_no( earlytargets ) = [];

%calculate ITI
iti = diff(t_down);
t_iti = t_down(2:end); %'time' of each interval (time of second tap in interval)

%correct double or missed taps
%define a range of target isi to keep as valid
%this is defined very strictly
keep_iti = beat_isi * [.55 1.5];
%keep_iti = [0.010 beat_isi * 1.5] % make doubles real doubles (i.e. in close succession)

idbl = find(iti < min(keep_iti));
%drop all extra taps
if ~isempty(idbl),
    tap_delete = idbl + 1; %delete second tap in group (New 2/4/09; before was first)
    tap_keep = setdiff(1:length(t_down), tap_delete);
    t_down(idbl) = [];
    iti = diff(t_down);
    t_iti = t_down(2:end); %'time' of each interval (time of second tap in interval)
end
valid_t_down = t_down;
imiss = find(iti > max(keep_iti));
ikeep = find(iti > min(keep_iti) & iti < max(keep_iti));

%figure out how many taps skipped (usually only 1 at a time);
n_missed = round( (iti(imiss)-beat_isi) / beat_isi);
total_n_missed = sum(n_missed);
pct_missed = 100 * total_n_missed / length(target_times);

if DEBUG && any(n_missed > 1),
    fprintf('* %.0f percent of beats missed\n', pct_missed);
end

%drop all iti values outside of range of plausibility
orig_iti = iti;
orig_t_iti = t_iti;
iti = iti(ikeep);
t_iti = t_iti(ikeep);

% new (2/4/09) rescale itis to close to tactus--includes taps following misses
rescaled_iti = orig_iti ./ (1+round( (orig_iti-beat_isi)/beat_isi ));
rescaled_t_iti = orig_t_iti;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% asynchrony
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0
  %delete target beats corresponding to the missing taps
  %   this is counted by tap/beat number
  async_target_times = target_times;
  if ~isempty(imiss),
    missingiti = [];
    deltarget = [];
    shift = cumsum([0 n_missed]);
    for i = 1:length(imiss),
      deltarget = [deltarget (imiss(i):imiss(i)+n_missed(i)-1) + shift(i)];
      missingiti = [missingiti (imiss(i):imiss(i)+n_missed(i)) + shift(i)];
    end
    deltarget = deltarget + 1;  %since we start iti from target 2
    deltarget( deltarget > length(target_times) ) = [];
    async_target_times(deltarget) = [];
    target_no(deltarget) = []; %index into ORIGINAL targets
    %this business only for finding evenly sampled timeseries (no longer
    %used)
    %itino = 2:length(iti)+sum(n_missed+1)+1; %idealized number of itis
    %itino(missingiti) = [];
  end
  
  %calculate asynchronies (until we've exhausted taps or targets)
  n_min = min(length(async_target_times), length(valid_t_down));
  async = valid_t_down(1:n_min) - async_target_times(1:n_min);
  t_async = async_target_times(1:n_min);
  async_target_no = target_no(1:n_min);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% asynchrony V2 (7/20/15)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The above seems to fail in some cases where there is a missed tap that
% yet doesn't exceed the threshold--e.g. subject: 'P0179', 850ms metronome
% (2012). First iti is just under 1.5, but is clearly a missed tap. Could
%   either tune the threshold, or instead find missed targets as those
%   without a tap within half an IBI from it. Alternatively, find the
%   nearest target to each tap.

async_target_times = target_times;
window = beat_isi * 0.5;
deltarget = [];
for iT = 1:length(target_times),
  nTapsNearby = sum(abs(valid_t_down - target_times(iT)) < window);
  if nTapsNearby == 0,
    deltarget = [deltarget iT];
  end
end
async_target_times(deltarget) = [];
target_no(deltarget) = []; %index into ORIGINAL targets
  
n_min = min(length(async_target_times), length(valid_t_down));
async = valid_t_down(1:n_min) - async_target_times(1:n_min);
t_async = async_target_times(1:n_min);
async_target_no = target_no(1:n_min);

%create timeseries with 'filled in' missing taps. There is no one way to do this,
% two obvious ways are to place tap half way between adjacent taps (this is more
% accurate in cases of drift); another would be to add tap with mean asynchrony.
% we'll recreate an async timeseries and calculate iti from it
%   every missed tap adds two itis to the iti time series
%fillMethod = 'interp_async';
fillMethod = 'mean_async';
mean_async = mean(async);
filled_async = async;
filled_async_target_no = async_target_no;
%nb imiss is missed ITI, so to convert to missed TAP, add one!!
imiss_tap = imiss + 1;
if ~isempty(imiss_tap),
    for ii = length(imiss_tap):-1:1, %work backwards, adding n_missed mean values before each imiss (which was deleted before)
      if imiss_tap(ii)>length(filled_async),
        continue
      end
      %two methods: mean async, mean of neighhboring asyncs
      % this yields different ITIs
      switch fillMethod,
        case 'mean_async',
          fill = mean_async*ones(1,n_missed(ii));
          %linear interpolation of asyncs from pre to post
          % this yields runs of identical ITIs
        case 'interp_async',
          fill = linspace(async(imiss_tap(ii)-1),async(imiss_tap(ii)),n_missed(ii)+2);
          fill = fill(2:end-1);
        otherwise
          error('unknown fillMethod')      
      end        
      filled_async = [filled_async(1:imiss_tap(ii)-1) fill filled_async(imiss_tap(ii):end) ];
      target_no_fill = linspace(filled_async_target_no(imiss_tap(ii)-1),filled_async_target_no(imiss_tap(ii)),n_missed(ii)+2);
      target_no_fill = target_no_fill(2:end-1);
      filled_async_target_no = ...
        [filled_async_target_no(1:imiss_tap(ii)-1) ...
        target_no_fill ...
        filled_async_target_no(imiss_tap(ii):end) ];
    end
end
%now re-calc ITI
filled_iti = beat_isi + -1*filled_async(1:end-1) + filled_async(2:end);
filled_valid_t_down = valid_t_down(1) + cumsum([0 filled_iti]);
fill_method = fillMethod;

% add back beat number calculations
%generate evenly sampled timeseries for async and iti--fill in missing beat values with mean
% NB: This needs fixing
% even_iti = iti;
% even_async = async;
% even_beatNo = 2:length(iti)+sum(n_missed+1)+1;
% if ~isempty(imiss),
%     mean_iti = mean(iti);
%     mean_async = mean(async);
%     
%     for ii = length(imiss):-1:1, %work backwards, adding n_missed mean values before each imiss (which was deleted before)
%       %if only one missed, bridge it with a mean value, >1 add nans
%       if n_missed(ii)<=1,
%         even_async = [even_async(1:imiss(ii)-1) mean_async*ones(1,n_missed(ii)) even_async(imiss(ii):end) ];
%         even_iti = [even_iti(1:imiss(ii)-1) mean_iti*ones(1,n_missed(ii)+1) even_iti(imiss(ii):end) ];
%       else
%         even_async = [even_async(1:imiss(ii)-1) nan(1,n_missed(ii)) even_async(imiss(ii):end) ];
%         even_iti = [even_iti(1:imiss(ii)-1) nan(1,n_missed(ii)+1) even_iti(imiss(ii):end) ];
%       end
%     end
% end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% relative phase
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[rp, t_rp, rp_unwrapped] = relphase([],tactus_target_times,valid_t_down);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% debug plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%debug--plot data for missing taps to check algorithm
if DEBUG && ~isempty(imiss),
    ff = gcf;
    figure
    %jisubplot(2,1,1)
    plot(target_times,ones(size(target_times)),'ro')
    hold on
    plot(async_target_times,ones(size(async_target_times)),'go')
    plot(t_down,ones(size(t_down)),'rx')
    stem(orig_t_iti,orig_iti./beat_isi,'b-^')
    stem(t_iti,iti./beat_isi,'g-^')
    gridy(keep_iti/beat_isi)
    
%     nextplot
%     plot(target_times,even_async,'b-+',t_async,async,'r--+')
%     
%     nextplot
%     plot(2:max(itino),even_iti,'b-+',itino,iti,'r--+')
    
    dbstop if error
    pause
    close
    figure(ff)
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% package results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tap = packstruct({'valid_t_down', 'tactus_target_times', 'beat_isi','isi','t_isi',...
  'iti', 't_iti','rescaled_iti','rescaled_t_iti', ...
  'async', 't_async','async_target_times','async_target_no',...
  'rp','t_rp', 'rp_unwrapped',...
  'imiss', 'idbl','total_n_missed',...
  'pct_missed','adjust_tactus', 'tactus_multiplier','tapTargRatio'});

%add filled version
tap.filled.method = fill_method;
tap.filled.valid_t_down = filled_valid_t_down;
tap.filled.iti = filled_iti;
tap.filled.t_iti = filled_valid_t_down(2:end);
tap.filled.async = filled_async;
tap.filled.async_target_no = filled_async_target_no;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% autocorrelation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%analyze autocorr: ASYNC
taps = 25; %number of lags to keep
[ac,tau] = xcorr(tap.async-nanmean(tap.async));
im1 = find(tau==-1);
i0 = im1+1;
im = max(1,im1-taps+1);
autocorrAsync = nan(taps+1,1);
autocorrAsync(1:(i0-im+1)) = ac(i0:-1:im); %include 0 to lag -taps

%analyze autocorr: ITI
[ac,tau] = xcorr(tap.iti-nanmean(tap.iti));
im1 = find(tau==-1);
i0 = im1+1;
im = max(1,im1-taps+1);
autocorrITI = nan(taps+1,1);
autocorrITI(1:(i0-im+1)) = ac(i0:-1:im); %include 0 to lag -taps
autocorrLag1ITI = ac(im1); %convenience, backward compat
autocorrLag0ITI = ac(im1+1);

autocorrTau = tau(i0:-1:im);

%add to output struct
tap.autocorrAsync = autocorrAsync;
tap.autocorrITI = autocorrITI;
tap.autocorrTau = autocorrTau;

%% filled autocorrelation
%analyze autocorr: ASYNC
taps = 25; %number of lags to keep
[ac,tau] = xcorr(tap.filled.async-nanmean(tap.filled.async));
im1 = find(tau==-1);
i0 = im1+1;
im = max(1,im1-taps+1);
autocorrAsync = nan(taps+1,1);
autocorrAsync(1:(i0-im+1)) = ac(i0:-1:im); %include 0 to lag -taps

%analyze autocorr: ITI
[ac,tau] = xcorr(tap.filled.iti-nanmean(tap.filled.iti));
im1 = find(tau==-1);
i0 = im1+1;
im = max(1,im1-taps+1);
autocorrITI = nan(taps+1,1);
autocorrITI(1:(i0-im+1)) = ac(i0:-1:im); %include 0 to lag -taps

tap.filled.autocorrAsync = autocorrAsync;
tap.filled.autocorrITI = autocorrITI;
tap.filled.autocorrTau = tau(i0:-1:im);
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
function s = packstruct(varargin)
% packstruct packs a set of variables into a structure
%
%   s = packstruct(varnames)
%
%   s = packstrucct(s,varnames)
%
%       varnames    cell array of variables, varnames become field names
%       s           if specified, must be a struct to append fields to
%
%   JRI 3/13/06

if nargin==0,
    eval(['help ' mfilename])
    return
end

if isstruct(varargin{1}),
  s = varargin{1};
  varnames = varargin{2};
else
  s=[];
  varnames = varargin{1};
end
for i = 1:length(varnames),
    s.(varnames{i}) = evalin('caller',varnames{i});
end
     