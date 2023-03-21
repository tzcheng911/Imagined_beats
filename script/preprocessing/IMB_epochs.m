filepath = ('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG');

%% epoch duple and triple for each participant
% s01
% filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s01/icapMA';
EEG0 = pop_loadset('filename','s01_IMB_cleaned_binica_dipfit_icapMA.set','filepath',filepath);
EEG1 = pop_epoch( EEG0, {  'duple.wav'  }, [-1  15], 'newname', 's01_IMB_cleaned_binica_dipfit_icapMA_duple', 'epochinfo', 'yes');
EEG1.setname='s01_IMB_cleaned_binica_dipfit_icapMA_duple';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG0, {  'triple.wav'  }, [-1  15], 'newname', 's01_IMB_cleaned_binica_dipfit_icapMA_triple', 'epochinfo', 'yes');
EEG2.setname='s01_IMB_cleaned_binica_dipfit_icapMA_triple';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

% s02
clear all
close all
clc
filepath = ('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG');
% filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s02/';
EEG0 = pop_loadset('filename','s02_IMB_cleaned_binica_dipfit_icapMA.set','filepath',filepath);
EEG1 = pop_epoch( EEG0, {  'Duple'  }, [-1  15], 'newname', 's02_IMB_cleaned_binica_dipfit_icapMA_duple', 'epochinfo', 'yes');
EEG1.setname='s02_IMB_cleaned_binica_dipfit_icapMA_duple';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG0, {  'Triple'  }, [-1  15], 'newname', 's02_IMB_cleaned_binica_dipfit_icapMA_triple', 'epochinfo', 'yes');
EEG2.setname='s02_IMB_cleaned_binica_dipfit_icapMA_triple';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

% s03
clear
filepath = ('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG');

% filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s03/';
EEG0 = pop_loadset('filename','s03_IMB_cleaned_binica_dipfit_icapMA.set','filepath',filepath);
EEG1 = pop_epoch( EEG0, {  'Duple'  }, [-1  15], 'newname', 's03_IMB_cleaned_binica_dipfit_icapMA_duple', 'epochinfo', 'yes');
EEG1.setname='s03_IMB_cleaned_binica_dipfit_icapMA_duple';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG0, {  'Triple'  }, [-1  15], 'newname', 's03_IMB_cleaned_binica_dipfit_icapMA_triple', 'epochinfo', 'yes');
EEG2.setname='s03_IMB_cleaned_binica_dipfit_icapMA_triple';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

% s04
clear
filepath = ('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG');

% filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s04/';
EEG0 = pop_loadset('filename','s04_IMB_cleaned_binica_dipfit_icapMA.set','filepath',filepath);
EEG1 = pop_epoch( EEG0, {  'Duple'  }, [-1  15], 'newname', 's04_IMB_cleaned_binica_dipfit_icapMA_duple', 'epochinfo', 'yes');
EEG1.setname='s04_IMB_cleaned_binica_dipfit_icapMA_duple';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG0, {  'Triple'  }, [-1  15], 'newname', 's04_IMB_cleaned_binica_dipfit_icapMA_triple', 'epochinfo', 'yes');
EEG2.setname='s04_IMB_cleaned_binica_dipfit_icapMA_triple';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

% s05
clear
filepath = ('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG');

% filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s05/';
EEG0 = pop_loadset('filename','s05_IMB_cleaned_binica_dipfit_icapMA.set','filepath',filepath);
EEG1 = pop_epoch( EEG0, {  'Duple'  }, [-1  15], 'newname', 's05_IMB_cleaned_binica_dipfit_icapMA_duple', 'epochinfo', 'yes');
EEG1.setname='s05_IMB_cleaned_binica_dipfit_icapMA_duple';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG0, {  'Triple'  }, [-1  15], 'newname', 's05_IMB_cleaned_binica_dipfit_icapMA_triple', 'epochinfo', 'yes');
EEG2.setname='s05_IMB_cleaned_binica_dipfit_icapMA_triple';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

% s06
clear
filepath = ('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG');

% filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s06/';
EEG0 = pop_loadset('filename','s06_IMB_cleaned_binica_dipfit_icapMA.set','filepath',filepath);
EEG1 = pop_epoch( EEG0, {  'Duple'  }, [-1  15], 'newname', 's06_IMB_cleaned_binica_dipfit_icapMA_duple', 'epochinfo', 'yes');
EEG1.setname='s06_IMB_cleaned_binica_dipfit_icapMA_duple';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG0, {  'Triple'  }, [-1  15], 'newname', 's06_IMB_cleaned_binica_dipfit_icapMA_triple', 'epochinfo', 'yes');
EEG2.setname='s06_IMB_cleaned_binica_dipfit_icapMA_triple';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

% s07
clear
filepath = ('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG');

% filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s07/icapMA';
EEG0 = pop_loadset('filename','s07_IMB_cleaned_binica_dipfit_icapMA.set','filepath',filepath);
EEG1 = pop_epoch( EEG0, {  'Duple'  }, [-1  15], 'newname', 's07_IMB_cleaned_binica_dipfit_MA_duple', 'epochinfo', 'yes');
EEG1.setname='s07_IMB_cleaned_binica_dipfit_MA_duple';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG0, {  'Triple'  }, [-1  15], 'newname', 's07_IMB_cleaned_binica_dipfit_MA_triple', 'epochinfo', 'yes');
EEG2.setname='s07_IMB_cleaned_binica_dipfit_MA_triple';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

% s08
clear
filepath = ('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG');

% filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s08/icapMA';
EEG0 = pop_loadset('filename','s08_IMB_cleaned_binica_dipfit_icapMA.set','filepath',filepath);
EEG1 = pop_epoch( EEG0, {  'Duple'  }, [-1  15], 'newname', 's08_IMB_cleaned_binica_dipfit_MA_duple', 'epochinfo', 'yes');
EEG1.setname='s08_IMB_cleaned_binica_dipfit_MA_duple';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG0, {  'Triple'  }, [-1  15], 'newname', 's08_IMB_cleaned_binica_dipfit_MA_triple', 'epochinfo', 'yes');
EEG2.setname='s08_IMB_cleaned_binica_dipfit_MA_triple';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

% s09
clear
filepath = ('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG');

% filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s09/icapMA';
EEG0 = pop_loadset('filename','s09_IMB_cleaned_binica_dipfit_icapMA.set','filepath',filepath);
EEG1 = pop_epoch( EEG0, {  'Duple'  }, [-1  15], 'newname', 's09_IMB_cleaned_binica_dipfit_MA_duple', 'epochinfo', 'yes');
EEG1.setname='s09_IMB_cleaned_binica_dipfit_MA_duple';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG0, {  'Triple'  }, [-1  15], 'newname', 's09_IMB_cleaned_binica_dipfit_MA_triple', 'epochinfo', 'yes');
EEG2.setname='s09_IMB_cleaned_binica_dipfit_MA_triple';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

%% Epoch BL, SBL, IM for each condition and each subject - use segmentation instead of epoch
%% s01 duple
clear
filepath = ('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG');
%filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s01/icapMA';
EEG0 = pop_loadset('filename','s01_IMB_cleaned_binica_dipfit_icapMA.set','filepath',filepath);

EEG_duple = pop_rmdat( EEG0, {'duple.wav'},[-1 21] ,0); % select the duple and triple events and do epoch on them, respectively
EEG_triple = pop_rmdat( EEG0, {'triple.wav'},[-1 21] ,0);

EEG1 = pop_epoch( EEG_duple, {  'BL'  }, [-1         4.99], 'newname', 's01_IMB_icapMA_duple_BL', 'epochinfo', 'yes');
EEG1.setname='s01_IMB_icapMA_duple_BL';
EEG1 = pop_rmbase( EEG1, [-50   0]);
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG_duple, {  'SBL'  }, [-1         4.99], 'newname', 's01_IMB_icapMA_duple_SBL', 'epochinfo', 'yes');
EEG2.setname='s01_IMB_icapMA_duple_SBL';
EEG2 = pop_rmbase( EEG2, [-50   0]);
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_epoch( EEG_duple, {  'IM'  }, [-1         4.99], 'newname', 's01_IMB_icapMA_duple_IM', 'epochinfo', 'yes');
EEG3.setname='s01_IMB_icapMA_duple_IM';
EEG3 = pop_rmbase( EEG3, [-50   0]);
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_epoch( EEG_duple, {  'IM'  }, [5         11], 'newname', 's01_IMB_icapMA_duple_tap', 'epochinfo', 'yes');
EEG4.setname='s01_IMB_icapMA_duple_tap';
EEG4 = pop_rmbase( EEG4, [5000   5050]);
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

% s01 triple
EEG1 = pop_epoch( EEG_triple, {  'BL'  }, [-1         4.99], 'newname', 's01_IMB_icapMA_triple_BL', 'epochinfo', 'yes');
EEG1.setname='s01_IMB_icapMA_triple_BL';
EEG1 = pop_rmbase( EEG1, [-50   0]);
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG_triple, {  'SBL'  }, [-1         4.99], 'newname', 's01_IMB_icapMA_triple_SBL', 'epochinfo', 'yes');
EEG2.setname='s01_IMB_icapMA_triple_SBL';
EEG2 = pop_rmbase( EEG2, [-50   0]);
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_epoch( EEG_triple, {  'IM'  }, [-1         4.99], 'newname', 's01_IMB_icapMA_triple_IM', 'epochinfo', 'yes');
EEG3.setname='s01_IMB_icapMA_triple_IM';
EEG3 = pop_rmbase( EEG3, [-50   0]);
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_epoch( EEG_triple, {  'IM'  }, [5         11], 'newname', 's01_IMB_icapMA_triple_tap', 'epochinfo', 'yes');
EEG4.setname='s01_IMB_icapMA_triple_tap';
EEG4 = pop_rmbase( EEG4, [5000   5050]);
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);
%% s02 duple
clear
filepath = ('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG');
%filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s02/icapMA';
EEG0 = pop_loadset('filename','s02_IMB_cleaned_binica_dipfit_icapMA.set','filepath',filepath);

EEG_duple = pop_rmdat( EEG0, {'Duple'},[-2 25] ,0);
EEG_triple = pop_rmdat( EEG0, {'Triple'},[-2 25] ,0);

EEG1 = pop_epoch( EEG_duple, {  'BL'  }, [-1         4.99], 'newname', 's02_IMB_icapMA_duple_BL', 'epochinfo', 'yes');
EEG1.setname='s02_IMB_icapMA_duple_BL';
EEG1 = pop_rmbase( EEG1, [-50   0]);
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG_duple, {  'SBL'  }, [-1         4.99], 'newname', 's02_IMB_icapMA_duple_SBL', 'epochinfo', 'yes');
EEG2.setname='s02_IMB_icapMA_duple_SBL';
EEG2 = pop_rmbase( EEG2, [-50   0]);
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_epoch( EEG_duple, {  'IM'  }, [-1         4.99], 'newname', 's02_IMB_icapMA_duple_IM', 'epochinfo', 'yes');
EEG3.setname='s02_IMB_icapMA_duple_IM';
EEG3 = pop_rmbase( EEG3, [-50   0]);
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_epoch( EEG_duple, {  'IM'  }, [5         11], 'newname', 's02_IMB_icapMA_duple_tap', 'epochinfo', 'yes');
EEG4.setname='s02_IMB_icapMA_duple_tap';
EEG4 = pop_rmbase( EEG4, [5000 5050]);
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

% s02 triple
EEG1 = pop_epoch( EEG_triple, {  'BL'  }, [-1         4.99], 'newname', 's02_IMB_icapMA_triple_BL', 'epochinfo', 'yes');
EEG1.setname='s02_IMB_icapMA_triple_BL';
EEG1 = pop_rmbase( EEG1, [-50   0]);
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG_triple, {  'SBL'  }, [-1         4.99], 'newname', 's02_IMB_icapMA_triple_SBL', 'epochinfo', 'yes');
EEG2.setname='s02_IMB_icapMA_triple_SBL';
EEG2 = pop_rmbase( EEG2, [-50   0]);
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_epoch( EEG_triple, {  'IM'  }, [-1         4.99], 'newname', 's02_IMB_icapMA_triple_IM', 'epochinfo', 'yes');
EEG3.setname='s02_IMB_icapMA_triple_IM';
EEG3 = pop_rmbase( EEG3, [-50   0]);
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_epoch( EEG_triple, {  'IM'  }, [5         11], 'newname', 's02_IMB_icapMA_triple_tap', 'epochinfo', 'yes');
EEG4.setname='s02_IMB_icapMA_triple_tap';
EEG4 = pop_rmbase( EEG4, [5000   5050]);
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

%% s03 duple
clear
clc
filepath = ('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG');

%filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s03/icapMA';
EEG0 = pop_loadset('filename','s03_IMB_cleaned_binica_dipfit_icapMA.set','filepath',filepath);

EEG_duple = pop_rmdat( EEG0, {'Duple'},[-1 21] ,0);
EEG_triple = pop_rmdat( EEG0, {'Triple'},[-1 21] ,0);

EEG1 = pop_epoch( EEG_duple, {  'BL'  }, [-1         4.99], 'newname', 's03_IMB_icapMA_duple_BL', 'epochinfo', 'yes');
EEG1.setname='s03_IMB_icapMA_duple_BL';
EEG1 = pop_rmbase( EEG1, [-50   0]);
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG_duple, {  'SBL'  }, [-1         4.99], 'newname', 's03_IMB_icapMA_duple_SBL', 'epochinfo', 'yes');
EEG2.setname='s03_IMB_icapMA_duple_SBL';
EEG2 = pop_rmbase( EEG2, [-50   0]);
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_epoch( EEG_duple, {  'IM'  }, [-1         4.99], 'newname', 's03_IMB_icapMA_duple_IM', 'epochinfo', 'yes');
EEG3.setname='s03_IMB_icapMA_duple_IM';
EEG3 = pop_rmbase( EEG3, [-50   0]);
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_epoch( EEG_duple, {  'IM'  }, [5         11], 'newname', 's03_IMB_icapMA_duple_tap', 'epochinfo', 'yes');
EEG4.setname='s03_IMB_icapMA_duple_tap';
EEG4 = pop_rmbase( EEG4, [5000   5050]);
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

% s03 triple
EEG1 = pop_epoch( EEG_triple, {  'BL'  }, [-1         4.99], 'newname', 's03_IMB_icapMA_triple_BL', 'epochinfo', 'yes');
EEG1.setname='s03_IMB_icapMA_triple_BL';
EEG1 = pop_rmbase( EEG1, [-50   0]);
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG_triple, {  'SBL'  }, [-1         4.99], 'newname', 's03_IMB_icapMA_triple_SBL', 'epochinfo', 'yes');
EEG2.setname='s03_IMB_icapMA_triple_SBL';
EEG2 = pop_rmbase( EEG2, [-50   0]);
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_epoch( EEG_triple, {  'IM'  }, [-1         4.99], 'newname', 's03_IMB_icapMA_triple_IM', 'epochinfo', 'yes');
EEG3.setname='s03_IMB_icapMA_triple_IM';
EEG3 = pop_rmbase( EEG3, [-50   0]);
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_epoch( EEG_triple, {  'IM'  }, [5         11], 'newname', 's03_IMB_icapMA_triple_tap', 'epochinfo', 'yes');
EEG4.setname='s03_IMB_icapMA_triple_tap';
EEG4 = pop_rmbase( EEG4, [5000   5050]);
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

%% s04 duple
clear
clc
filepath = ('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG');

%filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s04/icapMA';
EEG0 = pop_loadset('filename','s04_IMB_cleaned_binica_dipfit_icapMA.set','filepath',filepath);

EEG_duple = pop_rmdat( EEG0, {'Duple'},[-1 21] ,0);
EEG_triple = pop_rmdat( EEG0, {'Triple'},[-1 21] ,0);

EEG1 = pop_epoch( EEG_duple, {  'BL'  }, [-1         4.99], 'newname', 's04_IMB_icapMA_duple_BL', 'epochinfo', 'yes');
EEG1.setname='s04_IMB_icapMA_duple_BL';
EEG1 = pop_rmbase( EEG1, [-50   0]);
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG_duple, {  'SBL'  }, [-1         4.99], 'newname', 's04_IMB_icapMA_duple_SBL', 'epochinfo', 'yes');
EEG2.setname='s04_IMB_icapMA_duple_SBL';
EEG2 = pop_rmbase( EEG2, [-50   0]);
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_epoch( EEG_duple, {  'IM'  }, [-1         4.99], 'newname', 's04_IMB_icapMA_duple_IM', 'epochinfo', 'yes');
EEG3.setname='s04_IMB_icapMA_duple_IM';
EEG3 = pop_rmbase( EEG3, [-50   0]);
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_epoch( EEG_duple, {  'IM'  }, [5         11], 'newname', 's04_IMB_icapMA_duple_tap', 'epochinfo', 'yes');
EEG4.setname='s04_IMB_icapMA_duple_tap';
EEG4 = pop_rmbase( EEG4, [5000   5050]);
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

% s04 triple
EEG1 = pop_epoch( EEG_triple, {  'BL'  }, [-1         4.99], 'newname', 's04_IMB_icapMA_triple_BL', 'epochinfo', 'yes');
EEG1.setname='s04_IMB_icapMA_triple_BL';
EEG1 = pop_rmbase( EEG1, [-50   0]);
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG_triple, {  'SBL'  }, [-1         4.99], 'newname', 's04_IMB_icapMA_triple_SBL', 'epochinfo', 'yes');
EEG2.setname='s04_IMB_icapMA_triple_SBL';
EEG2 = pop_rmbase( EEG2, [-50   0]);
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_epoch( EEG_triple, {  'IM'  }, [-1         4.99], 'newname', 's04_IMB_icapMA_triple_IM', 'epochinfo', 'yes');
EEG3.setname='s04_IMB_icapMA_triple_IM';
EEG3 = pop_rmbase( EEG3, [-50   0]);
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_epoch( EEG_triple, {  'IM'  }, [5         11], 'newname', 's04_IMB_icapMA_triple_tap', 'epochinfo', 'yes');
EEG4.setname='s04_IMB_icapMA_triple_tap';
EEG4 = pop_rmbase( EEG4, [5000   5050]);
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

%% s05 duple
clear
clc
filepath = ('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG');

filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s05/icap_noalpha/';
EEG0 = pop_loadset('filename','s05_IMB_cleaned_binica_dipfit_icapnoalpha_fix.set','filepath',filepath);

EEG_duple = pop_rmdat( EEG0, {'Duple'},[-1 22] ,0);
EEG_triple = pop_rmdat( EEG0, {'Triple'},[-1 22] ,0);

EEG1 = pop_epoch( EEG_duple, {  'BL'  }, [-1         4.99], 'newname', 's05_IMB_icapMA_duple_BL', 'epochinfo', 'yes');
EEG1.setname='s05_IMB_icapMA_duple_BL';
EEG1 = pop_rmbase( EEG1, [-50   0]);
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG_duple, {  'SBL'  }, [-1         4.99], 'newname', 's05_IMB_icapMA_duple_SBL', 'epochinfo', 'yes');
EEG2.setname='s05_IMB_icapMA_duple_SBL';
EEG2 = pop_rmbase( EEG2, [-50   0]);
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_epoch( EEG_duple, {  'IM'  }, [-1         4.99], 'newname', 's05_IMB_icapMA_duple_IM', 'epochinfo', 'yes');
EEG3.setname='s05_IMB_icapMA_duple_IM';
EEG3 = pop_rmbase( EEG3, [-50   0]);
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_epoch( EEG_duple, {  'IM'  }, [5         11], 'newname', 's05_IMB_icapMA_duple_tap', 'epochinfo', 'yes');
EEG4.setname='s05_IMB_icapMA_duple_tap';
EEG4 = pop_rmbase( EEG4, [5000   5050]);
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

% s05 triple
EEG1 = pop_epoch( EEG_triple, {  'BL'  }, [-1         4.99], 'newname', 's05_IMB_icapMA_triple_BL', 'epochinfo', 'yes');
EEG1.setname='s05_IMB_icapMA_triple_BL';
EEG1 = pop_rmbase( EEG1, [-50   0]);
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG_triple, {  'SBL'  }, [-1         4.99], 'newname', 's05_IMB_icapMA_triple_SBL', 'epochinfo', 'yes');
EEG2.setname='s05_IMB_icapMA_triple_SBL';
EEG2 = pop_rmbase( EEG2, [-50   0]);
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_epoch( EEG_triple, {  'IM'  }, [-1         4.99], 'newname', 's05_IMB_icapMA_triple_IM', 'epochinfo', 'yes');
EEG3.setname='s05_IMB_icapMA_triple_IM';
EEG3 = pop_rmbase( EEG3, [-50   0]);
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath','/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp');

EEG4 = pop_epoch( EEG_triple, {  'IM'  }, [5         11], 'newname', 's05_IMB_icapMA_triple_tap', 'epochinfo', 'yes');
EEG4.setname='s05_IMB_icapMA_triple_tap';
EEG4 = pop_rmbase( EEG4, [5000   5050]);
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

%% s06 duple
clear
filepath = ('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG');

%filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s06/icapMA';
EEG0 = pop_loadset('filename','s06_IMB_cleaned_binica_dipfit_icapMA.set','filepath',filepath);

EEG_duple = pop_rmdat( EEG0, {'Duple'},[-1 21] ,0);
EEG_triple = pop_rmdat( EEG0, {'Triple'},[-1 21] ,0);

EEG1 = pop_epoch( EEG_duple, {  'BL'  }, [-1         4.99], 'newname', 's06_IMB_icapMA_duple_BL', 'epochinfo', 'yes');
EEG1.setname='s06_IMB_icapMA_duple_BL';
EEG1 = pop_rmbase( EEG1, [-50   0]);
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG_duple, {  'SBL'  }, [-1         4.99], 'newname', 's06_IMB_icapMA_duple_SBL', 'epochinfo', 'yes');
EEG2.setname='s06_IMB_icapMA_duple_SBL';
EEG2 = pop_rmbase( EEG2, [-50   0]);
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_epoch( EEG_duple, {  'IM'  }, [-1         4.99], 'newname', 's06_IMB_icapMA_duple_IM', 'epochinfo', 'yes');
EEG3.setname='s06_IMB_icapMA_duple_IM';
EEG3 = pop_rmbase( EEG3, [-50   0]);
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_epoch( EEG_duple, {  'IM'  }, [5         11], 'newname', 's06_IMB_icapMA_duple_tap', 'epochinfo', 'yes');
EEG4.setname='s06_IMB_icapMA_duple_tap';
EEG4 = pop_rmbase( EEG4, [5000   5050]);
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

% s06 triple
EEG1 = pop_epoch( EEG_triple, {  'BL'  }, [-1         4.99], 'newname', 's06_IMB_icapMA_triple_BL', 'epochinfo', 'yes');
EEG1.setname='s06_IMB_icapMA_triple_BL';
EEG1 = pop_rmbase( EEG1, [-50   0]);
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG_triple, {  'SBL'  }, [-1         4.99], 'newname', 's06_IMB_icapMA_triple_SBL', 'epochinfo', 'yes');
EEG2.setname='s06_IMB_icapMA_triple_SBL';
EEG2 = pop_rmbase( EEG2, [-50   0]);
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_epoch( EEG_triple, {  'IM'  }, [-1         4.99], 'newname', 's06_IMB_icapMA_triple_IM', 'epochinfo', 'yes');
EEG3.setname='s06_IMB_icapMA_triple_IM';
EEG3 = pop_rmbase( EEG3, [-50   0]);
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_epoch( EEG_triple, {  'IM'  }, [5         11], 'newname', 's06_IMB_icapMA_triple_tap', 'epochinfo', 'yes');
EEG4.setname='s06_IMB_icapMA_triple_tap';
EEG4 = pop_rmbase( EEG4, [5000   5050]);
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

%% s07 duple
clear
filepath = ('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG');

%filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s07/icapMA';
EEG0 = pop_loadset('filename','s07_IMB_cleaned_binica_dipfit_icapMA.set','filepath',filepath);

EEG_duple = pop_rmdat( EEG0, {'Duple'},[-1 21] ,0);
EEG_triple = pop_rmdat( EEG0, {'Triple'},[-1 21] ,0);

EEG1 = pop_epoch( EEG_duple, {  'BL'  }, [-1         4.99], 'newname', 's07_IMB_icapMA_duple_BL', 'epochinfo', 'yes');
EEG1.setname='s07_IMB_icapMA_duple_BL';
EEG1 = pop_rmbase( EEG1, [-50   0]);
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG_duple, {  'SBL'  }, [-1         4.99], 'newname', 's07_IMB_icapMA_duple_SBL', 'epochinfo', 'yes');
EEG2.setname='s07_IMB_icapMA_duple_SBL';
EEG2 = pop_rmbase( EEG2, [-50   0]);
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_epoch( EEG_duple, {  'IM'  }, [-1         4.99], 'newname', 's07_IMB_icapMA_duple_IM', 'epochinfo', 'yes');
EEG3.setname='s07_IMB_icapMA_duple_IM';
EEG3 = pop_rmbase( EEG3, [-50   0]);
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_epoch( EEG_duple, {  'IM'  }, [5         11], 'newname', 's07_IMB_icapMA_duple_tap', 'epochinfo', 'yes');
EEG4.setname='s07_IMB_icapMA_duple_tap';
EEG4 = pop_rmbase( EEG4, [5000   5050]);
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

% s07 triple
EEG1 = pop_epoch( EEG_triple, {  'BL'  }, [-1         4.99], 'newname', 's07_IMB_icapMA_triple_BL', 'epochinfo', 'yes');
EEG1.setname='s07_IMB_icapMA_triple_BL';
EEG1 = pop_rmbase( EEG1, [-50   0]);
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_epoch( EEG_triple, {  'SBL'  }, [-1         4.99], 'newname', 's07_IMB_icapMA_triple_SBL', 'epochinfo', 'yes');
EEG2.setname='s07_IMB_icapMA_triple_SBL';
EEG2 = pop_rmbase( EEG2, [-50   0]);
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_epoch( EEG_triple, {  'IM'  }, [-1         4.99], 'newname', 's07_IMB_icapMA_triple_IM', 'epochinfo', 'yes');
EEG3.setname='s07_IMB_icapMA_triple_IM';
EEG3 = pop_rmbase( EEG3, [-50   0]);
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_epoch( EEG_triple, {  'IM'  }, [5         11], 'newname', 's07_IMB_icapMA_triple_tap', 'epochinfo', 'yes');
EEG4.setname='s07_IMB_icapMA_triple_tap';
EEG4 = pop_rmbase( EEG4, [5000   5050]);
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

%% s08 duple
clear
filepath = ('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG');

%filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s08/icapMA';
EEG0 = pop_loadset('filename','s08_IMB_cleaned_binica_dipfit_icapMA.set','filepath',filepath);

EEG_duple = pop_rmdat( EEG0, {'Duple'},[-1 21] ,0);
EEG_triple = pop_rmdat( EEG0, {'Triple'},[-1 21] ,0);

EEG1 = pop_epoch( EEG_duple, {  'BL'  }, [-1         4.99], 'newname', 's08_IMB_icapMA_duple_BL', 'epochinfo', 'yes');
EEG1.setname='s08_IMB_icapMA_duple_BL';
EEG1 = pop_rmbase( EEG1, [-50   0]);
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);
EEG1.trials

EEG2 = pop_epoch( EEG_duple, {  'SBL'  }, [-1         4.99], 'newname', 's08_IMB_icapMA_duple_SBL', 'epochinfo', 'yes');
EEG2.setname='s08_IMB_icapMA_duple_SBL';
EEG2 = pop_rmbase( EEG2, [-50   0]);
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);
EEG2.trials

EEG3 = pop_epoch( EEG_duple, {  'IM'  }, [-1         4.99], 'newname', 's08_IMB_icapMA_duple_IM', 'epochinfo', 'yes');
EEG3.setname='s08_IMB_icapMA_duple_IM';
EEG3 = pop_rmbase( EEG3, [-50   0]);
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);
EEG3.trials

EEG4 = pop_epoch( EEG_duple, {  'IM'  }, [5         11], 'newname', 's08_IMB_icapMA_duple_tap', 'epochinfo', 'yes');
EEG4.setname='s08_IMB_icapMA_duple_tap';
EEG4 = pop_rmbase( EEG4, [5000   5050]);
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);
EEG4.trials

% s08 triple
EEG1 = pop_epoch( EEG_triple, {  'BL'  }, [-1         4.99], 'newname', 's08_IMB_icapMA_triple_BL', 'epochinfo', 'yes');
EEG1.setname='s08_IMB_icapMA_triple_BL';
EEG1 = pop_rmbase( EEG1, [-50   0]);
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);
EEG1.trials

EEG2 = pop_epoch( EEG_triple, {  'SBL'  }, [-1         4.99], 'newname', 's08_IMB_icapMA_triple_SBL', 'epochinfo', 'yes');
EEG2.setname='s08_IMB_icapMA_triple_SBL';
EEG2 = pop_rmbase( EEG2, [-50   0]);
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);
EEG2.trials

EEG3 = pop_epoch( EEG_triple, {  'IM'  }, [-1         4.99], 'newname', 's08_IMB_icapMA_triple_IM', 'epochinfo', 'yes');
EEG3.setname='s08_IMB_icapMA_triple_IM';
EEG3 = pop_rmbase( EEG3, [-50   0]);
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);
EEG3.trials

EEG4 = pop_epoch( EEG_triple, {  'IM'  }, [5         11], 'newname', 's08_IMB_icapMA_triple_tap', 'epochinfo', 'yes');
EEG4.setname='s08_IMB_icapMA_triple_tap';
EEG4 = pop_rmbase( EEG4, [5000   5050]);
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);
EEG4.trials

%% s09 duple
clear
filepath = ('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG');

%filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s09/icapMA';
EEG0 = pop_loadset('filename','s09_IMB_cleaned_binica_dipfit_icapMA.set','filepath',filepath);

EEG_duple = pop_rmdat( EEG0, {'Duple'},[-1 21] ,0);
EEG_triple = pop_rmdat( EEG0, {'Triple'},[-1 21] ,0);

EEG1 = pop_epoch( EEG_duple, {  'BL'  }, [-1         4.99], 'newname', 's09_IMB_icapMA_duple_BL', 'epochinfo', 'yes');
EEG1.setname='s09_IMB_icapMA_duple_BL';
EEG1 = pop_rmbase( EEG1, [-50   0]);
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);
EEG1.trials

EEG2 = pop_epoch( EEG_duple, {  'SBL'  }, [-1         4.99], 'newname', 's09_IMB_icapMA_duple_SBL', 'epochinfo', 'yes');
EEG2.setname='s09_IMB_icapMA_duple_SBL';
EEG2 = pop_rmbase( EEG2, [-50   0]);
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);
EEG2.trials

EEG3 = pop_epoch( EEG_duple, {  'IM'  }, [-1         4.99], 'newname', 's09_IMB_icapMA_duple_IM', 'epochinfo', 'yes');
EEG3.setname='s09_IMB_icapMA_duple_IM';
EEG3 = pop_rmbase( EEG3, [-50   0]);
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);
EEG3.trials

EEG4 = pop_epoch( EEG_duple, {  'IM'  }, [5         11], 'newname', 's09_IMB_icapMA_duple_tap', 'epochinfo', 'yes');
EEG4.setname='s09_IMB_icapMA_duple_tap';
EEG4 = pop_rmbase( EEG4, [5000   5050]);
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);
EEG4.trials

% s09 triple
EEG1 = pop_epoch( EEG_triple, {  'BL'  }, [-1         4.99], 'newname', 's09_IMB_icapMA_triple_BL', 'epochinfo', 'yes');
EEG1.setname='s09_IMB_icapMA_triple_BL';
EEG1 = pop_rmbase( EEG1, [-50   0]);
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);
EEG1.trials

EEG2 = pop_epoch( EEG_triple, {  'SBL'  }, [-1         4.99], 'newname', 's09_IMB_icapMA_triple_SBL', 'epochinfo', 'yes');
EEG2.setname='s09_IMB_icapMA_triple_SBL';
EEG2 = pop_rmbase( EEG2, [-50   0]);
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);
EEG2.trials

EEG3 = pop_epoch( EEG_triple, {  'IM'  }, [-1         4.99], 'newname', 's09_IMB_icapMA_triple_IM', 'epochinfo', 'yes');
EEG3.setname='s09_IMB_icapMA_triple_IM';
EEG3 = pop_rmbase( EEG3, [-50   0]);
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);
EEG3.trials

EEG4 = pop_epoch( EEG_triple, {  'IM'  }, [5         11], 'newname', 's09_IMB_icapMA_triple_tap', 'epochinfo', 'yes');
EEG4.setname='s09_IMB_icapMA_triple_tap';
EEG4 = pop_rmbase( EEG4, [5000   5050]);
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);
EEG4.trials