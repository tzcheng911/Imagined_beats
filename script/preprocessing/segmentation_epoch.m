%% Sementation
clear all
close all
clc

filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG';
EEG0 = pop_loadset('filename','s01_IMB_cleaned_binica_dipfit_icapMA_icapMA.set' ,'filepath', filepath);

EEG1 = pop_select( EEG0, 'point',[1.2e4 1.1e5] );
EEG1.setname='s01_IMB_cleaned_binica_dipfit_icapMA_tap1';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_select( EEG0, 'point',[1.429e5 2.441e5] );
EEG2.setname='s01_IMB_cleaned_binica_dipfit_icapMA_rdlisten2';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_select( EEG0, 'point',[4.574e5 5.542e5] );
EEG3.setname='s01_IMB_cleaned_binica_dipfit_icapMA_sync3';
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_select( EEG0, 'point',[5.64e5 1.72e5] );
EEG4.setname='s01_IMB_cleaned_binica_dipfit_icapMA_PTB_4';
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

% tap
clear all
EEG = pop_loadset('filename','s01_IMB_cleaned_binica_dipfit_icapMA_tap1.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '2'  }, [-0.3         0.5], 'newname', ...
    's01_IMB_cleaned_binica_dipfit_icapMA_tap1_e', 'epochinfo', 'yes');
EEG.setname='s01_IMB_cleaned_binica_dipfit_icapMA_tap1_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% rd listen
clear all

EEG = pop_loadset('filename','s01_IMB_cleaned_binica_dipfit_icapMA_rdlisten2.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    's01_IMB_cleaned_binica_dipfit_icapMA_rdlisten2_e', 'epochinfo', 'yes');
EEG.setname='s01_IMB_cleaned_binica_dipfit_icapMA_rdlisten2_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - listen
clear all

EEG = pop_loadset('filename','s01_IMB_cleaned_binica_dipfit_icapMA_sync3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    's01_IMB_cleaned_binica_dipfit_icapMA_sync3listen_e', 'epochinfo', 'yes');
EEG.setname='s01_IMB_cleaned_binica_dipfit_icapMA_sync3listen_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - tap
clear all

EEG = pop_loadset('filename','s01_IMB_cleaned_binica_dipfit_icapMA_sync3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '2'  }, [-0.3         0.5], 'newname', ...
    's01_IMB_cleaned_binica_dipfit_icapMA_sync3tap_e', 'epochinfo', 'yes');
EEG.setname='s01_IMB_cleaned_binica_dipfit_icapMA_sync3tap_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

%% s02: Sementation
clear all
close all
clc
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG';
EEG0 = pop_loadset('filename','s02_IMB_cleaned_binica_dipfit_icapMA.set' ,'filepath', filepath);

EEG1 = pop_select( EEG0, 'point',[3000 1e5] );
EEG1.setname='s02_IMB_cleaned_binica_dipfit_icapMA_tap1';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_select( EEG0, 'point',[1e5 2e5] );
EEG2.setname='s02_IMB_cleaned_binica_dipfit_icapMA_rdlisten2';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_select( EEG0, 'point',[2.04e5 2.96e5] );
EEG3.setname='s02_IMB_cleaned_binica_dipfit_icapMA_sync3';
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_select( EEG0, 'point',[3.29e5 1.48e6] );
EEG4.setname='s02_IMB_cleaned_binica_dipfit_icapMA_PTB_4';
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

% tap
clear all

EEG = pop_loadset('filename','s02_IMB_cleaned_binica_dipfit_icapMA_tap1.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '2'  }, [-0.3         0.5], 'newname', ...
    's02_IMB_cleaned_binica_dipfit_icapMA1_tap1_e', 'epochinfo', 'yes');
EEG.setname='s02_IMB_cleaned_binica_dipfit_icapMA1_tap1_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% rd listen
clear all

EEG = pop_loadset('filename','s02_IMB_cleaned_binica_dipfit_icapMA_rdlisten2.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    's02_IMB_cleaned_binica_dipfit_icapMA1_rdlisten2_e', 'epochinfo', 'yes');
EEG.setname='s02_IMB_cleaned_binica_dipfit_icapMA1_rdlisten2_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - listen
clear all

EEG = pop_loadset('filename','s02_IMB_cleaned_binica_dipfit_icapMA_sync3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    's02_IMB_cleaned_binica_dipfit_icapMA1_sync5listen_e', 'epochinfo', 'yes');
EEG.setname='s02_IMB_cleaned_binica_dipfit_icapMA1_sync3listen_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - tap
clear all

EEG = pop_loadset('filename','s02_IMB_cleaned_binica_dipfit_icapMA_sync3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '2'  }, [-0.3         0.5], 'newname', ...
    's02_IMB_cleaned_binica_dipfit_icapMA1_sync3tap_e', 'epochinfo', 'yes');
EEG.setname='s02_IMB_cleaned_binica_dipfit_icapMA1_sync5tap_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);
     
%% s03: Sementation
clear all
close all
clc
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG';
EEG0 = pop_loadset('filename','s03_IMB_cleaned_binica_dipfit_icapMA.set' ,'filepath', filepath);

EEG1 = pop_select( EEG0, 'point',[3000 1e5] );
EEG1.setname='s03_IMB_cleaned_binica_dipfit_icapMA_tap1';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_select( EEG0, 'point',[1e5 2e5] );
EEG2.setname='s03_IMB_cleaned_binica_dipfit_icapMA_rdlisten2';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_select( EEG0, 'point',[2.04e5 2.96e5] );
EEG3.setname='s03_IMB_cleaned_binica_dipfit_icapMA_sync3';
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_select( EEG0, 'point',[3.29e5 1.48e6] );
EEG4.setname='s03_IMB_cleaned_binica_dipfit_icapMA_PTB_4';
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

% tap
clear all

EEG = pop_loadset('filename','s03_IMB_cleaned_binica_dipfit_icapMA_tap1.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '2'  }, [-0.3         0.5], 'newname', ...
    's03_IMB_cleaned_binica_dipfit_icapMA_tap1_e', 'epochinfo', 'yes');
EEG.setname='s03_IMB_cleaned_binica_dipfit_icapMA_tap1_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% rd listen
clear all

EEG = pop_loadset('filename','s03_IMB_cleaned_binica_dipfit_icapMA_rdlisten2.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    's03_IMB_cleaned_binica_dipfit_icapMA_rdlisten2_e', 'epochinfo', 'yes');
EEG.setname='s03_IMB_cleaned_binica_dipfit_icapMA_rdlisten2_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - listen
clear all

EEG = pop_loadset('filename','s03_IMB_cleaned_binica_dipfit_icapMA_sync3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    's03_IMB_cleaned_binica_dipfit_icapMA_sync5listen_e', 'epochinfo', 'yes');
EEG.setname='s03_IMB_cleaned_binica_dipfit_icapMA_sync3listen_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - tap
clear all

EEG = pop_loadset('filename','s03_IMB_cleaned_binica_dipfit_icapMA_sync3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '2'  }, [-0.3         0.5], 'newname', ...
    's03_IMB_cleaned_binica_dipfit_icapMA_sync3tap_e', 'epochinfo', 'yes');
EEG.setname='s03_IMB_cleaned_binica_dipfit_icapMA_sync5tap_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);    
%% s04: Sementation
clear all
close all
clc

filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG';
EEG0 = pop_loadset('filename','s04_IMB_cleaned_binica_dipfit_icapMA.set' ,'filepath', filepath);

EEG1 = pop_select( EEG0, 'point',[0 9.5e4] );
EEG1.setname='s04_IMB_cleaned_binica_dipfit_icapMA_tap1';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_select( EEG0, 'point',[1e5 2.1e5] );
EEG2.setname='s04_IMB_cleaned_binica_dipfit_icapMA_rdlisten2';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_select( EEG0, 'point',[2.2e5 3.16e5] );
EEG3.setname='s04_IMB_cleaned_binica_dipfit_icapMA_sync3';
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_select( EEG0, 'point',[3.5e5 1.5e5] );
EEG4.setname='s04_IMB_cleaned_binica_dipfit_icapMA_PTB_4';
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

% tap
clear all

EEG = pop_loadset('filename','s04_IMB_cleaned_binica_dipfit_icapMA_tap1.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '2'  }, [-0.3         0.5], 'newname', ...
    's04_IMB_cleaned_binica_dipfit_icapMA_tap1_e', 'epochinfo', 'yes');
EEG.setname='s04_IMB_cleaned_binica_dipfit_icapMA_tap1_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% rd listen
clear all

EEG = pop_loadset('filename','s04_IMB_cleaned_binica_dipfit_icapMA_rdlisten2.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    's04_IMB_cleaned_binica_dipfit_icapMA_rdlisten2_e', 'epochinfo', 'yes');
EEG.setname='s04_IMB_cleaned_binica_dipfit_icapMA_rdlisten2_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - listen
clear all

EEG = pop_loadset('filename','s04_IMB_cleaned_binica_dipfit_icapMA_sync3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    's04_IMB_cleaned_binica_dipfit_icapMA_sync3listen_e', 'epochinfo', 'yes');
EEG.setname='s04_IMB_cleaned_binica_dipfit_icapMA_sync3listen_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - tap
clear all

EEG = pop_loadset('filename','s04_IMB_cleaned_binica_dipfit_icapMA_sync3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '2'  }, [-0.3         0.5], 'newname', ...
    's04_IMB_cleaned_binica_dipfit_icapMA_sync3tap_e', 'epochinfo', 'yes');
EEG.setname='s04_IMB_cleaned_binica_dipfit_icapMA_sync3tap_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

%% s05: Sementation
clear all
close all
clc

filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG';
EEG0 = pop_loadset('filename','s05_IMB_cleaned_binica_dipfit_icapMA.set' ,'filepath', filepath);

EEG1 = pop_select( EEG0, 'point',[0 1e5] );
EEG1.setname='s05_IMB_cleaned_binica_dipfit_icapMA_tap1';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_select( EEG0, 'point',[1e5 2.02e5] );
EEG2.setname='s05_IMB_cleaned_binica_dipfit_icapMA_rdlisten2';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_select( EEG0, 'point',[2.1e5 3.1e5] );
EEG3.setname='s05_IMB_cleaned_binica_dipfit_icapMA_sync3';
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_select( EEG0, 'point',[3.34e5 1.45e6] );
EEG4.setname='s05_IMB_cleaned_binica_dipfit_icapMA_PTB_4';
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

% tap
clear all

EEG = pop_loadset('filename','s05_IMB_cleaned_binica_dipfit_icapMA_tap1.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '2'  }, [-0.3         0.5], 'newname', ...
    's05_IMB_cleaned_binica_dipfit_icapMA_tap1_e', 'epochinfo', 'yes');
EEG.setname='s05_IMB_cleaned_binica_dipfit_icapMA_tap1_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% rd listen
clear all

EEG = pop_loadset('filename','s05_IMB_cleaned_binica_dipfit_icapMA_rdlisten2.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    's05_IMB_cleaned_binica_dipfit_icapMA_rdlisten2_e', 'epochinfo', 'yes');
EEG.setname='s05_IMB_cleaned_binica_dipfit_icapMA_rdlisten2_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);

EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - listen
clear all

EEG = pop_loadset('filename','s05_IMB_cleaned_binica_dipfit_icapMA_sync3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    's05_IMB_cleaned_binica_dipfit_icapMA_sync3listen_e', 'epochinfo', 'yes');
EEG.setname='s05_IMB_cleaned_binica_dipfit_icapMA_sync3listen_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - tap
clear all

EEG = pop_loadset('filename','s05_IMB_cleaned_binica_dipfit_icapMA_sync3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '2'  }, [-0.3         0.5], 'newname', ...
    's05_IMB_cleaned_binica_dipfit_icapMA_sync3tap_e', 'epochinfo', 'yes');
EEG.setname='s05_IMB_cleaned_binica_dipfit_icapMA_sync3tap_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

%% s06: Sementation
clear all
close all
clc

filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG';
EEG0 = pop_loadset('filename','s06_IMB_cleaned_binica_dipfit_icapMA.set' ,'filepath', filepath);

EEG1 = pop_select( EEG0, 'point',[2800 1e5] );
EEG1.setname='s06_IMB_cleaned_binica_dipfit_icapMA_tap1';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_select( EEG0, 'point',[1e5 2e5] );
EEG2.setname='s06_IMB_cleaned_binica_dipfit_icapMA_rdlisten2';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_select( EEG0, 'point',[2.12e5 3.1e5] );
EEG3.setname='s06_IMB_cleaned_binica_dipfit_icapMA_sync3';
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_select( EEG0, 'point',[3.3e5 1.5e6] );
EEG4.setname='s06_IMB_cleaned_binica_dipfit_icapMA_PTB_4';
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

% tap
clear all

EEG = pop_loadset('filename','s06_IMB_cleaned_binica_dipfit_icapMA_tap1.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '2'  }, [-0.3         0.5], 'newname', ...
    's06_IMB_cleaned_binica_dipfit_icapMA_tap1_e', 'epochinfo', 'yes');
EEG.setname='s06_IMB_cleaned_binica_dipfit_icapMA_tap1_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% rd listen
clear all

EEG = pop_loadset('filename','s06_IMB_cleaned_binica_dipfit_icapMA_rdlisten2.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    's06_IMB_cleaned_binica_dipfit_icapMA_rdlisten2_e', 'epochinfo', 'yes');
EEG.setname='s06_IMB_cleaned_binica_dipfit_icapMA_rdlisten2_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - listen
clear all

EEG = pop_loadset('filename','s06_IMB_cleaned_binica_dipfit_icapMA_sync3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '0'  }, [-0.3         0.5], 'newname', ...
    's06_IMB_cleaned_binica_dipfit_icapMA_sync3listen_e', 'epochinfo', 'yes');
EEG.setname='s06_IMB_cleaned_binica_dipfit_icapMA_sync3listen_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - tap
clear all

EEG = pop_loadset('filename','s06_IMB_cleaned_binica_dipfit_icapMA_sync3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  '2'  }, [-0.3         0.5], 'newname', ...
    's06_IMB_cleaned_binica_dipfit_icapMA_sync3tap_e', 'epochinfo', 'yes');
EEG.setname='s06_IMB_cleaned_binica_dipfit_icapMA_sync3tap_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

%% s07
clear all
close all
clc

filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG';
EEG0 = pop_loadset('filename','s07_IMB_cleaned_binica_dipfit_icapMA.set' ,'filepath', filepath);

EEG1 = pop_select( EEG0, 'point',[2800 1e5] );
EEG1.setname='s07_IMB_cleaned_binica_dipfit_icapMAtap1';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_select( EEG0, 'point',[1.1e5 2.1e5] );
EEG2.setname='s07_IMB_cleaned_binica_dipfit_icapMArdlisten2';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_select( EEG0, 'point',[2.29e5 3.22e5] );
EEG3.setname='s07_IMB_cleaned_binica_dipfit_icapMAsync3';
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_select( EEG0, 'point',[3.5e5 1.56e6] );
EEG4.setname='s07_IMB_cleaned_binica_dipfit_icapMA_PTB_4';
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

% tap
clear all

EEG = pop_loadset('filename','s07_IMB_cleaned_binica_dipfit_icapMAtap1.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  'Tap'  }, [-0.3         0.5], 'newname', ...
    's07_IMB_cleaned_binica_dipfit_icapMAtap1_e', 'epochinfo', 'yes');
EEG.setname='s07_IMB_cleaned_binica_dipfit_icapMAtap1_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% rd listen
clear all

EEG = pop_loadset('filename','s07_IMB_cleaned_binica_dipfit_icapMArdlisten2.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  'WB'  }, [-0.3         0.5], 'newname', ...
    's07_IMB_cleaned_binica_dipfit_icapMArdlisten2_e', 'epochinfo', 'yes');
EEG.setname='s07_IMB_cleaned_binica_dipfit_icapMArdlisten2_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - listen
clear all

EEG = pop_loadset('filename','s07_IMB_cleaned_binica_dipfit_icapMAsync3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  'WB'  }, [-0.3         0.5], 'newname', ...
    's07_IMB_cleaned_binica_dipfit_icapMAsync3listen_e', 'epochinfo', 'yes');
EEG.setname='s07_IMB_cleaned_binica_dipfit_icapMAsync3listen_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - tap
clear all

EEG = pop_loadset('filename','s07_IMB_cleaned_binica_dipfit_icapMAsync3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  'Tap'  }, [-0.3         0.5], 'newname', ...
    's07_IMB_cleaned_binica_dipfit_icapMAsync3tap_e', 'epochinfo', 'yes');
EEG.setname='s07_IMB_cleaned_binica_dipfit_icapMAsync3tap_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

%% s08
clear all
close all
clc

filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG';
EEG0 = pop_loadset('filename','s08_IMB_cleaned_binica_dipfit_icapMA.set' ,'filepath', filepath);

EEG1 = pop_select( EEG0, 'point',[1000 1e5] );
EEG1.setname='s08_IMB_cleaned_binica_dipfit_icapMAtap1';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_select( EEG0, 'point',[1e5 2e5] );
EEG2.setname='s08_IMB_cleaned_binica_dipfit_icapMArdlisten2';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_select( EEG0, 'point',[2.1e5 3.2e5] );
EEG3.setname='s08_IMB_cleaned_binica_dipfit_icapMAsync3';
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_select( EEG0, 'point',[3.4e5 1.6e6] );
EEG4.setname='s08_IMB_cleaned_binica_dipfit_icapMA_PTB_4';
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

% tap
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s08/';
EEG = pop_loadset('filename','s08_IMB_cleaned_binica_dipfit_icapMAtap1.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  'Tap'  }, [-0.3         0.5], 'newname', ...
    's08_IMB_cleaned_binica_dipfit_icapMAtap1_e', 'epochinfo', 'yes');
EEG.setname='s08_IMB_cleaned_binica_dipfit_icapMAtap1_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% rd listen
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s08/';
EEG = pop_loadset('filename','s08_IMB_cleaned_binica_dipfit_icapMArdlisten2.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  'WB'  }, [-0.3         0.5], 'newname', ...
    's08_IMB_cleaned_binica_dipfit_icapMArdlisten2_e', 'epochinfo', 'yes');
EEG.setname='s08_IMB_cleaned_binica_dipfit_icapMArdlisten2_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - listen
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s08/';
EEG = pop_loadset('filename','s08_IMB_cleaned_binica_dipfit_icapMAsync3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  'WB'  }, [-0.3         0.5], 'newname', ...
    's08_IMB_cleaned_binica_dipfit_icapMAsync3listen_e', 'epochinfo', 'yes');
EEG.setname='s08_IMB_cleaned_binica_dipfit_icapMAsync3listen_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - tap
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s08/';
EEG = pop_loadset('filename','s08_IMB_cleaned_binica_dipfit_icapMAsync3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  'Tap'  }, [-0.3         0.5], 'newname', ...
    's08_IMB_cleaned_binica_dipfit_icapMAsync3tap_e', 'epochinfo', 'yes');
EEG.setname='s08_IMB_cleaned_binica_dipfit_icapMAsync3tap_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

%% s09
clear all
close all
clc

filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/cmcohere/EEG';
EEG0 = pop_loadset('filename','s09_IMB_cleaned_binica_dipfit_icapMA.set' ,'filepath', filepath);

EEG1 = pop_select( EEG0, 'point',[1500 1e5] );
EEG1.setname='s09_IMB_cleaned_binica_dipfit_icapMAtap1';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_select( EEG0, 'point',[1e5 2e5] );
EEG2.setname='s09_IMB_cleaned_binica_dipfit_icapMArdlisten2';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_select( EEG0, 'point',[2.08e5 3.01e5] );
EEG3.setname='s09_IMB_cleaned_binica_dipfit_icapMAsync3';
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_select( EEG0, 'point',[5e5 1.75e6] );
EEG4.setname='s09_IMB_cleaned_binica_dipfit_icapMA_PTB_4';
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

% tap
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s09';
EEG = pop_loadset('filename','s09_IMB_cleaned_binica_dipfit_icapMAtap1.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  'Tap'  }, [-0.3         0.5], 'newname', ...
    's09_IMB_cleaned_binica_dipfit_icapMAtap1_e', 'epochinfo', 'yes');
EEG.setname='s09_IMB_cleaned_binica_dipfit_icapMAtap1_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% rd listen
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s09/';
EEG = pop_loadset('filename','s09_IMB_cleaned_binica_dipfit_icapMArdlisten2.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  'WB'  }, [-0.3         0.5], 'newname', ...
    's09_IMB_cleaned_binica_dipfit_icapMArdlisten2_e', 'epochinfo', 'yes');
EEG.setname='s09_IMB_cleaned_binica_dipfit_icapMArdlisten2_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - listen
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s09/';
EEG = pop_loadset('filename','s09_IMB_cleaned_binica_dipfit_icapMAsync3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  'WB'  }, [-0.3         0.5], 'newname', ...
    's09_IMB_cleaned_binica_dipfit_icapMAsync3listen_e', 'epochinfo', 'yes');
EEG.setname='s09_IMB_cleaned_binica_dipfit_icapMAsync3listen_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - tap
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s09/';
EEG = pop_loadset('filename','s09_IMB_cleaned_binica_dipfit_icapMAsync3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  'Tap'  }, [-0.3         0.5], 'newname', ...
    's09_IMB_cleaned_binica_dipfit_icapMAsync3tap_e', 'epochinfo', 'yes');
EEG.setname='s09_IMB_cleaned_binica_dipfit_icapMAsync3tap_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);