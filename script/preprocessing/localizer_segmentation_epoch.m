%% Segmentation 
% pilot Zoe: 2018/12/7
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer2';
EEG0 = pop_loadset('filename','localizer_Madison_binica_dipfit.set' ,'filepath', filepath);

EEG1 = pop_select( EEG0, 'point',[3255 55000] );
EEG1.setname='localizer_Madison_binica_tap1';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_select( EEG0, 'point',[91000 140000] );
EEG2.setname='localizer_Madison_binica_rdlisten2';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_select( EEG0, 'point',[140000 190400] );
EEG3.setname='localizer_Madison_binica_isoclisten3';
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_select( EEG0, 'point',[190400 240000] );
EEG4.setname='localizer_Madison_binica_rdlisten4';
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

EEG5 = pop_select( EEG0, 'point',[240000 290000] );
EEG5.setname='localizer_Madison_binica_sync5';
filename = char(EEG5.setname);
EEG5 = pop_saveset(EEG5,'filename',filename,'filepath',filepath);

% tap
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer2/';
EEG = pop_loadset('filename','localizer_Madison_binica_tap1.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '2'  }, [-0.3         0.5], 'newname', ...
    'localizer2_tap1_e', 'epochinfo', 'yes');
EEG.setname='localizer2_tap1_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% rd listen
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer2/';
EEG = pop_loadset('filename','localizer_Madison_binica_rdlisten2.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    'localizer2_rdlisten2_e', 'epochinfo', 'yes');
EEG.setname='localizer2_rdlisten2_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer2/';
EEG = pop_loadset('filename','localizer_Madison_binica_rdlisten4.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    'localizer2_rdlisten4_e', 'epochinfo', 'yes');
EEG.setname='localizer2_rdlisten4_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% iso listen
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer2/';
EEG = pop_loadset('filename','localizer_Madison_binica_isoclisten3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    'localizer2_isolisten3_e', 'epochinfo', 'yes');
EEG.setname='localizer2_isolisten3_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - listen
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer2/';
EEG = pop_loadset('filename','localizer_Madison_binica_sync5.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    'localizer2_sync5listen_e', 'epochinfo', 'yes');
EEG.setname='localizer2_sync5listen_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - tap
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer2/';
EEG = pop_loadset('filename','localizer_Madison_binica_sync5.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '2'  }, [-0.3         0.5], 'newname', ...
    'localizer2_sync5tap_e', 'epochinfo', 'yes');
EEG.setname='localizer2_sync5tap_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);
%% pilot Clemens: 2018/12/12
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer3';
EEG0 = pop_loadset('filename','localizer_Madison_binica_dipfit_relabel.set' ,'filepath', filepath);

EEG1 = pop_select( EEG0, 'point',[1200 47600] );
EEG1.setname='localizer_Madison_binica_dipfit_tap1';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_select( EEG0, 'point',[78000 130000] );
EEG2.setname='localizer_Madison_binica_dipfit_rdlisten2';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_select( EEG0, 'point',[130000 180000] );
EEG3.setname='localizer_Madison_binica_dipfit_isoclisten3';
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_select( EEG0, 'point',[180000 230000] );
EEG4.setname='localizer_Madison_binica_dipfit_rdlisten4';
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

EEG5 = pop_select( EEG0, 'point',[230000 278300] );
EEG5.setname='localizer_Madison_binica_dipfit_sync5';
filename = char(EEG5.setname);
EEG5 = pop_saveset(EEG5,'filename',filename,'filepath',filepath);

% tap
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer3/';
EEG = pop_loadset('filename','localizer_Madison_binica_dipfit_tap1.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '2'  }, [-0.3         0.5], 'newname', ...
    'localizer3_tap1_e', 'epochinfo', 'yes');
EEG.setname='localizer3_tap1_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% rd listen
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer3/';
EEG = pop_loadset('filename','localizer_Madison_binica_dipfit_rdlisten4.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    'localizer3_rdlisten4_e', 'epochinfo', 'yes');
EEG.setname='localizer3_rdlisten4_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer3/';
EEG = pop_loadset('filename','localizer_Madison_binica_dipfit_rdlisten2.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    'localizer3_rdlisten2_e', 'epochinfo', 'yes');
EEG.setname='localizer3_rdlisten2_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% iso listen
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer3/';
EEG = pop_loadset('filename','localizer_Madison_binica_dipfit_isoclisten3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    'localizer3_isolisten3_e', 'epochinfo', 'yes');
EEG.setname='localizer3_isolisten3_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - listen
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer3/';
EEG = pop_loadset('filename','localizer_Madison_binica_dipfit_sync5.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    'localizer3_sync5listen_e', 'epochinfo', 'yes');
EEG.setname='localizer3_sync5listen_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - tap
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer3/';
EEG = pop_loadset('filename','localizer_Madison_binica_dipfit_sync5.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '2'  }, [-0.3         0.5], 'newname', ...
    'localizer3_sync5tap_e', 'epochinfo', 'yes');
EEG.setname='localizer3_sync5tap_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);
%% pilot John: 2018/12/17
cd '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer4'
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer4';
EEG0 = pop_loadset('filename','1414_ImaginedBeatPilot_902_ds256_binica_dipfit_relabel.set' ,'filepath', filepath);

EEG1 = pop_select( EEG0, 'point',[253 47550] );
EEG1.setname='1414_ImaginedBeatPilot_902_ds256_binica_dipfit_tap1';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_select( EEG0, 'point',[79000 129000] );
EEG2.setname='1414_ImaginedBeatPilot_902_ds256_binica_dipfit_rdlisten2';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_select( EEG0, 'point',[129000 179000] );
EEG3.setname='1414_ImaginedBeatPilot_902_ds256_binica_dipfit_isoclisten3';
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_select( EEG0, 'point',[179000 230000] );
EEG4.setname='1414_ImaginedBeatPilot_902_ds256_binica_dipfit_rdlisten4';
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

EEG5 = pop_select( EEG0, 'point',[230000 280000] );
EEG5.setname='1414_ImaginedBeatPilot_902_ds256_binica_dipfit_sync5';
filename = char(EEG5.setname);
EEG5 = pop_saveset(EEG5,'filename',filename,'filepath',filepath);

% tap
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer4/';
EEG = pop_loadset('filename','1414_ImaginedBeatPilot_902_ds256_binica_dipfit_tap1.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '2'  }, [-0.3         0.5], 'newname', ...
    'localizer4_tap1_e', 'epochinfo', 'yes');
EEG.setname='localizer4_tap1_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% rd listen
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer4/';
EEG = pop_loadset('filename','1414_ImaginedBeatPilot_902_ds256_binica_dipfit_rdlisten2.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    'localizer4_rdlisten2_e', 'epochinfo', 'yes');
EEG.setname='localizer4_rdlisten2_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer4/';
EEG = pop_loadset('filename','1414_ImaginedBeatPilot_902_ds256_binica_dipfit_rdlisten4.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    'localizer4_rdlisten4_e', 'epochinfo', 'yes');
EEG.setname='localizer4_rdlisten4_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% iso listen
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer4/';
EEG = pop_loadset('filename','1414_ImaginedBeatPilot_902_ds256_binica_dipfit_isoclisten3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    'localizer4_isolisten3_e', 'epochinfo', 'yes');
EEG.setname='localizer4_isolisten3_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - listen
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer4/';
EEG = pop_loadset('filename','1414_ImaginedBeatPilot_902_ds256_binica_dipfit_sync5.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    'localizer4_sync5listen_e', 'epochinfo', 'yes');
EEG.setname='localizer4_sync5listen_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - tap
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/localizer/localizer4/';
EEG = pop_loadset('filename','1414_ImaginedBeatPilot_902_ds256_binica_dipfit_sync5.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '2'  }, [-0.3         0.5], 'newname', ...
    'localizer4_sync5tap_e', 'epochinfo', 'yes');
EEG.setname='localizer4_sync5tap_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

%% real task - s01
% Segmentation 0118 Zoe
clear all
close all 
clc
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s01/';
EEG0 = pop_loadset('filename','s01_localizer_cleaned_binica_dipfit.set' ,'filepath', filepath);

EEG1 = pop_select( EEG0, 'point',[1.2e4 1.1e5] );
EEG1.setname='s01_localizer_tap1';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_select( EEG0, 'point',[1.429e5 2.441e5] );
EEG2.setname='s01_localizer_rdlisten_drum_2';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_select( EEG0, 'point',[2.441e5 3.468e5] );
EEG3.setname='s01_localizer_rdlisten_tone_2';
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_select( EEG0, 'point',[3.574e5 4.574e5] );
EEG4.setname='s01_localizer_rdlisten_hihat_2';
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

EEG5 = pop_select( EEG0, 'point',[4.574e5 5.542e5] );
EEG5.setname='s01_localizer_sync5';
filename = char(EEG5.setname);
EEG5 = pop_saveset(EEG5,'filename',filename,'filepath',filepath);
%
% tap
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s01/';
EEG = pop_loadset('filename','s01_localizer_tap1.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '2'  }, [-0.3         0.5], 'newname', ...
    's01_localizer_tap1_e', 'epochinfo', 'yes');
EEG.setname='s01_localizer_tap1_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% rd listen
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s01/';
EEG = pop_loadset('filename','s01_localizer_rdlisten_drum_2.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    's01_localizer_rdlisten_drum_2_e', 'epochinfo', 'yes');
EEG.setname='s01_localizer_rdlisten_drum_2_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s01/';
EEG = pop_loadset('filename','s01_localizer_rdlisten_tone_2.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    's01_localizer_rdlisten_tone_2_e', 'epochinfo', 'yes');
EEG.setname='s01_localizer_rdlisten_tone_2_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s01/';
EEG = pop_loadset('filename','s01_localizer_rdlisten_hihat_2.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    's01_localizer_rdlisten_hihat_2_e', 'epochinfo', 'yes');
EEG.setname='s01_localizer_rdlisten_hihat_2_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - listen
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s01/';
EEG = pop_loadset('filename','s01_localizer_sync5.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    's01_localizer_sync5listen_e', 'epochinfo', 'yes');
EEG.setname='s01_localizer_sync5listen_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - tap
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s01/';
EEG = pop_loadset('filename','s01_localizer_sync5.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '2'  }, [-0.3         0.5], 'newname', ...
    's01_localizer_sync5tap_e', 'epochinfo', 'yes');
EEG.setname='s01_localizer_sync5tap_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);