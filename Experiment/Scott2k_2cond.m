% Clear the workspace
close all;
clearvars;
Screen('CloseAll');

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

%% ============================= %
%           Participant          %
%  ============================= %

pnum=input('Participant number: ');
fname=sprintf('Scott2k_p%0.3d.mat',pnum);
if (exist(fname)~=0)&&(pnum~=9999)
    cont=input('File already exists. Continue? (1=yes, 2=no): ');
    if cont~=1
        return
    end
end

%% ============================= %
%           Triggers Serial Port         %
%  ============================= %
serialport=1; %Enable/disable triggers

st=sprintf('ST'); % harcoded start command
ed=sprintf('ED'); % harcoded end command
C0=sprintf('E '); % Exp start marker
C1=sprintf('A '); % Condition 1
C2=sprintf('B '); % Condition 2
% C3=sprintf('C '); % Condition 3
% C4=sprintf('D '); % Condition 4
 
if serialport==1
    % % NIRS %%%
    com_port=serial('COM1','Baudrate',9600,'DataBits',8,'Parity','none','StopBits',1);
    com_port.Terminator='CR';
    
    fopen(com_port);
end

%% ============================= %
%             SCREEN             %
%  ============================= %

HideCursor;

% Screen ID
screens = Screen('Screens');
screenNumber = max(screens);

% Back, White and Grey RGB indexes
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

KbName('UnifyKeyNames');
QuitChar=KbName('Escape');

% Open the Screen
% % % % [window, windowRect] = PsychImaging('OpenWindow', screenNumber,...
% % % %     grey, [0 0 400 400], 32, 2, [], [], kPsychNeed32BPCFloat);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber,...
    grey, [], 32, 2, [], [], kPsychNeed32BPCFloat);

if serialport==1 % Start NIRS Acquistion
    fprintf(com_port,st);
    disp('NIRS Acquistion Started');
end

% Refresh frequency 1/ifi
ifi = Screen('GetFlipInterval', window);

% Screen Size VERY IMPORTANT!
screenwidth=500; % Monitor Width in mm <---------- CHANGE HERE!!!!
totdist=600; % Distance subject-Monitor in mm <---------- CHANGE HERE!!!!
screenres=windowRect(3); % x Screen Resolution
screenresY=windowRect(4); % x Screen Resolution


textcol=[1 1 1]; % TEXT COLOR
textsize=50;

Screen('TextFont', window, 'Helvetica');
Screen('TextSize', window, textsize);
Screen('TextColor', window, textcol);

% Time to wait in frames for a flip
waitframes = 1;

% Texture cue that determines which texture we will show
textureCue = [1 2];

% Sync us to the vertical retrace
% vbl = Screen('Flip', window);

%% =============================%%
%           Experiment           %
%  ============================= %
trailsPerCondition = 10;     % Number of trials per condition
rest_dur= 15 ;              % Rest Duration
max_jitter_dur = 5;         % Maximum jitter lenght

sentances = 1;             % number of sentances per trial

% Generate Random Condition Order
randConditionOrder= {}

for trail=1:trailsPerCondition
    conditionOrder = {};
    conditionOrder{end+1} = '_f';
    %conditionOrder{end+1} = '_fn';
    %conditionOrder{end+1} = '_fr';
    conditionOrder{end+1} = '_frn';
    Perms = randperm(length(conditionOrder));
    randConditionOrder = [randConditionOrder, conditionOrder(Perms)];
end

% Generate Randomised Sentance Order
randSentanceOrder = {};
sentanceOrder = {}
for list=1:21
    for sentance=1:16
        sentanceOrder{end+1}= strcat(num2str(list,'%02d'), num2str(sentance,'%02d'));
    end
    
end
Perms = randperm(length(sentanceOrder));
randSentanceOrder=sentanceOrder(Perms);

DrawFormattedText(window, 'Please Wait', 'center', 'center', black);
Screen('Flip', window);

WaitSecs(11)

DrawFormattedText(window, 'Press Any Key To Start', 'center', 'center', black);
Screen('Flip', window);
KbStrokeWait;

if serialport==1 % Start of the experiment
    fprintf(com_port,C0);
    WaitSecs(2);
    fprintf(com_port,C0);
    WaitSecs(5);
end


StartTime=GetSecs; % record start of task
f=1;
textsize=20;
Screen('TextSize', window, textsize);
vbl = Screen('Flip', window);

for trial=1:length(randConditionOrder)
    %== Fixation Cross ==
    Screen('FillRect', window, grey);
    Screen('TextSize', window, textsize);
    Screen('TextColor', window, textcol);
    DrawFormattedText(window, '+', 'center', 'center');
    Screen('Flip',window);
    disp('In Trial');
    
    list = trial;
    
    
   condition = randConditionOrder{trial}

    
    %==Send start of trail trigger == 
    if serialport==1 % Start of the task block
        if strcmp(condition,'_f')
            fprintf(com_port,C1);
        elseif strcmp(condition,'_fn')
            fprintf(com_port,C2);
        elseif strcmp(condition,'_fr')
            fprintf(com_port,C3);
        elseif strcmp(condition,'_frn')
            fprintf(com_port,C4);
        end
    end
    
    disp('Stimulating');
    out = {};
    lenout = 0;
for sentance=1:sentances
        next = trial*sentances+sentance;
        file = strcat('stim/BKBQ', num2str(randSentanceOrder{next},'%02d'), condition, '.wav');
        [y,Fs] = audioread(file);
        out{end+1} = y;
        lenout = lenout + length(y);
    end
    stream = [];
    %To pad to 20 secs
    totLen = 15*Fs
    difLeng = totLen - lenout
    padding = int64(difLeng / (sentances - 1))
    for aud=1:length(out)
        stream = cat(1,stream,out{aud},zeros(padding,1));
    end
    
    obj = audioplayer(stream, Fs);
    playblocking(obj);
    
    %==Send end of trail trigger == 
    if serialport==1 % Start of the task block
        if strcmp(condition,'_f')
            fprintf(com_port,C1);
        elseif strcmp(condition,'_fn')
            fprintf(com_port,C2);
        elseif strcmp(condition,'_fr')
            fprintf(com_port,C3);
        elseif strcmp(condition,'_frn')
            fprintf(com_port,C4);
        end
    end
    
    %== Relaxation time
    
    WaitSecs(rest_dur); %+ randi(max_jitter_dur));
 
    %=== Checking for key presses ===
    keyIsDown=0;
        [keyIsDown,secs,keycode] = KbCheck(-1);
        
        if sum(keycode)~=0
            response=find(keycode);
            clear keycode
        else response=999;
        end
        if response==QuitChar
            Screen('CloseAll');
            ShowCursor;
            fclose(com_port);
            delete(com_port);
            save(fname); %save data to file
            return
        end
end

%%% END EXPERIMENT

textsize=60;
Screen('TextSize', window, textsize);
DrawFormattedText(window, 'Experiment Finished \n\n Press Any Key To Exit',...
    'center', 'center', black);
Screen('Flip', window);
KbStrokeWait;
sca;

if serialport==1 % End of the task block
    fprintf(com_port,ed);
    fclose(com_port);
    delete(com_port);
end

ShowCursor;

save(fname);

