function plotallclean(STUDY, ALLEEG, cluster, varargin)
close all

opt = finputcheck(varargin, ...
    { ...
    'menu'  'string' {'on', 'off'}  'off'; ...
    });

% Get screen size for compatibility
screen = get(0, 'ScreenSize');

% Set order for plotting conditions
% --RHTYHM STUDY ONLY--
file = STUDY.filename;
switch file
    case {'copy of Rhythm_Cleaned_f.study', 'Rhythm_fixed_c6.study'}
%         STUDY.design.variable(1).value = {'144' '244' '133' '233'};
        plotorder = [1 2 3 4];
    case 'Rhythm_Cleaned_f.study'
        STUDY.design.variable(1).value = {'233' '144' '133' '244'};
        plotorder = [2 4 3 1];
    case 'another copy of Rhythm_Cleaned_f.study'
        STUDY.design.variable(1).value = {'233' '144' '133' '244'};
        plotorder = [2 4 3 1];
end
plotorder = [1 2 3 4];    
% Plot data
% ----------------

% Plot scalp maps
std_topoplot(STUDY,ALLEEG, 'clusters', cluster, 'mode', 'apart', 'figure', 'off');
pos1 = [(screen(3)*0)/20 ((screen(4)*10)/20) ((screen(3)*2)/6) ((screen(4)*2.6)/6)];
set(gcf, 'Position', pos1);
if strcmpi(opt.menu, 'off')
    set(gcf, 'MenuBar', 'none');
end;

% Plot dipoles
std_dipplot(STUDY,ALLEEG, 'clusters', cluster, 'figure', 'on', 'projlines', 'on');
pos2 = [((screen(3)*0)/20) ((screen(4)*0)) ((screen(3)*2)/6) ((screen(4)*2.8)/6)];
set(gcf,'Position',pos2);
if strcmpi(opt.menu, 'off')
    set(gcf,'MenuBar','none');
    set(gcf,'ToolBar','none');
end;

% Plot ERP
std_erpplot(STUDY,ALLEEG, 'clusters', cluster, 'plotconditions', 'apart','filter', 10,'conditionplotorder', plotorder);
h = findall(gcf, 'type', 'axes');
%Draw axes for conditions
for i = 1:4
    axes(h(i));
    str = get(get(gca, 'title'), 'string');
    x = length(str) - 2;
    title = str(x:end);
    gridx(targetBeat(title));
end;
pos3 = [((screen(3)*2)/6) ((screen(4)*3)/2) ((screen(3)*3.5)/6) ((screen(4)*1.9)/7)];
set(gcf,'Position',pos3);
set(gca,'fontsize',7)
if strcmpi(opt.menu, 'off')
    set(gcf,'MenuBar','none');
end;

% % Plot spectra
% std_specplot(STUDY,ALLEEG, 'clusters', cluster, 'plotconditions', 'together', 'plotmode', 'normal','freqrange',[3 40], 'conditionplotorder', plotorder);
% pos4 = [((screen(3)*1.9)/2) (screen(4)) (screen(3)/9) ((screen(4)*2)/7)];
% set(gcf,'Position',pos4);
% set(gca,'fontsize',7)
% if strcmpi(opt.menu, 'off')
%     set(gcf,'MenuBar','none');
% end;

% Plot ERSP
std_erspplot(STUDY,ALLEEG, 'clusters', cluster, 'plotconditions', 'together', 'plotmode', 'normal','freqrange',[3 50], 'conditionplotorder', plotorder);
h = findall(gcf, 'type', 'axes');
%Draw axes for conditions
for i = 1:length(h)
    axes(h(i));
    str = get(get(gca, 'title'), 'string');
    x = length(str) - 2;
	if(x < 1)
		continue;
	end;
    title = str(x:end);
    gridx(targetBeat(title), 'b--');
end;
pos6 = [((screen(3)*2.1)/6) ((screen(4)*2)/6) ((screen(3)*4)/6) ((screen(4)*1.9)/7)];
set(gcf,'Position',pos6);
if strcmpi(opt.menu, 'off')
    set(gcf,'MenuBar','none');
end;
y = [5 10 15 20 30 40 50];
h = findall(gcf,'type','axes');
for i = 1:size(h,1) - 1
    axes(h(i));
    set(gca,'YTick',log(y));
    set(gca,'YTickLabel',y);
end;

% Plot ITC
std_itcplot(STUDY,ALLEEG, 'clusters', cluster, 'plotconditions', 'together', 'plotmode', 'normal', 'freqrange', [3 50]);
h = findall(gcf, 'type', 'axes');
%Draw axes for conditions
for i = 1:length(h)
    axes(h(i));
    str = get(get(gca, 'title'), 'string');
    x = length(str) - 2;
	if(strcmp(str, 'ITC'))
		continue;
	end;
    title = str(x:end);
    gridx(targetBeat(title),'b--');
end;
pos7 = [((screen(3)*2.1)/6) ((screen(4)*0)) ((screen(3)*4)/6) ((screen(4)*1.9)/7)];
set(gcf,'Position',pos7);
if strcmpi(opt.menu, 'off')
    set(gcf,'MenuBar','none');
end;
h = findall(gcf,'type','axes');
for i = 1:size(h,1)-1
    axes(h(i));
    set(gca,'YTick',log(y));
    set(gca,'YTickLabel',y);
end;
% STUDY.design.variable(1).value = {'133' '144' '233' '244'};

end

% --RHYTHM STUDY ONLY--
function beats = targetBeat(tBeat)
% tBeat;
switch tBeat
    case '144'
        beats = [-2000 -1250 -500 0 1000 2000];
    case '244'
        beats = [-2000 -1000 0 1000 2000];
    case '133'
        beats = [-2000 -1000 0 750 1500 2000];
    case '233'
        beats = [-2000 -1250 -500 0 750 1500 2000];
end

end
