% pointing connectivity stats

% load study first
%

%AUG14, N=10

doCollapse = false;

%% 
starteeglab

datadir = fullfile(G.paths.data_volume,'projects/EFRI/Pointing/pointing_ICA/Pointing_epoched_rs_STUDY/SIFT/','');
studyfname = fullfile(datadir,'Pointing_epoched_rs_srcpot_SIFT_N10.study');

[STUDY ALLEEG] = pop_loadstudy('filename', studyfname);
CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];
eeglab redraw

%% collapse across freq and time, to yield coarse tiling of time-freq
measure = 'dDTF08';
%measure = 'nPDC'
%measure = 'pCoh'%
%measure = 'S'

foi = [0 8; 8 15; 15 30; 30 50];
winlen = 0.5;
toi = [0 0.5-winlen/2; 0.6+winlen/2 2]; %first window doesn't intrude on movement, which can occur any time from .5-.7, second

stattime = [0 0.5];
statfreq = mean(foi,2)';

EEGcol = EEG;
if doCollapse,
  for i = 1:length(EEG),
    EEGcol(i).CAT.Conn = hlp_collapseConn('Conn',EEG(i).CAT.Conn,'verb',0,...
      'coldim',{'freq',{'method','net','range',foi},'time',{'method','mean','range',[toi]}});
  end
end

%% split into conditions
data{1} = arrayfun(@(x) x.CAT.Conn.(measure),EEGcol(1:2:end),'UniformOutput',false);
data{2} = arrayfun(@(x) x.CAT.Conn.(measure),EEGcol(2:2:end),'UniformOutput',false);

data{1} = cat(5,data{1}{:});
data{2} = cat(5,data{2}{:});

%% perform stats: bootstrap or permutation (they give same results)
if 0,
  %[stats, df, pvals, surrog] = statcond(data,'paired','on','method','bootstrap','alpha',0.05,'structoutput','on');
  [stats, df, pvals, surrog] = statcond(data,'paired','on','method','perm','naccu',1000,'alpha',0.05,'structoutput','on');
else
  [stats, df, pvals, surrog] = statcond(data,'paired','on','method','param','alpha',0.05,'structoutput','on');
end

%% look at abs(reach-hold)?
% if 0, %verify we get same results with this approach--yes, if use method param, no for boot/perm
%   % also, why doesn't this work if we just pass a single element cell of the differenes?
%   diffdata{1} v= data{1}-data{2};
%   diffdata{2} = zeros*diffdata{1};
%   %[stats2, df, pvals, surrog] = statcond(diffdata,'paired','on','method','perm','naccu',1000,'alpha',0.05,'structoutput','on');
%   [stats2, df, pvals, surrog] = statcond(diffdata,'paired','on','method','param','alpha',0.05,'structoutput','on');
% else %many more significant absolute differences (of course). using permutation makes all sigificant, why?
%   absdata{1} = abs(data{1}-data{2});
%   absdata{2} = zeros*absdata{1};
%   %[stats2, df, pvals, surrog] = statcond(absdata,'paired','on','method','perm','naccu',1000,'alpha',0.05,'structoutput','on');
%   [stats2, df, pvals, surrog] = statcond(absdata,'paired','on','method','param','alpha',0.05,'structoutput','on');
% end

%% transform dipole coordinates
disp('Transforming coordinates to match head model');
EEGdip = EEGcol(1);
transfmat = traditionaldipfit(EEGdip.dipfit.coord_transform);

coord = EEGdip.dipfit.surfmesh.vertices;
tmp = transfmat * [ coord ones(size(coord,1),1) ]';
EEGdip.dipfit.surfmesh.vertices = tmp(1:3,:)';

coord = EEGdip.dipfit.reducedMesh.vertices;
tmp = transfmat * [ coord ones(size(coord,1),1) ]';
EEGdip.dipfit.reducedMesh.vertices = tmp(1:3,:)';

for i = 1:length(EEGdip.dipfit.model),
  coord = EEGdip.dipfit.model(i).posxyz;
  tmp = transfmat * [ coord ones(size(coord,1),1) ]';
  EEGdip.dipfit.model(i).posxyz = tmp(1:3,:)';
  
  coord =  EEGdip.dipfit.model(i).surfmesh.vertices;
  tmp = transfmat * [ coord ones(size(coord,1),1) ]';
  EEGdip.dipfit.model(i).surfmesh.vertices = tmp(1:3,:)';

end

%% create a new stats result dataset to plot
EEGres = EEGdip;
EEGres.subject = 'POINTING stats';
EEGres.condition = 'reach - rest';
EEGres.CAT.Conn.pval = 1 - stats.pval; %check if we need to reset time and freq...
EEGres.CAT.Conn.mask = stats.mask; %true in cells where p<0.05;
EEGres.CAT.Conn.t = stats.t;
EEGres.CAT.Conn.masked_t = stats.t .* (stats.pval<=0.01);
if doCollapse,
    EEGres.CAT.Conn.winCenterTimes = stattime;
    EEGres.CAT.Conn.erWinCenterTimes = stattime;
    EEGres.CAT.Conn.freqs = statfreq;
end
pop_vis_TimeFreqGrid(EEGres)

%% create mean difference map...
EEGdif = EEGdip;
EEGdif.subject = 'POINTING mean';
EEGdif.condition = 'reach - rest';
EEGdif.CAT.Conn.([measure '_diff']) = mean(data{1}-data{2},5);
EEGdif.CAT.Conn.([measure '_absdiff']) = mean(abs(data{1}-data{2}),5);
EEGdif.CAT.Conn.([measure '_mean_reach']) = mean(data{1},5);
EEGdif.CAT.Conn.([measure '_mean_hold']) = mean(data{2},5);
EEGdif.CAT.Conn.([measure '_mean_sum']) = mean((data{1}+data{2})/2,5);
EEGdif.CAT.Conn.([measure '_diff_masked']) = mean(data{1}-data{2},5) .* stats.mask;
try,
  load(['tfgrid_' measure '_cfg.mat'])
catch
  cfg=[];
end
[tmp cfg] = pop_vis_TimeFreqGrid(EEGdif,0,cfg);
set(gcf,'color','w')
ax = findobj(gcf,'type','axes');
set(ax,'color','w','xcolor','k','ycolor','k')

%% brain movie

if ~doCollapse,
  load('brainmovie_cfg.mat')
   cfg.connmethod = [measure '_diff'];
   cfg.BMopts.view = [-82 34];
   cfg.BMopts.Layers.scalp.scalptrans=0.85;
   cfg.BMopts.Layers.cortex.cortextrans = .8;
  [tmp cfg] = pop_vis_causalBrainMovie3D(EEGdif,0,cfg);%'nogui'
end


