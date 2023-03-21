%%
clear all
close all
clc
cd '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s06/raw'
EEG = pop_loadset('filename','s06_IMB_evtag.set');
tap = EEG.data(end-32+7,:);
trigger = EEG.data(end-32+8,:);
EEG.data = [tap;trigger];
filename = 's06_AIB_output';
EEG = pop_saveset(EEG,'filename',filename);

%%
clear all
close all
clc
cd '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s05/raw'
EEG = pop_loadset('filename','s05_IMB_evtag.set');
tap = EEG.data(end-32+7,:);
trigger = EEG.data(end-32+8,:);
EEG.data = [tap;trigger];
filename = 's05_AIB_output';
EEG = pop_saveset(EEG,'filename',filename);
%%
clear all
close all
clc
cd '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s04/raw'
EEG = pop_loadset('filename','s04_IMB_evtag.set');
tap = EEG.data(end-32+7,:);
trigger = EEG.data(end-32+8,:);
EEG.data = [tap;trigger];
filename = 's04_AIB_output';
EEG = pop_saveset(EEG,'filename',filename);

%%
clear all
close all
clc
cd '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s03/raw'
EEG = pop_loadset('filename','s03_IMB_evtag.set');
tap = EEG.data(end-32+7,:);
trigger = EEG.data(end-32+8,:);
EEG.data = [tap;trigger];
filename = 's03_AIB_output';
EEG = pop_saveset(EEG,'filename',filename);

%%
clear all
close all
clc
cd '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s02/raw'
EEG = pop_loadset('filename','s02_IMB_evtag.set');
tap = EEG.data(end-32+7,:);
trigger = EEG.data(end-32+8,:);
EEG.data = [tap;trigger];
filename = 's02_AIB_output';
EEG = pop_saveset(EEG,'filename',filename);

%%
clear all
close all
clc
cd '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s01/raw'
EEG = pop_loadset('filename','s01_IMB_evtag.set');
tap = EEG.data(end-32+7,:);
trigger = EEG.data(end-32+8,:);
EEG.data = [tap;trigger];
filename = 's01_AIB_output';
EEG = pop_saveset(EEG,'filename',filename);