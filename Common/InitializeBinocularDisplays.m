function [leftEyeWindow,rightEyeWindow,leftEyeScreenRect,rightEyeScreenRect,initDisplay_OK] = InitializeBinocularDisplays(exp_run,bgcolor,ScrWidth,ScrHeight)

% Initializes PTB screen for monocular/binocular presentations (OLD PTB method).
% function [leftEyeWindow,rightEyeWindow,leftEyeScreenRect,rightEyeScreenRect,initDisplay_OK] =
%                                        InitializeBinocularDisplays(exp_run, bgcolor, ScrWidth, ScrHeight)
%
% Initialize PTB Screen settings for monocular/binocular viewing display
% Available for both haploscope and fMRI experimental environment.
%
% [requirement/dependency]
% Psychtoolbox ver.3 or above
%
% [input]
% exp_run   : experimental environment, string, 'fMRI','Haploscope','TMS',
%             'RedGreen','RedCyan','Nottingham','test_cross', 'test_parallel',
%             or 'Debug'
% bgcolor   : background color, [r,g,b]
% ScrWidth  : the width of the screen, [pixels]
% ScrHeight : the height of the screen, [pixels]
%
% [output]
% leftEyeWindow      : left eye window of PTB screen, pid
% rightEyeWindow     : right eye window of PTB screen, pid
% leftEyeScreenRect  : the size of left screen's rectangle, [x_start y_start x_end y_end]
% rightEyeScreenRect : the size of right screen's rectangle, [x_start y_start x_end y_end]
% initDisplay_OK     : if 1, the initialization is done correctly [0/1]
%
% [note]
% PTB screens should be initialized
% 1. depending on the number of displays you use (1, 2, or 3).
% 2. depending on whether the experiment is conducted with Haploscope or in fMRI scanner.
% for details, please type,
% >> help Screen
% on MATLAB command window.
%
% Created : Feb 04 2010 Hiroshi Ban
% Last Update: "2013-11-22 23:18:05 ban (ban.hiroshi@gmail.com)"

% initialize
leftEyeWindow=[];
rightEyeWindow=[];
leftEyeScreenRect=[];
rightEyeScreenRect=[];

% for fMRI experiment
if strcmp(exp_run,'fMRI')
  if(size(Screen('screens'),2) < 3)
    disp('Not enough displays. Using Scrren 0 alone.');
    % set the same screen number (0) to both (right & left) displays.
    leftEyeScreenRect  = Screen(0, 'rect');
    rightEyeScreenRect  = leftEyeScreenRect;

    rightEyeWindow=Screen(0,'OpenWindow', bgcolor,[]);%,rightEyeScreenRect,32); % 8 bits = 256 graycale. open display window - 32bit white background
    leftEyeWindow=rightEyeWindow;
  else % if there are 3 screens (console, right & left displays)
     leftEyeScreenRect  = Screen(1, 'rect');
     rightEyeScreenRect  = Screen(2, 'rect');
     if rightEyeScreenRect(1)~=0
       rightEyeScreenRect = rightEyeScreenRect - [ScrWidth 0 ScrWidth 0]; % for dual display, for old version of PTB3
     end

     leftEyeWindow=Screen(1,'OpenWindow', bgcolor);%,leftEyeScreenRect,32);   %open display window - 32bit white background
     rightEyeWindow=Screen(2,'OpenWindow', bgcolor);%,rightEyeScreenRect,32);   %open display window - 32bit white background
  end
  initDisplay_OK = 1;

% for haploscope room experiment
elseif strcmp(exp_run,'Haploscope')
  if(size(Screen('screens'),2) < 2)
    disp('Not enough displays');
    % set the same screen number (0) to both (right & left) displays.
    leftEyeScreenRect  = Screen(0, 'rect');
    rightEyeScreenRect  = leftEyeScreenRect;

    rightEyeWindow=Screen(0,'OpenWindow', bgcolor,[]);%,rightEyeScreenRect,32); % 8 is each color depth. open display window - 32bit white background
    leftEyeWindow=rightEyeWindow;
  else % if there are 2 screens (console, and right-left-combined displays(haploscope room))
    leftEyeWindow=Screen(2,'OpenWindow', bgcolor);%,rightEyeScreenRect,32); % 8 is each color depth. open display window - 32bit white background
    rightEyeWindow=leftEyeWindow;

    % strange haplo issue
    rightEyeScreenRect = [0 0 ScrWidth ScrHeight];
    leftEyeScreenRect = rightEyeScreenRect + [ScrWidth 0 ScrWidth 0];
  end
  initDisplay_OK = 1;

% for TMS room experiment
elseif strcmp(exp_run,'TMS')
  if(size(Screen('screens'),2) < 2)
    disp('Not enough displays');
    % set the same screen number (0) to both (right & left) displays.
    leftEyeScreenRect  = Screen(0, 'rect');
    rightEyeScreenRect  = leftEyeScreenRect;

    rightEyeWindow=Screen(0,'OpenWindow', bgcolor,[]);%,rightEyeScreenRect,32); % 8 is each color depth. open display window - 32bit white background
    leftEyeWindow=rightEyeWindow;
  else % if there are 3 screens (console, right & left displays)
     leftEyeScreenRect  = Screen(2, 'rect');
     rightEyeScreenRect  = Screen(1, 'rect');
     if leftEyeScreenRect(1)~=0
       leftEyeScreenRect = leftEyeScreenRect - [ScrWidth 0 ScrWidth 0]; % for dual display, for old version of PTB3
     end
     if rightEyeScreenRect(1)~=0
       rightEyeScreenRect = rightEyeScreenRect - [ScrWidth 0 ScrWidth 0]; % for dual display, for old version of PTB3
     end

     leftEyeWindow=Screen(2,'OpenWindow', bgcolor);%,leftEyeScreenRect,32);   %open display window - 32bit white background
     rightEyeWindow=Screen(1,'OpenWindow', bgcolor);%,rightEyeScreenRect,32);   %open display window - 32bit white background
  end
  initDisplay_OK = 1;

% for Red/Green viewing
elseif strcmp(exp_run,'RedGreen')
  leftEyeScreenRect  = Screen(0, 'rect');
  rightEyeScreenRect  = leftEyeScreenRect;

  rightEyeWindow=Screen(0,'OpenWindow', bgcolor,[]);%,rightEyeScreenRect,32); % 8 bits = 256 graycale. open display window - 32bit white background
  leftEyeWindow=rightEyeWindow;
  initDisplay_OK = 1;

% for Red/Cyan viewing
elseif strcmp(exp_run,'RedCyan')
  leftEyeScreenRect  = Screen(0, 'rect');
  rightEyeScreenRect  = leftEyeScreenRect;

  rightEyeWindow=Screen(0,'OpenWindow', bgcolor,[]);%,rightEyeScreenRect,32); % 8 bits = 256 graycale. open display window - 32bit white background
  leftEyeWindow=rightEyeWindow;
  initDisplay_OK = 1;

% for Nottingham Red/Green viewing
elseif strcmp(exp_run,'Nottingham')
  if size(Screen('screens'),2)<2
    disp('Not enough displays');
    leftEyeScreenRect  = Screen(0, 'rect');
    rightEyeScreenRect  = leftEyeScreenRect;

    rightEyeWindow=Screen(0,'OpenWindow', bgcolor,[]);%,rightEyeScreenRect,32); % 8 bits = 256 graycale. open display window - 32bit white background
    leftEyeWindow=rightEyeWindow;
    initDisplay_OK = 1;
  else
    leftEyeScreenRect  = Screen(1, 'rect');
    rightEyeScreenRect  = leftEyeScreenRect;

    rightEyeWindow=Screen(1,'OpenWindow', bgcolor,[]);%,rightEyeScreenRect,32); % 8 bits = 256 graycale. open display window - 32bit white background
    leftEyeWindow=rightEyeWindow;
    initDisplay_OK = 1;
  end

% for testing stimulus display with parallel viewing
elseif strcmp(exp_run,'test_parallel')
  % set the same screen number (0) to both (right & left) displays.
  tmp=Screen(0,'rect');
  leftEyeScreenRect  = [tmp(1) (tmp(4)-tmp(2))/4 tmp(3)/2 3*(tmp(4)-tmp(2))/4];
  rightEyeScreenRect  = [tmp(3)/2 (tmp(4)-tmp(2))/4 tmp(3) 3*(tmp(4)-tmp(2))/4];

  leftEyeWindow=Screen(0,'OpenWindow', bgcolor,[]);%leftEyeScreenRect,8); % 8 is each color depth. open display window - 32bit white background
  rightEyeWindow=leftEyeWindow; % set the same ID with left window
  initDisplay_OK = 1;

% for testing stimulus display with cross viewing
elseif strcmp(exp_run,'test_cross')
  % set the same screen number (0) to both (right & left) displays.
  tmp=Screen(0,'rect');
  rightEyeScreenRect  = [tmp(1) (tmp(4)-tmp(2))/4 tmp(3)/2 3*(tmp(4)-tmp(2))/4];
  leftEyeScreenRect  = [tmp(3)/2 (tmp(4)-tmp(2))/4 tmp(3) 3*(tmp(4)-tmp(2))/4];

  leftEyeWindow=Screen(0,'OpenWindow', bgcolor,[]);%leftEyeScreenRect,8); % 8 is each color depth. open display window - 32bit white background
  rightEyeWindow=leftEyeWindow; % set the same ID with left window
  initDisplay_OK = 1;

% for Debug
elseif strcmp(exp_run,'Debug')
  leftEyeScreenRect  = Screen(0, 'rect');
  rightEyeScreenRect  = leftEyeScreenRect;

  rightEyeWindow=Screen(0,'OpenWindow', bgcolor,[]);%,rightEyeScreenRect,32); % 8 bits = 256 graycale. open display window - 32bit white background
  leftEyeWindow=rightEyeWindow;
  initDisplay_OK = 1;

else
  initDisplay_OK = 0;
end
