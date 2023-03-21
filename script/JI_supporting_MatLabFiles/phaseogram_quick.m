% This is a quick and dirty phaseogram program.
% Does NOT compute noise floor and white/greenify below-noise-floor points.
% Through line 18, enter filenames, and assorted desired parameters.

clc, clear all, close all
% Filnames and channel to analyze
FirstFilename = 'D:\Desktop\New folder\Ga_average.avg'; 
SecondFilename = 'D:\Desktop\New folder\Ba_average.avg'; 
Channel = 4; % numeric, not name!

% Some analysis and plot options
FreqRes = 4; % freq step (i.e., along resolution along y-axis, suggest 4)
ColorMax = pi; % colorbar range
FreqMax = 2000; % how high to plot freq?

% start/end time for analysis (and step size, suggest 1)
starttimesms = (-40:1:160)'; % in ms
endtimesms = (-20:1:180)'; % in ms

%% Engine to compute phaseogram based on info entered above

temp = openavg(FirstFilename);
x = genx(temp);
Fs = temp.rate;
First = temp.signal(:,Channel);
temp = openavg(SecondFilename);
Second = temp.signal(:,Channel); clear temp

FFTSize = round(Fs/FreqRes); 

% Make sliding time segments
[junk, TimeZero] = closestrc(x,0); clear junk x % point number of zero ms.

starttimes = round(starttimesms.*(Fs/1000)+TimeZero);
endtimes = round(endtimesms.*(Fs/1000)+TimeZero);

% pre-allocating... May not work in every case due to rounding.  
% If not working for given pair of files, simply comment out this line.  
% Will run fine without it; just slightly slower than with it.
PA = zeros(FFTSize/2+1,length(starttimes));

% Cross-phase engine
for seg=1:length(starttimes)
    Epoch = (starttimes(seg):endtimes(seg))';
    % baseline and ramp
    FirstStack = detrend(First(Epoch),'constant');
    SecondStack = detrend(Second(Epoch),'constant');
    FirstStack = FirstStack.*hann(length(FirstStack));
    SecondStack = SecondStack.*hann(length(SecondStack));
    % compute and extract phase angle 
    [CrossSpec,Yaxis] = cpsd(FirstStack,SecondStack,[],[],FFTSize,Fs);
    PA(:,seg) = unwrap(angle(CrossSpec));
end

% massage to avoid pi-jumps.
PA = mod(PA-pi, 2*pi)-pi;

%% color plots
% create xaxis
Xaxis = endtimesms - (endtimesms(1) - starttimesms(1))/2;
figure 
imagesc(Xaxis,Yaxis,PA) % x-axis bins, y-axis bins, length(y)*length(x) matrix
set(gca,'YDir','normal') % puts 0 at bottom
caxis([-ColorMax ColorMax]) % scales whole range of colors btw +/- ColorMax (regardless of contents of matrix)
colorbar('ylim', [-ColorMax ColorMax]) % adds color bar and sets its limits
xlabel('time (ms)'), ylabel ('freq (Hz)'), ylim([0 FreqMax])

% clear all the stuff except useful data in case user wants to save
clear Channel ColorMax CrossSpec Epoch FFTSize First FirstStack
clear FreqMax FreqRes Fs Second SecondStack TimeZero
clear endtimes endtimesms seg starttimes starttimesms
