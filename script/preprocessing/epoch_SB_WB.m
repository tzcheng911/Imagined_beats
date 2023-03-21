%% PB
% strong beat of PB
clear
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s07/icapMA';
outpath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/test_SSEP/PB';
EEG_o = pop_loadset('filename','s07_IMB_icapMA_triple_SBL.set'...
    ,'filepath',filepath);
EEG_1 = pop_epoch( EEG_o, {  'SB'  }, [-0.4         0.4], 'newname', ...
    's07_IMB_icapMA_triple_SBL_1', 'epochinfo', 'yes');
EEG_1.setname='s07_IMB_icapMA_triple_SBL_1';
EEG_1 = pop_rmbase( EEG_1, [-100          -50]);
filename = char(EEG_1.setname);
EEG_1 = pop_saveset(EEG_1,'filename',filename,'filepath',outpath);

% weak beat of PB
EEG_0 = pop_epoch( EEG_o, {  'WB'  }, [-0.4         0.4], 'newname', ...
    's07_IMB_icapMA_triple_SBL_0', 'epochinfo', 'yes');
EEG_0.setname='s07_IMB_icapMA_triple_SBL_0';
EEG_0 = pop_rmbase( EEG_0, [-100          -50]);
filename = char(EEG_0.setname);
EEG_0 = pop_saveset(EEG_0,'filename',filename,'filepath',outpath);

%% IM
% strong beat of PB
clear
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s07/icapMA';
outpath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/test_SSEP/IB';
EEG_o = pop_loadset('filename','s07_IMB_icapMA_duple_IM_evtag.set'...
    ,'filepath',filepath);
EEG_1 = pop_epoch( EEG_o, {  'WB1'  }, [-0.1         0.4], 'newname', ...
    's07_IMB_icapMA_duple_IM_1', 'epochinfo', 'yes');
EEG_1.setname='s07_IMB_icapMA_duple_IM_1';
EEG_1 = pop_rmbase( EEG_1, [-100          -50]);
filename = char(EEG_1.setname);
EEG_1 = pop_saveset(EEG_1,'filename',filename,'filepath',outpath);

% weak beat of PB
EEG_0 = pop_epoch( EEG_o, {  'WB2'  }, [-0.1         0.4], 'newname', ...
    's07_IMB_icapMA_duple_IM_0', 'epochinfo', 'yes');
EEG_0.setname='s07_IMB_icapMA_duple_IM_0';
EEG_0 = pop_rmbase( EEG_0, [-100          -50]);
filename = char(EEG_0.setname);
EEG_0 = pop_saveset(EEG_0,'filename',filename,'filepath',outpath);