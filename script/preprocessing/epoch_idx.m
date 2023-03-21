%% Set path
cd('/Applications/eeglab2021.1')
eeglab
addpath('/Volumes/TOSHIBA/Research/Imagined_beats/script/analysis')
addpath('/Volumes/TOSHIBA/Research/Imagined_beats/script/JI_supporting_MatLabFiles')
addpath('/Volumes/TOSHIBA/Research/Imagined_beats/script/preprocessing')

%%
clear
sync_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/sync/';
sync_files = dir(fullfile(sync_path,'*sync3s.set'));
sync_name = {sync_files.name};

% Load files and save removed epoch idx
for nsub = 1:length(sync_name)
    tempEEG = sync_name{nsub};
    parts = cellstr(split(tempEEG,'.'));
    EEG = pop_loadset('filename',tempEEG ,'filepath', sync_path);
    EEG = eeg_checkset(EEG);
    
    for n = 1:length(EEG.event)
        if string(EEG.event(n).type) == 'Tap'
           taps (n,1) = EEG.event(n).latency/EEG.srate*1000;
        elseif string(EEG.event(n).type) == 'WB'
           listens(n,1) = EEG.event(n).latency/EEG.srate*1000;
        end
    end
    new_taps = taps(taps~=0);
    new_listens = listens(listens~=0);

    
    [EEG_sync3s_e,tmp_acceptedind_sync3s_e] = pop_epoch( EEG, {'WB'}, [-0.3 0.5]);
    acceptedind_sync3s_e{nsub} = tmp_acceptedind_sync3s_e;
    disp(EEG_sync3s_e.trials)

    [EEG_sync3t_e,tmp_acceptedind_sync3t_e] = pop_epoch( EEG, {'Tap'}, [-0.3 0.5]);
    acceptedind_sync3t_e{nsub} = tmp_acceptedind_sync3t_e;
    disp(EEG_sync3t_e.trials)    
    
    new_taps = new_taps(tmp_acceptedind_sync3t_e); % remove the tap trials rejected by pop_epoch 
    new_listens = new_listens(tmp_acceptedind_sync3s_e); % remove the sound trials rejected by pop_epoch
    
    tap_results{nsub} = calc_tap_z(new_taps, new_listens);
    lonely_sounds_ind = setdiff(1:length(new_listens),tap_results{nsub}.ipresound);
    
    EEG_sync3s_e_nols = pop_select(EEG_sync3s_e,'notrial',lonely_sounds_ind); % exclude the lonely sounds and the last element
    
    disp('EEG trial number vs. rp trial number')
    disp(EEG_sync3s_e_nols.trials)
    disp(length(tap_results{nsub}.rp))
    
    if EEG_sync3s_e_nols.trials == length(tap_results{nsub}.rp)
        EEG = pop_saveset(EEG_sync3s_e_nols,'filename',filename,'filepath',sync_path);
    else
        disp('The EEG trials and taps do not match.')
    end
    
    clear tmp_acceptedind_sync3t_e tmp_acceptedind_sync3s_e EEG_sync3t_e EEG_sync3s_e EEG
end

%% Set path
cd('/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/sync/')
sync_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/sync/';
sync_files = dir(fullfile(sync_path,'*sync3t_e.set'));
sync_name = {synce_files.name};

% remove the epochs of double taps and the last tap
load('calc_tap_output.mat')
load('relative_phase.mat')

for nsub = 1:length(synce_name)
    tempEEG = synce_name{nsub};
    parts = cellstr(split(tempEEG,'.'));
    EEG = pop_loadset('filename',tempEEG ,'filepath', sync_path);
    EEG = eeg_checkset(EEG);
    idbl = tap_results{nsub}.idbl;
    
    % confirm the number of EEG trials and taps 
    disp(EEG.trials)
    disp(length(tap_results{nsub}.rp))
    EEG.setname = char(strcat(parts(1),'_nodbl'));
    filename = EEG.setname;
    if EEG.trials == length(tap_results{nsub}.rp)
        EEG = pop_saveset(EEG,'filename',filename,'filepath',sync_path);
    else
        disp('The EEG trials and taps do not match.')
    end
    
    % exclude relphase outliers 
    
    EEG = pop_select(EEG,'notrial',[idbl,EEG.trials]); % exclude the dbl and the last element
    
    clear idbl EEG
end

%% How many taps for each subject
cd('/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/sync/')
sync_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/sync/';
sync_files = dir(fullfile(sync_path,'*sync3t_e.set'));
sync_name = {sync_files.name};

for nsub = 1:length(sync_name)
    tempEEG = sync_name{nsub};
    parts = cellstr(split(tempEEG,'.'));
    EEG = pop_loadset('filename',tempEEG ,'filepath', sync_path);
    
    % confirm the number of EEG trials and taps 
    disp(EEG.trials)
    trials(nsub) = EEG.trials;
end

%% How many missing beats in SMS
load('/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/sync/calc_tap_output.mat')
for i =  1:25
%    disp(sync_name{i})
    disp(num2str(i))
    disp(tap_results{i}.total_n_missed)
    disp(length(tap_results{i}.valid_t_down))
    taps(i) = length(tap_results{i}.valid_t_down)
end

%% How many outlier relative phases based on criteria of [-0.3 0.1]
load('/Volumes/TOSHIBA/Research/Imagined_beats/results/Localizers/sync/relative_phase.mat')
for i =  1:25
    disp(sync_name{i})
    disp(num2str(i))
    disp(sum(relative_phase{i}>0.1 | relative_phase{i}<-0.3))
end

%% Let's restart everything 
clear
clc
sync_path = '/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/localizer_trials/sync/';
sync_files = dir(fullfile(sync_path,'*sync3s.set'));
sync_name = {sync_files.name};

%% Load files and save removed epoch idx
% not working for nsub = 5,10,16,17,18,19 
for nsub = 1:length(sync_name)

    tempEEG = sync_name{nsub};
    parts = cellstr(split(tempEEG,'.'));
    EEG = pop_loadset('filename',tempEEG ,'filepath', sync_path);
    EEG = eeg_checkset(EEG);
    
    for n = 1:length(EEG.event)
        if string(EEG.event(n).type) == 'Tap'
           taps (n,1) = EEG.event(n).latency/EEG.srate*1000;
        elseif string(EEG.event(n).type) == 'WB'
           listens(n,1) = EEG.event(n).latency/EEG.srate*1000;
        end
    end
    new_taps = taps(taps~=0);
    new_listens = listens(listens~=0);
    
    [EEG_sync3s_e,tmp_acceptedind_sync3s_e] = pop_epoch( EEG, {'WB'}, [-0.3 0.5]);
    acceptedind_sync3s_e{nsub} = tmp_acceptedind_sync3s_e;

    [EEG_sync3t_e,tmp_acceptedind_sync3t_e] = pop_epoch( EEG, {'Tap'}, [-0.3 0.5]);
    acceptedind_sync3t_e{nsub} = tmp_acceptedind_sync3t_e;
    
    new_taps = new_taps(tmp_acceptedind_sync3t_e); % remove the tap trials rejected by pop_epoch 
    new_listens = new_listens(tmp_acceptedind_sync3t_e); % remove the tap trials rejected by pop_epoch ***this is the crucial step to match the trial number***
    
    tap_results{nsub} = calc_tap_z(new_taps, new_listens);
    
    if length(tmp_acceptedind_sync3t_e) <= length(tmp_acceptedind_sync3s_e)
        EEG_sync3s_e = pop_select(EEG_sync3s_e,'trial',tmp_acceptedind_sync3t_e);
    end
    
    list_to_remove = [tap_results{nsub}.idbl tap_results{nsub}.ilatetaps tap_results{nsub}.iearlytaps];
    EEG_sync3s_e_nodb = pop_select(EEG_sync3s_e,'notrial',list_to_remove); % exclude the double taps

    EEG_sync3s_e_nodb.setname = char(strcat(parts(1),'_nodbl'));
    filename = EEG_sync3s_e_nodb.setname;

    disp('EEG trial number vs. rp trial number')
    disp(EEG_sync3s_e_nodb.trials)
    disp(length(tap_results{nsub}.rp))
    
%     if EEG_sync3s_e_nodb.trials == length(tap_results{nsub}.rp)
%         EEG = pop_saveset(EEG_sync3s_e_nodb,'filename',filename,'filepath',sync_path);
%     else
%         disp('The EEG trials and taps do not match.')
%     end
    clear tmp_acceptedind_sync3t_e tmp_acceptedind_sync3s_e EEG_sync3t_e EEG_sync3s_e EEG_sync3s_e_nodb EEG taps listens n
end