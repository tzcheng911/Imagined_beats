close all
clear all
cd /Users/tzu-hancheng/Google_Drive/Research/Proposals/stimuli
%% subject information
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

%% core matrix (3 instruments, 2 tempos, 2 meters) randomize the order of the tempo and the meter
ntrial = 1;
output_result = [];  
    for i = 1:length(instrument) 
        for j = 1:length(tempo)
            for k = 1:length(meter)
                for ntr = 1:numTrials
                    output_result(ntrial,1) = instrument(i);
                    output_result(ntrial,2) = tempo(j);
                    output_result(ntrial,3) = meter(k);
                    output_result(ntrial,4) = 0;
                    ntrial = ntrial + 1;
                end
            end
        end       
    end    
    clear ntrial;
result = output_result;
randomized_1 = output_result(randperm(40),2:3);
randomized_2 = output_result(randperm(40),2:3);
randomized_3 = output_result(randperm(40),2:3);
result(1:40,2:3) = randomized_1;
result(41:80,2:3) = randomized_2;
result(81:120,2:3) = randomized_3;

%% Instruction New Line Text
Screen('TextFont',wPtr, char(font));
Screen('TextSize', wPtr , fontsize);
Screen('DrawText',wPtr,'Press Space key when you are ready to start.',mx/3,my/2, [0 0 0]);
Screen('Flip', wPtr);
KbWait;

%% Trial loop
nTrials = size(result,1);
for ntrial = 1:nTrials
Screen('FillRect',wPtr,gray);
Screen('TextFont',wPtr, char(font));
Screen('TextSize', wPtr ,fontsize);
Screen('DrawText', wPtr, '+' ,mx/2-6 ,my/2-11 ,[0 0 0] ,[],[],[]);
t1=Screen('Flip', wPtr);

% audio stimuli
ninstrument = {'puretone';'kickdrum';'hihat'} ;% 
ntempo = {'200';'300'};
nmeter = {'duple';'triple'};

filename = [ninstrument{result(ntrial,1)} '_' num2str(result(ntrial,2)) 'bpm_' nmeter{result(ntrial,3)} '.wav'];
[y,fs] = audioread(filename);
p = audioplayer(y,fs);

% send markers into the outlet
% outlet.push_sample({filename});   % note that the string is wrapped into a cell-array

%%
t = GetSecs;
play(p)
%draw response reminder
Screen('FillRect',wPtr,gray);
Screen('TextSize', wPtr ,50);
Screen('DrawText',wPtr,'Please start tapping.',mx/3,my/2, [0 0 0]);
if result(ntrial,2) == 200
    t2 = Screen('Flip', wPtr,t+11.8-slack); % trial length = 1 + 10.8 + 5
else 
    t2 = Screen('Flip', wPtr,t+8.2-slack); % trial length = 1 + 7.2 + 5
end
Screen('FillRect',wPtr,gray);
t3=Screen('Flip', wPtr,t2+5-slack,doclear);
 
%% how many breaks
if mod(ntrial,3)==0 
    Screen('TextFont',wPtr, char(font));
    Screen('TextSize', wPtr ,fontsize);
    Screen('DrawText',wPtr,'Take a break! Press space button when you are ready.',mx/3, my/2,[0,0,0]);
    Screen('Flip', wPtr);
    KbWait;
    [keyIsDown, t4, keyCode] = KbCheck;
     if keyCode(EscapeKey)
        break;
     else
        keyCode(Space)
     end  
end

save(fname,'subDetails','result');
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


%% questionaires
basicdialog = basicdialog;
MusicBackground = MusicBackground;
save(fname,'subDetails','result','basicdialog','MusicBackground');