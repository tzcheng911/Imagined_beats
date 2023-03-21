clean_path = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/preprocessed';
clean_files = dir(fullfile(clean_path,'*clean.set'));
clean_name = {clean_files.name};

nsub = 9;
tempEEG = clean_name{nsub};
parts_cleanEEG = cellstr(split(tempEEG,'.'));
EEG = pop_loadset('filename',tempEEG ,'filepath', clean_path);
EEG = eeg_checkset( EEG );    
EEG = clean_rawdata(EEG, 'off', 'off', 0.6, 'off', 5, 0.25, 4);
EEG.setname = strcat(parts_cleanEEG(1),'_crd21');
filename = char(EEG.setname);
EEG = pop_saveset(EEG,'filename',filename,'filepath',clean_path);


