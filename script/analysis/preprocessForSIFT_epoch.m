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

doForceRecompute = true;

studydir = fullfile(G.paths.data_volume,'projects/EFRI/Pointing/pointing_ICA/Pointing_epoched_rs_STUDY','');
srcdir = fullfile(G.paths.data_volume,'projects/EFRI/Pointing/pointing_ICA/src','');
outdir = fullfile_mkdir(studydir,'SIFT','');
sets = cellstr(pickfiles(studydir,{'_114_','.set'}));

%for now only first 6
sets = sets(1:6);

outFileTemplate = '%s_116_pruned_epoched_forSIFT';

index = 0;
for iS = 1:length(sets),
  
  [path,name,ext] = fileparts(sets{iS});
  subj = name(1:10);
  fprintf('\n\n==== Subject: %s ====\n\n',subj)
  
  outFile = sprintf(outFileTemplate, subj);
  if ~doForceRecompute && exist(fullfile(outdir,[outFile '.set'])),
    disp('aready preprocessed')
    continue
  end
  
  %peek to see if have goodcomps
  EEG = pop_loadset('filename',sets{iS},'loadmode','info');
  if isempty(EEG.goodcomps)
    fprintf(2,'Warning: %s has no goodcomps\n',subj);
    continue
  end
    EEG = pop_loadset('filename',sets{iS});

  
  %get epochs of interest
  e0 = getTimeLockingEvents(EEG,'blocktype',0); %later can optionally add: 'omitfeedback',79 to exclude non-responses
  e1 = getTimeLockingEvents(EEG,'blocktype',1);
  events = [e0 e1];
  trials = [events.epoch];
  
  EEG = pop_select(EEG,'trial',trials);  
  
  %remove non-good components
  nComp = size(EEG.icaweights,1);
  rmcomps = setdiff(1:nComp,EEG.goodcomps);
  EEGc = pop_subcomp(EEG, rmcomps,0);
  
  EEGc.setname = [EEG.setname '_pruned_epoched']; %note--we don't want the additions of pop_subcomp
  
  pop_saveset(EEGc,'filename',outFile,'filepath',outdir)
  
end