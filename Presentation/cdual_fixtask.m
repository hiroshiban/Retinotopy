function cdual_fixtask(subjID,exp_mode,acq,displayfile,stimulusfile,gamma_table,overwrite_flg,force_proceed_flag)

% Color/luminance-defined checkerboard retinotopy stimulus with checker-patch luminance change-detection tasks.
% function cdual_fixtask(subjID,exp_mode,acq,:displayfile,:stimulusfile,:gamma_table,:overwrite_flg,:force_proceed_flag)
% (: is optional)
%
% This function generates and presents color/luminance-defined checkerboard stimulus
% to measure cortical retinotopy and to delineate retinotopic borders.
%
% [note]
% Behavioral task of cdual_fixtask is to detect changes of luminance of the central
% fixation period, whereas tasks in cdual is to detect changes of luminance of one
% of the patches in the checkerboard stimuli. The central fixation task will be
% suitable for naive participants as it can minimize eye movement of untrained observers.
%
% - Acquired fMRI data evoked by this stimulus will be utilized
%   to delineate retinotopic visual area borders (conventional retinotopy)
% - This script shoud be used with MATLAB Psychtoolbox version 3 or above.
% - Stimulus presentation timing are controled by vertical synch signals
%
%
% Created    : "2018-12-20 14:26:03 ban"
% Last Update: "2019-02-01 16:57:50 ban"
%
%
%
% [input variables]
% sujID         : ID of subject, string, such as 's01'
%                 you also need to create a directory ./subjects/(subj) and put displayfile and stimulusfile there.
%                 !!!!!!!!!!!!!!!!!! IMPORTANT NOTE !!!!!!!!!!!!!!!!!!!!!!!!
%                 !!! if 'debug' (case insensitive) is included          !!!
%                 !!! in subjID string, this program runs as DEBUG mode; !!!
%                 !!! stimulus images are saved as *.png format at       !!!
%                 !!! ~/Retinotopy/Presentation/images                   !!!
%                 !!!!!!!!!!!!!!!!!! IMPORTANT NOTE !!!!!!!!!!!!!!!!!!!!!!!!
%
% exp_mode      : experiment mode that you want to run, one of
%  - ccwexp : a checkerboard wedge rotating counter-clockwisely + an expanding annulus
%  - cwexp  : a checkerboard wedge rotating clockwisely + an expanding annulus
%  - ccwcont: a checkerboard wedge rotating counter-clockwisely + a contracting annulus
%  - cwcont : a checkerboard wedge rotating clockwisely + a contracting annulus
% acq           : acquisition number (design file number),
%                 an integer, such as 1, 2, 3, ...
% displayfile   : (optional) display condition file,
%                 *.m file, such as 'RetDepth_display_fmri.m'
%                 the file should be located in ./subjects/(subj)/
% stimulusfile  : (optional) stimulus condition file,
%                 *.m file, such as 'RetDepth_stimulus_exp1.m'
%                 the file should be located in ./subjects/(subj)/
% gamma_table   : (optional) table(s) of gamma-corrected video input values (Color LookupTable).
%                 256(8-bits) x 3(RGB) x 1(or 2,3,... when using multiple displays) matrix
%                 or a *.mat file specified with a relative path format. e.g. '/gamma_table/gamma1.mat'
%                 The *.mat should include a variable named "gamma_table" consists of a 256x3xN matrix.
%                 if you use multiple (more than 1) displays and set a 256x3x1 gamma-table, the same
%                 table will be applied to all displays. if the number of displays and gamma tables
%                 are different (e.g. you have 3 displays and 256x3x!2! gamma-tables), the last
%                 gamma_table will be applied to the second and third displays.
%                 if empty, normalized gamma table (repmat(linspace(0.0,1.0,256),3,1)) will be applied.
% overwrite_flg : (optional) whether overwriting pre-existing result file. if 1, the previous result
%                 file with the same acquisition number will be overwritten by the previous one.
%                 if 0, the existing file will be backed-up by adding a prefix '_old' at the tail
%                 of the file. 0 by default.
% force_proceed_flag : (optional) whether proceeding stimulus presentatin without waiting for
%                 the experimenter response (e.g. presesing the ENTER key) or a trigger.
%                 if 1, the stimulus presentation will be automatically carried on.
%
% !!! NOTICE !!!!
% displayfile & stimulusfile should be located at
% ./subjects/(subjID)/
% as ./subjects/(subjID)/*_display_fmri.m
%    ./subjects/(subjID)/*_stimuli.m
%
%
% [output variables]
% no output matlab variable.
%
%
% [output files]
% 1. result file
%    stored ./subjects/(subjID)/results/(date)
%    as ./subjects/(subjID)/results/(date)/(subjID)_cdual_fixtask_(exp_mode)_results_run_(run_num).mat
%
%
% [example]
% >> cdual_fixtask('HB','ccwexp',1,'ret_display.m','ret_checker_stimulus_exp1.m')
%
% [About displayfile]
% The contents of the displayfile are as below.
% (The file includs 6 lines of headers and following display parameters)
%
% (an example of the displayfile)
%
% % ************************************************************
% % This is the display configuration file for the retinotopy stimuli
% % Programmed by Hiroshi Ban Nov 01 2013
% % ************************************************************
%
% % display mode, one of "mono", "dual", "cross", "parallel", "redgreen", "greenred",
% % "redblue", "bluered", "shutter", "topbottom", "bottomtop", "interleavedline", "interleavedcolumn"
% dparam.ExpMode='mono';
%
% dparam.scrID=1; % screen ID, generally 0 for a single display setup, 1 for dual display setup
%
% % a method to start stimulus presentation
% % 0:ENTER/SPACE, 1:Left-mouse button, 2:the first MR trigger pulse (CiNet),
% % 3:waiting for a MR trigger pulse (BUIC) -- checking onset of pin #11 of the parallel port,
% % or 4:custom key trigger (wait for a key input that you specify as tgt_key).
% dparam.start_method=2;
%
% % a pseudo trigger key from the MR scanner when it starts, valid only when dparam.start_method=4;
% dparam.custom_trigger='t';
%
% % keyboard settings
% dparam.Key1=51; % key 1 (left)
% dparam.Key2=52; % key 2 (right)
%
% % screen settings
%
% %%% whether displaying the stimuli in full-screen mode or
% %%% as is (the precise resolution), 'true' or 'false' (true)
% dparam.fullscr=false;
%
% %%% the resolution of the screen height
% dparam.ScrHeight=1200;
%
% %% the resolution of the screen width
% dparam.ScrWidth=1920;
%
% % whether forcing to use specific frame rate, if 0, the frame rate wil bw computed in the ImagesShowPTB function.
% % if non zero, the value is used as the screen frame rate.
% dparam.force_frame_rate=60;
%
% % whther skipping the PTB's vertical-sync signal test. if 1, the sync test is skipped
% dparam.skip_sync_test=0;
%
%
% [About stimulusfile]
% The contents of the stimulusfile are as below.
% (The file includs 6 lines of headers and following stimulus parameters)
%
% (an example of the stimulusfile)
%
% % ************************************************************
% % This is the stimulus parameter file for the dual (wedge + annulus) retinotopy stimulus
% % Programmed by Hiroshi Ban Jan 25 2019
% % ************************************************************
%
% % "sparam" means "stimulus generation parameters"
%
% %%% stimulus parameters
% sparam.pol_nwedges     = 4;     % number of wedge subdivisions along polar angle
% sparam.pol_nrings      = 8;     % number of ring subdivisions along eccentricity angle
% sparam.pol_width       = 48;    % wedge width in deg along polar angle
% sparam.pol_phase       = 0;     % phase shift in deg
% sparam.pol_rotangle    = 12;    % rotation angle in deg
% sparam.pol_startangle  = -sparam.pol_width/2-90; % presentation start angle in deg, from right-horizontal meridian, ccw
%
% sparam.ecc_nwedges     = 4;     % number of wedge subdivisions along polar angle
% sparam.ecc_nrings      = 2;     % number of ring subdivisions along eccentricity angle
% sparam.ecc_width       = sparam.pol_width/2;
% sparam.ecc_phase       = 0;     % phase shift in deg
% sparam.ecc_rotangle    = sparam.pol_rotangle;
% sparam.ecc_startangle  = -sparam.ecc_width/2-90;  % presentation start angle in deg, from right-horizontal meridian, ccw (actually this value is not used for the eccentricity stimuli (exp and cont))
%
% sparam.maxRad      = 6.0    % maximum radius of  annulus (degrees)
% sparam.minRad      = 0;    % minumum
%
% sparam.dimratio    = 0.4; % luminance dim ratio for the checker-pattern change detection task
%
% sparam.colors      = [ 128, 128, 128; % number of colors for compensating flickering checkerboard
%                        255,   0,   0; % the first row is background
%                          0, 255,   0; % the second to end are patch colors
%                        255, 255,   0;
%                          0,   0, 255;
%                        255,   0, 255;
%                          0, 255, 255;
%                        255, 255, 255;
%                          0,   0,   0;
%                        255, 128,   0;
%                        128,   0, 255;];
%
% %%% duration in msec for each cycle & repetitions
% % ===========================================================================================================================================
% % IMPORTANT NOTE: sparam.pol_cycle_duration x sparam.pol_numRepeats should be the same with sparam.ecc_cycle_duration x sparam.ecc_numRepeats
% % ===========================================================================================================================================
%
% sparam.pol_cycle_duration=60000; % msec
% sparam.pol_rest_duration =0; % msec, rest after each cycle, stimulation = cycle_duration-eccrest
% sparam.pol_numRepeats=6;
%
% sparam.ecc_cycle_duration=40000; % msec
% sparam.ecc_rest_duration =8000; % msec, rest after each cycle, stimulation = cycle_duration-eccrest
% sparam.ecc_numRepeats=9;
%
% %%% set number of frames to flip the screen
% % Here, I set the number as large as I can to minimize vertical cynching error.
% % the final 2 is for 2 times repetitions of flicker
% % Set 1 if you want to flip the display at each vertical sync, but not recommended due to much CPU power
% sparam.waitframes = Screen('FrameRate',0)*(sparam.cycle_duration/1000) / (360/sparam.rotangle) / ( (size(sparam.colors,1)-1)*2 );
% % sparam.waitframes = 1;
%
% %%% fixation period in msec before/after presenting the target stimuli, integer
% % must set a value more than 1 TR for initializing the frame counting.
% sparam.initial_fixation_time=[4000,4000];
%
% %%% fixation size & color
% sparam.fixsize=12; % radius in pixels
% sparam.fixcolor=[255,255,255];
%
% %%% background color
% sparam.bgcolor=sparam.colors(1,:); %[0,0,0];
%
% %%% RGB for background patches
% % 1x3 matrices
% sparam.patch_color1=[255,255,255];
% sparam.patch_color2=[0,0,0];
%
% %%% for converting degree to pixels
% run(fullfile(fileparts(mfilename('fullpath')),'sizeparams'));
% %sparam.pix_per_cm=57.1429;
% %sparam.vdist=65;
%
%
% [HOWTO create stimulus files]
% 1. All of the stimuli are created in this script in real-time
%    with MATLAB scripts & functions.
%    see ../Generation & ../Common directries.
% 2. Stimulus parameters are defined in the display & stimulus file.
%
%
% [about stimuli and task]
% The central fixation point sometimes changes its color from white to gray.
% If you find this contrast difference, press any key.
% Response kes are difined in display file.
%
%
% [reference]
% for stmulus generation, see ../Generation & ../Common directories.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Check the input variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear global; clear mex;
if nargin<3, help(mfilename()); return; end
if nargin<4 || isempty(displayfile), displayfile=[]; end
if nargin<5 || isempty(stimulusfile), stimulusfile=[]; end
if nargin<6 || isempty(gamma_table), gamma_table=[]; end
if nargin<7 || isempty(overwrite_flg), overwrite_flg=1; end
if nargin<8 || isempty(force_proceed_flag), force_proceed_flag=0; end

% check the aqcuisition number
if acq<1, error('Acquistion number must be integer and greater than zero'); end

% check the experiment mode (stimulus type)
if ~strcmpi(exp_mode,'ccwexp') && ~strcmpi(exp_mode,'cwexp') && ~strcmpi(exp_mode,'ccwcont') && ~strcmpi(exp_mode,'cwcont')
  error('exp_mode should be one of "ccwexp", "cwexp", "ccwcont", and "cwcont". check the input variable.');
end

% check the subject directory
if ~exist(fullfile(pwd,'subjects',subjID),'dir'), error('can not find subj directory. check the input variable.'); end

rootDir=fileparts(mfilename('fullpath'));

% check the display/stimulus files
if ~isempty(displayfile)
  if ~strcmpi(displayfile(end-1:end),'.m'), displayfile=[displayfile,'.m']; end
  if ~exist(fullfile(rootDir,'subjects',subjID,displayfile),'file'), error('displayfile not found. check the input variable.'); end
end

if ~isempty(stimulusfile)
  if ~strcmpi(stimulusfile(end-1:end),'.m'), stimulusfile=[stimulusfile,'.m']; end
  if ~exist(fullfile(rootDir,'subjects',subjID,stimulusfile),'file'), error('stimulusfile not found. check the input variable.'); end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Add path to the subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% add paths to the subfunctions
addpath(genpath(fullfile(rootDir,'..','Common')));
addpath(fullfile(rootDir,'..','Generation'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% For log file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get date
today=datestr(now,'yymmdd');

% result directry & file
resultDir=fullfile(rootDir,'subjects',num2str(subjID),'results',today);
if ~exist(resultDir,'dir'), mkdir(resultDir); end

% record the output window
logfname=fullfile(resultDir,[num2str(subjID),'_cdual_fixtask_',exp_mode,'_results_run_',num2str(acq,'%02d'),'.log']);
diary(logfname);
warning off; %#ok warning('off','MATLAB:dispatcher:InexactCaseMatch');


%%%%% try & catch %%%%%
try


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Check the PTB version
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PTB_OK=CheckPTBversion(3); % check wether the PTB version is 3
if ~PTB_OK, error('Wrong version of Psychtoolbox is running. %s requires PTB ver.3',mfilename()); end

% debug level, black screen during calibration
Screen('Preference', 'VisualDebuglevel', 3);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Setup random seed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

InitializeRandomSeed();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Reset display Gamma-function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(gamma_table)
  gamma_table=repmat(linspace(0.0,1.0,256),3,1); %#ok
  GammaResetPTB(1.0);
else
  GammaLoadPTB(gamma_table);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Validate dparam (displayfile) and sparam (stimulusfile) structures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% organize dparam
dparam=struct(); % initialize
if ~isempty(displayfile), run(fullfile(rootDir,'subjects',subjID,displayfile)); end % load specific dparam parameters configured for each of the participants
dparam=ValidateStructureFields(dparam,... % validate fields and set the default values to missing field(s)
         'ExpMode','mono',...
         'scrID',1,...
         'start_method',0,...
         'custom_trigger','t',...
         'Key1',51,...
         'Key2',52,...
         'fullscr',false,...
         'ScrHeight',1200,...
         'ScrWidth',1920,...
         'force_frame_rate',60,...
         'skip_sync_test',0);

% organize sparam
sparam=struct(); % initialize
sparam.mode=exp_mode;
if ~isempty(stimulusfile), run(fullfile(rootDir,'subjects',subjID,stimulusfile)); end % load specific sparam parameters configured for each of the participants
sparam=ValidateStructureFields(sparam,... % validate fields and set the default values to missing field(s)
         'pol_nwedges',4,...
         'pol_nrings',4,...
         'pol_width',48,...
         'pol_phase',0,...
         'pol_rotangle',12,...
         'pol_startangle',-48/2-90,...
         'ecc_nwedges',4,...
         'ecc_nrings',2,...
         'ecc_width',48,...
         'ecc_phase',0,...
         'ecc_rotangle',12,...
         'ecc_startangle',-48/2-90,...
         'maxRad',8,...
         'minRad',0,...
         'dimratio',0.4,...
         'colors',[ 128, 128, 128;
                    255,   0,   0;
                      0, 255,   0;
                    255, 255,   0;
                      0,   0, 255;
                    255,   0, 255;
                      0, 255, 255;
                    255, 255, 255;
                      0,   0,   0;
                    255, 128,   0;
                    128,   0, 255],...
         'pol_cycle_duration',60000,...
         'pol_rest_duration',0,...
         'pol_numRepeats',6,...
         'ecc_cycle_duration',40000,...
         'ecc_rest_duration',8000,...
         'ecc_numRepeats',9,...
         'waitframes',6,... % Screen('FrameRate',0)*(sparam.cycle_duration/1000) / (360/sparam.rotangle) / ( (size(sparam.colors,1)-1)*2 );
         'initial_fixation_time',[4000,4000],...
         'fixsize',12,...
         'fixcolor',[255,255,255],...
         'bgcolor',[128,128,128],... % sparam.colors(1,:);
         'patch_color1',[255,255,255],...
         'patch_color2',[0,0,0],...
         'pix_per_cm',57.1429,...
         'vdist',65);

% change unit from msec to sec.
sparam.initial_fixation_time=sparam.initial_fixation_time./1000; %#ok

% change unit from msec to sec.
sparam.pol_cycle_duration = sparam.pol_cycle_duration./1000;
sparam.pol_rest_duration  = sparam.pol_rest_duration./1000;

sparam.ecc_cycle_duration = sparam.ecc_cycle_duration./1000;
sparam.ecc_rest_duration  = sparam.ecc_rest_duration./1000;

% set the other parameters
dparam.RunScript = mfilename();
sparam.RunScript = mfilename();

%% check varidity of parameters
fprintf('checking validity of stimulus generation/presentation parameters...');
if sparam.pol_cycle_duration*sparam.pol_numRepeats~=sparam.ecc_cycle_duration*sparam.ecc_numRepeats
  error('sparam.pol_cycle_duration x sparam.pol_numRepeats should be the same with sparam.ecc_cycle_duration x sparam.ecc_numRepeats. check the input variables.');
end
if mod(360,sparam.pol_rotangle), error('mod(360,sparam.pol_rotangle) should be 0. check the input variables.'); end
if mod(360,sparam.ecc_rotangle), error('mod(360,sparam.ecc_rotangle) should be 0. check the input variables.'); end
if mod(sparam.pol_width,sparam.pol_rotangle), error('mod(sparam.pol_width,sparam.pol_rotangle) should be 0. check the input variables.'); end
if mod(sparam.ecc_width,sparam.ecc_rotangle), error('mod(sparam.ecc_width,sparam.ecc_rotangle) should be 0. check the input variables.'); end
disp('done.');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Displaying the presentation parameters you set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('The Presentation Parameters are as below.\n\n');
fprintf('************************************************\n');
fprintf('****** Script, Subject, Acquistion Number ******\n');
fprintf('Running Script Name    : %s\n',mfilename());
fprintf('Subject ID             : %s\n',subjID);
fprintf('Acquisition Number     : %d\n',acq);
fprintf('********* Run Type, Display Image Type *********\n');
fprintf('Display Mode           : %s\n',dparam.ExpMode);
fprintf('use Full Screen Mode   : %d\n',dparam.fullscr);
fprintf('Start Method           : %d\n',dparam.start_method);
if dparam.start_method==4
  fprintf('Custom Trigger         : %d\n',dparam.custom_trigger);
end
fprintf('*************** Screen Settings ****************\n');
fprintf('Screen Height          : %d\n',dparam.ScrHeight);
fprintf('Screen Width           : %d\n',dparam.ScrWidth);
fprintf('*********** Stimulation Periods etc. ***********\n');
fprintf('Fixation Time(sec)     : %d & %d\n',sparam.initial_fixation_time(1),sparam.initial_fixation_time(2));
fprintf('[POL] Cycle Duration(sec) : %d\n',sparam.pol_cycle_duration);
fprintf('      Rest  Duration(sec) : %d\n',sparam.pol_rest_duration);
fprintf('      Repetitions(cycles) : %d\n',sparam.pol_numRepeats);
fprintf('[ECC] Cycle Duration(sec) : %d\n',sparam.ecc_cycle_duration);
fprintf('      Rest  Duration(sec) : %d\n',sparam.ecc_rest_duration);
fprintf('      Repetitions(cycles) : %d\n',sparam.ecc_numRepeats);
fprintf('Frame Flip(per VerSync): %d\n',sparam.waitframes);
fprintf('Total Time (sec)       : %d\n',sum(sparam.initial_fixation_time)+sparam.pol_numRepeats*sparam.pol_cycle_duration);
fprintf('**************** Stimulus Type *****************\n');
fprintf('Experiment Mode        : %s\n',sparam.mode);
fprintf('************ Response key settings *************\n');
fprintf('Reponse Key #1         : %d = %s\n',dparam.Key1,KbName(dparam.Key1));
fprintf('Reponse Key #2         : %d = %s\n',dparam.Key2,KbName(dparam.Key2));
fprintf('************************************************\n\n');
fprintf('Please carefully check before proceeding.\n\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initialize response & event logger objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize MATLAB objects for event and response logs
event=eventlogger();
resps=responselogger([dparam.Key1,dparam.Key2]);
resps.initialize(event); % initialize responselogger


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Wait for user reponse to start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~force_proceed_flag
  [user_answer,resps]=resps.wait_to_proceed();
  if ~user_answer, diary off; return; end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initialization of Left & Right screens for binocular presenting/viewing mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if dparam.skip_sync_test, Screen('Preference','SkipSyncTests',1); end

[winPtr,winRect,nScr,dparam.fps,dparam.ifi,initDisplay_OK]=InitializePTBDisplays(dparam.ExpMode,sparam.bgcolor,0,[],dparam.scrID);
if ~initDisplay_OK, error('Display initialization error. Please check your exp_run parameter.'); end
HideCursor();

if isstructmember(dparam,'force_frame_rate')
  if dparam.force_frame_rate
    dparam.fps=dparam.force_frame_rate;
    dparam.ifi=1/dparam.fps;
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Setting the PTB runnning priority to MAX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set the priority of this script to MAX
priorityLevel=MaxPriority(winPtr,'WaitBlanking');
Priority(priorityLevel);

% conserve VRAM memory: Workaround for flawed hardware and drivers
% 32 == kPsychDontShareContextRessources: Do not share ressources between
% different onscreen windows. Usually you want PTB to share all ressources
% like offscreen windows, textures and GLSL shaders among all open onscreen
% windows. If that causes trouble for some weird reason, you can prevent
% automatic sharing with this flag.
%Screen('Preference','ConserveVRAM',32);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Setting the PTB OpenGL functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Enable OpenGL mode of Psychtoolbox: This is crucially needed for clut animation
InitializeMatlabOpenGL();

% This script calls Psychtoolbox commands available only in OpenGL-based
% versions of the Psychtoolbox. (So far, the OS X Psychtoolbox is the
% only OpenGL-base Psychtoolbox.)  The Psychtoolbox command AssertPsychOpenGL will issue
% an error message if someone tries to execute this script on a computer without
% an OpenGL Psychtoolbox
AssertOpenGL();

% set OpenGL blend functions
Screen('BlendFunction', winPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initializing MATLAB OpenGL shader API
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% just call DrawTextureWithCLUT with window pointer alone
DrawTextureWithCLUT(winPtr);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Displaying 'Initializing...'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% displaying texts on the center of the screen
DisplayMessage2('Initializing...',sparam.bgcolor,winPtr,nScr,'Arial',36);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initializing variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% unit conversion

% cm per pix
sparam.cm_per_pix=1/sparam.pix_per_cm;

% pixles per degree
sparam.pix_per_deg=round( 1/( 180*atan(sparam.cm_per_pix/sparam.vdist)/pi ) );

% deg to radian
% do not convert!
% sparam.width, sparam.phase, sparam.startangle, sparam.rotangle are used in deg formats

% number of checkerboard color
sparam.ncolors=(size(sparam.colors,1)-1)/2;

% sec to number of frames
nframe_fixation=round(sparam.initial_fixation_time.*dparam.fps./sparam.waitframes);

sparam.pol_npositions=360/sparam.pol_rotangle;
sparam.ecc_npositions=sparam.pol_npositions*(sparam.ecc_cycle_duration-sparam.ecc_rest_duration)/(sparam.pol_cycle_duration-sparam.pol_rest_duration);

nframe_rotation=round((sparam.pol_cycle_duration-sparam.pol_rest_duration)*dparam.fps/(360/sparam.pol_rotangle)/sparam.waitframes);
nframe_flicker=round(nframe_rotation/sparam.ncolors/4);
nframe_task=round(18/sparam.waitframes); % just arbitral, you can change as you like

%% initialize chackerboard parameters

% adjust size ratio considering full-screen effect
if dparam.fullscr
  % here, use width information alone, assuming that the pixel is square
  ratio_wid=( winRect(3)-winRect(1) )/dparam.ScrWidth;
  %ratio_hei=( winRect(4)-winRect(2) )/dparam.ScrHeight;

  % min/max radius of annulus
  rmin=sparam.minRad*ratio_wid; % !!! degree, not pixel or cm !!!
  rmax=sparam.maxRad*ratio_wid;
else
  rmin=sparam.minRad;
  rmax=sparam.maxRad;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Generating checkerboard patterns
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [note]
% After this processing, each checkerboard image has checker elements with values as shown below
% 0 = background
% 1 = checker ID 1
% 2 = checker ID 2
% 3 = checker ID 3
% .....
% sparam.npatches = checker ID
% Each patch ID will be associated with a CLUT color of the same ID

%%% a wedge for polar representation
startangles=zeros(sparam.pol_npositions,1);
for nn=1:1:sparam.pol_npositions, startangles(nn)=sparam.pol_startangle+(nn-1)*sparam.pol_rotangle; end

[pol_checkerboardID,pol_checkerboard]=pol_GenerateCheckerBoard1D(rmin,rmax,sparam.pol_width,startangles,sparam.pix_per_deg,...
                                                                       sparam.pol_nwedges,sparam.pol_nrings,sparam.pol_phase);

%%% an annulus for eccentricity representation
eccedge=(rmax-rmin)/( sparam.ecc_npositions-1 );
eccwidth=eccedge*(sparam.ecc_width/sparam.ecc_rotangle);

% get annuli's min/max lims
ecclims=zeros(sparam.ecc_npositions,3);
for nn=1:1:sparam.ecc_npositions %1:1:sparam.npositions
  minlim=rmin+(nn-1)*eccedge-eccwidth/2;
  if minlim<rmin, minlim=rmin; end
  maxlim=rmin+(nn-1)*eccedge+eccwidth/2;
  if maxlim>rmax, maxlim=rmax; end

  ecclims(nn,:)=[minlim,maxlim,eccwidth];
end

[ecc_checkerboardID,ecc_checkerboard]=ecc_GenerateCheckerBoard1D(ecclims,360,sparam.ecc_startangle,sparam.pix_per_deg,...
                                      round(360*sparam.ecc_nwedges/sparam.ecc_width),sparam.ecc_nrings,sparam.ecc_phase);

%% flip all data for ccw/cont
if ~isempty(strfind(sparam.mode,'ccw'))

  tmp_checkerboardID=cell(sparam.pol_npositions,1);
  for nn=1:1:sparam.pol_npositions, tmp_checkerboardID{nn}=pol_checkerboardID{sparam.pol_npositions-(nn-1)}; end
  pol_checkerboardID=tmp_checkerboardID;
  clear tmp_checkerboardID;

  tmp_checkerboard=cell(sparam.pol_npositions,1);
  for nn=1:1:sparam.pol_npositions, tmp_checkerboard{nn}=pol_checkerboard{sparam.pol_npositions-(nn-1)}; end
  pol_checkerboard=tmp_checkerboard;
  clear tmp_checkerboard;

end

if ~isempty(strfind(sparam.mode,'cont'))

  tmp_checkerboardID=cell(sparam.ecc_npositions,1);
  for nn=1:1:sparam.ecc_npositions, tmp_checkerboardID{nn}=ecc_checkerboardID{sparam.ecc_npositions-(nn-1)}; end
  ecc_checkerboardID=tmp_checkerboardID;
  clear tmp_checkerboardID;

  tmp_checkerboard=cell(sparam.ecc_npositions,1);
  for nn=1:1:sparam.ecc_npositions, tmp_checkerboard{nn}=ecc_checkerboard{sparam.ecc_npositions-(nn-1)}; end
  ecc_checkerboard=tmp_checkerboard;
  clear tmp_checkerboard;

end

%%% generate the combined checkerboard patterns

commduration=lcm(sparam.pol_cycle_duration,sparam.ecc_cycle_duration); % the least common multiple duration at which the stimulus rotation turns to the beginning.
if commduration<sparam.pol_cycle_duration*sparam.pol_numRepeats
  pol_subrepeats=ceil(commduration/sparam.pol_cycle_duration);
  ecc_subrepeats=ceil(commduration/sparam.ecc_cycle_duration);
else
  fprintf('WARNING: It is recommended to adjust the sparam parameters so that lcm(sparam.pol_cycle_duration,sparam.ecc_cycle_duration) is less than sparam.pol_cycle_duration*sparam.pol_numRepeats\n');
  pol_subrepeats=sparam.pol_numRepeats;
  ecc_subrepeats=sparam.ecc_numRepeats;
end

% put the rest period for polar patterns
nrest=sparam.pol_npositions/(sparam.pol_cycle_duration-sparam.pol_rest_duration)*sparam.pol_rest_duration;
if nrest>0
  if ~isempty(strfind(sparam.mode,'ccw'))
    pol_checkerboard=[pol_checkerboard;repmat({zeros(size(pol_checkerboard{1}))},nrest,1)];
    pol_checkerboardID=[pol_checkerboardID;repmat({zeros(size(pol_checkerboardID{1}))},nrest,1)];
  else % if ~isempty(strfind(sparam.mode,'cw'))
    pol_checkerboard=[repmat({zeros(size(pol_checkerboard{1}))},nrest,1);pol_checkerboard];
    pol_checkerboardID=[repmat({zeros(size(pol_checkerboardID{1}))},nrest,1);pol_checkerboardID];
  end
end

% put the rest period for eccentricity patterns
nrest=sparam.ecc_npositions/(sparam.ecc_cycle_duration-sparam.ecc_rest_duration)*sparam.ecc_rest_duration;
if nrest>0
  if ~isempty(strfind(sparam.mode,'cont'))
    ecc_checkerboard=[repmat({zeros(size(ecc_checkerboard{1}))},nrest,1);ecc_checkerboard];
    ecc_checkerboardID=[repmat({zeros(size(ecc_checkerboardID{1}))},nrest,1);ecc_checkerboardID];
  else % if ~isempty(strfind(sparam.mode,'ecc'))
    ecc_checkerboard=[ecc_checkerboard;repmat({zeros(size(ecc_checkerboard{1}))},nrest,1)];
    ecc_checkerboardID=[ecc_checkerboardID;repmat({zeros(size(ecc_checkerboardID{1}))},nrest,1)];
  end
end

% multiply the patterns for the pol_subrepeats
pol_checkerboard=repmat(pol_checkerboard,pol_subrepeats,1);
pol_checkerboardID=repmat(pol_checkerboardID,pol_subrepeats,1);

% initialize the final checkerboard by eccentricity patterns
checkerboard=repmat(ecc_checkerboard,ecc_subrepeats,1);
checkerboardID=repmat(ecc_checkerboardID,ecc_subrepeats,1);

% get the maximum ID of the ecc_checkerboardID
maxID=1;
for nn=1:1:length(ecc_checkerboardID)
  if maxID<max(ecc_checkerboardID{nn}(:))
    maxID=max(ecc_checkerboardID{nn}(:));
  end
end

% overwrite the polar patterns
for nn=1:1:length(pol_checkerboard)
  checkerboard{nn}(pol_checkerboard{nn}~=0)=pol_checkerboard{nn}(pol_checkerboard{nn}~=0);
  checkerboardID{nn}(pol_checkerboardID{nn}~=0)=pol_checkerboardID{nn}(pol_checkerboardID{nn}~=0)+maxID; % +maxID is required to avoid overlapping of the IDs
end
clear pol_checkerboard pol_checkerboardID ecc_checkerboard ecc_checkerboardID;

% generate the final checkerboard patterns
subrepeats=ceil(sparam.pol_numRepeats/pol_subrepeats);
checkerboard=repmat(checkerboard,[subrepeats,1]);
checkerboardID=repmat(checkerboardID,[subrepeats,1]);

% cut the patterns that exceeds the whole stimulus presentation trials
if length(checkerboard) > sparam.pol_cycle_duration*sparam.pol_numRepeats/(sparam.pol_cycle_duration/sparam.pol_npositions)
  checkerboard=checkerboard(1:sparam.pol_cycle_duration*sparam.pol_numRepeats/(sparam.pol_cycle_duration/sparam.pol_npositions));
end

%% Make Checkerboard textures
checkertexture=cell(length(checkerboard),1);
for nn=1:1:length(checkerboard)
  checkertexture{nn}=Screen('MakeTexture',winPtr,checkerboard{nn});
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initializing Color Lookup-Table (CLUT)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [note]
% all checker color/luminance flickering is realized by just flipping CLUT generated here
% to save memory and CPU power

CLUT=cell(sparam.ncolors,2); % 2 is for compensating patterns

% generate base CLUT
for cc=1:1:sparam.ncolors
  for pp=1:1:2 % compensating checkers

    % initialize, DrawTextureWithCLUT requires [256x4] color lookup table even when we do not use whole 256 colors
    % though DrawTextureWithCLUT does not support alpha transparency up to now...
    CLUT{cc,pp}=zeros(256,4);
    CLUT{cc,pp}(:,4)=1; % default alpha is 1 (no transparent)

    CLUT{cc,pp}(1,:)=[sparam.colors(1,:),0]; % background LUT, default alpha is 0 (invisible);

    if ~mod(pp,2)
      CLUT{cc,pp}(2,1:3)=sparam.colors(2*cc,:);
      CLUT{cc,pp}(3,1:3)=sparam.colors(2*cc+1,:);
    else
      CLUT{cc,pp}(2,1:3)=sparam.colors(2*cc+1,:);
      CLUT{cc,pp}(3,1:3)=sparam.colors(2*cc,:);
    end

  end % for pp=1:1:2 % compensating checkers
end % for cc=1:1:sparam.ncolors


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Debug codes
%%%% just to save each images as *.png format files.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%% DEBUG codes start here
% note: debug stimuli have no jitters of binocular disparity
if strfind(upper(subjID),'DEBUG')

  % just to get stimulus figures
  Screen('CloseAll');
  for nn=1:1:length(checkerboard)
    figure; hold on;
    imfig=imagesc(flipdim(checkerboard{nn},1),[0,numel(unique(checkerboardID{nn}))-1]);
    axis off; axis square;
    colormap(CLUT{1,1}(1:3,1:3)./255);
    fname=sprintf('retinotopy_%s_pos%02d.png',sparam.mode,nn);
    save_dir=fullfile(pwd,'images');
    if ~exist(save_dir,'dir'), mkdir(save_dir); end
    saveas(imfig,[save_dir,filesep(),fname,'.png'],'png');
  end
  save([save_dir,filesep(),sprintf('checkerboard_%s.mat',sparam.mode)],'checkerboard','sparam','dparam','CLUT');
  keyboard;

end % if strfind(upper(subjID),'DEBUG')
% %%%%%% DEBUG code ends here


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Generating fixation detection task parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% set task variables
% flag to decide whether presenting fixation task
totalframes=max(sum(nframe_fixation),1)+length(checkerboard)*nframe_rotation;
num_tasks=ceil(totalframes/nframe_task);
task_flg=ones(1,num_tasks);
for nn=2:1:num_tasks
  if task_flg(nn-1)==2
    task_flg(nn)=1;
  else
    if mod(randi(4,1),4)==0 % this is arbitral, but I put these lines just to reduce the number of tasks
      task_flg(nn)=round(rand(1,1))+1;
    else
      task_flg(nn)=1;
    end
  end
end
task_flg=repmat(task_flg,nframe_task,1);
task_flg=task_flg(:);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initializing checkerboard color management parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% checkerboard color id
color_id=1;

% checkerboard compensating color id
compensate_id=1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Creating background images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% creating target and background images

%%%% Creating background %%%
patch_size=[5,5]; patch_num=[30,30];
%aperture_size=[500,500];

% calculate the central aperture size of the background image
edgeY=mod(dparam.ScrHeight,patch_num(1)); % delete exceeded region
p_height=round((dparam.ScrHeight-edgeY)/patch_num(1)); % height in pix of patch_height + interval-Y

edgeX=mod(dparam.ScrWidth,patch_num(2)); % delete exceeded region
p_width=round((dparam.ScrWidth-edgeX)/patch_num(2)); % width in pix of patch_width + interval-X

aperture_size(1)=2*( p_height*ceil(rmax*sparam.pix_per_deg/p_height) );
aperture_size(2)=2*( p_width*ceil(rmax*sparam.pix_per_deg/p_width) );

bgimg{1} = repmat(reshape(sparam.colors(1,:),[1,1,3]),[dparam.ScrHeight,dparam.ScrWidth]);
%bgimg = CreateBackgroundImage([dparam.ScrHeight,dparam.ScrWidth],aperture_size,patch_size,sparam.bgcolor,sparam.patch_color1,sparam.patch_color2,sparam.fixcolor,patch_num,0,0,0);
background = Screen('MakeTexture',winPtr,bgimg{1});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Creating the central fixation, cross images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create fixation cross images, first larger fixations are generated, then they are antialiased
% This is required to present a beautiful circle
fix=CreateFixationImgCircular(4*sparam.fixsize,sparam.fixcolor,sparam.bgcolor,4*sparam.fixsize,0,0);
dark_fix=CreateFixationImgCircular(4*sparam.fixsize,[64,64,64],sparam.bgcolor,4*sparam.fixsize,0,0);
fix=imresize(fix,0.25);
dark_fix=imresize(dark_fix,0.25);

fcircle=cell(2,1); % 1 is for default fixation, 2 is for darker fixation (luminance detection task)
fcircle{1}=Screen('MakeTexture',winPtr,fix);
fcircle{2}=Screen('MakeTexture',winPtr,dark_fix);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Image size adjusting to match the current display resolutions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if dparam.fullscr
  ratio_wid= ( winRect(3)-winRect(1) )/dparam.ScrWidth;
  ratio_hei= ( winRect(4)-winRect(2) )/dparam.ScrHeight;
  bgSize   = [size(bgimg{1},2)*ratio_wid, size(bgimg{1},1)*ratio_hei];
  stimSize = [size(checkerboard{1},2)*ratio_wid, size(checkerboard{1},1)*ratio_hei];
  fixSize  = [2*sparam.fixsize*ratio_wid, 2*sparam.fixsize*ratio_hei];
else
  bgSize   = [dparam.ScrWidth, dparam.ScrHeight];
  stimSize = [size(checkerboard{1},2), size(checkerboard{1},1)];
  fixSize  = [2*sparam.fixsize, 2*sparam.fixsize];
end

% for some display modes in which one screen is splitted into two binocular displays
if strcmpi(dparam.ExpMode,'cross') || strcmpi(dparam.ExpMode,'parallel') || ...
   strcmpi(dparam.ExpMode,'topbottom') || strcmpi(dparam.ExpMode,'bottomtop')
  bgSize=bgSize./2;
  stimSize=stimSize./2;
  fixSize=fixSize./2;
end

bgRect  = [0, 0, bgSize]; % used to display background images;
stimRect= [0, 0, stimSize];
fixRect = [0, 0, fixSize]; % used to display the central fixation point


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initialize functions and variables for trial loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize variables that we will use during the experiment (faster)
cur_frames=0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Displaying 'Ready to Start'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% displaying texts on the center of the screen
DisplayMessage2('Ready to Start',sparam.bgcolor,winPtr,nScr,'Arial',36);
ttime=GetSecs(); while (GetSecs()-ttime < 0.5), end  % run up the clock.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Flip the display(s) to the background image(s)
%%%% and inform the ready of stimulus presentation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% change the screen and wait for the trigger or pressing the start button
for nn=1:1:nScr
  Screen('SelectStereoDrawBuffer',winPtr,nn-1);
  Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
  Screen('DrawTexture',winPtr,fcircle{2},[],CenterRect(fixRect,winRect));
end
Screen('DrawingFinished',winPtr);
Screen('Flip', winPtr,[],[],[],1);

% prepare the next frame for the initial fixation period
for nn=1:1:nScr
  Screen('SelectStereoDrawBuffer',winPtr,nn-1);
  Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
  Screen('DrawTexture',winPtr,fcircle{1},[],CenterRect(fixRect,winRect)); % fix{1} is valis as no task in the first period
end
Screen('DrawingFinished',winPtr);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Wait for the first trigger pulse from fMRI scanner or start with button pressing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% add time stamp (this also works to load add_event method in memory in advance of the actual displays)
fprintf('\nWaiting for the start...\n');
event=event.add_event('Experiment Start',strcat([datestr(now,'yymmdd'),' ',datestr(now,'HH:mm:ss')]),GetSecs());

% waiting for stimulus presentation
resps.wait_stimulus_presentation(dparam.start_method,dparam.custom_trigger);
%PlaySound(1);
fprintf('\nExperiment running...\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initial Fixation Period
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vbl=Screen('Flip',winPtr,[],[],[],1); % the first flip
[event,the_experiment_start]=event.set_reference_time(GetSecs());
event=event.add_event('Initial Fixation',[]);
fprintf('\nfixation\n\n');
cur_frames=cur_frames+1;

% wait for the initial fixation
for ff=1:1:nframe_fixation(1)
  for nn=1:1:nScr
    Screen('SelectStereoDrawBuffer',winPtr,nn-1);
    Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
    Screen('DrawTexture',winPtr,fcircle{task_flg(cur_frames)},[],CenterRect(fixRect,winRect));
  end
  Screen('DrawingFinished',winPtr);
  Screen('Flip',winPtr,vbl+(ff*sparam.waitframes-0.5)*dparam.ifi,[],[],1);
  cur_frames=cur_frames+1;

  % update task
  if task_flg(cur_frames-1)==2 && task_flg(cur_frames-2)==1, event=event.add_event('Luminance Task',[]); end

  [resps,event]=resps.check_responses(event);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% The Trial Loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for cc=1:1:length(checkerboard)
  % NOTE: as this event will be logged before the first flip in the trial,
  % it will be faster by sparam.waitframes in the record of the event. Please be careful.
  event=event.add_event(sprintf('Trial: %d',cc),[]);
  if cc==1, fprintf('Trial: '); end
  if mod(cc,20)~=0 && cc~=length(checkerboard), fprintf(sprintf('%03d, ',cc)); end
  if mod(cc,20)==0 || cc==length(checkerboard), fprintf('%03d\n       ',cc); end

  %% stimulus presentation loop
  for ff=1:1:nframe_rotation

    %% display the current frame
    for nn=1:1:nScr
      Screen('SelectStereoDrawBuffer',winPtr,nn-1);
      Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect)); % background
      DrawTextureWithCLUT(winPtr,checkertexture{cc},CLUT{color_id,compensate_id},[],CenterRect(stimRect,winRect)); % checkerboard
      Screen('DrawTexture',winPtr,fcircle{task_flg(cur_frames)},[],CenterRect(fixRect,winRect)); % the central fixation oval
    end

    % flip the window
    Screen('DrawingFinished',winPtr);
    Screen('Flip',winPtr,vbl+sparam.initial_fixation_time(1)+( ((cc-1)*nframe_rotation+(ff-1))*sparam.waitframes-0.5 )*dparam.ifi,[],[],1);
    cur_frames=cur_frames+1;

    % update task
    if task_flg(cur_frames)==2 && task_flg(cur_frames-1)==1, event=event.add_event('Luminance Task',[]); end

    %% exit from the loop if the final frame is displayed

    if ff==nframe_rotation && cc==length(checkerboard), continue; end

    %% update IDs

    % flickering checkerboard
    if ~mod(ff,nframe_flicker) % color reversal
      compensate_id=mod(compensate_id,2)+1;
    end

    if ~mod(ff,2*nframe_flicker) % color change
      color_id=color_id+1;
      if color_id>sparam.ncolors, color_id=1; end
    end

    % get responses
    [resps,event]=resps.check_responses(event);

  end % for ff=1:1:nframe_rotation
end % for cc=1:1:length(checkerboard)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Final Fixation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for nn=1:1:nScr
  Screen('SelectStereoDrawBuffer',winPtr,nn-1);
  Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
  Screen('DrawTexture',winPtr,fcircle{task_flg(cur_frames)},[],CenterRect(fixRect,winRect));
end
Screen('DrawingFinished',winPtr);
Screen('Flip',winPtr,vbl+sparam.initial_fixation_time(1)+sparam.pol_numRepeats*sparam.pol_cycle_duration-0.5*dparam.ifi,[],[],1); % the first flip
%cur_frames=cur_frames+1;
event=event.add_event('Final Fixation',[]);
fprintf('\nfixation\n');

% wait for the initial fixation
for ff=1:1:nframe_fixation(2)
  for nn=1:1:nScr
    Screen('SelectStereoDrawBuffer',winPtr,nn-1);
    Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
    Screen('DrawTexture',winPtr,fcircle{task_flg(cur_frames)},[],CenterRect(fixRect,winRect));
  end
  Screen('DrawingFinished',winPtr);
  Screen('Flip',winPtr,vbl+sparam.initial_fixation_time(1)+sparam.pol_numRepeats*sparam.pol_cycle_duration+(ff*sparam.waitframes-0.5)*dparam.ifi,[],[],1);
  cur_frames=cur_frames+1;

  % update task
  if task_flg(cur_frames-1)==2 && task_flg(cur_frames-2)==1, event=event.add_event('Luminance Task',[]); end

  [resps,event]=resps.check_responses(event);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Experiment & scanner end here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

experimentDuration=GetSecs()-the_experiment_start;
event=event.add_event('End',[]);
disp(' ');
fprintf('Experiment Completed: %.2f/%.2f secs\n',experimentDuration,...
        sum(sparam.initial_fixation_time)+sparam.pol_numRepeats*sparam.pol_cycle_duration);
disp(' ');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Write data into file for post analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% saving the results
fprintf('saving data...');

% save data
savefname=fullfile(resultDir,[num2str(subjID),'_cdual_fixtask_',sparam.mode,'_results_run_',num2str(acq,'%02d'),'.mat']);

% backup the old file(s)
if ~overwrite_flg
  BackUpObsoleteFiles(fullfile('subjects',num2str(subjID),'results',today),...
                      [num2str(subjID),'_cdual_fixtask_',sparam.mode,'_results_run_',num2str(acq,'%02d'),'.mat'],'_old');
end

eval(sprintf('save %s subjID acq sparam dparam event gamma_table;',savefname));
disp('done.');

% calculate & display task performance
fprintf('calculating task accuracy...\n');
correct_event=cell(2,1); for ii=1:1:2, correct_event{ii}=sprintf('key%d',ii); end
[task.numTasks,task.numHits,task.numErrors,task.numResponses,task.RT]=event.calc_accuracy(correct_event);
event=event.get_event(); % convert an event logger object to a cell data structure
eval(sprintf('save -append %s event task;',savefname));
disp('done.');

% tell the experimenter that the measurements are completed
try
  for ii=1:1:3, Snd('Play',sin(2*pi*0.2*(0:900)),8000); end
catch
  % do nothing
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Cleaning up MATLAB OpenGL shader API
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% just call DrawTextureWithCLUT without any input argument
DrawTextureWithCLUT();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Cleaning up the PTB screen, removing path to the subfunctions, and finalizing the script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Screen('CloseAll');
ShowCursor();
Priority(0);
GammaResetPTB(1.0);
rmpath(genpath(fullfile(rootDir,'..','Common')));
rmpath(fullfile(rootDir,'..','Generation'));
%clear all; clear mex; clear global;
diary off;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Catch the errors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

catch lasterror
  % this "catch" section executes in case of an error in the "try" section
  % above.  Importantly, it closes the onscreen window if its open.
  Screen('CloseAll');
  ShowCursor();
  Priority(0);
  GammaResetPTB(1.0);
  tmp=lasterror; %#ok
  %if exist('event','var'), event=event.get_event(); end %#ok % just for debugging
  diary off;
  fprintf(['\nErrror detected and the program was terminated.\n',...
           'To check error(s), please type ''tmp''.\n',...
           'Please save the current variables now if you need.\n',...
           'Then, quit by ''dbquit''\n']);
  keyboard;
  rmpath(genpath(fullfile(rootDir,'..','Common')));
  rmpath(fullfile(rootDir,'..','Generation'));
  %psychrethrow(psychlasterror);
  %clear global; clear mex; clear all; close all;
  return
end % try..catch


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% That's it - we're done
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return;
% end % function cdual_fixtask
