for i = 1:length(EEG.event)
    if EEG.event(i).type == {'2'}
        str2num(EEG.event(i).type)
        && (EEG.event(i+1).type == {'2'})
        