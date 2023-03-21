% eeglab
clear
close all
clc

%% Load the files - localizer
addpath(genpath('/Volumes/TOSHIBA EXT/Research/Imagined_beats/script'))

EEG_path = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/localizer_trials/rdlisten';
rdlisten_files = dir(fullfile(EEG_path,'*rdlisten2_e.set'));
rdlisten_name = {rdlisten_files.name};
rdlisten_name(19) = [];
rdlisten_name(10) = [];
% Parameters

% am selection 1
% amIC(1,:) = [6;8;13;9;8;3;7;5;2;9;32;3;8;6;6;3;5;3;7;4;6;4;5;3;4]; % representative auditory ICs
% amIC(2,:) = [11;4;11;11;10;11;10;4;29;16;15;7;18;8;16;21;12;18;17;17;11;9;14;21;8]; % representative motor ICs

% am selection 2
% new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	7	4	1	1	5	13	4];
% new_amIC(2,:) = [11	1	11	11	10	11	10	4	13	16	15	7	18	8	10	21	12	36	17	17	6	9	14	21	8];

% am selection 3 
% new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	6	4	1	4	5	13	4];
% new_amIC(2,:) = [11	1	11	11	10	11	7	4	29	6	15	7	18	8	16	21	11	36	17	17	6	1	14	17	8];

% am selection 4
% new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	6	4	1	1	5	8	4];
% new_amIC(2,:) = [8	1	11	11	24	11	8	4	13	4	15	7	18	8	16	21	12	36	4	17	6	4	14	17	8];

% am selection 4b
% new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	6	4	1	1	5	8	4];
% new_amIC(2,:) = [8	1	11	11	10	11	7	4	13	4	15	7	18	8	16	21	12	36	4	17	6	9	14	21	8];

% am selection 4c
new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	6	4	1	1	5	8	4];
new_amIC(2,:) = [8	1	11	11	10	11	7	4	13	4	15	7	18	8	16	21	12	36	4	17	6	4	24	21	8];

EEG_fs = 512; % EEG srate
trial_length = 150; % each trial is max 25 s
pres_rate = 2.4;
filtSpec.range = [2 3]; % frequency of interest 2 - 3 Hz in IMB
filtSpec.order = ceil(EEG_fs * 4 / min(filtSpec.range)); % contain at least 4 cycles of the lowest freq
plv = zeros(length(rdlisten_name),EEG_fs*trial_length,3,3); % sub, time, 3 components (including env), 3 components (including env)

% Get the envelop from the sound files 
[stimuli,stimuli_fs] = audioread('/Users/t.z.cheng/Google_Drive/Research/Imaginedbeat/materials/Socal_drumbeat.mp3');
sound = stimuli(1:1/2.4*stimuli_fs,1); % create 1/2.4 IOI
catsound = repmat(sound,[trial_length*pres_rate,1]); % repeat for 60 times (5 x 12) for the longest possible randomization
env_catsound = abs(hilbert(catsound)); % get the envelop of the sound stimuli
env_catsound_r = resample(env_catsound,EEG_fs,stimuli_fs); % downsample to match EEG signal

% Load the EEG of each subject
for nsub = 1:length(rdlisten_name)
    data_name = strcat(sub(nsub),'_evtag_512_clean_binica_dipfit_',meter(nmeter),'_',cond(ncond),'_e.set');
    parts_cleanEEG = cellstr(split(data_name,'.'));
    EEG = pop_loadset('filename',data_name ,'filepath', EEG_path); % epoched data
    EEG = eeg_checkset(EEG);
    eeg = EEG.icaact(new_amIC(:,nsub),1:EEG_fs*trial_length);
    eeg(3,:,:) = env_catsound_r*5; % target matrix includes 
    % EEG and sound env (components x time x trials)
    % consider sound env as one component (the last one) to use pn_eegPLV.m
    tempplv = Zoe_plv(eeg, EEG_fs, filtSpec,0.25); % calculate PLV between the sound env and EEG. 
    % Note that the baseline normalization procedure shown in the figure is not yet implemented in the script.
    plv(nsub,:,:,:,:) = tempplv;
    clear eeg
end

meanplv = squeeze(mean(plv,1));
% figure; imagesc(squeeze(mean(meanplv,1))); colorbar
figure; plot(EEG.times(EEG_fs+1:end),squeeze(meanplv(:,1:2,3)),'LineWidth',2)
gridx([0.5 1 1.5 2]*1e4)
xlabel('Time (ms)')
legend('aIC','mIC')
title('PLV between sound env and EEG in duple condition')
set(gca,'FontSize',18)

% save triple_plv plv times meanplv EEG_fs

% plv(sub, time, IC, IC) IC order: auditory, motor ICs, sound envelope

%% Load the files - IMB
clear
close all
clc

%% Parameters 
cd('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/results/Main_task/PLV/AM4b')
addpath(genpath('/Volumes/TOSHIBA EXT/Research/Imagined_beats/script'))
sub = {'s02','s03','s04','s05','s06','s07','s08','s09','s10','s11','s12','s13','s14','s15'...
    ,'s16','s17','s18','s19','s20','s21','s22','s23','s24','s26','s27'};
data_path = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/preprocessed/epoch/5sphases';
cond = {'BL','PB','IB','tap'};
meter = {'duple','triple'};

% Parameters
% am selection 1
% amIC(1,:) = [6;8;13;9;8;3;7;5;2;9;32;3;8;6;6;3;5;3;7;4;6;4;5;3;4]; % representative auditory ICs
% amIC(2,:) = [11;4;11;11;10;11;10;4;29;16;15;7;18;8;16;21;12;18;17;17;11;9;14;21;8]; % representative motor ICs

% am selection 2
% new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	7	4	1	1	5	13	4];
% new_amIC(2,:) = [11	1	11	11	10	11	10	4	13	16	15	7	18	8	10	21	12	36	17	17	6	9	14	21	8];

% am selection 3 
% new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	6	4	1	4	5	13	4];
% new_amIC(2,:) = [11	1	11	11	10	11	7	4	29	6	15	7	18	8	16	21	11	36	17	17	6	1	14	17	8];

% am selection 4
% new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	6	4	1	1	5	8	4];
% new_amIC(2,:) = [8	1	11	11	24	11	8	4	13	4	15	7	18	8	16	21	12	36	4	17	6	4	14	17	8];

% am selection 4b
new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	6	4	1	1	5	8	4];
new_amIC(2,:) = [8	1	11	11	10	11	7	4	13	4	15	7	18	8	16	21	12	36	4	17	6	9	14	21	8];

% am selection 4c
% new_amIC(1,:) = [6	8	3	9	8	3	7	5	2	9	1	3	8	6	1	1	5	3	6	4	1	1	5	8	4];
% new_amIC(2,:) = [8	1	11	11	10	11	7	4	13	4	15	7	18	8	16	21	12	36	4	17	6	4	24	21	8];

EEG_fs = 512; % EEG srate
trial_length = 5; % each trial is max 25 s
pres_rate = 2.4;
filtSpec.range = [0.5 2]; % frequency of interest 2 - 3 Hz in IMB
filtSpec.order = ceil(EEG_fs * 4 / min(filtSpec.range)); % contain at least 4 cycles of the lowest freq

%% remove subjects here 
rmsub = {'s03','s08','s11','s20','s24'}; % N20
% rmsub = {'s08','s11','s20'}; % N22

for i = 1:length(rmsub)
    rmsub_idx(i) = find(strcmp(sub,rmsub{i}));
end
new_amIC(:,rmsub_idx) =[];
sub(rmsub_idx) =[];

% Deal with the sound files to get the envelop
[stimuli,stimuli_fs] = audioread('/Users/t.z.cheng/Google_Drive/Research/Imaginedbeat/materials/Socal_drumbeat.mp3');
sound = stimuli(1:1/2.4*stimuli_fs,1); % create 1/2.4 IOI
catsound = repmat(sound,[trial_length*2.4,1]); % repeat for 60 times (5 x 12) for the longest possible randomization
env_catsound = abs(hilbert(catsound)); % get the envelop of the sound stimuli
env_catsound_r = resample(env_catsound,EEG_fs,stimuli_fs); % downsample to match EEG signal

%% Load the EEG of each subject
disp('Make sure the sound trial and EEG trial start together (check onset)!!')

for nsub = 1:length(sub)
    for nmeter = 1:length(meter)
        for ncond = 1:length(cond)
            data_name = strcat(sub(nsub),'_evtag_512_clean_binica_dipfit_',meter(nmeter),'_',cond(ncond),'_e.set');
            parts_cleanEEG = cellstr(split(data_name{:},'.'));
            EEG = pop_loadset('filename',data_name{:} ,'filepath', data_path); % epoched data
            EEG = eeg_checkset(EEG);
            findtapevents = cellstr(split(data_name{:},'_')); % deal with the tapping condition, epoch based on IB
            if findtapevents{8}(1) == 't' 
                EEG.times = EEG.times - 5e3;
            end
            onset = find(EEG.times == 0);
            eeg = EEG.icaact(new_amIC(:,nsub),onset:end,:);
            soundtrial = repmat(env_catsound_r,[1,EEG.trials]); % target matrix includes
            eeg(3,:,:) = soundtrial(1:size(eeg,2),:); % need to match the beginning of the EEG trial 
            % EEG and sound env (components x time x trials)
            % consider sound env as one component (the last one) to use pn_eegPLV.m
            [tmptrialplv, tmpswtimeplv,tmptimeplv, tmpcompx] = Zoe_plv(eeg, EEG_fs, filtSpec,2); % calculate PLV between the sound env and EEG. 
            % Note that the baseline normalization procedure shown in the figure is not yet implemented in the script.
            trialplv(nsub,nmeter,ncond,:,:,:) = tmptrialplv;
            swtimeplv(nsub,nmeter,ncond,:,:,:) = tmpswtimeplv;
            timeplv(nsub,nmeter,ncond,:,:) = squeeze(mean(tmptimeplv,1)); % average across trials
            compx(nsub,nmeter,ncond,:,:,:) = tmpcompx;
            clear eeg
        end
    end
end
times = EEG.times;
%save timeplvN20_AM4c trialplv timeplv EEG_fs times

%% Extract data for statistic testing 
clear 
load('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/results/Main_task/PLV/AM4/timeplvN20_AM4b.mat');
as = squeeze(timeplv(:,:,:,1,3));
ms = squeeze(timeplv(:,:,:,2,3));
am = squeeze(timeplv(:,:,:,1,2));

astimeplv = reshape(permute(as,[1,3,2]),[size(as,1),size(as,2)*size(as,3),1]); % Need to swap d2 amd d3 for the reshape
mstimeplv = reshape(permute(ms,[1,3,2]),[size(as,1),size(as,2)*size(as,3),1]); % Need to swap d2 amd d3 for the reshape
amtimeplv = reshape(permute(am,[1,3,2]),[size(as,1),size(as,2)*size(as,3),1]); % Need to swap d2 amd d3 for the reshape

%% Plot the results
% inter-trial
meanplv = squeeze(mean(trialplv,1));
errplv = squeeze(std(trialplv))./sqrt(length(name));

figure; 
plotShadedError(EEG.times(EEG_fs+1:end),squeeze(meanplv(:,1,3)),squeeze(errplv(:,1,3)),'k');
hold on 
plotShadedError(EEG.times(EEG_fs+1:end),squeeze(meanplv(:,2,3)),squeeze(errplv(:,2,3)),'b');

gridx([0.5 1 1.5 2]*1e4)
legend('aIC','mIC')
xlabel('Time (ms)')
set(gca,'FontSize',18)
title('Inter-trial PLV between sound and EEG in duple condition (2 - 3 Hz)')

% inter-time
meanplv = squeeze(mean(timeplv_triple,1));
errplv = squeeze(std(timeplv_triple))./sqrt(length(name));

figure; 
plotShadedError(EEG.times(EEG_fs+1:end-2*EEG_fs/2),squeeze(meanplv(:,1,3)),squeeze(errplv(:,1,3)),'k');
hold on 
plotShadedError(EEG.times(EEG_fs+1:end-2*EEG_fs/2),squeeze(meanplv(:,2,3)),squeeze(errplv(:,2,3)),'b');

gridx([0.5 1 1.5 2]*1e4)
legend('aIC','mIC')
xlabel('Time (ms)')
set(gca,'FontSize',14)
title('Inter-time PLV between sound and EEG in duple condition (2 - 3 Hz, win = 0.5 s)')


figure; plot(EEG.times(EEG_fs+1:end),squeeze(meanplv(:,1:2,3)),'LineWidth',2)
gridx([0.5 1 1.5 2]*1e4)
legend('aIC','mIC')
xlabel('Time (ms)')
set(gca,'FontSize',18)
title('PLV between sound env and EEG in duple condition (2 - 3 Hz)')

% plot complex
phase = size(compx_triple,2)/5;

test_mean_compx = squeeze(mean(compx_triple(:,phase*4+1:phase*5,1,3),1));
figure;compass(test_mean_compx)
title('inter-time compx between sound and aIC')

%% plot the figure outlier: s08
IC1 = 2; % 1: auditory, 2: motor, 3:sound env 
IC2 = 3; % 1: auditory, 2: motor, 3:sound env
% time = 1:12800; % 0 to 25 sec
time = 1:10753; % 0 to 21 sec

phaselen = 2560;
phases = [time(1),phaselen;phaselen+1,2*phaselen;2*phaselen+1,3*phaselen;3*phaselen+1,4*phaselen;4*phaselen+1,time(end)];

cd('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/preprocessed/epoch')
triple = load('triple_plv.mat'); 
duple = load('duple_plv.mat');

duple.plv(7,:,:,:) = [];
triple.plv(7,:,:,:) = [];

mean_duple = mean(squeeze(duple.plv(:,time,IC1,IC2)),1); 
mean_triple = mean(squeeze(triple.plv(:,time,IC1,IC2)),1);
mean_duple_triple = 0.5*(duple.plv+triple.plv);

mean_auditory = mean(mean_duple_triple(:,time,1,3),1);
mean_motor = mean(mean_duple_triple(:,time,2,3),1);

%%
for i = 1:length(time)
    err_duple(i) = std(squeeze(duple.plv(:,i,IC1,IC2)));
    err_triple(i) = std(squeeze(triple.plv(:,i,IC1,IC2)));
end

figure; plotShadedError(duple.times,mean_duple,err_duple)
figure; plotShadedError(duple.times,mean_triple,err_triple)
xlabel('Time (ms)')
ylabel('PLV')

figure; plot(duple.times(time)/1000,[mean_duple;mean_triple],'LineWidth',2)
xlabel('Time (s)')
legend('March','Waltz')
title('')
set(gca,'FontSize',18)
xlim([0 duple.times(time(end))/1000])

figure; plot(duple.times(time)/1000,[mean_auditory;mean_motor],'LineWidth',2)
xlabel('Time (s)')
legend('Auditory IC','Motor IC')
title('')
set(gca,'FontSize',18)
xlim([0 duple.times(time(end))/1000])


%% calculate psd
%epochs = mean(EEG.data,3);
IC = 5;
%epochs = mean(EEG.icaact,3);
a = EEG.icaact(IC,:,1);

window_s = 10;
noverlap_s = 0.5;
figure;
[pss, f] =  pwelch(a,EEG.srate*window_s,EEG.srate*window_s*noverlap_s,EEG.srate*window_s,EEG.srate);
plot(f,10*log10(pss))
xlim([0 45])

