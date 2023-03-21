%% check if the AIB signal and the event signal are the same
clear all
clc
cd '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s01/raw'
EEG = pop_loadset('s01_AIB_output.set');
for nt = 1:length(EEG.event)
    tempt(nt) = EEG.event(nt).latency;
end    
tempt = round(tempt);
EEG.data(3,tempt) = max(EEG.data(1,:));

figure;
plot(EEG.data(1,:));
hold on 
plot(EEG.data(2,:));
hold on 
plot(EEG.data(3,:));
legend('AIB-taps','AIB-sounds','event')
%%
clear all
clc
cd '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s02/raw'
EEG = pop_loadset('s02_AIB_output.set');
for nt = 1:length(EEG.event)
    tempt(nt) = EEG.event(nt).latency;
end    
tempt = round(tempt);
EEG.data(3,tempt) = max(EEG.data(1,:));

figure;
plot(EEG.data(1,:));
hold on 
plot(EEG.data(2,:));
hold on 
plot(EEG.data(3,:));
legend('AIB-taps','AIB-sounds','Extract event')

%%
clear all
clc
cd '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s03/raw'
EEG = pop_loadset('s03_AIB_output.set');
for nt = 1:length(EEG.event)
    tempt(nt) = EEG.event(nt).latency;
end    
tempt = round(tempt);
EEG.data(3,tempt) = max(EEG.data(1,:));

figure;
plot(EEG.data(1,:));
hold on 
plot(EEG.data(2,:));
hold on 
plot(EEG.data(3,:));
legend('AIB-taps','AIB-sounds','event')

%%
clear all
close all
clc
cd '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s04/raw'
EEG = pop_loadset('s04_AIB_output.set');
for nt = 1:length(EEG.event)
    tempt(nt) = EEG.event(nt).latency;
end    
tempt = round(tempt);
EEG.data(3,tempt) = max(EEG.data(1,:));

figure;
plot(EEG.data(1,:));
hold on 
plot(EEG.data(2,:));
hold on 
plot(EEG.data(3,:));
legend('AIB-taps','AIB-sounds','event')

%%
clear all
clc
cd '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s05/raw'
EEG = pop_loadset('s05_AIB_output.set');
for nt = 1:length(EEG.event)
    tempt(nt) = EEG.event(nt).latency;
end    
tempt = round(tempt);
EEG.data(3,tempt) = max(EEG.data(1,:));

figure;
plot(EEG.data(1,:));
hold on 
plot(EEG.data(2,:));
hold on 
plot(EEG.data(3,:));
legend('AIB-taps','AIB-sounds','event')

%%
clear all
clc
cd '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/s06/raw'
EEG = pop_loadset('s06_AIB_output.set');
for nt = 1:length(EEG.event)
    tempt(nt) = EEG.event(nt).latency;
end    
tempt = round(tempt);
EEG.data(3,tempt) = max(EEG.data(1,:));

figure;
plot(EEG.data(1,:));
hold on 
plot(EEG.data(2,:));
hold on 
plot(EEG.data(3,:));
legend('AIB-taps','AIB-sounds','event')