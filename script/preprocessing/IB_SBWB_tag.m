clear
close all
clc
%% Duple 
outpath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/test_SSEP/PB';
cd('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s01/icapMA')
EEG = pop_loadset('s01_IMB_icapMA_duple_IM.set');
type = {EEG.event.type};
IM_ind = find(ismember(type, 'IM'));

for n = 1:12
    switch mod(n,2)
        case 1
            temp_type{n} = char({'WB1'});
        case 0
            temp_type{n} = char({'WB2'});
    end
end

for i = 1:length(IM_ind)
    type(IM_ind(i)+1:IM_ind(i)+12) = temp_type;
end

for j = 1:length(EEG.event)
    [EEG.event(j).type] =  char(type(j));
end

old_filename = EEG.setname;
filename = strcat(old_filename,'_evtag');
EEG = pop_saveset(EEG,'filename',filename,'filepath',outpath);

%% Triple
clear 
outpath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/test_SSEP/PB';
cd('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s01/icapMA')
EEG = pop_loadset('s01_IMB_icapMA_triple_IM.set');
events = EEG.event;
type = {EEG.event.type};
IM_ind = find(ismember(type, 'IM'));

for n = 1:12
    switch mod(n,3)
        case 1
            temp_type{n} = char({'WB1'});
        case 2
            temp_type{n} = char({'WB2'});
        case 0
            temp_type{n} = char({'WB3'});
    end
end

for i = 1:length(IM_ind)
    type(IM_ind(i)+1:IM_ind(i)+12) = temp_type;
end

for j = 1:length(EEG.event)
    [EEG.event(j).type] =  char(type(j));
end

old_filename = EEG.setname;
filename = strcat(old_filename,'_evtag');
EEG = pop_saveset(EEG,'filename',filename,'filepath',outpath);
