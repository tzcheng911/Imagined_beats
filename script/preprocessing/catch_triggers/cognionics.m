% analyze cognionics cABR experiment

%% parameters
%addpath('/supporting_MatLabFiles/')
doResample = false; %true, resample to 500Hz (OK for ERP)

%filtering range
filt = [3 30];
filtString = 'cABR(80-1500)';
%filtString = 'ERP(1-100)'; %name for dataset

triggerShift = 0.02; %triggers are #s before the stimulus

%define speaker latencies for SF experiment
clear speakerLatency
speakerLatency(1) = 0.001 * (144/12); %position 1, 32"
speakerLatency(2) = 0.001 * (96/12); %position 2, 70"
speakerLatency(3) = 0.001 * (32/12); %position 2, 70"
%speakerLatency(99) = 0; %use code '99' for headphones


doReject = true; %reject extreme outliers if true
if doReject
    rejectThreshold = 150; %tweak this?
    rejString = [', clean' num2str(rejectThreshold)];
else
    rejString = [];
end

forceRecompute = false; %WARNING setting to tru will overwrite all existing set files

%% get list of subjects, parse out their condition and position

dataDir = '/Users/Shared/Google Drive UCSD/NSF Group Brain Dynamics Network/Experimental Data/mictry';
%dataDir = '/users/Alex/Desktop/missingfundamental';
files = dir(fullfile(dataDir,'*.bdf'));
%files = dir(fullfile(dataDir,'*.set'));
datasets = {files.name};

%% load data into EEGLAB

for iS = 1:length(datasets)
    datasetFile = datasets{iS};
    
    if strcmp(datasetFile,'1212_1.hi.bdf'), disp('skipping 1212 (500 Hz)'), continue, end
    
    
    %decode info from the dataset name
    parts = cellstr(split(datasetFile,'.'));
    subjectPos = parts{1};
    condition = parts{2};
    parts = cellstr(split(subjectPos,'_'));
    subject = parts{1};
    position = str2num(parts{2});

    speakerDelay = speakerLatency(position);
        
    dataset = [subject '_' num2str(position) '.' condition];
    
    testFile = fullfile(dataDir,[dataset '_' filtString '_low.set']);
    if ~forceRecompute && exist(testFile,'file')
        fprintf('Skipping %s\n',dataset)
        continue
    end
    
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
    
    EEG = pop_biosig(fullfile(dataDir,datasetFile), 'importevent','off');
    
    EEG.subject = subject;
    EEG.condition = condition;
    EEG.position = position;
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',datasetFile,'gui','off');
    
    eeglab redraw
    
    %% find channel numbers
    czChan = strmatch('Cz',{EEG.chanlocs.labels});
    triggerLabel = 'EXT1';
    trigChan = strmatch(triggerLabel,{EEG.chanlocs.labels});
    soundChan = strmatch('EXT0',{EEG.chanlocs.labels});
    
    %figure out how many channels are EEG
    nChan = length(EEG.chanlocs);
    eegChans = 1:(nChan-4); %last four channels are not EEG
    
    %% get triggers, high pass filter to remove dc and low frequency variation
    trigger = EEG.data(trigChan,:);
    trigger = trigger - mean(trigger);
    sound = EEG.data(soundChan,:);
    sound = sound - mean(sound);
    
    % check in case trigger was plugged into EXT1. Assume a 'floating'
    % channel will have huge standard deviation, while a real trigger will
    % have standard deviation around 500
%     if std(trigger) > 500 && std(sound) < 500 %swap sound and trigger -- we now have a situation where one is mic and one is trigger: the STD is actually very similar. but amplitude is quite different.
%         tmp = trigger;
%         trigger = sound;
%         sound = tmp;
%         tmp = trigChan;
%         trigChan = soundChan;
%         soundChan = trigChan;
%         clear tmp
%         triggerLabel = 'EXT1';
%     end
    
    if 0 %use this filter if there's a shifting baseline
        [B, A] = butter(1, 80/2000, 'high');
        trigger = filter(B,A,trigger);
    end
    %sound = filter(B,A,sound);
    
    latency  = triggerShift + speakerDelay; % NEW 8/14/17
    
    %mic trigger
    event = processGblnTrigger(EEG.times/1000,trigger,'threshold',3000, 'burstduration',.700,...
        'latency',latency,'eventtype',{'standard','hi','low'},'eventfrequency',[350 650 250]);
      
      
    
    %for da/danoise experiment -- with same amplitude triggers, but two
    %blocks
    da_analysisrange = [10 300];
    danoise_analysisrange = [330 600];
    danoise_latency = danoise_analysisrange(1) - da_analysisrange(1);
    event_da = processGblnTrigger(EEG.times/1000,trigger,'threshold',1000, 'burstduration',.04,...
        'analysisrange', da_analysisrange, 'latency',latency,'eventtype',{'da'});
    event_danoise = processGblnTrigger(EEG.times/1000,trigger,'threshold',1000, 'burstduration',.04,...
        'analysisrange', danoise_analysisrange, 'latency',latency+danoise_latency,'eventtype',{'da','danoise'});
    event = [event_da event_danoise]; %??
    
    %add information about attention task and position
    for i = 1:length(event)
        event(i).position = position;
        switch event(i).type
            case 'standard'
                event(i).saliency = 'standard';
            case 'high'
                if strcmp(condition,'hi')
                    event(i).saliency = 'attended';
                else
                    event(i).saliency = 'unattended';
                end
            case 'low'
                if strcmp(condition,'lo')
                    event(i).saliency = 'attended';
                else
                    event(i).saliency = 'unattended';
                end
        end
    end
    
    
    urevent = rmfield(event,'urevent');
    EEG.event = event;
    EEG.urevent = urevent;
    EEG.triggerLabel = triggerLabel;
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET); %replace current dataset
    eeglab redraw
    
    if length(event) < 1000 || length(event) > 1900
        error('whoa there! Problems with the events. Plot channel data (scroll) to check it out! ')
    end
    %% remove any glitchy data: time range is in seconds
    %EEG = pop_select( EEG,'notime',[939 1143] );
    %[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET); %replace current dataset
    %eeglab redraw
    
    %% resample?
    EEG = pop_resample( EEG, 500);
    
    %% do some filtering here-- 1-20 for ERP, 90-1500 for cABR
    
    EEG = pop_eegfiltnew(EEG, filt(1),filt(2));
    setname = [EEG.setname ' ' filtString];
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',setname,'gui','off');
    eeglab redraw
    
    EEG_preEpoch = EEG; %save this dataset, so we can use it for the different epoching below
    
    %% epoch the data - standard
    setname = [EEG_preEpoch.setname ' epoched, standard'];
    EEG = pop_epoch( EEG_preEpoch, { 'standard'  }, [-0.500     1.000], 'newname', setname, 'epochinfo', 'yes');
    %EEG = pop_rmbase( EEG, [-20    0]); %baseline removal between two times in brackets
    EEG = pop_rmbase( EEG, [-500    0]);
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG); %create new dataset
    
    if doReject
        EEG = pop_eegthresh(EEG,1,eegChans ,-rejectThreshold,rejectThreshold,-0.5,0.99975,0,1);
        EEG.setname = [EEG.setname rejString];
        [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);
    end
    EEG = pop_saveset(EEG,'filename',[dataset '_' filtString '_standard.set'],'filepath',dataDir);
    eeglab redraw
    
    %% epoch the data - HIGH oddball
    setname = [EEG_preEpoch.setname ' epoched, HIGH oddball'];
    EEG = pop_epoch( EEG_preEpoch, { 'high'  }, [-0.500     1.000], 'newname', setname, 'epochinfo', 'yes');
    %EEG = pop_rmbase( EEG, [-20    0]); %baseline removal between two times in brackets
    EEG = pop_rmbase( EEG, [-500    0]);
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG); %create new dataset
    
    if doReject
        EEG = pop_eegthresh(EEG,1,eegChans ,-rejectThreshold,rejectThreshold,-0.5,0.99975,0,1);
        EEG.setname = [EEG.setname rejString];
        [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);
    end
    EEG = pop_saveset(EEG,'filename',[dataset '_' filtString '_high.set'],'filepath',dataDir);
    eeglab redraw
    
    %% epoch the data - LOW oddball
    setname = [EEG_preEpoch.setname ' epoched, LOW oddball'];
    EEG = pop_epoch( EEG_preEpoch, { 'low' }, [-0.500     1.000], 'newname', setname, 'epochinfo', 'yes');
    %EEG = pop_rmbase( EEG, [-20    0]); %baseline removal between two times in brackets
    EEG = pop_rmbase( EEG, [-500    0]);
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG); %create new dataset
    
    if doReject
        EEG = pop_eegthresh(EEG,1,eegChans ,-rejectThreshold,rejectThreshold,-0.5,0.99975,0,1);
        EEG.setname = [EEG.setname rejString];
        [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);
    end
    EEG = pop_saveset(EEG,'filename',[dataset '_' filtString '_low.set'],'filepath',dataDir);
    eeglab redraw
    
    %% check the sound epoching (ALSO: calculate ERP: must be done every time datasets are switched)
    erp = mean(EEG.data,3); %erp = mean(abs(EEG.data),3);%% use this to see absolute values
    figure;plot(EEG.times,erp(trigChan,:)); % channel 9 or 10 for 8chan headsets, channel 5 or 6 for 4chan
    hold on
    title([dataset ' ' triggerLabel])
    
    %% figure; (because mic and trigger signals are SO large, to see the ERP multiply signal by 10)
    % plot(EEG.times,erp(czChan,:)*1000); %Cz is chan 1 in 4chan and 2 in 8chan
    % hold on
    %% do some filtering here-- 1-20 for ERP, 50- for cABR
    % erpo = mean(ALLEEG(5).data,3);
    % erpe = mean(ALLEEG(6).data,3);
    %
    % erp1 = erpo + erpe;
    % figure;plot(EEG.times,erp1(2,:))
    
    %% NEW: compare standard and oddball ERPS
    % find standard and oddball datasets
    allSetnames = {ALLEEG.setname}; %list of all dataset names
    standardSet = [];
    highOddballSet = [];
    lowOddballSet = [];
    for i = 1:length(allSetnames)
        if ~isempty(strfind(allSetnames{i},['standard' rejString]))
            standardSet = i;
        end
        if ~isempty(strfind(allSetnames{i},['HIGH oddball' rejString]))
            highOddballSet = i;
        end
        if ~isempty(strfind(allSetnames{i},['LOW oddball' rejString]))
            lowOddballSet = i;
        end
    end
    
    %% plot ERPs
    erpStandard = mean(ALLEEG(standardSet).data,3);
    erpHighOddball = mean(ALLEEG(highOddballSet).data,3);
    erpLowOddball = mean(ALLEEG(lowOddballSet).data,3);
    
    figure
    plot(EEG.times, erpStandard(czChan,:), 'g-')
    hold on
    plot(EEG.times, erpHighOddball(czChan,:), 'r-')
    plot(EEG.times, erpLowOddball(czChan,:), 'b-')
    legend('standard','HIGH oddball','LOW oddball')
    
    xlabel('time [s]')
    ylabel('amplitude')
    title([dataset rejString])
    gridx
    expmulti(gcf,'pdf',[dataset '_ERP'],600)
    close(gcf)
    
    %% plot erpimages
    figure
    jisubplot(3,1,1,'tall')
    pop_erpimage(ALLEEG(standardSet),1, [2],[[]],[dataset rejString ', standard Cz'],50,1,{},[],'' ,'yerplabel','\muV','erp','on','cbar','on','coher',[4 15 0.05],'spec',filt,'erpalpha',0.05 );
    nextplot
    pop_erpimage(ALLEEG(highOddballSet),1, [2],[[]],[dataset rejString ', HIGH Cz'],10,1,{},[],'' ,'yerplabel','\muV','erp','on','cbar','on','coher',[4 15 0.05],'spec',filt,'erpalpha',0.05 );
    nextplot
    pop_erpimage(ALLEEG(lowOddballSet),1, [2],[[]],[dataset rejString ', LOW Cz'],10,1,{},[],'' ,'yerplabel','\muV','erp','on','cbar','on','coher',[4 15 0.05],'spec',filt,'erpalpha',0.05 );
    
    expmulti(gcf,'pdf',[dataset '_ERPimage'],600)
    close(gcf)
end % loop over datasets