%% Load the data
sound_path = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/experiment/June3';
[duple,fs] = audioread(fullfile(sound_path,'duple.wav'));
[triple,~] = audioread(fullfile(sound_path,'triple.wav'));

%% Calculate PLV between sound envelop and the EEG in listen and tap phases
% use the phantom sounds to calculate the PLV in tap phase


%% Calculate the SSEP in listen and tap phases
