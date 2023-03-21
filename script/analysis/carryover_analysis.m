clear 
close all
clc
%% Epoch duple and triple 
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s02/icapMA';
outpath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/test_SSEP/carryover';
EEG0 = pop_loadset('filename','s02_IMB_cleaned_binica_dipfit_icap_noalpha_MA.set','filepath','/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s02/icapMA');
EEG = pop_epoch( EEG0, {  'Duple' 'Triple' }, [-1  15], 'newname', 's02_IMB_cleaned_binica_dipfit_icapnoalpha_MA', 'epochinfo', 'yes');
%%
EEG.setname='s02_IMB_cleaned_binica_dipfit_icapnoalpha_MA';
load('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s02/raw/s021test')

% Load the index from mat file 
ind_duple = find(result == 1);
ind_after_duple = ind_duple + 1;
ind_triple = find(result == 2);
ind_after_triple = ind_triple + 1;
ind_after_duple = ind_after_duple(1:end-1); % remove the last one 
ind_after_triple = ind_after_triple(1:end-1); % remove the last one 

% Extract the "after-duple" trials and "after-triple" trials,respectively
EEG_after_duple = EEG;
EEG_after_triple = EEG;
EEG_after_duple.epoch = EEG.epoch(ind_after_duple);
EEG_after_duple.data = EEG.data(:,:,ind_after_duple);
EEG_after_duple.icaact = EEG.icaact(:,:,ind_after_duple);
EEG_after_triple.epoch = EEG.epoch(ind_after_triple);
EEG_after_triple.data = EEG.data(:,:,ind_after_triple);
EEG_after_triple.icaact = EEG.icaact(:,:,ind_after_triple);

% Save them
filename_d = strcat(EEG.setname,'_afd');
filename_t = strcat(EEG.setname,'_aft');
EEG_after_duple = pop_saveset(EEG_after_duple,'filename',filename_d,'filepath',outpath);
EEG_after_triple = pop_saveset(EEG_after_triple,'filename',filename_t,'filepath',outpath);
