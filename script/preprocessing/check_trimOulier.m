clean_path = '/data/projects/zoe/ImaginedBeats/real_exp/preprocessed';
clean_files = dir(fullfile(clean_path,'*clean.set'));
clean_name = {clean_files.name};

for nsub = 1:length(clean_name)
    tempEEG = clean_name{nsub};
    parts_cleanEEG = cellstr(split(tempEEG,'.'));
    EEG = pop_loadset('filename',tempEEG ,'filepath', clean_path);
    parts_cleanEEG(1)
    EEG.nbchan
    EEG.history(300:333)
end