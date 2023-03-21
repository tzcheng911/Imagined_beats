%% check how many points are removed after clean_rawdata
clean_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/preprocessed';
clean_files = dir(fullfile(clean_path,'*dipfit.set'));
clean_name = {clean_files.name};

for nsub = 1:length(clean_name)
    tempEEG = clean_name{nsub};
    EEG = pop_loadset('filename',tempEEG ,'filepath', clean_path);
    comparecrd(1,nsub) = EEG.pnts; % after clean_rawdata
    comparecrd(2,nsub) = length(EEG.etc.clean_sample_mask); % before clean_rawdata
    clear tempEEG EEG
end

%% check how many trials for each condition in IMB
clean_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/preprocessed/epoch';
clean_files = dir(fullfile(clean_path,'*_e.set'));
clean_name = {clean_files.name};

for nsub = 1:length(clean_name)
    tempEEG = clean_name{nsub};
    EEG = pop_loadset('filename',tempEEG ,'filepath', clean_path);
    tempepoch_num(nsub) = size(EEG.data,3); % after clean_rawdata
    clear tempEEG EEG
end
epoch_num = reshape(tempepoch_num,12,23)';

%% check how many trials for each condition in localizers
clean_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/rdlisten'; % rdlisten, spontap, sync
clean_files = dir(fullfile(clean_path,'*rdlisten2_e.set'));
clean_name = {clean_files.name};

for nsub = 1:length(clean_name)
    tempEEG = clean_name{nsub};
    EEG = pop_loadset('filename',tempEEG ,'filepath', clean_path);
    tempepoch_num0(nsub) = size(EEG.data,3); % after clean_rawdata
    clear tempEEG EEG
end
tempepoch_num = tempepoch_num0';
tempepoch_num([2,7,10,19,23]) = [];
mean(tempepoch_num)
std(tempepoch_num)
