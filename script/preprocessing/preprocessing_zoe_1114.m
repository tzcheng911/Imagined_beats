eeglab
clear
close all
clc

datapath  = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/insert_rbd';
cd(datapath)
File = 'zoe_rdb_evtag.set';
%% Tag the event codes by evtag.m done in my laptop
%% Preprocessing until trimoutlier
     EEG = pop_loadset('filename',File ,'filepath', datapath);
     EEG = pop_select( EEG, 'channel',{'A1' 'A2' 'A3' 'A4' 'A5' 'A6' 'A7' 'A8' 'A9' 'A10' 'A11' 'A12' 'A13' 'A14' 'A15' 'A16' 'A17' 'A18' 'A19' 'A20' 'A21' 'A22' 'A23' 'A24' 'A25' 'A26' 'A27' 'A28' 'A29' 'A30' 'A31' 'A32' 'B1' 'B2' 'B3' 'B4' 'B5' 'B6' 'B7' 'B8' 'B9' 'B10' 'B11' 'B12' 'B13' 'B14' 'B15' 'B16' 'B17' 'B18' 'B19' 'B20' 'B21' 'B22' 'B23' 'B24' 'B25' 'B26' 'B27' 'B28' 'B29' 'B30' 'B31' 'B32' 'C1' 'C2' 'C3' 'C4' 'C5' 'C6' 'C7' 'C8' 'C9' 'C10' 'C11' 'C12' 'C13' 'C14' 'C15' 'C16' 'C17' 'C18' 'C19' 'C20' 'C21' 'C22' 'C23' 'C24' 'C25' 'C26' 'C27' 'C28' 'C29' 'C30' 'C31' 'C32' 'D1' 'D2' 'D3' 'D4' 'D5' 'D6' 'D7' 'D8' 'D9' 'D10' 'D11' 'D12' 'D13' 'D14' 'D15' 'D16' 'D17' 'D18' 'D19' 'D20' 'D21' 'D22' 'D23' 'D24' 'D25' 'D26' 'D27' 'D28' 'D29' 'D30' 'D31' 'D32' 'E1' 'E2' 'E3' 'E4' 'E5' 'E6' 'E7' 'E8' 'E9' 'E10' 'E11' 'E12' 'E13' 'E14' 'E15' 'E16' 'E17' 'E18' 'E19' 'E20' 'E21' 'E22' 'E23' 'E24' 'E25' 'E26' 'E27' 'E28' 'E29' 'E30' 'E31' 'E32' 'F1' 'F2' 'F3' 'F4' 'F5' 'F6' 'F7' 'F8' 'F9' 'F10' 'F11' 'F12' 'F13' 'F14' 'F15' 'F16' 'F17' 'F18' 'F19' 'F20' 'F21' 'F22' 'F23' 'F24' 'F25' 'F26' 'F27' 'F28' 'F29' 'F30' 'F31' 'F32' 'G1' 'G2' 'G3' 'G4' 'G5' 'G6' 'G7' 'G8' 'G9' 'G10' 'G11' 'G12' 'G13'});
     EEG = pop_eegfiltnew(EEG, 45,0.1,16896,0,[],1);     
     EEG = pop_chanedit(EEG);
     EEG = pop_trimOutlier(EEG);
     EEG = pop_reref( EEG, []);
     EEG = clean_rawdata(EEG, 'off', 'off', 0.6, 'off', 5, 0.25); % change the criteria for s09 -- correlation = 0.6
     EEG.setname = 'zoe_rdb_cleaned.set';
     EEG.filename = EEG.setname;
     EEG = pop_saveset(EEG,'filename',char(EEG.setname),'filepath',datapath);

%% Inspect the data: confirm the event markers is correct and the data is clean enough
%% Preprocessing after cleaning the data
datapath  = '/data/projects/zoe/ImaginedBeats/real_exp/s09/raw_data';     
icadatasetFile = 'zoe_rdb_cleaned.set';
     parts = cellstr(split(icadatasetFile,'.'));
     EEG = pop_loadset('filename',icadatasetFile ,'filepath', datapath);
     EEG = eeg_checkset( EEG );    
     EEG = pop_runica(EEG, 'icatype', 'binica', 'extended',1);
     EEG.setname = strcat(parts(1),'_binica');
     filename = char(EEG.setname);
     EEG = pop_saveset(EEG,'filename',filename,'filepath',datapath);
     EEG = pop_dipfit_settings( EEG, 'hdmfile','/data/common/matlab/eeglab/plugins/dipfit2.3/standard_BEM/standard_vol.mat',...
    'coordformat','MNI','mrifile','/data/common/matlab/eeglab/plugins/dipfit2.3/standard_BEM/standard_mri.mat','chanfile',...
    '/data/common/matlab/eeglab/plugins/dipfit2.3/standard_BEM/elec/standard_1005.elc','coord_transform',...
    [-0.015 -22 -15 0.34907 0 -1.571 1050 990.1 990.1165] ,'chansel',[1:EEG.nbchan] ); % change the parameters to better fit the channel and headmodel
     EEG = pop_multifit(EEG, [1:EEG.nbchan] ,'threshold',100,'plotopt',{'normlen' 'on'});
     EEG = pop_saveset( EEG, 'filename','zoe_rdb_cleaned_binica_dipfit.set','filepath','/data/projects/zoe/ImaginedBeats/real_exp/s09');

%% Sementation
clear all
close all
clc

filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s09';
EEG0 = pop_loadset('filename','zoe_rdb_cleaned_binica_dipfit_icapMA.set' ,'filepath', filepath);

EEG1 = pop_select( EEG0, 'point',[1500 1e5] );
EEG1.setname='zoe_rdb_cleaned_binica_dipfit_tap1';
filename = char(EEG1.setname);
EEG1 = pop_saveset(EEG1,'filename',filename,'filepath',filepath);

EEG2 = pop_select( EEG0, 'point',[1e5 2e5] );
EEG2.setname='zoe_rdb_cleaned_binica_dipfit_rdlisten2';
filename = char(EEG2.setname);
EEG2 = pop_saveset(EEG2,'filename',filename,'filepath',filepath);

EEG3 = pop_select( EEG0, 'point',[2.08e5 3.01e5] );
EEG3.setname='zoe_rdb_cleaned_binica_dipfit_sync3';
filename = char(EEG3.setname);
EEG3 = pop_saveset(EEG3,'filename',filename,'filepath',filepath);

EEG4 = pop_select( EEG0, 'point',[5e5 1.75e6] );
EEG4.setname='zoe_rdb_cleaned_binica_dipfit_PTB_4';
filename = char(EEG4.setname);
EEG4 = pop_saveset(EEG4,'filename',filename,'filepath',filepath);

% tap
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s09';
EEG = pop_loadset('filename','zoe_rdb_cleaned_binica_dipfit_tap1.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  'Tap'  }, [-0.3         0.5], 'newname', ...
    'zoe_rdb_cleaned_binica_dipfit_tap1_e', 'epochinfo', 'yes');
EEG.setname='zoe_rdb_cleaned_binica_dipfit_tap1_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% rd listen
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s09/';
EEG = pop_loadset('filename','zoe_rdb_cleaned_binica_dipfit_rdlisten2.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  'WB'  }, [-0.3         0.5], 'newname', ...
    'zoe_rdb_cleaned_binica_dipfit_rdlisten2_e', 'epochinfo', 'yes');
EEG.setname='zoe_rdb_cleaned_binica_dipfit_rdlisten2_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - listen
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s09/';
EEG = pop_loadset('filename','zoe_rdb_cleaned_binica_dipfit_sync3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  'WB'  }, [-0.3         0.5], 'newname', ...
    'zoe_rdb_cleaned_binica_dipfit_sync3listen_e', 'epochinfo', 'yes');
EEG.setname='zoe_rdb_cleaned_binica_dipfit_sync3listen_e';
EEG = pop_rmbase( EEG, [-100          -50]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);

% sync - tap
clear all
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s09/';
EEG = pop_loadset('filename','zoe_rdb_cleaned_binica_dipfit_sync3.set'...
    ,'filepath',filepath);
EEG = pop_epoch( EEG, {  'Tap'  }, [-0.3         0.5], 'newname', ...
    'zoe_rdb_cleaned_binica_dipfit_sync3tap_e', 'epochinfo', 'yes');
EEG.setname='zoe_rdb_cleaned_binica_dipfit_sync3tap_e';
EEG = pop_rmbase( EEG, [-300.7812          -250]);
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',filepath);
     