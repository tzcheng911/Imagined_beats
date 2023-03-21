function resampledData = resamplePhasespace(S, times)
% resamplePhasespace  Resample mocap data to match e.g. EEG sampling rate
%
%   resampledData = resamplePhasespace(S, times)
%
%   S       load_xdf 'PhaseSpace' stream
%   times   desired sample times (typically EEG.times)
%
%   resampledData  {xyzq} by length(times) matrix
%                   

% method is corrected method from p01_importXDF
%   xyz are interpolated, q is a squarewave and is distorted by such
%   interpolation, so we use an expansion technique instead. We also recode
%   so good quality = 1, bad quality = -1

% JRI/MM

if ~strcmp(S.info.name,'PhaseSpace')
    error('Must use a PhaseSpace stream')
end

phaseSpaceData = S.time_series;
phaseSpaceTime = S.time_stamps;
resampledData = ( interp1(phaseSpaceTime, phaseSpaceData', times, 'pchip', nan) )';
%improve interp of quality field, conservatively--expanding. NB: now good = 1 bad = -1
quality = ...
    ~( (interp1(phaseSpaceTime, phaseSpaceData(4:4:end,:)', times, 'previous', nan) < 0)' | ...
    (interp1(phaseSpaceTime, phaseSpaceData(4:4:end,:)', times, 'next', nan) < 0)' );
quality = double(quality); %careful, even assigning # to a logical doesn't convert it
quality(quality==0) = -1;
resampledData(4:4:end,:) = quality;