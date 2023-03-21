function EEG = extractActions(EEG, varargin)
%
% Author: Rishikesh Ingale
%
% This function takes in EEG data from a single channel (specifically a 
% pressure sensor) and extracts each instance of action and classifies it
% as a tap or press and adds it to the event vector passed in.
%
% Terminal Command: extractActions(EEG, pp, dtp, mpd)
%
% @param EEG the EEG data to be modified
% @param pp the minimum prominence of presses
% @param dtp the minimum prominence of taps per ms
% @param mpd the minimum distance between peaks (time * sampling rate)
% @return altered EEG vector with new events
%

% the below values were obtained using visual inspection of typical peak
% heights by adjusting according to minimum values that qualified certain
% peaks to be considered events rather than other artifacts

% assumes processNewMM has been run on data

switch nargin
    case 1
        pressProminence = (5 * 10^4);
        dTapProminence = (5 * 10^3);
        minPeakDistance = 0.1 * (EEG.srate); % time * sampling rate
    case 2
        pressProminence = varargin{1};
        dTapProminence = (5 *10^3);
        minPeakDistance = 0.1 * (EEG.srate); % time * sampling rate
    case 3
        pressProminence = varargin{1};
        dTapProminence = varargin{2};
        minPeakDistance = 0.1 * (EEG.srate); % time * sampling rate
    case 4
        pressProminence = varargin{1};
        dTapProminence = varargin{2};
        minPeakDistance = varargin{3}; % time * sampling rate
    otherwise
        error('Invalid Arguments. Function Call: extractActions(EEG, pressProminence, tapProminence, minPeakDistance')
end

Y = double(EEG.etc.press); % convert to double needed by findpeaks
dY = diff(Y);
EEG.event = renameEvents(EEG.event);
if contains(EEG.event(1).type, 'Picture')
    firstPictureMissing = false;
else
    firstPictureMissing = true;
end
event = EEG.event;

taps = zeros(1, 0);
presses = zeros(1, 0);

trialStarts = zeros(1, 0);
trialEnds = zeros(1, 0);
pictures = zeros(1, 0);
for i = 1:length(event)
    if(contains(event(i).type, 'introtone') && contains(event(i + 1).type, 'beat'))
        trialStarts = [trialStarts floor(event(i).latency)];
    end
    if(contains(event(i).type, 'endtone'))
        trialEnds = [trialEnds floor(event(i).latency)];
    end
    if(contains(event(i).type, 'Picture') && (contains(event(i).type, 'code=') || contains(event(i).type, 'trial:')))
        pictures = [pictures i];
    end
end % store trial start and end times

% go through trials, locate events, and assign attributes
for i = 1:length(trialStarts)
    if i == 1 && firstPictureMissing
        % do center-weighted smoothing on data to resolve clipping 
        trialData = smooth(150, Y(trialStarts(i):trialEnds(i) + 100));
        
        [pressPks, pressLocs] = findpeaks(trialData, 'MinPeakProminence', pressProminence, 'MinPeakDistance', minPeakDistance);
        for p = 1:length(pressPks)
            event(end + 1).latency = pressLocs(p) + trialStarts(i) - 1;
            presses = [presses event(end).latency];
            event(end).duration = 0;
            event(end).peak = pressPks(p); % maximum = original
            event(end).urevent = length(event);
            event(end).rhythm = '4/4 time';
            event(end).hand = 'Right';
            event(end).finger = 'Index';
            event(end).pictureCode = '1112';
            event(end).type = ['press ' event(end).hand];
                                          % this assumes the event variable 
                                          % passed in is not empty.
        end % loop over peaks of current trial
        continue
    end
    
    pictureCode = char(extractAfter(event(pictures(i)).type, 'code=')); % newer versions of matlab return 'string' objects 
    if isempty(pictureCode)
        pictureCode = char(extractAfter(event(pictures(i)).type, 'trial:'));
    end
    if pictureCode(4) == '2'
        % do center-weighted smoothing on data to resolve clipping 
        trialData = smooth(150, Y(trialStarts(i):trialEnds(i) + 100));
        
        [pressPks, pressLocs] = findpeaks(trialData, 'MinPeakProminence', pressProminence, 'MinPeakDistance', minPeakDistance);
        
        % Decode picture attributes: rhythm, hand, and finger
        %rhythmStrings = {'4/4 time','3/3/2 time'};
        %rhythm = rhythmStrings{str2double(pictureCode(1))};
        
        
        if(pictureCode(1) == '1')
            rhythm = '4/4 time';
        else
            rhythm = '3/3/2 time';
        end
        if(pictureCode(2) == '1')
            hand = 'Right';
        else
            hand = 'Left';
        end
        if(pictureCode(3) == '1')
            finger = 'Index';
        elseif(pictureCode(3) == '2')
            finger = 'Little';
        else
            finger = 'Thumb';
        end
        
        for p = 1:length(pressPks)
            event(end + 1).latency = pressLocs(p) + trialStarts(i) - 1;
            presses = [presses event(end).latency];
            event(end).duration = 0;
            event(end).peak = pressPks(p); % maximum = original
            event(end).urevent = length(event);
            event(end).rhythm = rhythm;
            event(end).hand = hand;
            event(end).finger = finger;
            event(end).pictureCode = pictureCode;
            event(end).type = ['press ' event(end).hand];
        end % loop over peaks of current trial
    else
        [tapStrts, tapLocs] = findpeaks(dY(trialStarts(i):trialEnds(i) + 100), 'MinPeakProminence', dTapProminence, 'MinPeakDistance', minPeakDistance);
        
         % Decode picture attributes: rhythm, hand, and finger
        if(pictureCode(1) == '1')
            rhythm = '4/4 time';
        else
            rhythm = '3/3/2 time';
        end
        if(pictureCode(2) == '1')
            hand = 'Right';
        else
            hand = 'Left';
        end
        if(pictureCode(3) == '1')
            finger = 'Index';
        elseif(pictureCode(3) == '2')
            finger = 'Little';
        else
            finger = 'Thumb';
        end
        
        for t = 1:length(tapStrts)
            d = tapLocs(t) + trialStarts(i) - 1;
            while dY(d) >= 0
                d = d + 1;
            end
            
            event(end + 1).latency = d;
            taps = [taps event(end).latency];
            event(end).duration = 0;
            event(end).peak = Y(event(end).latency);
            event(end).urevent = length(event);
            event(end).rhythm = rhythm;
            event(end).hand = hand;
            event(end).finger = finger;
            event(end).pictureCode = pictureCode;
            event(end).type = ['tap ' event(end).hand];
        end % loop over peaks of current trial
    end
end % store press/tap magnitudes and occurrences by trial

EEG.event = event;
figure
plot(Y);
gridx(presses, 'g')
gridx(taps, 'r')