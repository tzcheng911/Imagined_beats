close all
clear all
cd /Users/tzu-hancheng/Google_Drive/Academia/Swartz_center/imaginedbeats/stimuli%% subject information

subDetails.Name = input('Subject Number (e.g., s01): ','s');
subDetails.Age = input('Subject Age: ','s');
subDetails.Sex = input('Subject Sex (M/F): ','s');
subDetails.Hand = input('Subject Handedness (R/L): ','s');

results_dir = fullfile(pwd,subDetails.Name);
    if ~exist(results_dir,'dir'), mkdir(results_dir), end
fnametemp = fullfile(results_dir,'temp_block_bar.mat');
counter=1;
fname = fullfile(results_dir,[subDetails.Name,num2str(counter),'test.mat']);
    while exist(fname,'file')
          counter=counter+1;
          fname = fullfile(results_dir,[subDetails.Name,num2str(counter),'test.mat']);
    end

%% Call LSL library
% addpath(genpath('/Applications/labstreaminglayer-master/LSL/liblsl-Matlab'));
% disp('Loading library...');
% lib = lsl_loadlib();
% 
% disp('Creating a new marker stream info...');
% info = lsl_streaminfo(lib,'MyMarkerStream','Markers',1,1,'cf_string','');
% 
% disp('Opening an outlet...');
% outlet = lsl_outlet(info);
%% window setting    
HideCursor;
FlushEvents;
echo off    
iscreen = []; 
try 
    
AssertOpenGL;
    if isempty(iscreen)
        iscreen = max(Screen('Screens'));
    end
    [wPtr, rect] = Screen('OpenWindow', iscreen);
    w = wPtr;
    wRect = rect;

    resolutions = Screen('Resolution', iscreen);
    video.fps = Screen('FrameRate',wPtr); 
    slack = Screen('GetFlipInterval', wPtr)/2;
    IPF = Screen('GetFlipInterval', wPtr); 

    mx = 1280 ;      % mx = monitor width
    my = 800 ;     % my = monitor height
    
    Screen('BlendFunction', wPtr, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    Screen('Preference', 'TextAlphaBlending', 1);
    
    syncToVBL = 1; 
    if syncToVBL > 0
        asyncflag = 0;
    else 
        asyncflag = 2;
    end

    dontclear = 1; 
    doclear = 0; 
    
%% text property
fontsize = 20;
font ='Helvetica';
KbName('UnifyKeyNames');
EscapeKey = KbName('Escape');
Space=KbName('Space');

%% set color
gray=[128 128 128];

%% set time
fixDuration = 0.5;
ITI = 1;

%% factors
instrument = [1,2,3]; % [1;2;3] = {'hihat';'kickdrum';'puretone'}
tempo = [200,300];
meter = [1,2]; % [1;2] = {'duple';'triple'}
numTrials= 10; %number of trials per subcondition

%% Instruction New Line Text
Screen('TextFont',wPtr, char(font));
Screen('TextSize', wPtr , fontsize);
Screen('DrawText',wPtr,'Press Space key when you are ready to start.',mx/3,my/2, [0 0 0]);
Screen('Flip', wPtr);
KbWait;

%% Trial loop
nTrials = 2;
for ntrial = 1:nTrials
Screen('FillRect',wPtr,gray);
Screen('TextFont',wPtr, char(font));
Screen('TextSize', wPtr ,fontsize);
Screen('DrawText', wPtr, '+' ,mx/2-6 ,my/2-11 ,[0 0 0] ,[],[],[]);
t1=Screen('Flip', wPtr);

% audio stimuli
filename = 'sound_localizer_600ms.wav';
[y,fs] = audioread(filename);
p = audioplayer(y,fs);

% send markers into the outlet
% outlet.push_sample({filename});   % note that the string is wrapped into a cell-array

%%
t = GetSecs;
play(p)
 
    Screen('TextFont',wPtr, char(font));
    Screen('TextSize', wPtr ,fontsize);
    Screen('DrawText',wPtr,'Please close your eyes',mx/3, my/2,[0,0,0]);
    Screen('Flip', wPtr);

end


%% Experiment  End
    Screen('FillRect', wPtr, gray);            
    DrawFormattedText(wPtr, 'End','center','center', [0 0 0],[],[],[],2);
    Screen('Flip', wPtr,[],[],1);
    WaitSecs(1);
    Priority(0);
    Priority(0);
    Screen('CloseAll');
    FlushEvents;
    ShowCursor;
catch
    psychrethrow(psychlasterror);
end