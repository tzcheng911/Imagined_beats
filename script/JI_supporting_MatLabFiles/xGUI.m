function varargout = xGUI(varargin)
% xGUI is a user-interface for the phasetrack *.m file.  It was designed for making cross-spectral comparisons  (power and phase) for two groups (e.g.,  quiet-to-noise cross-phase comparisons for grp1 vs. grp2). 
% For each group, you need to load in two sets of files (e.g., quiet = set 1,  noise = set 2).   
% For the version of xGUI that is distributed outside of the Kraus Lab, we
% the power spectrum comparisons are not being plotted. This is because
% this analysis has not been used in any of our publications and is not as
% well understood as the cross-phase comparisons.  We have simply commented
% out the cross-power code.   

% In addition to plotting cross-periodograms and cross-phaseograms,  8 additional figures are generated based on the user's input.
% The user can obtain average phase and power measurements over two sets of time-frequency ranges (for example,  100-500 Hz over the 15-60 ms, and 100-5000 Hz over the 60-180 ms range).
% Figure 1:  Cross-Periodogram (grp1 in top subplot, grp2 in bottom subplot)
% Figure 2:  Cross-Spectruam (same format at Figure 1)
% Figure 3:  Average power over frequency range1 for both groups  ( in all figures, dashed lines indicate standard errors)
% Figure 4:  Average power over time range1 for both groups 
% Figure 5:  Average  power over frequency range2 for both groups
% Figure 6:  Average power over time range 2 for both groups
% Figure 7:  Average phase over frequency range1 for both groups  ( in all figures, dashed lines indicate standard errors)
% Figure 8:  Average phase over time range1 for both groups 
% Figure 9:  Average  phase over frequency range2 for both groups
% Figure 10: Average phase over time range 2 for both groups
% Average power and phase values are outputted ton an excel file, named "Grp1_x-spectral.xls" and "Grp2_x-spectral.xls". Files saved to cd.
% The meat of the code starts around line 500. 
% Written by Erika Skoe (eeskoe@northwestern.edu), in conjunction with Adam Tierney, from the Auditory Neuroscience Laboratory, at Northwestrn university. 
%
% Dependencies:
% closestrc, maximize, ms2row, openavg, phasetrack, suptitle, xlswrite, 
%
% The xGUI  is free software: you can redistribute it and/or modiffy it under the terms of the GNU General Public License as published by
% the Free Software Foundation.
%
% xGUI is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
% See the GNU General Public License for more details <http://www.gnu.org/licenses/>/
%
% 
%

% SETTING EVERYTHING UP:  GETTING VARIABLES READY
addpath([cd, '\ProgramFiles'])

mInputArgs = varargin;
mOutputArgs = {};

warning 'off' 'all';
savefig = 1;

global freqaxis1;
global write_matrix;
write_matrix{1} = 0;
global write_matrix2;
write_matrix2{1} = 0;
global freqaxis2;
global time1;
global time2;
global PhaseAngle1;
global PhaseAngle2;
freqaxis1 = {};
freqaxis2 = {};
time1 = {};
time2 = {};
PhaseAngle1 = {};
PhaseAngle2 = {};
global filename1;
global filename2;
global filename3;
global filename4;
global chan;
chan = [];
filename1 = '';
filename2 = '';
filename3 = '';
filename4 = '';
global pathname1;
global pathname2;
global pathname3;
global pathname4;
pathname1 = '';
pathname2 = '';
pathname3 = '';
pathname4 = '';
global grp1name;
grp1name = 'Group Name';
global grp2name;
grp2name = 'Group Name';
global startptval;
startptval = 20;
global stopptval;
stopptval = 60;
global lowestfreq;
lowestfreq = 70;
global highestfreq;
highestfreq = 300;
global startptval2;
startptval2 = 60;
global stopptval2;
stopptval2 = 170;
global lowestfreq2;
lowestfreq2 = 70;
global highestfreq2;
highestfreq2 = 300;
from_bottom = 240;

% 
block = 40; %40-ms blocks are analyzed,   If the first bin is 0-40 ms, this bin is plotted at 20 ms in all figures.
step = 1 ;   %The start of block(n) and block)n+1) is 1 ms
%

%% CREATING FIGURE
fig = figure('Visible','on','Name','xGUI','Position',[360,100,600,300 + from_bottom]);
set(fig,'color',[0.85 0.85 0.85]);
title_text = uicontrol('Style','text','String','xGUI','FontSize',20,'Position',[150 (240 + from_bottom) 300 40]);
set(title_text,'BackgroundColor',[0.85 0.85 0.85]);

txt_g1 = uicontrol('Style','text','String','Files - Group 1','Position',[5 (200 + from_bottom) 80 15]);
set(txt_g1,'BackgroundColor',[0.85 0.85 0.85]);
selected_g1 = uicontrol('Style','text','String','Select Group 1, Cond. 1 Files','Position',[90 (200 + from_bottom) 160 15]);
set(selected_g1,'BackgroundColor',[0.85 0.85 0.85]);
select_g1 = uicontrol('Style','pushbutton','String','Find Files','Position',[255 (197 + from_bottom) 80 20]);
groupname_g1 = uicontrol('Style','edit','String','Group 1 Name','Position',[340 (197 + from_bottom) 80 20]);
set(groupname_g1,'BackgroundColor',[0.85 0.85 0.85]);
path_g1 = uicontrol('Style','text','String','Pathname - files group 1, cond. 1','Position',[90 (170 + from_bottom) 415 20]);
set(select_g1,'Callback',@select_group1);
set(groupname_g1,'Callback',@groupname_group1);

txt_g2 = uicontrol('Style','text','String','Files - Group 1/TEMPLATE','Position',[5 (140 + from_bottom) 80 15]);
set(txt_g2,'BackgroundColor',[0.85 0.85 0.85]);
selected_g2 = uicontrol('Style','text','String','Select Group 1, Cond. 2 Files','Position',[90 (140 + from_bottom) 160 15]);
set(selected_g2,'BackgroundColor',[0.85 0.85 0.85]);
select_g2 = uicontrol('Style','pushbutton','String','Find Files','Position',[255 (137 + from_bottom) 80 20]);
groupname_g2 = uicontrol('Style','text','String','Group 1 Name','Position',[340 (137 + from_bottom) 80 20]);
set(groupname_g2,'BackgroundColor',[0.85 0.85 0.85]);
path_g2 = uicontrol('Style','text','String','Pathname - files group 1, cond. 2','Position',[90 (110 + from_bottom) 415 20]);
set(select_g2,'Callback',@select_group2);

txt_g3 = uicontrol('Style','text','String','Files - Group 2','Position',[5 (80 + from_bottom) 80 15]);
set(txt_g3,'BackgroundColor',[0.85 0.85 0.85]);
selected_g3 = uicontrol('Style','text','String','Select Group 2, Cond. 1 Files','Position',[90 (80 + from_bottom) 160 15]);
set(selected_g3,'BackgroundColor',[0.85 0.85 0.85]);
select_g3 = uicontrol('Style','pushbutton','String','Find Files','Position',[255 (77 + from_bottom) 80 20]);
groupname_g3 = uicontrol('Style','edit','String','Group 2 Name','Position',[340 (77 + from_bottom) 80 20]);
set(groupname_g3,'BackgroundColor',[0.85 0.85 0.85]);
path_g3 = uicontrol('Style','text','String','Pathname - files group 2, cond. 1','Position',[90 (50 + from_bottom) 415 20]);
set(select_g3,'Callback',@select_group3);
set(groupname_g3,'Callback',@groupname_group2);

txt_g4 = uicontrol('Style','text','String','Files - Group 2/TEMPLATE','Position',[5 (20 + from_bottom) 80 15]);
set(txt_g4,'BackgroundColor',[0.85 0.85 0.85]);
selected_g4 = uicontrol('Style','text','String','Select Group 2, Cond. 2 Files','Position',[90 (20 + from_bottom) 160 15]);
set(selected_g4,'BackgroundColor', [0.85 0.85 0.85]);
select_g4 = uicontrol('Style','pushbutton','String','Find Files','Position',[255 (17 + from_bottom) 80 20]);
groupname_g4 = uicontrol('Style','text','String','Group 2 Name','Position',[340 (17 + from_bottom) 80 20]);
set(groupname_g4,'BackgroundColor',[0.85 0.85 0.85]);
path_g4 = uicontrol('Style','text','String','Pathname - files group 2, cond. 2','Position',[90 (from_bottom - 10) 415 20]);
set(select_g4,'Callback',@select_group4);

text_FFT = uicontrol('Style','text','String','Parameters for average 1','Position',[50 190 200 20],'FontSize',12, 'BackgroundColor', [0.85 0.85 0.85]);
text_start = uicontrol('Style','text','String','Midpoint of first window','Position',[70 150 100 30],'BackgroundColor', [0.85 0.85 0.85]);
text_stop = uicontrol('Style','text','String','Midpoint of last window','Position',[70 110 100 30],'BackgroundColor', [0.85 0.85 0.85]);
text_start = uicontrol('Style','text','String','Lowest frequency','Position',[70 80 100 20],'BackgroundColor', [0.85 0.85 0.85]);
text_stop = uicontrol('Style','text','String','Highest frequency','Position',[70 50 100 20],'BackgroundColor', [0.85 0.85 0.85]);
start_ms = uicontrol('Style','edit','String','20','Position',[180 160 30 20],'BackgroundColor', [0.85 0.85 0.85]);
set(start_ms,'BackgroundColor',[0.85 0.85 0.85]);
set(start_ms,'Callback',@startpoint);
stop_ms = uicontrol('Style','edit','String','60','Position',[180 120 30 20],'BackgroundColor', [0.85 0.85 0.85]);
set(stop_ms,'BackgroundColor',[0.85 0.85 0.85]);
set(stop_ms,'Callback',@stoppoint);
low_freq = uicontrol('Style','edit','String','70','Position',[180 80 30 20],'BackgroundColor', [0.85 0.85 0.85]);
set(low_freq,'BackgroundColor',[0.85 0.85 0.85]);
set(low_freq,'Callback',@lowfreq);
high_freq = uicontrol('Style','edit','String','300','Position',[180 50 30 20],'BackgroundColor', [0.85 0.85 0.85]);
set(high_freq,'BackgroundColor',[0.85 0.85 0.85]);
set(high_freq,'Callback',@highfreq);

text_FFT2 = uicontrol('Style','text','String','Parameters for average 2','Position',[300 190 200 20],'FontSize',12,'BackgroundColor', [0.85 0.85 0.85]);
text_start2 = uicontrol('Style','text','String','Midpoint of first window','Position',[320 150 100 30],'BackgroundColor', [0.85 0.85 0.85]);
text_stop2 = uicontrol('Style','text','String','Midpoint of last window','Position',[320 110 100 30],'BackgroundColor', [0.85 0.85 0.85]);
text_start2 = uicontrol('Style','text','String','Lowest frequency','Position',[320 80 100 20],'BackgroundColor', [0.85 0.85 0.85]);
text_stop2 = uicontrol('Style','text','String','Highest frequency','Position',[320 50 100 20],'BackgroundColor', [0.85 0.85 0.85]);
start_ms2 = uicontrol('Style','edit','String','60','Position',[430 160 30 20],'BackgroundColor', [0.85 0.85 0.85]);
set(start_ms2,'BackgroundColor',[0.85 0.85 0.85]);
set(start_ms2,'Callback',@startpoint2);
stop_ms2 = uicontrol('Style','edit','String','170','Position',[430 120 30 20],'BackgroundColor', [0.85 0.85 0.85]);
set(stop_ms2,'BackgroundColor',[0.85 0.85 0.85]);
set(stop_ms2,'Callback',@stoppoint2);
low_freq2 = uicontrol('Style','edit','String','70','Position',[430 80 30 20],'BackgroundColor', [0.85 0.85 0.85]);
set(low_freq2,'BackgroundColor',[0.85 0.85 0.85]);
set(low_freq2,'Callback',@lowfreq2);
high_freq2 = uicontrol('Style','edit','String','300','Position',[430 50 30 20],'BackgroundColor', [0.85 0.85 0.85]);
set(high_freq2,'BackgroundColor',[0.85 0.85 0.85]);
set(high_freq2,'Callback',@highfreq2);

okay_button = uicontrol('Style','pushbutton','String','OK','FontSize',15,'Position',[500 15 80 40]);
set(okay_button,'Callback',@push_okay);
text_ms1 = uicontrol('Style','text','String','ms','Position',[220 160 20 20],'BackgroundColor', [0.85 0.85 0.85]);
text_ms2 = uicontrol('Style','text','String','ms','Position',[220 120 20 20],'BackgroundColor', [0.85 0.85 0.85]);
text_Hz1 = uicontrol('Style','text','String','Hz','Position',[220 80 20 20],'BackgroundColor', [0.85 0.85 0.85]);
text_Hz2 = uicontrol('Style','text','String','Hz','Position',[220 50 20 20],'BackgroundColor', [0.85 0.85 0.85]);
text_ms3 = uicontrol('Style','text','String','ms','Position',[470 160 20 20],'BackgroundColor', [0.85 0.85 0.85]);
text_ms4 = uicontrol('Style','text','String','ms','Position',[470 120 20 20],'BackgroundColor', [0.85 0.85 0.85]);
text_Hz3 = uicontrol('Style','text','String','Hz','Position',[470 80 20 20],'BackgroundColor', [0.85 0.85 0.85]);
text_Hz4 = uicontrol('Style','text','String','Hz','Position',[470 50 20 20],'BackgroundColor', [0.85 0.85 0.85]);
function varargout = select_group1(hObject, eventdata)


        global numFiles



        global filename_temp

        [filename_temp pathname1] = uigetfile('.avg','Select Files',cd,'MultiSelect', 'on');



        if ~iscell(filename_temp);
            %     errordlg('Please select more than 1 file');
            numFiles = 1;
            filename1{1} = filename_temp;
        else

            filename1 = filename_temp;
            [numFiles] = size(filename1,2);

        end


        if numFiles == 1
            text = '1 file selected';
            set(selected_g1, 'String', text);
            set(path_g1, 'String', pathname1);
        end

        if numFiles > 1
            text = [num2str(numFiles) ' files selected'];
            set(selected_g1, 'String', text);
            set(path_g1, 'String', pathname1);
        end

        for x=1:length(filename1);
            if isempty(chan);
                f = openavg([pathname1 filename1{x}]);
                if size(f.chan_names,1) >1
                    [chan v]=  listdlg('PromptString', 'Select Channel to Process' ,'ListString', f.chan_names, 'SelectionMode', 'single') ;
                else
                    chan = 1;

                end

            end
        end

    end

    function varargout = select_group2(hObject, eventdata)


        global numFiles

        global filename_temp

        [filename_temp pathname2] = uigetfile('.avg','Select Files',cd,'MultiSelect', 'on');



        if ~iscell(filename_temp);
            %     errordlg('Please select more than 1 file');
            numFiles = 1;
            filename2{1} = filename_temp;
        else

            filename2 = filename_temp;
            [numFiles] = size(filename2,2);

        end


        if numFiles == 1
            text = '1 file selected';
            msgbox('NOTE: all Grp1 Cond1 files will be compared to this single template file ')
            set(selected_g2, 'String', text);
            set(path_g2, 'String', pathname2);
        end

        if numFiles > 1
            text = [num2str(numFiles) ' files selected'];
            set(selected_g2, 'String', text);
            set(path_g2, 'String', pathname2);
        end

        for x=1:length(filename2);
            if isempty(chan);
                f = openavg([pathname2 filename2{x}]);
                if size(f.chan_names,1) >1
                    [chan v]=  listdlg('PromptString', 'Select Channel to Process' ,'ListString', f.chan_names, 'SelectionMode', 'single') ;
                else
                    chan = 1;

                end

            end
        end

    end

    function varargout = select_group3(hObject, eventdata)


        global numFiles

        global filename_temp

        [filename_temp pathname3] = uigetfile('.avg','Select Files',cd,'MultiSelect', 'on');



        if ~iscell(filename_temp);
            %     errordlg('Please select more than 1 file');
            numFiles = 1;
            filename3{1} = filename_temp;
        else

            filename3 = filename_temp;
            [numFiles] = size(filename3,2);

        end


        if numFiles == 1
            text = '1 file selected';
           
            set(selected_g3, 'String', text);
            set(path_g3, 'String', pathname3);
        end

        if numFiles > 1
            text = [num2str(numFiles) ' files selected'];
            set(selected_g3, 'String', text);
            set(path_g3, 'String', pathname3);
        end

        for x=1:length(filename3);
            if isempty(chan);
                f = openavg([pathname3 filename3{x}]);
                if size(f.chan_names,1) >1
                    [chan v]=  listdlg('PromptString', 'Select Channel to Process' ,'ListString', f.chan_names, 'SelectionMode', 'single') ;
                else
                    chan = 1;

                end

            end
        end

    end

    function varargout = select_group4(hObject, eventdata)


        global numFiles




        global filename_temp

        [filename_temp pathname4] = uigetfile('.avg','Select Files',cd,'MultiSelect', 'on');



        if ~iscell(filename_temp);
            msgbox('NOTE: all Grp2 Cond1 files will be compared to this single template file ')
            numFiles = 1;
            filename4{1} = filename_temp;
        else

            filename4 = filename_temp;
            [numFiles] = size(filename4,2);

        end


        if numFiles == 1
            text = '1 file selected: all Grp1 Cond1 file will be compared to this single file ';
            set(selected_g2, 'String', text);
            set(selected_g4, 'String', text);
            set(path_g4, 'String', pathname4);
        end

        if numFiles > 1
            text = [num2str(numFiles) ' files selected'];
            set(selected_g4, 'String', text);
            set(path_g4, 'String', pathname4);
        end

        for x=1:length(filename4);
            if isempty(chan);
                f = openavg([pathname4 filename4{x}]);
                if size(f.chan_names,1) >1
                    [chan v]=  listdlg('PromptString', 'Select Channel to Process' ,'ListString', f.chan_names, 'SelectionMode', 'single') ;
                else
                    chan = 1;

                end

            end


        end

    end

    function varargout = groupname_group1(hObject, eventdata)

        grp1name = get(hObject,'String');
        set(groupname_g2,'String',grp1name);

    end

    function varargout = groupname_group2(hObject, eventdata)

        grp2name = get(hObject,'String');
        set(groupname_g4,'String',grp2name);

    end

    function varargout = startpoint(hObject, eventdata)

        startptval = str2num(get(hObject,'String'));

    end

    function varargout = stoppoint(hObject, eventdata)

        stopptval = str2num(get(hObject,'String'));

    end


    function varargout = lowfreq(hObject, eventdata)

        lowestfreq = str2num(get(hObject,'String'));

    end

    function varargout = highfreq(hObject, eventdata)

        highestfreq = str2num(get(hObject,'String'));

    end

    function varargout = startpoint2(hObject, eventdata)

        startptval2 = str2num(get(hObject,'String'));

    end

    function varargout = stoppoint2(hObject, eventdata)

        stopptval2 = str2num(get(hObject,'String'));

    end


    function varargout = lowfreq2(hObject, eventdata)

        lowestfreq2 = str2num(get(hObject,'String'));

    end

    function varargout = highfreq2(hObject, eventdata)

        highestfreq2 = str2num(get(hObject,'String'));

    end


    function varargout = push_okay(hObject,eventdata)
        close all;

        filename1=sort(filename1);  %Grp1, cond 1
        filename2=sort(filename2);  %Grp2, cond 2
        filename3=sort(filename3);  %Grp32 cond 1
        filename4=sort(filename4);  %Grp2, cond 2
        grp1path=[pathname1];
        grp2path=[pathname2];
        grp3path=[pathname3];
        grp4path=[pathname4];
        numfiles1=length(filename1);
        numfiles2=length(filename2);
        numfiles3=length(filename3);
        numfiles4=length(filename4);

        % GROUP1
        for n = 1:length(filename1)
            if numfiles2 == 1
                filename2_temp{n} = filename2{1};  % if only 1 file is selected for the second condition, then all of the files in first condition are compared to this one file.
            else
                 filename2_temp{n} = filename2{n};
            end
            
            if n == 1;
                f = openavg( [grp2path, filename2_temp{1}]);

                startAnalysis = f.xmin;
            end
                
	    % perforam cross-spectral comparisons for the two conditions for grp1. 	
            [time blocks CPSD_output FreqAxis ] = phasetrack([grp1path, filename1{n}], [grp2path, filename2_temp{n}], block, step, startAnalysis,chan);
            time1{n} = time;
            PhaseAngle = unwrap(angle(CPSD_output));
            PhaseAngle = mod(PhaseAngle-pi, 2*pi)-pi;  %correct jumps greater than pi
            PhaseAngle1{n} = PhaseAngle;
            freqAxis1{n} = FreqAxis;
            Periodogram1(:,:,n) = CPSD_output;
        end

	% GROUP 2
        for n = 1:length(filename3)
            if numfiles4 == 1
                filename4_temp{n} = filename4{1};  % if only 1 file is selected for the second condition, then all of the files in first condition are compared to this one file.

            else
                 filename4_temp{n} = filename4{n};
            end
            if n == 1;
                f = openavg( [grp4path, filename4_temp{1}]);

                startAnalysis = f.xmin;
            end
            [time blocks CPSD_output FreqAxis ] = phasetrack([grp3path, filename3{n}], [grp4path, filename4_temp{n}], block, step, startAnalysis,chan);
            time2{n} = time;
            PhaseAngle = unwrap(angle(CPSD_output));
            PhaseAngle = mod(PhaseAngle-pi, 2*pi)-pi;
            PhaseAngle2{n} = PhaseAngle;
            freqAxis2{n} = FreqAxis;
            Periodogram2(:,:,n) = CPSD_output;
        end

        
        %generate average cross-spectrogram
        avgPeriodogram1 = mean(abs(Periodogram1), 3);
        avgPeriodogram2 = mean(abs(Periodogram2),3);
        
        
        % generate average cross-phaseogram
        [one,two] = size(PhaseAngle1{1});
        three = length(PhaseAngle1);

        First(one,two,three) = 0;
        three = length(PhaseAngle2);
        Second(one,two,three) = 0;

        for x = 1:length(PhaseAngle1)
            First(:,:,x) = PhaseAngle1{x};   % First = group 1 comparisons
        end
        First_mean = mean(First,3);
        for x = 1:length(PhaseAngle2)
            Second(:,:,x) = PhaseAngle2{x};  % Second = group 2 comparisons
        end
        Second_mean = mean(Second,3);

        
	%%  FIGURE 1:  plot cross-spectrogram
 
%         figure;
%         subplot(2,1,1);
%         lim = [pi];
%         startHz = 0;
%         imagesc(time1{1}, freqAxis1{1}, avgPeriodogram1)
%         set(gca, 'ydir', 'normal')
%         title(grp1name, 'FontSize', 16);
%         xlabel('Time(ms)')
%         ylabel('Frequency(Hz)')
%         ylim([0 1000])
%     
%         q=colorbar('Location', 'EastOutside' );
%         set(q, 'FontSize', 8);
%          set(gca, 'FontSize', 20)
% 	%    set(q,'ylabel', 'Power/Frequency dB/rad/cycle')
%         subplot(2,1,2);
%         imagesc(time2{1}, freqAxis2{1}, avgPeriodogram2)
%         set(gca, 'ydir', 'normal')
%         set(gca, 'box', 'off');
%         title(grp2name, 'FontSize', 16);
%         ylim([0 1000])
%         xlabel('Time(ms)')
%         ylabel('Frequency(Hz)')
%         q=colorbar('Location', 'EastOutside' );
%         set(q, 'FontSize', 8);
% 	%  set(q,'ylabel', 'Power/Frequency dB/rad/cycle')
%         suptitle('Cross-Spectrogram')
%            maximize(gcf)
%            set(gca, 'FontSize', 20)
	
	%% FIGURE 2 plot cross-phaseogram
        figure;
        subplot(2,1,1);
        lim = [pi];
        startHz = 0;
        imagesc(time1{1}, freqAxis1{1}, First_mean)
        set(gca, 'ydir', 'normal')
        title(grp1name, 'FontSize', 16);
        caxis([-lim lim])
        ylim([0 1000])
        colorbar
	%   colorbar('YTickLabel',{'cond2 earlier than cond1', '', '', '', 'cond1 earlier than cond2'});
        xlabel('Time(ms)')
        ylabel('Frequency(Hz)')
	set(gca, 'FontSize', 20)
        subplot(2,1,2);
        imagesc(time2{1}, freqAxis2{1}, Second_mean)
        set(gca, 'ydir', 'normal')
        set(gca, 'box', 'off');
        title(grp2name, 'FontSize', 16);
        caxis([-lim lim])
        ylim([0 1000])
        colorbar
	%  colorbar('YTickLabel',{'cond2 earlier than cond1', '', '', '', 'cond1 earlier than cond2'});
        xlabel('Time(ms)')
        ylabel('Frequency(Hz)')
        suptitle('Cross-Phaseogram')
         set(gca, 'FontSize', 20)
        maximize(gcf)
        
			
	%% preparing for calculating averages and stds.
        for x = 1:length(PhaseAngle1)

            frequency1 = lowestfreq;
            frequency2 =  highestfreq;
            [d clf] = closestrc(freqAxis1{1}, frequency1);
            [d clf2] = closestrc(freqAxis1{1}, frequency2);
            [d time_clf] = closestrc(time1{1}, startptval);
            [d time_clf2] = closestrc(time1{1}, stopptval);

            Frst =  First(:,:,x);
            Extract = mean(Frst(clf:clf2,:))';
            ExtractFirst1(x) = mean(Extract(time_clf:time_clf2));
            
            
            Frst_Pgram =  abs(Periodogram1(:,:,x));
            Extract_Frst_Pgram = mean(Frst_Pgram(clf:clf2, :))';
            ExtractFirst1_Pgram(x) = mean(Extract_Frst_Pgram(time_clf:time_clf2));

        end



        for x = 1:length(PhaseAngle2)

            frequency1 = lowestfreq;
            frequency2 =  highestfreq;
            [d clf] = closestrc(freqAxis2{1}, frequency1);
            [d clf2] = closestrc(freqAxis2{1}, frequency2);
            [d time_clf] = closestrc(time2{1}, startptval);
            [d time_clf2] = closestrc(time2{1}, stopptval);

            Scnd =  Second(:,:,x);

            Extract = mean(Scnd(clf:clf2,:))';
            ExtractSecond1(x) = mean(Extract(time_clf:time_clf2));
            
            Scnd_Pgram =  abs(Periodogram2(:,:,x));
            Extract_Scnd_Pgram = mean(Scnd_Pgram(clf:clf2, :))';
            ExtractSecond1_Pgram(x) = mean(Extract_Scnd_Pgram(time_clf:time_clf2));
           
            

        end
 
        for x = 1:length(PhaseAngle1)

            frequency1 = lowestfreq2;
            frequency2 =  highestfreq2;
            [d clf] = closestrc(freqAxis1{1}, frequency1);
            [d clf2] = closestrc(freqAxis1{1}, frequency2);
            [d time_clf] = closestrc(time1{1}, startptval2);
            [d time_clf2] = closestrc(time1{1}, stopptval2);

            Frst =  First(:,:,x);

            Extract = mean(Frst(clf:clf2,:))';
            ExtractFirst2(x) = mean(Extract(time_clf:time_clf2));
            
            
            Frst_Pgram =  abs(Periodogram1(:,:,x));
            Extract_Frst_Pgram = mean(Frst_Pgram(clf:clf2, :))';
            ExtractFirst2_Pgram(x) = mean(Extract_Frst_Pgram(time_clf:time_clf2));

            

        end



        for x = 1:length(PhaseAngle2)

            frequency1 = lowestfreq2;
            frequency2 =  highestfreq2;
            [d clf] = closestrc(freqAxis2{1}, frequency1);
            [d clf2] = closestrc(freqAxis2{1}, frequency2);
            [d time_clf] = closestrc(time2{1}, startptval2);
            [d time_clf2] = closestrc(time2{1}, stopptval2);

            Scnd =  Second(:,:,x);

            Extract = mean(Scnd(clf:clf2,:))';
            ExtractSecond2(x) = mean(Extract(time_clf:time_clf2));
            
            Scnd_Pgram =  abs(Periodogram2(:,:,x));
            Extract_Scnd_Pgram = mean(Scnd_Pgram(clf:clf2, :))';
            ExtractSecond2_Pgram(x) = mean(Extract_Scnd_Pgram(time_clf:time_clf2));
            

        end
 
        for x = 1:length(filename1)
            name = filename1{x};
            write_matrix{x,1} = name(1:4);
        end
        for x = 1:length(filename3)
            name = filename3{x};
            write_matrix2{x,1} = name(1:4);
        end

        ExtractFirst1 = ExtractFirst1';
        ExtractFirst2 = ExtractFirst2';
        ExtractSecond1 = ExtractSecond1';
        ExtractSecond2 = ExtractSecond2';

        ExtractFirst1_Pgram = ExtractFirst1_Pgram';
        ExtractFirst2_Pgram = ExtractFirst2_Pgram';
        ExtractSecond1_Pgram = ExtractSecond1_Pgram';
        ExtractSecond2_Pgram = ExtractSecond2_Pgram';
        
	%% Write stuff into an excel file.
 
        % The POWER data will go into columns 2 and 3, the phase data
        % into 4 and 5. 
%          for x = 1:length(ExtractFirst1_Pgram)
%             write_matrix{x,2} = ExtractFirst1_Pgram(x);     % Group 1, time-frequency range 1
%         end
% 
%         for x = 1:length(ExtractSecond1_Pgram)
%             write_matrix2{x,2} = ExtractSecond1_Pgram(x);  %Grp2,  time-frequency range 2
%         end
% 
%         for x = 1:length(ExtractFirst2_Pgram)
%             write_matrix{x,3} = ExtractFirst2_Pgram(x);   % Group 1, time-frequency range 2
%         end
% 
%         for x = 1:length(ExtractSecond2_Pgram)
%             write_matrix2{x,3} = ExtractSecond2_Pgram(x);  % Group 2, time-frequency range 2
%         end
%         

        
        for x = 1:length(ExtractFirst1)
            write_matrix{x,2} = ExtractFirst1(x);  % Group 1, time-frequency range 1
 
        end

        for x = 1:length(ExtractSecond1)
            write_matrix2{x,2} = ExtractSecond1(x);  % Group 2, time-frequency range 1
 
        end

        for x = 1:length(ExtractFirst2)			% Group 1, time-frequency range 2
 
            write_matrix{x,3} = ExtractFirst2(x);
        end

        for x = 1:length(ExtractSecond2)			% Group 2, time-frequency range 2
            write_matrix2{x,3} = ExtractSecond2(x);
        end

        
        
        colnames = {'subject', ['Power Spectrum ', num2str(startptval) '_' num2str(stopptval) '_' num2str(lowestfreq) '_' num2str(highestfreq)], ['Power Spectrum ', num2str(startptval2) '_' num2str(stopptval2) '_' num2str(lowestfreq2) '_' num2str(highestfreq2)], ['Phase ', num2str(startptval) '_' num2str(stopptval) '_' num2str(lowestfreq) '_' num2str(highestfreq)], ['Phase ', num2str(startptval2) '_' num2str(stopptval2) '_' num2str(lowestfreq2) '_' num2str(highestfreq2)]};

        colnames = {'subject', ['Phase ', num2str(startptval) '_' num2str(stopptval) '_' num2str(lowestfreq) '_' num2str(highestfreq)], ['Phase ', num2str(startptval2) '_' num2str(stopptval2) '_' num2str(lowestfreq2) '_' num2str(highestfreq2)]};

        header1 = [grp1name '_cross_spectral_analysis'];
        header2 = [grp2name '_cross_spectral_analysis'];

        % writing header names to the file.
      xlswrite(write_matrix, header1, colnames, [grp1name '_x-spectral.xls']);
      xlswrite(write_matrix2, header2, colnames, [grp2name '_x-spectral.xls']);

        

%%  Extract means and STDs for the Cross-Phaseogram
        
        frequency1 = lowestfreq;
        frequency2 = highestfreq;
        [d clf] = closestrc(freqAxis1{1}, frequency1);
        [d clf2] = closestrc(freqAxis1{1}, frequency2);
        [d time_clf] = closestrc(time1{1}, startptval);
        [d time_clf2] = closestrc(time1{1}, stopptval);
        
        % now generate averages and stds for the cross-phase and
        % cross-spectum information.
        Pgram_first_freq_average1 = mean(avgPeriodogram1(clf:clf2,:),1);
        Pgram_first_time_average1 = mean(avgPeriodogram1(:,time_clf:time_clf2),2);
        Pgram_first_freq_std1 = std(mean(Periodogram1(clf:clf2,:,:),1),0,3)./sqrt(length(time1));
        Pgram_first_time_std1 = std(mean(Periodogram1(:,time_clf:time_clf2,:),2),0,3)./sqrt(length(time1));

        frequency1 = lowestfreq;
        frequency2 = highestfreq;
        [d clf] = closestrc(freqAxis2{1}, frequency1);
        [d clf2] = closestrc(freqAxis2{1}, frequency2);
        [d time_clf] = closestrc(time2{1}, startptval);
        [d time_clf2] = closestrc(time2{1}, stopptval);
        Pgram_second_freq_average1 = mean(avgPeriodogram2(clf:clf2,:),1);
        Pgram_second_time_average1 = mean(avgPeriodogram2(:,time_clf:time_clf2),2);
        Pgram_second_freq_std1 = std(mean(Periodogram2(clf:clf2,:,:),1),0,3)./sqrt(length(time2));
        Pgram_second_time_std1 = std(mean(Periodogram2(:,time_clf:time_clf2,:),2),0,3)./sqrt(length(time2));

        frequency1 = lowestfreq2;
        frequency2 = highestfreq2;
        [d clf] = closestrc(freqAxis1{1}, frequency1);
        [d clf2] = closestrc(freqAxis1{1}, frequency2);
        [d time_clf] = closestrc(time1{1}, startptval2);
        [d time_clf2] = closestrc(time1{1}, stopptval2);
        Pgram_first_freq_average2 = mean(avgPeriodogram1(clf:clf2,:),1);
        Pgram_first_time_average2 = mean(avgPeriodogram1(:,time_clf:time_clf2),2);
        Pgram_first_freq_std2 = std(mean(Periodogram1(clf:clf2,:,:),1),0,3)./sqrt(length(time1));
        Pgram_first_time_std2 = std(mean(Periodogram1(:,time_clf:time_clf2,:),2),0,3)./sqrt(length(time1));

        frequency1 = lowestfreq2;
        frequency2 = highestfreq2;
        [d clf] = closestrc(freqAxis2{1}, frequency1);
        [d clf2] = closestrc(freqAxis2{1}, frequency2);
        [d time_clf] = closestrc(time2{1}, startptval2);
        [d time_clf2] = closestrc(time2{1}, stopptval2);
        Pgram_second_freq_average2 = mean(avgPeriodogram2(clf:clf2,:),1);
        Pgram_second_time_average2 = mean(avgPeriodogram2(:,time_clf:time_clf2),2);
        Pgram_second_freq_std2 = std(mean(Periodogram2(clf:clf2,:,:),1),0,3)./sqrt(length(time2));
        Pgram_second_time_std2 = std(mean(Periodogram2(:,time_clf:time_clf2,:),2),0,3)./sqrt(length(time2));

%         figure  % figure 3
%         plot(time1{1},Pgram_first_freq_average1,'r');
%         hold on;
%         plot(time1{1},Pgram_second_freq_average1,'b');
%         plot(time1{1},(Pgram_first_freq_std1 + Pgram_first_freq_average1),'--r');
%         plot(time1{1},(Pgram_second_freq_std1 + Pgram_second_freq_average1),'--b');
%         xlabel('Time (ms)', 'FontSize', 20);
%         ylabel('Power Differences', 'FontSize', 20);
%         legend(grp1name,grp2name);
%         title(['Cross-Power spectrum: ', num2str(lowestfreq) ' to ' num2str(highestfreq) ' Hz'])
% 
%         figure % figure 4
%         plot(freqAxis1{1},Pgram_first_time_average1,'r');
%         hold on;
%         plot(freqAxis1{1}, Pgram_second_time_average1,'b');
%         plot(freqAxis1{1},(Pgram_first_time_std1 + Pgram_first_time_average1),'--r');
%         plot(freqAxis1{1},(Pgram_second_time_std1 + Pgram_second_time_average1),'--b');
%        xlabel('Time (ms)', 'FontSize', 20);
%         ylabel('Power Differences', 'FontSize', 20);
%         legend(grp1name,grp2name);
%         title(['Cross-Power Spectrum  ', num2str(startptval) ' to ' num2str(stopptval) ' ms'])
%         xlim([0 1000]);
% 
%         figure % figure 5
%         plot(time2{1},Pgram_first_freq_average2,'r');
%         hold on;
%         plot(time2{1},Pgram_second_freq_average2,'b');
%         plot(time2{1},(Pgram_first_freq_std2 + Pgram_first_freq_average2),'--r');
%         plot(time2{1},(Pgram_second_freq_std2 + Pgram_second_freq_average2),'--b');
%         xlabel('Time (ms)', 'FontSize', 14);
%         ylabel('Power Differences', 'FontSize', 14);
%         legend(grp1name,grp2name);
%         title(['Cross-Power Spectrum:  ', num2str(lowestfreq2) ' to ' num2str(highestfreq2) ' Hz'], 'FontSize', 20)
% 
%         figure % figure 6
%         plot(freqAxis2{1},Pgram_first_time_average2,'r');
%         hold on;
%         plot(freqAxis2{1},Pgram_second_time_average2,'b');
%         plot(freqAxis2{1},(Pgram_first_time_std2 + Pgram_first_time_average2),'--r');
%         plot(freqAxis2{1},(Pgram_second_time_std2 + Pgram_second_time_average2),'--b');
%         xlabel('Time (ms)', 'FontSize', 14);
%         ylabel('Power Differences', 'FontSize', 14);
%         legend(grp1name,grp2name);
%         title(['Cross-Power Spectrum:  ', num2str(startptval2) ' to ' num2str(stopptval2) ' ms'],'FontSize', 20)
%         xlim([0 1000]);
 
        first_average = mean(First,3);  %this is calculated earlier using a different name
        second_average = mean(Second,3); % this is also calculated earlier uisng a different name.
               
        frequency1 = lowestfreq;
        frequency2 = highestfreq;
        [d clf] = closestrc(freqAxis1{1}, frequency1);
        [d clf2] = closestrc(freqAxis1{1}, frequency2);
        [d time_clf] = closestrc(time1{1}, startptval);
        [d time_clf2] = closestrc(time1{1}, stopptval);
        
        % now generate averages and stds for the cross-phase and
        % cross-spectum information.
        first_freq_average1 = mean(first_average(clf:clf2,:),1);
        first_time_average1 = mean(first_average(:,time_clf:time_clf2),2);
        first_freq_std1 = std(mean(First(clf:clf2,:,:),1),0,3)./sqrt(length(time1));
        first_time_std1 = std(mean(First(:,time_clf:time_clf2,:),2),0,3)./sqrt(length(time1));

        frequency1 = lowestfreq;
        frequency2 = highestfreq;
        [d clf] = closestrc(freqAxis2{1}, frequency1);
        [d clf2] = closestrc(freqAxis2{1}, frequency2);
        [d time_clf] = closestrc(time2{1}, startptval);
        [d time_clf2] = closestrc(time2{1}, stopptval);
        second_freq_average1 = mean(second_average(clf:clf2,:),1);
        second_time_average1 = mean(second_average(:,time_clf:time_clf2),2);
        second_freq_std1 = std(mean(Second(clf:clf2,:,:),1),0,3)./sqrt(length(time2));
        second_time_std1 = std(mean(Second(:,time_clf:time_clf2,:),2),0,3)./sqrt(length(time2));

        frequency1 = lowestfreq2;
        frequency2 = highestfreq2;
        [d clf] = closestrc(freqAxis1{1}, frequency1);
        [d clf2] = closestrc(freqAxis1{1}, frequency2);
        [d time_clf] = closestrc(time1{1}, startptval2);
        [d time_clf2] = closestrc(time1{1}, stopptval2);
        first_freq_average2 = mean(first_average(clf:clf2,:),1);
        first_time_average2 = mean(first_average(:,time_clf:time_clf2),2);
        first_freq_std2 = std(mean(First(clf:clf2,:,:),1),0,3)./sqrt(length(time1));
        first_time_std2 = std(mean(First(:,time_clf:time_clf2,:),2),0,3)./sqrt(length(time1));

        frequency1 = lowestfreq2;
        frequency2 = highestfreq2;
        [d clf] = closestrc(freqAxis2{1}, frequency1);
        [d clf2] = closestrc(freqAxis2{1}, frequency2);
        [d time_clf] = closestrc(time2{1}, startptval2);
        [d time_clf2] = closestrc(time2{1}, stopptval2);
        second_freq_average2 = mean(second_average(clf:clf2,:),1);
        second_time_average2 = mean(second_average(:,time_clf:time_clf2),2);
        second_freq_std2 = std(mean(Second(clf:clf2,:,:),1),0,3)./sqrt(length(time2));
        second_time_std2 = std(mean(Second(:,time_clf:time_clf2,:),2),0,3)./sqrt(length(time2));

	% figure 7
        figure
        plot(time1{1},first_freq_average1,'r');
        hold on;
        plot(time1{1},second_freq_average1,'b');
        plot(time1{1},(first_freq_std1 + first_freq_average1),'--r');
        plot(time1{1},(second_freq_std1 + second_freq_average1),'--b');
        xlabel('Time (ms)', 'FontSize', 14);
        ylabel('Phase shift (radians)', 'FontSize', 14);
        legend(grp1name,grp2name);
        title(['Cross-Phaseogram: ', num2str(lowestfreq) ' to ' num2str(highestfreq) ' Hz'],'FontSize', 20)

	% figure 8
        figure
        plot(freqAxis1{1},first_time_average1,'r');
        hold on;
        plot(freqAxis1{1},second_time_average1,'b');
        plot(freqAxis1{1},(first_time_std1 + first_time_average1),'--r');
        plot(freqAxis1{1},(second_time_std1 + second_time_average1),'--b');
               xlabel('Time (ms)', 'FontSize', 14);
        ylabel('Phase shift (radians)', 'FontSize', 14);
        legend(grp1name,grp2name);
        title(['Cross-Phaseogram: ', num2str(startptval) ' to ' num2str(stopptval) ' ms'],'FontSize', 20)
        xlim([0 1000]);

	% figure 9
        figure
        plot(time2{1},first_freq_average2,'r');
        hold on;
        plot(time2{1},second_freq_average2,'b');
        plot(time2{1},(first_freq_std2 + first_freq_average2),'--r');
        plot(time2{1},(second_freq_std2 + second_freq_average2),'--b');
                xlabel('Time (ms)', 'FontSize', 14);
        ylabel('Phase shift (radians)', 'FontSize', 14);
        legend(grp1name,grp2name);
        title(['Cross-Phaseogram: ', num2str(lowestfreq2) ' to ' num2str(highestfreq2) ' Hz'],'FontSize', 20)

	% figure 10
        figure
        plot(freqAxis2{1},first_time_average2,'r');
        hold on;
        plot(freqAxis2{1},second_time_average2,'b');
        plot(freqAxis2{1},(first_time_std2 + first_time_average2),'--r');
        plot(freqAxis2{1},(second_time_std2 + second_time_average2),'--b');
               xlabel('Time (ms)', 'FontSize', 14);
        ylabel('Phase shift (radians)', 'FontSize', 14);
        legend(grp1name,grp2name);
        title(['Cross-Phaseogram: ', num2str(startptval2) ' to ' num2str(stopptval2) ' ms'],'FontSize', 20)
        xlim([0 1000]);

    end

end
