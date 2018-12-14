function [winPtr,winRect,nScr,fps,ifi,initDisplay_OK]=InitializePTBDisplays(disp_mode,bgcolor,flipping,rgb_gains,custom_scrIDs)

% Initializes PTB screen(s) for monocular/binocular presentations using PsychImaging() function.
% function [winPtr,winRect,nScr,fps,ifi,initDisplay_OK]=InitializePTBDisplays(:disp_mode,:bgcolor,:flipping,:rgb_gains,:custom_scrIDs)
% (: is optional)
%
% Initialize PTB Screen settings for monocular/binocular viewing
% Available for both haploscope and fMRI experimental environment.
%
% [requirement/dependency]
% Psychtoolbox ver.3 or above
%
% [example to draw/display stimuli with InitializePTBDisplays]
% >> % Select left-eye image buffer for drawing:
% >> Screen('SelectStereoDrawBuffer', windowPtr, 0);
% >> Screen('DrawDots',...);
% >> (etc, etc.)
% >> % Select right-eye image buffer for drawing:
% >> Screen('SelectStereoDrawBuffer', windowPtr, 1);
% >> Screen('DrawDots',...);
% >> (etc, etc.)
% >> % Tell PTB that drawing is finished for this frame:
% >> Screen('DrawingFinished', windowPtr);
% >> % Flip stim to display and take timestamp of stimulus-onset after
% >> % displaying the new stimulus and record it in vector t:
% >> t=Screen('Flip', windowPtr);
%
% [input]
% disp_mode : display mode, one of "mono", "dual", "dualcross", "dualparallel", "cross", "parallel", "redgreen", "greenred",
%             "redblue", "bluered", "shutter", "topbottom", "bottomtop", "interleavedline", "interleavedcolumn".
%             "mono" by default.
% bgcolor   : background color, [r,g,b]. [127,127,127] by default.
% flipping  : whther flipping displays, 0:none, 1:horizontal, 2:vertical, 3:horizontal & vertical. 0 by default.
% rgb_gains : RGB phosphor gains, [2(left/right)x3(r,g,b)] matrix. [1,1,1;1,1,1] by default.
%             if empty, the default parameters will be set. For details, see the codes below.
% custom_scrIDs : scrIDs you want to force to use in displaying stimuli. [ID] or [ID(left-eye),ID(righteye)].
%                 if empty, default value(s) (dependes on the display mode) will be applied. empty by default.
%
% [output]
% winPtr         : target window pointer
% winRect        : target window screen rect
% nScr           : the number of screens to be used for the presentation
% fps            : screen refresh rate (the number of screen flips per second)
% ifi            : inter flip interval in sec
% initDisplay_OK : if 1, the initialization is done correctly [0/1]
%
% [note]
% PTB screens should be initialized
% 1. depending on the number of displays you use (0, 1, 2, and/or 3).
% 2. depending on whether the experiment is conducted with Haploscope or in fMRI scanner.
% for details, please type,
% >> help Screen
% on MATLAB command window.
%
%
% Created : Feb 04 2010 Hiroshi Ban
% Last Update: "2018-01-30 23:27:19 ban"

% initialize
winPtr=[];
winRect=[];
nScr=2; % use two screens by default, but if disp_mode=='mono', it will turn to 1.

% check input variables
if nargin<1 || isempty(disp_mode), disp_mode='mono'; end
if nargin<2 || isempty(bgcolor), bgcolor=[127,127,127]; end
if nargin<3 || isempty(flipping), flipping=0; end
if nargin<4 || isempty(rgb_gains)
  if strcmpi(disp_mode,'redgreen')
    rgb_gains(1,:)=[1.0,0.0,0.0];
    rgb_gains(2,:)=[0.0,1.0,0.0];%[0.0,0.6,0.0];
  elseif strcmpi(disp_mode,'greenred')
    rgb_gains(1,:)=[0.0,1.0,0.0];%[0.0,0.6,0.0];
    rgb_gains(2,:)=[1.0,0.0,0.0];
  elseif strcmpi(disp_mode,'redblue')
    rgb_gains(1,:)=[0.4,0.0,0.0];
    rgb_gains(2,:)=[0.0,0.2,0.7];
  elseif strcmpi(disp_mode,'bluered')
    rgb_gains(1,:)=[0.0,0.2,0.7];
    rgb_gains(2,:)=[0.4,0.0,0.0];
  else % red green by default.
    rgb_gains(1,:)=[1.0,0.0,0.0];
    rgb_gains(2,:)=[0.0,1.0,0.0];
  end
end
if nargin<5, custom_scrIDs=[]; end

if numel(bgcolor)==1, bgcolor=[bgcolor,bgcolor,bgcolor]; end
if ~isempty(rgb_gains) && size(rgb_gains,2)==1, rgb_gains=[rgb_gains,rgb_gains,rgb_gains]; end
if ~isempty(rgb_gains) && size(rgb_gains,1)==1, rgb_gains=[rgb_gains;rgb_gains]; end

% check OS (Windows or the others)
is_windows=false;
winstr=mexext(); winstr=winstr(end-2:end);
if strcmpi(winstr,'w32') || strcmpi(winstr,'w64'), is_windows=true; end

try

  % assign display mode (stereomode)
  if strcmpi(disp_mode,'mono')
    display_mode=0; % mono display, no stereo at all.
  elseif strcmpi(disp_mode,'dual')
    display_mode=10; % dual display mode (especially for Mac with Matrox DualHead setups)
  elseif strcmpi(disp_mode,'dualcross')
    display_mode=5; % dual displays + free cross fusion (lefteye=right, righteye=left)
  elseif strcmpi(disp_mode,'dualparallel')
    display_mode=4; % dual displays + free parallel fusion (lefteye=left, righteye=right)
  elseif strcmpi(disp_mode,'cross')
    display_mode=5; % free cross fusion (lefteye=right, righteye=left)
  elseif strcmpi(disp_mode,'parallel')
    display_mode=4; % free parallel fusion (lefteye=left, righteye=right)
  elseif strcmpi(disp_mode,'redgreen')
    display_mode=6; % stereo view with red/green glasses
  elseif strcmpi(disp_mode,'greenred')
    display_mode=7; % stereo view with green/red glasses
  elseif strcmpi(disp_mode,'redblue')
    display_mode=8; % stereo view with red/blue glasses
  elseif strcmpi(disp_mode,'bluered')
    display_mode=9; % stereo view with blue/red glasses
  elseif strcmpi(disp_mode,'shutter')
    display_mode=1; % flip frame stereo (temporally interleaved), need shutter glasses
  elseif strcmpi(disp_mode,'topbottom')
    display_mode=2; % top/bottom image stereo with left=top
  elseif strcmpi(disp_mode,'bottomtop')
    display_mode=3; % top/bottom image stereo with left=bottom
  elseif strcmpi(disp_mode,'interleavedline')
    display_mode=100; % interleaved line stereo: left=even scanlines, right=odd scanlines
  elseif strcmpi(disp_mode,'interleavedcolumn')
    display_mode=101; % interleaved column stereo: left=even columns, right=odd columns
  else
    error('disp_mode is not valid. check input variable.');
  end

  % set window ID
  scrID1=max(Screen('Screens'));

  % Windows-Hack: If mode 4 or 5 is requested, we select screen zero as target screen: This will open a window
  % that spans multiple monitors on multi-display setups, which is usually what one wants for this mode.
  if is_windows && ( strcmpi(disp_mode,'dualcross') || strcmpi(disp_mode,'dualparallel') )
    if numel(Screen('Screens'))>1
      scrID1=1;
    else
      scrID1=0;
    end
  end

  % check whether the computer is connected to two displays
  if strcmpi(disp_mode,'dual')
    if length(Screen('Screens'))<2
      warning('Not enough displays. Using screen 0 alone.');
      disp_mode='mono';
    end
  end

  % setup the OS-dependent screen ID for dual display mode
  if strcmpi(disp_mode,'dual')
    if is_windows
      scrID1=1;
    else
      scrID1=0;
    end
  end

  % override the screen ID if it is specified
  if ~isempty(custom_scrIDs), scrID1=custom_scrIDs(1); end

  % set the number of screens
  if strcmpi(disp_mode,'mono'), nScr=1; end

  % Open double-buffered onscreen window with the requested display mode,
  % setup imaging pipeline for additional on-the-fly processing:

  % prep PTB PsychImaging configuration
  PsychImaging('PrepareConfiguration');

  % flipping Screen
  if flipping==1
    PsychImaging('AddTask','AllViews','FlipHorizontal');
  elseif flipping==2
    PsychImaging('AddTask','AllViews','FlipVertical');
  elseif flipping==3
    PsychImaging('AddTask','AllViews','FlipHorizontal');
    PsychImaging('AddTask','AllViews','FlipVertical');
  end

  % triggers line interleaved display:
  if strcmpi(disp_mode,'interleavedline'), PsychImaging('AddTask','General','InterleavedLineStereo',0); end

  % triggers column interleaved display
  if strcmpi(disp_mode,'interleavedcolumn'), PsychImaging('AddTask','General','InterleavedColumnStereo',0); end

  % Consolidate the list of requirements (error checking etc.), open a suitable onscreen window and configure
  % the imaging pipeline for that window according to our specs. The syntax is the same as for Screen('OpenWindow'):
  [winPtr,winRect]=PsychImaging('OpenWindow',scrID1,bgcolor,[],[],[],display_mode);

  % In dual-window, dual-display mode, we open the slave window on
  % the secondary screen. Please note that, after opening this window
  % with the same parameters as the "master-window", we won't touch
  % it anymore until the end of the experiment. PTB will take care of
  % managing this window automatically as appropriate for a stereo
  % display setup. That is why we are not even interested in the window
  % handles of this window:
  if strcmpi(disp_mode,'dual')
    if is_windows
      scrID2=2;
    else
      scrID2=1;
    end
    % override the screen ID when it is specified
    if numel(custom_scrIDs)==2, scrID2=custom_scrIDs(2); end
    Screen('OpenWindow',scrID2,bgcolor,[],[],[],display_mode); % slave window
  end

  % set color gains for stereo glasses viewing
  if ismember(display_mode,[6,7,8,9])
    if isempty(rgb_gains)
      switch display_mode
        case 6,
          SetAnaglyphStereoParameters('LeftGains',winPtr,[1.0,0.0,0.0]);
          SetAnaglyphStereoParameters('RightGains',winPtr,[0.0,0.6,0.0]);
        case 7,
          SetAnaglyphStereoParameters('LeftGains',winPtr,[0.0,0.6,0.0]);
          SetAnaglyphStereoParameters('RightGains',winPtr,[1.0,0.0,0.0]);
        case 8,
          SetAnaglyphStereoParameters('LeftGains',winPtr,[0.4,0.0,0.0]);
          SetAnaglyphStereoParameters('RightGains',winPtr,[0.0,0.2,0.7]);
        case 9,
          SetAnaglyphStereoParameters('LeftGains',winPtr,[0.0,0.2,0.7]);
          SetAnaglyphStereoParameters('RightGains',winPtr,[0.4,0.0,0.0]);
        otherwise
          % do nothing
      end
    else
      SetAnaglyphStereoParameters('LeftGains',winPtr,rgb_gains(1,:));
      SetAnaglyphStereoParameters('RightGains',winPtr,rgb_gains(2,:));
    end
  end

  % get screen refresh rate and inter-flip-interval
  fps=Screen('FrameRate',winPtr);
  ifi=Screen('GetFlipInterval',winPtr);
  fps=60; ifi=1/60;
  if fps==0, fps=1/ifi; end
  %fps=Screen('FrameRate',winPtr);
  %if fps==0
  %  dparam.ifi=Screen('GetFlipInterval',winPtr);
  %  dparam.fps=1/dparam.ifi;
  %else
  %  ifi=1/dparam.fps;
  %end

  initDisplay_OK=true;
catch lasterror
  display(lasterror);
  nScr=0;
  fps=0;
  ifi=0;
  initDisplay_OK=false;
end

return
