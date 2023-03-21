clear
close all
clc
sub = {'s01','s02','s03','s04','s05','s06','s07','s08','s09'};
meter = {'Duple','Triple'};
for nsub = 7:9
filepath = strcat('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/',sub(nsub),'/raw');
savepath = strcat('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/',sub(nsub),'/icapMA');
filename = strcat(sub(nsub),'_evtag_AIB7','.set');
    for nmeter = 1:length(meter)
EEG = pop_loadset('filename',filename,'filepath',filepath{:});
savename = strcat(sub(nsub),'_evtag_',meter(nmeter),'_tapbeh','.set');
setname = strcat(sub(nsub),'_evtag_',meter(nmeter),'_tapbeh');
EEG = pop_rmdat( EEG, meter(nmeter),[-2 25] ,0);
EEG = pop_epoch( EEG, {  'IM'  }, [5         13], 'newname', setname{:}, 'epochinfo', 'yes');
EEG.setname = setname{:};
EEG = pop_saveset(EEG,'filename',savename{:},'filepath',savepath{:});
    end
   clear EEG 
end




