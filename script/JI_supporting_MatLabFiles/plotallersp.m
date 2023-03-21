function plotallersp( STUDY, ALLEEG, varargin )

inputOptions = finputcheck(varargin, ...
    { ...
    'plotting' 'string' {'smooth', 'rough'} 'smooth';
    'cluster' 'integer' [] [];
    'comps' {'integer', 'string'} [] 'all'; ...
    });

if ischar(inputOptions)
    error(inputOptions);
end;

if ( strcmp(inputOptions.comps, 'all') )
    [~, allersp, ersptimes, erspfreqs, ~, ~, ~] = std_erspplot(STUDY,ALLEEG, 'clusters', inputOptions.cluster, 'freqrange',[3 50], 'plotmode', 'none');
else
    [~, allersp, ersptimes, erspfreqs, ~, ~, ~] = std_erspplot(STUDY,ALLEEG, 'clusters', inputOptions.cluster, 'comps', inputOptions.comps, 'freqrange',[3 50], 'plotmode', 'none');
end;

%Find mean of ersp data
erspdata = allersp;
denom = size(allersp{1,1},3);
for i = 1:size(allersp,1)
    for j = 1:size(allersp{i,1},3)
        erspdata{i,1}(:,:,1) = erspdata{i,1}(:,:,1) + allersp{i,1}(:,:,j);
    end;
    erspdata{i,1}(:,:,1) = erspdata{i,1}(:,:,1)/denom;
end;
erspdata{i + 1,1}(:,:,1) = erspdata{1,1}(:,:,1);

%Create figure and size appropriately
figure('Position',[500 500 937 592]);
subplot(2,1,1);

%Plot in forward or reverse order
if ( strcmp(inputOptions.plotting, 'smooth') )
    for i = 1:5
        offset = ((i - 1)*2000);
        time{i, 1} = ersptimes + offset;
        start(i) = time{i, 1}(1);
        finish(i) = time{i,1}(200);
    end;
    a = 1;
%     overlap = 0;
    for i = 1:4
        x = 1;
        y = 1;
        for j = 1:size(time{i,1},2)
            if(time{i,1}(j) > start(i + 1))
                overlap(i,x,1) = j;
                x = x + 1;
            end;
            if(time{i + 1,1}(j) < finish(i))
                overlap(i,y,2) = j;
                y = y + 1;
            end;
        end;
    end;
    for a = 1:4
        for i = 1:size(overlap,2)
            o1 = overlap(a,i,1);
            o2 = overlap(a,i,2);
            for j = 1:size(erspfreqs,2)
                e1 = erspdata{a,1}(j,o1,1);
                e2 = erspdata{a,1}(j,o2,1);
                total = abs(e1) + abs(e2);
                weight1 = abs(e1)/total;
                weight2 = abs(e2)/total;
                weightedBlendVal = (e1*weight1) + (e2*weight2);
%                 weightedBlendVal = (e1 + e2)/2;
                erspdata{a,1}(j,o1,1) = weightedBlendVal;
                erspdata{a + 1,1}(j,o2,1) = weightedBlendVal;
            end;
        end;
    end;
    for i = 1:4
        offset = ((i - 1)*2000);
        imagesc(time{i, 1}, erspfreqs, erspdata{i,1}(:,:,1));
        gridx(targetBeat(i) + offset, 'k--', 1);
        hold on;
    end;
    imagesc(time{5,1}, erspfreqs, erspdata{5,1}(:,:,1));
    gridx(targetBeat(1) + 8000, 'k--', 1);
    hold on;
end;
if ( strcmp(inputOptions.plotting, 'rough') )
    for i = 1:4
        offset = ((i - 1)*2000);
        time{i, 1} = ersptimes + offset;
        imagesc(time{i, 1}, erspfreqs, erspdata{i,1}(:,:,1));
        gridx(targetBeat(i) + offset, 'k--', 1);
        hold on;
    end;
    imagesc(time{1,1} + 8000, erspfreqs, erspdata{1,1}(:,:,1));
    gridx(targetBeat(1) + 8000, 'k--', 1);
    hold on;
%     imagesc(ersptimes + 8000, erspfreqs, erspdata{1,1}(:,:,1));
%     gridx(targetBeat(1) + 8000, 'k--', 1);
%     hold on;
%     for i = 1:4
%         offset = ((4 - i)*2000);
%         time{i, 1} = ersptimes + offset;
%         imagesc(time{i, 1}, erspfreqs, erspdata{5 - i,1}(:,:,1));
%         gridx(targetBeat(5 - i) + offset, 'k--', 1);
%         hold on;
%     end;
end;

%Label Data
text(-1000, 53, '...', 'FontWeight', 'bold', 'FontSize', 28);
text(550, 52, '4 + 4', 'FontWeight', 'bold', 'FontSize', 16);
text(2550, 52, '4 + 4', 'FontWeight', 'bold', 'FontSize', 16);
text(4486.5, 52, '3 + 3 + 2', 'FontWeight', 'bold', 'FontSize', 16);
text(6486.5, 52, '3 + 3 + 2', 'FontWeight', 'bold', 'FontSize', 16);
text(8500, 53, '...', 'FontWeight', 'bold', 'FontSize', 28);

%Adjust zoom and axes
axis auto;
axis xy;
axis tight;
ylim([3 50]);
gridx([0,2000,4000,6000,8000], 'k', 2);

%Plot supplementary figures
subplot(2,2,3);
if ( strcmp(inputOptions.comps, 'all') )
    std_dipplot(STUDY, ALLEEG, 'clusters', inputOptions.cluster, 'figure', 'off', 'projimg', 'on', 'projlines', 'on', 'color', 'g');
else
    std_dipplot(STUDY, ALLEEG, 'clusters', inputOptions.cluster, 'comps', inputOptions.comps, 'figure', 'off', 'projimg', 'on', 'projlines', 'on', 'color', 'g');
end;

subplot(2,2,4);
if ( strcmp(inputOptions.comps, 'all') )
    std_topoplot(STUDY, ALLEEG, 'clusters', inputOptions.cluster, 'mode', 'together', 'figure', 'off');
else
    std_topoplot(STUDY, ALLEEG, 'clusters', inputOptions.cluster, 'comps', inputOptions.comps, 'mode', 'together', 'figure', 'off');
end;

end

function beats = targetBeat(tBeat)
%Beat axes
switch tBeat
    case 1
        beats = [-1250 -500 1000];
    case 2
        beats = [-1000 1000];
    case 3
        beats = [-1000 750 1500];
    case 4
        beats = [-1250 -500 750 1500];
end

end