% preprocess data for SIFT
%   goal: we want the minimal continuous dataset that encompasses all epochs of interest.
%   do this by building a list of epochs of interest and get their original sample latency from urevents
%
%   we also need to remove all non-good components
%
% JRI 3/6/14

%was going to start with full data, but recall we already have epoched data! So--add our dipole fits to that and go
% datadir = fullfile(G.paths.data_volume,'projects/EFRI/Pointing/pointing_ICA','');
% sets = cellstr(pickfiles(datadir,{'112','.set'}));
% 
% outFileTemplate = '%s_114_continuous_with_ica_chanlocs_dip_rs_epoch_goodcomps';

tmp = {'POINTING03_100_viztick_reassigned.set','POINTING04_100_viztick_reassigned.set',...
 'POINTING05_100_viztick_reassigned.set','POINTING06_100_viztick_reassigned.set',...
 'POINTING07_5_reref.set','POINTING09_07_insert.set','POINTING10_07_insert.set',...
 'POINTING12_06_insert.set','POINTING13_06_insert.set','POINTING14_06_insert.set'};

studydir = fullfile(G.paths.data_volume,'projects/EFRI/Pointing/pointing_ICA/Pointing_epoched_rs_STUDY','');
srcdir = fullfile(G.paths.data_volume,'projects/EFRI/Pointing/pointing_ICA/src','');
outdir = fullfile_mkdir(srcdir,'SIFT','');
sets = cellstr(pickfiles(studydir,{'_114_','.set'}));

sets = cellstr(pickfiles(srcdir,{'_10_','.set'}));

%for now only first 6
sets = sets(1:6);

outFileTemplate = '%s_115_continuous_goodcomps_forSIFT';
continuousFileTemplate = '%s_110_continuous_with_ica';

index = 0;
%for iS = 1:length(sets),
for iS = 3,
  
  [path,name,ext] = fileparts(sets{iS});
  subj = name(1:10);
  fprintf('\n\n==== Subject: %s ====\n\n',subj)
  
  outFile = sprintf(outFileTemplate, subj);
  if exist(fullfile(outdir,[outFile '.set'])),
    disp('aready preprocessed')
    continue
  end
  
  continuousFile = sprintf(continuousFileTemplate, subj);
  
  continuousFile = tmp{iS};

  %peek to see if have goodcomps
  EEG = pop_loadset('filename',sets{iS},'loadmode','info');
  if isempty(EEG.goodcomps)
    fprintf(2,'Warning: %s has no goodcomps\n',subj);
    continue
  end
  
  EEG = pop_loadset('filename',sets{iS});
    
  %get epochs of interest
  e0 = getTimeLockingEvents(EEG,'blocktype',0); %later can optionally add: 'omitfeedback',79 to exclude non-responses
  e1 = getTimeLockingEvents(EEG,'blocktype',0);
  events = [e0 e1];
  
  %this range of samples will encompass all epochs in the set. There may be gaps, which we can consider cutting out later...
  sampMin = min([events.absoluteTimeSamples])-5;
  sampMax = max([events.absoluteTimeSamples])+5;
  
  EEGc = pop_loadset('filename',[continuousFile],'filepath',srcdir);
  
  %resample?
  %EEGc = pop_resample(EEGc,128);
  
  %test: find matching event (ugh, they have different fields and names, so add fields to new event so we can match
  tmpevent = events(1);
  tmpevent.pretotalTW = tmpevent.pretotal_tw*1000;
  rangeStr = sprintf('%g<=%g',tmpevent.pretotalTW*.995, tmpevent.pretotalTW*1.005);
  tmpevent.hit = tmpevent.feedback;
  tmpevent.type = str2num(tmpevent.type);
  
  %i = matchEvent(tmpevent, EEGc, {'blocktype','hit',{'pretotalTW',rangeStr} });
  i = matchEvent(tmpevent, EEGc, {'blocktype','trial' });
  
  %compare absolute position in file
  events(1).absoluteTimeSamples
  EEGc.event(i)
  EEGc.urevent(event(i).urevent)
  
  %excise range of data
  EEGc = pop_select(EEG,'point',[sampMin sampMax]);
  
  EEG.setname = [EEG.setname '_rs_epoch_goodcomps'];
  
  pop_saveset(EEG,'filename',outFile,'filepath',outdir)
  
end