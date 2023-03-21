function [time blocks CPSD_FILE1vFILE2 F]= phasetrack(file1, file2,  block, step, startAnalysis, channel)
%
% phasetrack performs cross-spectrum comparisons between two files. Analysis is performed in a running-window fashion.
% Input args: 
% file1:  filename of first file, must be in Neuroscan *.avg format
% file2:  filename of second file, must be in Neuroscan *.avg format
% block:  size in ms of each window to analyze. (20, 30 or 40 ms are typical values)
% step:  how many ms separate consecutive blocks.  (1 ms is a typical value)
% startAnalysis:   when (in ms) the first block starts
% channel:  A numerical value indicating which column of the avg file to process.  For 1-channel data, channel = 1; 
%Output args:
%time: a vector corresponding to the midpoint of each block that was analyzed  
% F:  a vector corresponding to each frequency at which the cross-spectral comparison was made
% CPSD_FILE1vFILE2:  Cross-power spectral density function between File1 and File2 (time x frequency matrix).

% Written by Erika Skoe, eeskoe@northwestern.edu, from the Auditory Neuroscience Laboratory at Northwestern.edu
%
% This  is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation. This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
% See the GNU General Public License for more details <http://www.gnu.org/licenses/>/
%
% NOTE:  The code was originally written for compariong responses collected in quiet (q) and noisy (n) conditions (files 1 and 2, respectively). This nomenclature has been retained.
%
% Now the code begins:
% ----------------------- OPEN FILES -------------------------------------
%Open average file
[qf]= openavg(file1);
%Define time axis
timeaxis = linspace(qf.xmin, qf.xmax, qf.pnts)';
% extract signal
qSIGNAL = qf.signal(:,channel);
% get sampling rate
fs = qf.rate;
% repeat for file 2.
[nf]= openavg(file2);
nSIGNAL = nf.signal(:,channel);


%  ------------------ ANALYZE of RESPONSE CHUNKS-----------------------
j = startAnalysis; % each time through loop j increases by step size;

chunks = 5000;    % an arbitrary maximum number of blocks that the program will create.

for k = 1:chunks;   %the program knows to stop once file.xmax is exceeded

    % variables created:
    ramptime = (block/1000);   % ramp the entire chunk
    start = j;
    stop = j+block;

    if stop>(qf.xmax)  % if stop exceeds the maximum ms time then abort and break out from loop
        k=k-1;
        j=j-step;
        break;
    else
        qsignal = detrend(qSIGNAL(ms2row(qf, start):ms2row(qf, stop)), 'constant');
        
        nsignal = detrend(nSIGNAL(ms2row(nf, start):ms2row(nf, stop)), 'constant'); % de-mean to zero
    end

    midpoint(k) = mean(ms2row(qf, start):ms2row(qf,stop));  %calculates the time corresponding to the midpoint of the chunk

    % generate ramp
    ramp = hann(size(qf,1));
    % ramp and de-mean
    qsignal = detrend(qsignal.*ramp, 'constant');
    nsignal = detrend(nsignal.*ramp, 'constant');

    [CPSD_FILE1vFILE2(:,k) F] = cpsd(qsignal,nsignal, [],[],5000,fs);
    j = j+step;  % loop through next time chunk

end
time = timeaxis(round(midpoint));
blocks = k;

