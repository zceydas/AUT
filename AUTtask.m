% set directory
st = dbstack;
namestr = st.name;
directory=fileparts(which([namestr, '.m']));
cd(directory)

PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
%PsychDebugWindowConfiguration(0,0.5) % for debugging purposes

design.trialdeadline=180; % in seconds (for idea generation)
design.subjectId=input('What is subject ID?');
design.Session=input('What is study session? PreTest(1), Test1(2), Test2(3): '); % this can be 1 or 2 (test and re-test)
design.runEEG=input('Are you recording EEG? Yes(1), No(0): '); % this can be 1 or 2 (test and re-test)

datafileName = ['AUT_ID_' num2str(design.subjectId) '_SessionNo' num2str(design.Session) '_Data Folder'];
if ~exist(datafileName, 'dir')
    mkdir(datafileName);
end

if design.runEEG
    design.sp           = BioSemiSerialPort();
    pauseOff=254;
    pauseOn=255;
    design.sp.sendTrigger(pauseOff)
end

%Import the options of the excel file
opts=detectImportOptions('AUTtrials.xlsx');
ConditionList=readtable('AUTtrials.xlsx',opts, 'ReadVariableNames', true);

rng('default')
rng(design.subjectId)
order=shuffle([1:9]); % on each session 15 of them will be presented
if design.Session == 1
    sessionorder=order(1:3);
elseif design.Session == 2
    sessionorder=order(4:6);
elseif design.Session == 3
    sessionorder=order(7:9);
end

mic_image=imread('mic_image.png');
baseRect = [0 0 200 200];


% Get the screen numbers
screens = Screen('Screens');

% Select the external screen if it is present, else revert to the native
% screen
screenNumber = max(screens);

% Define black, white and grey
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
design.grey = white / 2;

% Open an on screen window and color it grey
[design.window, design.windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Set the blend funciton for the screen
Screen('BlendFunction', design.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Get the size of the on screen window in pixels
% For help see: Screen WindowSize?
[screenXpixels, design.screenYpixels] = Screen('WindowSize', design.window);

% Get the centre coordinate of the window in pixels
% For help see: help RectCenter
[design.xCenter, design.yCenter] = RectCenter(design.windowRect);
design.allRects(:, 1) = CenterRectOnPointd(baseRect, design.xCenter, design.yCenter);
numchannels = 1; % mono sound
% you can CHOOSE your frequency when recording
design.freq = 44100;

% we also open an audio channel when we're doing recording
audiochannel = PsychPortAudio('Open', [], 2, [], design.freq, numchannels);
% except we set it to 2 instead of 1
% 2 is for recording mode
% 3 is for BOTH

% we need to set aside from space for the sound that we're going to record
PsychPortAudio('GetAudioData', audiochannel, 10);
% this would set aside 10 seconds of recording per trial
% better to error on the side of caution
% if you use MORE than the time you alloted, it starts writing over the
% start of the sound (like an old VHS tape)

Screen('TextSize', design.window, 30);
AUTInstructions(design);

Trialtype='Practice';
Index = find(contains(ConditionList.TrialType,Trialtype));
Results={}; counter=1;
for t=1:length(Index)
    Category=ConditionList.Category{Index(t)};
    design.fontsize=70;
    [Results,counter]=AUTTrialstructure(design,counter,Results,audiochannel,mic_image,t,Category,Trialtype);
end
PracticeTable=cell2table(Results,'VariableNames',{'TrialNo' 'Category' 'ReadTime' 'RT' 'Recordtime' 'TaskType'});
writetable(PracticeTable,['AUTPracticeResults',num2str(design.Session),'_' 'subject',num2str(design.subjectId),'_',date,'.xlsx']);

Screen('TextSize', design.window, 30);
DrawFormattedText(design.window, sprintf('%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s', ...
    'Great! You are now done with practice.', ...
    'If you have any questions, ask the researcher now. ', ...
    'Otherwise, press a key to start testing.'), 'center', 'center',design.grey,[100],[],[],[2]);
Screen('Flip',design.window); KbStrokeWait;

Trialtype='Test'; Results={}; counter=1;
for t=1:length(sessionorder)
    
    Category=ConditionList.Category{sessionorder(t)};
    design.fontsize=70;
    [Results,counter]=AUTTrialstructure(design,counter,Results,audiochannel,mic_image,t,Category,Trialtype);
end
TestTable=cell2table(Results,'VariableNames',{'TrialNo' 'Category' 'ReadTime' 'RT' 'Recordtime' 'TaskType'});
writetable(TestTable,['AUTTestResults',num2str(design.Session),'_' 'subject',num2str(design.subjectId),'_',date,'.xlsx']);

PsychPortAudio('Close', audiochannel);

files = dir(['subject' num2str(design.subjectId) '*.wav']);
for f=1:length(files)
    movefile(fullfile(files(f).folder,files(f).name), datafileName)
end
tablefiles = dir(['*_subject' num2str(design.subjectId) '*.xlsx']);
for f=1:length(tablefiles)
    movefile(fullfile(tablefiles(f).folder,tablefiles(f).name), datafileName)
end

Screen('TextSize', design.window, 30);
DrawFormattedText(design.window, sprintf('%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s', ...
    'Great! You finished the game!', ...
    'Thank you for your participation!'), 'center', 'center',design.grey,[100],[],[],[2]);
Screen('Flip',design.window); KbStrokeWait;

if design.runEEG
    design.sp.sendTrigger(pauseOn)
end

% Clear the screen
sca;