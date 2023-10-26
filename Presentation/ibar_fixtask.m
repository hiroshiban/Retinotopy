function ibar_fixtask(subjID,exp_mode,acq,displayfile,stimulusfile,gamma_table,overwrite_flg,force_proceed_flag)

% Object-image-defined bar stimulus with fixation luminance change-detection tasks.
% function ibar_fixtask(subjID,exp_mode,acq,:displayfile,:stimulusfile,:gamma_table,:overwrite_flg,:force_proceed_flag)
% (: is optional)
%
% - This function generates and presents the conventional pRF bar stimulus on which
%   object images are randomly located with brownian noise images on its background.
%   The bar sweeps periodically over the whole visual field.
%   The stimulus can be used to measure cortical retinotopy and to delineate retinotopic
%   borders using the standard pRF (population receptive field) analysis techniques.
%
%   reference: Population receptive field estimates in human visual cortex.
%              Dumoulin, S.O. and Wandell, B.A. (2008). Neuroimage, 39(2), 647-660.
%
% - This script shoud be used with MATLAB Psychtoolbox version 3 or above.
%
% - Luminance detection task: the central fixation point (default: white)
%   randomly turns to gray. An observer has to press the button if s/he
%   detects this luminance change. Response keys are defined in displayfile.
%
% [about the object images used in this function]
% The object images used in this function (stored in ~/Retinotopy/object_images/ as object_image_database.mat) are
% obtained and modified from the databases publicly available from http://konklab.fas.harvard.edu/#
% I sincerely express my gratitude to the developers, distributors, and scientists in Dr Talia Konkle's research group
% for their contributions to these databases. When you use this function for your research, please cite the original
% papers listed below.
%
% - Tripartite Organization of the Ventral Stream by Animacy and Object Size.
%   Konkle, T., & Caramazza, A. (2013). Journal of Neuroscience, 33 (25), 10235-42.
%
% - A real-world size organization of object responses in occipito-temporal cortex.
%   Konkle. T., & Oliva, A. (2012). Neuron, 74(6), 1114-24.
%
% - Visual long-term memory has a massive storage capacity for object details.
%   Brady, T. F., Konkle, T., Alvarez, G. A. & Oliva, A. (2008). Proceedings of the National Academy of Sciences USA, 105(38), 14325-9.
%
% - Conceptual distinctiveness supports detailed visual long-term memory.
%   Konkle, T., Brady, T. F., Alvarez, G. A., & Oliva, A. (2010). Journal of Experimental Psychology: General, 139(3), 558-578.
%
% - A Familiar Size Stroop Effect: Real-world size is an automatic property of object representation.
%   Konkle, T., & Oliva, A. (2012). Journal of Experimental Psychology: Human Perception & Performance, 38, 561-9.
%
% [note]
% Behavioral task of (function_name)_fixtask is to detect changes of luminance
% of the central fixation point, while the task in (function_name) is to detect
% changes of luminance of one of the patches in the checkerboard stimuli.
% Here, the central fixation task is more easy to sustain the stable fixation
% on the center of the screen and may be suitable for naive/non-expert
% participants with minimizing unwilling eye movements. However, some studies
% have reported that attention to the target stimulus (checker-patch luminance
% change detection task) is required to get reliable retinotopic representations
% in higher-order visual areas.
%
%
% Created    : "2019-03-05 15:54:52 ban"
% Last Update: "2023-10-26 15:58:22 ban"
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
% exp_mode      : experiment mode acceptable in this script is only "bar"
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
%    as ./subjects/(subjID)/results/(date)/(subjID)_ibar_fixtask_results_run_(run_num).mat
%
%
% [example]
% >> ibar_fixtask('HB','bar',1,'bar_display.m','bar_stimulus.m')
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
% % display mode, one of "mono", "dual", "dualcross", "dualparallel", "cross", "parallel", "redgreen", "greenred",
% % "redblue", "bluered", "shutter", "topbottom", "bottomtop", "interleavedline", "interleavedcolumn", "propixxmono", "propixxstereo"
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
% % whether displaying stimulus onset marker when each of the stimuli is presented (e.g. each timing of the rotating wedge onset).
% % the marker can be used to get a photodiode trigger etc. The trigger duration is set to each_of_stim_on_duration/2.
% % [type,onset_marker_size]
% % type, 0: none, 1: upper-left, 2: upper-right, 3: lower-left, 4: lower-right
% % onset_marker_size : pixels of the marker
% dparam.onset_punch=[0,50];
%
%
% [About stimulusfile]
% The contents of the stimulusfile are as below.
% (The file includs 6 lines of headers and following stimulus parameters)
%
% (an example of the stimulusfile)
%
% % ************************************************************
% % This is the stimulus parameter file for the pRF bar stimulus
% % Programmed by Hiroshi Ban Nov 20 2018
% % ************************************************************
%
% % "sparam" means "stimulus generation parameters"
%
% %%% stimulus parameters
% sparam.fieldSize   = 12; % stimulation field size in deg, [row,col]. circular region with sparam.fieldSize is stimulated.
% sparam.width       = 1.5; % bar width in deg
%
% % rotation angles in deg, 0 = right horizontal meridian, counter-clockwise.
% % when sparam.rotangles(1)=0, the bar emerges at the right hemifield and sweeps
% % the visual field leftwards.
% %
% % following this parameter, stimulus presentation seuence is defined.
% % for instance, is sparam.rotangles   = [0,45,90,135,180,225,270,315];,
% % the bar sweeps visual field like
% % 1. sparam.rotangles(1)=0   : right to left horizontally, then rest for sparam.rest_duration
% % 2. sparam.rotangles(2)=45  : upper right to lower left at 45 deg direction, then rest for sparam.rest_duration
% % 3. sparam.rotangles(3)=90  : upper to lower vertically, then rest for sparam.rest_duration
% % 4. sparam.rotangles(4)=135 : upper left to lower right at 45 deg direction, then rest for sparam.rest_duration
% % ...
% % ... to sparam.rotangles(end)
% sparam.rotangles   = [0,45,90,135,180,225,270,315];
%
% sparam.steps       = 16; % steps in sweeping the visual field (from start to end)
%
% %%% duration in msec for each cycle & repetitions
% sparam.cycle_duration=40000; % msec
% sparam.rest_duration =8000; % msec, rest after each cycle, stimulation = cycle_duration-eccrest
% sparam.numRepeats=1;
%
% %%% parameters used only for object-image-based retinotopy stimuli
% sparam.flip_duration=250; % msec
% sparam.nimg=120; % number of images to be presented at a frame
% sparam.imRatio=[0.2,0.5]; % image magnification ratio, [min, max] (0.0-1.0), the image sizes are randomly selected whithin this range
% sparam.imdepth=[-12,12]; % disparities (arcmins) added to the images, effective only in a stereo mode (e.g. shutter, dual, parallel etc)
%
% %%% set number of frames to flip the screen
% % Here, I set the number as large as I can to minimize vertical cynching error.
% % Set 1 if you want to flip the display at each vertical sync, but not recommended as it uses much CPU power
% sparam.waitframes = 6; % #frames for each object-images, 30 = 0.5 sec if the display vsynch = 60 Hz.
%
% %%% fixation period in msec before/after presenting the target stimuli, integer
% % must set a value more than 1 TR for initializing the frame counting.
% sparam.initial_fixation_time=[4000,4000];
%
% %%% fixation size & color
% sparam.fixtype=1; % 1: circular, 2: rectangular, 3: concentric fixation point
% sparam.fixsize=4; % radius in pixels
% sparam.fixcolor=[255,255,255];
%
% %%% background color
% sparam.bgcolor=[128,128,128];
%
% %%% background-patch colors (RGB)
% sparam.bgtype=1; % 1: a simple background with sparam.bgcolor (then, the parameters belows are not used), 2: a background with grid guides
% sparam.patch_size=[30,30]; % background patch size, [height,width] in pixels
% sparam.patch_num=[20,40];  % the number of background patches along vertical and horizontal axis
% sparam.patch_color1=[255,255,255];
% sparam.patch_color2=[0,0,0];
%
% %%% for converting degree to pixels
% run(fullfile(fileparts(mfilename('fullpath')),'sizeparams'));
% %sparam.pix_per_cm=57.1429;
% %sparam.vdist=65;
% %sparam.ipd=6.5;
%
%
% [HOWTO create stimulus files]
% 1. All of the stimuli are created in this script in real-time
%    with MATLAB scripts & functions.
%    see ../Generation & ../Common directries.
% 2. Stimulus parameters are defined in the display & stimulus file.
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
if ~strcmpi(exp_mode,'bar'), error('exp_mode acceptable in this script is only "bar". check the input variable.'); end

rootDir=fileparts(mfilename('fullpath'));

% check the subject directory
if ~exist(fullfile(rootDir,'subjects',subjID),'dir'), error('can not find subj directory. check the input variable.'); end

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
logfname=fullfile(resultDir,[num2str(subjID),'_ibar_fixtask_results_run_',num2str(acq,'%02d'),'.log']);
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
         'skip_sync_test',0,...
         'onset_punch',[0,50]);

% organize sparam
sparam=struct(); % initialize
sparam.mode=exp_mode;
if ~isempty(stimulusfile), run(fullfile(rootDir,'subjects',subjID,stimulusfile)); end % load specific sparam parameters configured for each of the participants
sparam=ValidateStructureFields(sparam,... % validate fields and set the default values to missing field(s)
         'fieldSize',[12,12],...
         'width',1.5,...
         'rotangles',[0,45,90,135,180,225,270,315],...
         'steps',16,...
         'cycle_duration',40000,...
         'rest_duration',8000,...
         'numRepeats',1,...
         'flip_duration',250,...
         'nimg',120,...
         'imRatio',[0.2,0.5],...
         'imdepth',[-12,12],... % effective only when the stimuli are presented in stereo mode (e.g. dual, cross, parallel etc)
         'waitframes',6,... % Screen('FrameRate',0)*(sparam.cycle_duration/1000) / (360/sparam.rotangle) / ( (size(sparam.colors,1)-1)*2 );
         'initial_fixation_time',[4000,4000],...
         'fixtype',1,...
         'fixsize',4,...
         'fixcolor',[255,255,255],...
         'bgcolor',[128,128,128],... % sparam.colors(1,:);
         'bgtype',1,...
         'patch_size',[30,30],...
         'patch_num',[20,40],...
         'patch_color1',[255,255,255],...
         'patch_color2',[0,0,0],...
         'pix_per_cm',57.1429,...
         'vdist',65,...
         'ipd',6.5);

% change unit from msec to sec.
sparam.initial_fixation_time=sparam.initial_fixation_time./1000; %#ok

% change unit from msec to sec.
sparam.cycle_duration = sparam.cycle_duration./1000;
sparam.flip_duration  = sparam.flip_duration./1000;
sparam.rest_duration  = sparam.rest_duration./1000;

% set the other parameters
dparam.RunScript = mfilename();
sparam.RunScript = mfilename();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Displaying the presentation parameters you set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('The Presentation Parameters are as below.\n\n');
fprintf('************************************************\n');
fprintf('****** Script, Subject, Acquistion Number ******\n');
fprintf('Date & Time            : %s\n',strcat([datestr(now,'yymmdd'),' ',datestr(now,'HH:mm:ss')]));
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
fprintf('Onset Punch [type,size]: [%d,%d]\n',dparam.onset_punch(1),dparam.onset_punch(2));
fprintf('*********** Stimulation Periods etc. ***********\n');
fprintf('Fixation Time(sec)     : %d & %d\n',sparam.initial_fixation_time(1),sparam.initial_fixation_time(2));
fprintf('Cycle Duration(sec)    : %d\n',sparam.cycle_duration);
fprintf('Rest  Duration(sec)    : %d\n',sparam.rest_duration);
fprintf('Repetitions(cycles)    : %d\n',sparam.numRepeats);
fprintf('Frame Flip(per VerSync): %d\n',sparam.waitframes);
fprintf('Total Time (sec)       : %d\n',sum(sparam.initial_fixation_time)+sparam.numRepeats*sparam.cycle_duration*numel(sparam.rotangles));
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

% sec to number of frames
nframe_fixation=round(sparam.initial_fixation_time.*dparam.fps./sparam.waitframes);
nframe_stim=round((sparam.cycle_duration-sparam.rest_duration)*dparam.fps/sparam.waitframes);
nframe_rest=round(sparam.rest_duration*dparam.fps/sparam.waitframes);
nframe_movement=round((sparam.cycle_duration-sparam.rest_duration)*dparam.fps/sparam.steps/sparam.waitframes);
nframe_flicker=round(sparam.flip_duration*dparam.fps/sparam.waitframes);
nframe_task=round(18/sparam.waitframes); % just arbitral, you can change as you like

%% initialize chackerboard parameters

% adjust size ratio considering full-screen effect
if dparam.fullscr
  % here, use width information alone, assuming that the pixel is square
  ratio_wid=( winRect(3)-winRect(1) )/dparam.ScrWidth;
  %ratio_hei=( winRect(4)-winRect(2) )/dparam.ScrHeight;

  % adjusting stimulus sizes
  fieldSize=sparam.fieldSize*ratio_wid; % !!! degree, not pixel or cm !!!
  width=sparam.width*ratio_wid;
else
  fieldSize=sparam.fieldSize;
  width=sparam.width;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Generating checkerboard bar patterns
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

% generate the checker bar stimuli, checkerboard{rotangles,steps}
[dummy1,dummy2,checkerboard]=bar_GenerateCheckerBar1D(fieldSize,width,sparam.rotangles,sparam.steps,sparam.pix_per_deg,1,1,0);

%% organize the checkerboard into masks
for aa=1:1:numel(sparam.rotangles)
  for nn=1:1:sparam.steps
    checkerboard{aa,nn}=repmat(255.*double(~checkerboard{aa,nn}),[1,1,4]);
    checkerboard{aa,nn}(:,:,1:3)=repmat(reshape(sparam.bgcolor,[1,1,3]),[size(checkerboard{aa,nn},1),size(checkerboard{aa,nn},2)]);
  end
end

%% Make Checkerboard-mask textures
checkertexture=cell(numel(sparam.rotangles),sparam.steps);
for aa=1:1:numel(sparam.rotangles)
  for nn=1:1:sparam.steps
    checkertexture{aa,nn}=Screen('MakeTexture',winPtr,checkerboard{aa,nn});
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initializing a background brownian noise image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%pdims=[4,4];
%szh=size(checkerboard{1,1},1);
%if mod(szh,pdims(1)), szh=szh+pdims(1)-mod(szh,pdims(1)); end
%szw=size(checkerboard{1,1},2);
%if mod(szw,pdims(2)), szw=szw+pdims(2)-mod(szw,pdims(1)); end
%bnimg=CreateColoredNoise([szh,szw],pdims,3,2,1,0,0);
%bnimg=bnimg(1:size(checkerboard{1,1},1),1:size(checkerboard{1,1},2),:);

bnimg=CreateColoredNoise(round([size(checkerboard{1,1},1),size(checkerboard{1,1},2)]./4),[1,1],3,2,1,0,0); % ./4 is for reducing computation time, 3 is required for RGB color noise
noisetexture=Screen('MakeTexture',winPtr,bnimg);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initializing object images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% loading the object image database
load(fullfile(fileparts(mfilename('fullpath')),'..','object_images','object_image_database.mat')); % img is loaded on the memory

% shuffling the presentation order
img=img(:,:,:,shuffle(1:size(img,4)));
imgsz=[size(img,1),size(img,2)];
posLims=CenterRect([0,0,size(checkerboard{1,1},2),size(checkerboard{1,1},1)],winRect); % image location limit, [x_min, y_min, x_max, y_max], the image positions are randomly selected whithin this range

% initializing the firt object image textures

% image IDs
imgids=1:1:sparam.nimg;
imgids(imgids>size(img,4))=mod(imgids(imgids>size(img,4)),size(img,4));
imgids(imgids==0)=size(img,4);

% rectangles
cpos=[(posLims(3)-posLims(1)).*rand(sparam.nimg,1)+posLims(1),(posLims(4)-posLims(2)).*rand(sparam.nimg,1)+posLims(2)]; % center positions, [x,y]
cszs=(sparam.imRatio(2)-sparam.imRatio(1)).*rand(sparam.nimg,1)+sparam.imRatio(1); % image maginification factor
imgpos=[round(cpos(:,1)-cszs*imgsz(2)/2)+1,round(cpos(:,2)-cszs*imgsz(1)/2)+1,round(cpos(:,1)+cszs*imgsz(2)/2),round(cpos(:,2)+cszs*imgsz(1)/2)]';

% angles
imgrot=360.*rand(sparam.nimg,1);

% stereo depth
if nScr>1
  % compute image shift from disparity
  depths=(sparam.imdepth(2)-sparam.imdepth(1)).*rand(sparam.nimg,1)+sparam.imdepth(1);
  zdist=CalcDistFromDisparity(sparam.ipd,depths,sparam.vdist);
  zdist=sort(zdist,'descend');
  [Lshift,Rshift]=RayTrace_ScreenPos_X_MEX(zdist,sparam.ipd,sparam.vdist,sparam.pix_per_cm,0);
  stereopos{1}=[Lshift,zeros(sparam.nimg,1),Lshift,zeros(sparam.nimg,1)]';
  stereopos{2}=[Rshift,zeros(sparam.nimg,1),Rshift,zeros(sparam.nimg,1)]';
else
  stereopos{1}=repmat([0,0,0,0],[sparam.nimg,1])';
  stereopos{2}=repmat([0,0,0,0],[sparam.nimg,1])';
end

% generate the object image textures at the first frame
objecttextures=zeros(numel(imgids),1);
for pp=1:1:numel(imgids), objecttextures(pp)=Screen('MakeTexture',winPtr,img(:,:,:,imgids(pp))); end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Debug codes
%%%% saving the stimulus images as *.png format files and enter the debug (keyboard) mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%% DEBUG codes start here
if strfind(upper(subjID),'DEBUG')

  Screen('CloseAll');

  save_dir=fullfile(resultDir,'images_ibar_fixtask');
  if ~exist(save_dir,'dir'), mkdir(save_dir); end

  % open a new window for drawing stimuli
  stimRect=[0,0,size(checkerboard{1,1},2),size(checkerboard{1,1},1)];
  [winPtr,winRect]=Screen('OpenWindow',dparam.scrID,sparam.bgcolor,CenterRect(stimRect,Screen('Rect',dparam.scrID)));

  % set OpenGL
  priorityLevel=MaxPriority(winPtr,'WaitBlanking');
  Priority(priorityLevel);
  AssertOpenGL();
  Screen('BlendFunction', winPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  % regenerate checkerboard textures
  for aa=1:1:numel(sparam.rotangles)
    for nn=1:1:sparam.steps
      checkertexture{aa,nn}=Screen('MakeTexture',winPtr,checkerboard{aa,nn});
    end
  end

  % check the number of flickers
  if mod((sparam.cycle_duration-sparam.rest_duration)/sparam.steps/sparam.flip_duration,1)~=0
    warning('(sparam.cycle_duration-sparam.rest_duration)/sparam.steps/sparam.flip_duration is not an integer. check the sparam parameters.');
  end

  % processing
  obj_counter=0;
  for aa=1:1:numel(sparam.rotangles)
    for nn=1:1:sparam.steps
      for cc=1:1:round((sparam.cycle_duration-sparam.rest_duration)/sparam.steps/sparam.flip_duration)

        % brownian noise image
        bnimg=CreateColoredNoise(round([size(checkerboard{1,1},1),size(checkerboard{1,1},2)]./4),[1,1],3,2,1,0,0);
        noisetexture=Screen('MakeTexture',winPtr,bnimg);

        for pp=1:1:2 % by default, 2 image sets in one background noise flicker
          % generate object image textures

          % image IDs
          obj_counter=obj_counter+1;
          imgids=sparam.nimg*(obj_counter-1)+1:1:sparam.nimg*obj_counter;
          imgids(imgids>size(img,4))=mod(imgids(imgids>size(img,4)),size(img,4));
          imgids(imgids==0)=size(img,4);

          % rectangles
          cpos=[(stimRect(3)-stimRect(1)).*rand(sparam.nimg,1)+stimRect(1),(stimRect(4)-stimRect(2)).*rand(sparam.nimg,1)+stimRect(2)]; % center positions, [x,y]
          cszs=(sparam.imRatio(2)-sparam.imRatio(1)).*rand(sparam.nimg,1)+sparam.imRatio(1); % image maginification factor
          imgpos=[round(cpos(:,1)-cszs*imgsz(2)/2)+1,round(cpos(:,2)-cszs*imgsz(1)/2)+1,round(cpos(:,1)+cszs*imgsz(2)/2),round(cpos(:,2)+cszs*imgsz(1)/2)]';

          % angles
          imgrot=360.*rand(sparam.nimg,1);

          % stereo depth
          if nScr>1
            % compute image shift from disparity
            depths=(sparam.imdepth(2)-sparam.imdepth(1)).*rand(sparam.nimg,1)+sparam.imdepth(1);
            zdist=CalcDistFromDisparity(sparam.ipd,depths,sparam.vdist);
            zdist=sort(zdist,'descend');
            [Lshift,Rshift]=RayTrace_ScreenPos_X_MEX(zdist,sparam.ipd,sparam.vdist,sparam.pix_per_cm,0);
            stereopos{1}=[Lshift,zeros(sparam.nimg,1),Lshift,zeros(sparam.nimg,1)]';
            stereopos{2}=[Rshift,zeros(sparam.nimg,1),Rshift,zeros(sparam.nimg,1)]';
          else
            stereopos{1}=repmat([0,0,0,0],[sparam.nimg,1])';
            stereopos{2}=repmat([0,0,0,0],[sparam.nimg,1])';
          end

          for mm=1:1:numel(imgids), objecttextures(mm)=Screen('MakeTexture',winPtr,img(:,:,:,imgids(mm))); end

          for nnnn=1:1:nScr
            % drawing
            Screen('DrawTexture',winPtr,noisetexture,[],CenterRect(stimRect,winRect)); % noise textures
            Screen('DrawTextures',winPtr,objecttextures,[],imgpos+stereopos{nnnn},imgrot); % object images
            Screen('DrawTexture',winPtr,checkertexture{aa,nn},[],CenterRect(stimRect,winRect)); % checkerboard mask

            % flip the window
            Screen('DrawingFinished',winPtr);
            Screen('Flip',winPtr,[],[],[],1);

            % get the current frame and save it
            imwrite(Screen('GetImage',winPtr,winRect),fullfile(save_dir,sprintf('retinotopy_%s_angle_%02d_pos_%02d_type_%02d_%02d_stereo_%02d.png',sparam.mode,aa,nn,cc,pp,nnnn)),'png');
          end

          % close the textures and OffScreenWindow
          for mm=1:1:numel(imgids), Screen('Close',objecttextures(mm)); end
        end % for pp=1:1:2
        Screen('Close',noisetexture);

      end % for cc=1:1:round((sparam.cycle_duration-sparam.rest_duration)/(360/sparam.rotangle)/sparam.flip_duration)
    end % for nn=1:1:sparam.steps
  end % for aa=1:1:numel(sparam.rotangles)

  Screen('CloseAll');
  save(fullfile(save_dir,sprintf('stimulus_%s.mat',sparam.mode)),'checkerboard','sparam','dparam');
  keyboard;

end % if strfind(upper(subjID),'DEBUG')
% %%%%%% DEBUG code ends here


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Generating fixation detection task parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% set task variables
% flag to decide whether presenting fixation task
totalframes=max(sum(nframe_fixation),1)+numel(sparam.rotangles)*(nframe_stim+nframe_rest)*sparam.numRepeats;
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

% variable to store the current rotation/disparity id
stim_pos_id=1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Creating background images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if sparam.bgtype==1 % a simple background with sparam.bgcolor
  bgimg{1}=repmat(reshape(sparam.bgcolor,[1,1,3]),[dparam.ScrHeight,dparam.ScrWidth]);

elseif sparam.bgtype==2 % a background with grid guides

  % calculate the central aperture size of the background image
  edgeY=mod(dparam.ScrHeight,sparam.patch_num(1)); % delete the exceeded region
  p_height=round((dparam.ScrHeight-edgeY)/sparam.patch_num(1)); % height in pix of patch_height + interval-Y

  edgeX=mod(dparam.ScrWidth,sparam.patch_num(2)); % delete exceeded region
  p_width=round((dparam.ScrWidth-edgeX)/sparam.patch_num(2)); % width in pix of patch_width + interval-X

  if dparam.fullscr
    aperture_size=[2*( p_height*ceil( size(checkerboard{1,1},1)/2*( (winRect(4)-winRect(2))/dparam.ScrHeight ) /p_height ) ),...
                   2*( p_width*ceil( size(checkerboard{1,1},2)/2*( (winRect(3)-winRect(1))/dparam.ScrWidth ) /p_width ) )];
  else
    aperture_size=[2*( p_height*ceil(size(checkerboard{1,1},1)/2/p_height) ),...
                   2*( p_width*ceil(size(checkerboard{1,1},2)/2/p_width) )];
  end

  bgimg=CreateBackgroundImage([dparam.ScrHeight,dparam.ScrWidth],aperture_size,sparam.patch_size,sparam.bgcolor,sparam.patch_color1,sparam.patch_color2,sparam.fixcolor,sparam.patch_num,0,0,0);
else
  error('sparam.bgtype should be 1 or 2. check the input variable.');
end

% set mask and transparency in the middle region of the background where the target stimuli are to be presented.
% this mask is required to prevent the object images from being presented in the external regions.
bgimg=bgimg{1};
bgimg(:,:,4)=255*ones(size(bgimg,1),size(bgimg,2));
maskRect=CenterRect([1,1,size(checkerboard{1,1},2),size(checkerboard{1,1},1)],[1,1,size(bgimg,2),size(bgimg,1)]);
bgimg(maskRect(2)+1:maskRect(4),maskRect(1)+1:maskRect(3),4)=0; % alpha channel, transparency

background=Screen('MakeTexture',winPtr,bgimg);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Creating the central fixation, cross images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create fixation cross images.
% Firstly larger fixations are generated, then they are antialiased. This is required to present a beautiful circle

if isMATLABToolBoxAvailable('Image Processing Toolbox')
  resize_r=4;
else
  resize_r=1;
end

if sparam.fixtype==1 % circular fixation
  fixW=CreateFixationImgCircular(resize_r*sparam.fixsize,sparam.fixcolor,sparam.bgcolor,resize_r*sparam.fixsize,0,0);
  fixD=CreateFixationImgCircular(resize_r*sparam.fixsize,[64,64,64],sparam.bgcolor,resize_r*sparam.fixsize,0,0);
elseif sparam.fixtype==2 % rectangular fixation
  fixW=CreateFixationImgMono(resize_r*sparam.fixsize,sparam.fixcolor,sparam.bgcolor,resize_r*2,resize_r*ceil(0.4*sparam.fixsize),0,0);
  fixD=CreateFixationImgMono(resize_r*sparam.fixsize,[64,64,64],sparam.bgcolor,resize_r*2,resize_r*ceil(0.4*sparam.fixsize),0,0);
elseif sparam.fixtype==3 % concentric fixation
  fixW=CreateFixationImgConcentrateMono(resize_r*sparam.fixsize,sparam.fixcolor,sparam.bgcolor,resize_r*[2,ceil(0.8*sparam.fixsize)],0,0,0);
  fixD=CreateFixationImgConcentrateMono(resize_r*sparam.fixsize,[64,64,64],sparam.bgcolor,resize_r*[2,ceil(0.8*sparam.fixsize)],0,0,0);
else
  error('sparam.fixtype should be one of 1,2, and 3. check the input variable.');
end

if resize_r~=1
  fixW=imresize(fixW,1/resize_r);
  fixD=imresize(fixD,1/resize_r);
end

fix=cell(2,1); % 1 is for default fixation, 2 is for darker fixation (luminance detection task)
fix{1}=Screen('MakeTexture',winPtr,fixW);
fix{2}=Screen('MakeTexture',winPtr,fixD);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Prepare blue lines for stereo image flip sync with VPixx PROPixx
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% There seems to be a blueline generation bug on some OpenGL systems.
% SetStereoBlueLineSyncParameters(winPtr, winRect(4)) corrects the
% bug on some systems, but breaks on other systems.
% We'll just disable automatic blueline, and manually draw our own bluelines!

if strcmpi(dparam.ExpMode,'propixxstereo')
  SetStereoBlueLineSyncParameters(winPtr, winRect(4)+10);
  blueRectOn(1,:)=[0, winRect(4)-1, winRect(3)/4, winRect(4)];
  blueRectOn(2,:)=[0, winRect(4)-1, winRect(3)*3/4, winRect(4)];
  blueRectOff(1,:)=[winRect(3)/4, winRect(4)-1, winRect(3), winRect(4)];
  blueRectOff(2,:)=[winRect(3)*3/4, winRect(4)-1, winRect(3), winRect(4)];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Image size adjusting to match the current display resolutions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if dparam.fullscr
  ratio_wid= ( winRect(3)-winRect(1) )/dparam.ScrWidth;
  ratio_hei= ( winRect(4)-winRect(2) )/dparam.ScrHeight;
  bgSize   = [size(bgimg{1},2)*ratio_wid, size(bgimg{1},1)*ratio_hei];
  stimSize = [size(checkerboard{1,1},2)*ratio_wid, size(checkerboard{1,1},1)*ratio_hei];
  fixSize  = [2*sparam.fixsize*ratio_wid, 2*sparam.fixsize*ratio_hei];
else
  bgSize   = [dparam.ScrWidth, dparam.ScrHeight];
  stimSize = [size(checkerboard{1,1},2), size(checkerboard{1,1},1)];
  fixSize  = [2*sparam.fixsize, 2*sparam.fixsize];
end

% for some display modes in which one screen is splitted into two binocular displays
if strcmpi(dparam.ExpMode,'cross') || strcmpi(dparam.ExpMode,'parallel') || ...
   strcmpi(dparam.ExpMode,'topbottom') || strcmpi(dparam.ExpMode,'bottomtop')
  bgSize=bgSize./2;
  stimSize=stimSize./2;
  fixSize=fixSize./2;

  % adjust image size (note: in contrast, we have to keep the stereo shifts as they are)
  imgsz=imgsz./2;

  % update lim positions just for the first frame
  posLims=CenterRect([0,0,size(checkerboard{1},2)./2,size(checkerboard{1},1)./2],winRect); % image location limit, [x_min, y_min, x_max, y_max], the image positions are randomly selected whithin this range

  % update image locations just for the first frame
  cpos=[(posLims(3)-posLims(1)).*rand(sparam.nimg,1)+posLims(1),(posLims(4)-posLims(2)).*rand(sparam.nimg,1)+posLims(2)]; % center positions, [x,y]
  cszs=(sparam.imRatio(2)-sparam.imRatio(1)).*rand(sparam.nimg,1)+sparam.imRatio(1); % image maginification factor
  imgpos=[round(cpos(:,1)-cszs*imgsz(2)/2)+1,round(cpos(:,2)-cszs*imgsz(1)/2)+1,round(cpos(:,1)+cszs*imgsz(2)/2),round(cpos(:,2)+cszs*imgsz(1)/2)]';
end

bgRect  = [0, 0, bgSize]; % used to display background images;
stimRect= [0, 0, stimSize];
fixRect = [0, 0, fixSize]; % used to display the central fixation point


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Prepare a rectangle for onset punch stimulus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if dparam.onset_punch(1)
  psize=dparam.onset_punch(2); offset=bgSize./2;
  if dparam.onset_punch(1)==1 % upper-left
    punchoffset=[psize/2,psize/2,psize/2,psize/2]-[offset,offset];
  elseif dparam.onset_punch(1)==2 % upper-right
    punchoffset=[-psize/2,psize/2,-psize/2,psize/2]+[offset(1),-offset(2),offset(1),-offset(2)];
  elseif dparam.onset_punch(1)==3 %lower-left
    punchoffset=[psize/2,-psize/2,psize/2,-psize/2]+[-offset(1),offset(2),-offset(1),offset(2)];
  elseif dparam.onset_punch(1)==4 % lower-right
    punchoffset=-[psize/2,psize/2,psize/2,psize/2]+[offset,offset];
  end
  clear offset;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Generating additional mask which covers the outside region of the background.
%%%% The mask is required to hide parts of the objects presented outside the background
%%%% when the script is not running with full-screen mode.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wrect=Screen('Rect',winPtr);
if wrect(3)-wrect(1)>bgRect(3)-bgRect(1) | wrect(4)-wrect(2)>bgRect(4)-bgRect(2) % if background is smaller than the whole screen
  hide_flg=1;
  amskimg=repmat(reshape(sparam.colors(1,:),[1,1,3]),[wrect(4)-wrect(2),wrect(3)-wrect(1)]);
  amskimg(:,:,4)=255*ones(size(amskimg,1),size(amskimg,2));
  amskRect=CenterRect(bgRect,wrect);
  amskimg(amskRect(2)+1:amskRect(4),amskRect(1)+1:amskRect(3),4)=0; % alpha channel, transparency

  abackground=Screen('MakeTexture',winPtr,amskimg);
else
  hide_flg=0;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initialize functions and variables for trial loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize variables that we will use during the experiment (faster)
cur_frames=0;

% object image counter
obj_counter=0;


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
  Screen('DrawTexture',winPtr,fix{2},[],CenterRect(fixRect,winRect));
  Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
  if dparam.onset_punch(1), Screen('FillRect',winPtr,[0,0,0],CenterRect([0,0,psize,psize],winRect)+punchoffset); end

  % blue line for stereo sync
  if strcmpi(dparam.ExpMode,'propixxstereo')
    Screen('FillRect',winPtr,[0,0,255],blueRectOn(nn,:));
    Screen('FillRect',winPtr,[0,0,0],blueRectOff(nn,:));
  end
end
Screen('DrawingFinished',winPtr);
Screen('Flip', winPtr,[],[],[],1);

% prepare the next frame for the initial fixation period
for nn=1:1:nScr
  Screen('SelectStereoDrawBuffer',winPtr,nn-1);
  Screen('DrawTexture',winPtr,fix{1},[],CenterRect(fixRect,winRect)); % fix{1} is valid as no task in the first period
  Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
  if dparam.onset_punch(1), Screen('FillRect',winPtr,[0,0,0],CenterRect([0,0,psize,psize],winRect)+punchoffset); end

  % blue line for stereo sync
  if strcmpi(dparam.ExpMode,'propixxstereo')
    Screen('FillRect',winPtr,[0,0,255],blueRectOn(nn,:));
    Screen('FillRect',winPtr,[0,0,0],blueRectOff(nn,:));
  end
end
Screen('DrawingFinished',winPtr);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Wait for the first trigger pulse from fMRI scanner or start with button pressing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% add time stamp (this also works to load add_event method in memory in advance of the actual displays)
fprintf('\nWaiting for the start...\n');
event=event.add_event('Experiment Start',strcat([datestr(now,'yymmdd'),' ',datestr(now,'HH:mm:ss')]),NaN);

% waiting for stimulus presentation
resps.wait_stimulus_presentation(dparam.start_method,dparam.custom_trigger);
%PlaySound(1);
fprintf('\nExperiment running...\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initial Fixation Period
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vbl=Screen('Flip',winPtr,[],[],[],1); % the first flip
[event,the_experiment_start]=event.set_reference_time(vbl);
event=event.add_event('Initial Fixation',[]);
fprintf('\nfixation\n\n');
cur_frames=cur_frames+1;

% wait for the initial fixation
for ff=1:1:nframe_fixation(1)
  for nn=1:1:nScr
    Screen('SelectStereoDrawBuffer',winPtr,nn-1);
    Screen('DrawTexture',winPtr,fix{task_flg(cur_frames)},[],CenterRect(fixRect,winRect));
    Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
    if dparam.onset_punch(1), Screen('FillRect',winPtr,[0,0,0],CenterRect([0,0,psize,psize],winRect)+punchoffset); end

    % blue line for stereo sync
    if strcmpi(dparam.ExpMode,'propixxstereo')
      Screen('FillRect',winPtr,[0,0,255],blueRectOn(nn,:));
      Screen('FillRect',winPtr,[0,0,0],blueRectOff(nn,:));
    end
  end
  Screen('DrawingFinished',winPtr);
  while GetSecs()<vbl+(ff*sparam.waitframes-0.5)*dparam.ifi, [resps,event]=resps.check_responses(event); end
  Screen('Flip',winPtr,[],[],[],1);

  % update task
  cur_frames=cur_frames+1;
  if task_flg(cur_frames-1)==2 && task_flg(cur_frames-2)==1, event=event.add_event('Luminance Task',[]); end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% The Trial Loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for cc=1:1:sparam.numRepeats

  % loop for angle directions
  for aa=1:1:numel(sparam.rotangles)

    %% stimulus presentation loop
    for ff=1:1:nframe_stim+nframe_rest

      %% display the current frame
      for nn=1:1:nScr
        Screen('SelectStereoDrawBuffer',winPtr,nn-1);
        if ff<=nframe_stim
          Screen('DrawTexture',winPtr,noisetexture,[],CenterRect(stimRect,winRect)); % noise textures
          Screen('DrawTextures',winPtr,objecttextures,[],imgpos+stereopos{nn},imgrot); % object images
          Screen('DrawTexture',winPtr,checkertexture{aa,stim_pos_id},[],CenterRect(stimRect,winRect)); % checkerboard mask
          if hide_flg, Screen('DrawTexture',winPtr,abackground,[],winRect); end % additional background to hide the external region
        end
        Screen('DrawTexture',winPtr,fix{task_flg(cur_frames)},[],CenterRect(fixRect,winRect)); % the central fixation oval
        Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect)); % background
        if dparam.onset_punch(1)
          if ff<=nframe_stim/2
            Screen('FillRect',winPtr,[255,255,255],CenterRect([0,0,psize,psize],winRect)+punchoffset);
          else
            Screen('FillRect',winPtr,[0,0,0],CenterRect([0,0,psize,psize],winRect)+punchoffset);
          end
        end

        % blue line for stereo sync
        if strcmpi(dparam.ExpMode,'propixxstereo')
          Screen('FillRect',winPtr,[0,0,255],blueRectOn(nn,:));
          Screen('FillRect',winPtr,[0,0,0],blueRectOff(nn,:));
        end
      end

      % flip the window
      Screen('DrawingFinished',winPtr);
      while GetSecs()<vbl+sparam.initial_fixation_time(1)+(cc-1)*numel(sparam.rotangles)*sparam.cycle_duration+...
                      (aa-1)*sparam.cycle_duration+((ff-1)*sparam.waitframes-0.5)*dparam.ifi, [resps,event]=resps.check_responses(event); end
      Screen('Flip',winPtr,[],[],[],1);

      if ff==1
        event=event.add_event(sprintf('Cycle: %d, Direction: %.2f deg',(cc-1)*numel(sparam.rotangles)+aa,sparam.rotangles(aa)),[]);
        fprintf('Cycle: %03d, Direction: %.2f deg...\n',(cc-1)*numel(sparam.rotangles)+aa,sparam.rotangles(aa));
      end

      % update task
      cur_frames=cur_frames+1;
      if task_flg(cur_frames)==2 && task_flg(cur_frames-1)==1, event=event.add_event('Luminance Task',[]); end

      %% exit from the loop if the final frame is displayed
      if ff==nframe_stim+nframe_rest && aa==numel(sparam.rotangles), continue; end

      %% update IDs

      if ff<=nframe_stim

        % flickering the target image
        if ~mod(ff,nframe_flicker) % noise pattern reversal
          % update the brownian noise texture.
          Screen('Close',noisetexture);
          %bnimg=CreateColoredNoise([szh,szw],pdims,3,2,1,0,0);
          %bnimg=bnimg(1:size(checkerboard{1,1},1),1:size(checkerboard{1,1},2),:);
          bnimg=CreateColoredNoise(round([size(checkerboard{aa,nn},1),size(checkerboard{aa,nn},2)]./4),[1,1],3,2,1,0,0);
          noisetexture=Screen('MakeTexture',winPtr,bnimg);
        end

        if ~mod(ff,ceil(nframe_flicker/2)) % object image reversal
          %% update object images
          for pp=1:1:numel(imgids), Screen('Close',objecttextures(pp)); end

          obj_counter=obj_counter+1;

          % image IDs
          imgids=sparam.nimg*obj_counter+1:1:sparam.nimg*(obj_counter+1); % the first image set is already presented
          imgids(imgids>size(img,4))=mod(imgids(imgids>size(img,4)),size(img,4));
          imgids(imgids==0)=size(img,4);

          % rectangles
          cpos=[(posLims(3)-posLims(1)).*rand(sparam.nimg,1)+posLims(1),(posLims(4)-posLims(2)).*rand(sparam.nimg,1)+posLims(2)]; % center positions, [x,y]
          cszs=(sparam.imRatio(2)-sparam.imRatio(1)).*rand(sparam.nimg,1)+sparam.imRatio(1); % image maginification factor
          imgpos=[round(cpos(:,1)-cszs*imgsz(2)/2)+1,round(cpos(:,2)-cszs*imgsz(1)/2)+1,round(cpos(:,1)+cszs*imgsz(2)/2),round(cpos(:,2)+cszs*imgsz(1)/2)]';

          % angles
          imgrot=360.*rand(sparam.nimg,1);

          % stereo depth
          if nScr>1
            % compute image shift from disparity
            depths=(sparam.imdepth(2)-sparam.imdepth(1)).*rand(sparam.nimg,1)+sparam.imdepth(1);
            zdist=CalcDistFromDisparity(sparam.ipd,depths,sparam.vdist);
            zdist=sort(zdist,'descend');
            [Lshift,Rshift]=RayTrace_ScreenPos_X_MEX(zdist,sparam.ipd,sparam.vdist,sparam.pix_per_cm,0);
            stereopos{1}=[Lshift,zeros(sparam.nimg,1),Lshift,zeros(sparam.nimg,1)]';
            stereopos{2}=[Rshift,zeros(sparam.nimg,1),Rshift,zeros(sparam.nimg,1)]';
          else
            stereopos{1}=repmat([0,0,0,0],[sparam.nimg,1])';
            stereopos{2}=repmat([0,0,0,0],[sparam.nimg,1])';
          end

          % generate object image textures
          for pp=1:1:numel(imgids), objecttextures(pp)=Screen('MakeTexture',winPtr,img(:,:,:,imgids(pp))); end
        end

        % stimulus position id for the next presentation
        if ~mod(ff,nframe_movement)
          stim_pos_id=stim_pos_id+1;
          if stim_pos_id>sparam.steps, stim_pos_id=1; end
        end
      else % required to compensate insubdivisible frames
        stim_pos_id=1;
      end
    end % for ff=1:1:nframe_stim+nframe_rest
  end % for aa=1:1:numel(sparam.rotangles)
end % for cc=1:1:sparam.numRepeats


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Final Fixation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for nn=1:1:nScr
  Screen('SelectStereoDrawBuffer',winPtr,nn-1);
  Screen('DrawTexture',winPtr,fix{task_flg(cur_frames)},[],CenterRect(fixRect,winRect));
  Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
  if dparam.onset_punch(1), Screen('FillRect',winPtr,[0,0,0],CenterRect([0,0,psize,psize],winRect)+punchoffset); end

  % blue line for stereo sync
  if strcmpi(dparam.ExpMode,'propixxstereo')
    Screen('FillRect',winPtr,[0,0,255],blueRectOn(nn,:));
    Screen('FillRect',winPtr,[0,0,0],blueRectOff(nn,:));
  end
end
Screen('DrawingFinished',winPtr);
while GetSecs()<vbl+sparam.initial_fixation_time(1)+sparam.numRepeats*numel(sparam.rotangles)*sparam.cycle_duration-0.5*dparam.ifi, [resps,event]=resps.check_responses(event); end
Screen('Flip',winPtr,[],[],[],1);
%cur_frames=cur_frames+1;
event=event.add_event('Final Fixation',[]);
fprintf('\nfixation\n');

% wait for the initial fixation
for ff=1:1:nframe_fixation(2)
  for nn=1:1:nScr
    Screen('SelectStereoDrawBuffer',winPtr,nn-1);
    Screen('DrawTexture',winPtr,fix{task_flg(cur_frames)},[],CenterRect(fixRect,winRect));
    Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
    if dparam.onset_punch(1), Screen('FillRect',winPtr,[0,0,0],CenterRect([0,0,psize,psize],winRect)+punchoffset); end

    % blue line for stereo sync
    if strcmpi(dparam.ExpMode,'propixxstereo')
      Screen('FillRect',winPtr,[0,0,255],blueRectOn(nn,:));
      Screen('FillRect',winPtr,[0,0,0],blueRectOff(nn,:));
    end
  end
  Screen('DrawingFinished',winPtr);
  while GetSecs()<vbl+sparam.initial_fixation_time(1)+sparam.numRepeats*numel(sparam.rotangles)*sparam.cycle_duration+(ff*sparam.waitframes-0.5)*dparam.ifi, [resps,event]=resps.check_responses(event); end
  Screen('Flip',winPtr,[],[],[],1);

  % update task
  cur_frames=cur_frames+1;
  if task_flg(cur_frames-1)==2 && task_flg(cur_frames-2)==1, event=event.add_event('Luminance Task',[]); end
end

% the final clock up
while GetSecs()-the_experiment_start<sum(sparam.initial_fixation_time)+sparam.numRepeats*numel(sparam.rotangles)*sparam.cycle_duration
  [resps,event]=resps.check_responses(event);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Experiment & scanner end here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

experimentDuration=GetSecs()-the_experiment_start;
event=event.add_event('End',[]);
fprintf('\n');
fprintf('Experiment Completed: %.2f/%.2f secs\n',experimentDuration,...
        sum(sparam.initial_fixation_time)+sparam.numRepeats*numel(sparam.rotangles)*sparam.cycle_duration);
fprintf('\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Cleaning up the PTB screen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Screen('CloseAll');

% closing datapixx
if strcmpi(dparam.ExpMode,'propixxmono') || strcmpi(dparam.ExpMode,'propixxstereo')
  if Datapixx('IsViewpixx3D')
    Datapixx('DisableVideoLcd3D60Hz');
    Datapixx('RegWr');
  end
  Datapixx('Close');
end

ShowCursor();
Priority(0);
GammaResetPTB(1.0);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Write data into file for post analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% saving the results
fprintf('saving data...');

% save data
savefname=fullfile(resultDir,[num2str(subjID),'_ibar_fixtask_results_run_',num2str(acq,'%02d'),'.mat']);

% backup the old file(s)
if ~overwrite_flg
  BackUpObsoleteFiles(fullfile('subjects',num2str(subjID),'results',today),...
                      [num2str(subjID),'_ibar_fixtask_results_run_',num2str(acq,'%02d'),'.mat'],'_old');
end

eval(sprintf('save %s subjID acq sparam dparam event gamma_table;',savefname));
fprintf('done.\n');

% calculate & display task performance
fprintf('calculating task accuracy...\n');
correct_event=cell(2,1); for ii=1:1:2, correct_event{ii}=sprintf('key%d',ii); end
[task.numTasks,task.numHits,task.numErrors,task.numResponses,task.RT]=event.calc_accuracy(correct_event);
event=event.get_event(); % convert an event logger object to a cell data structure
eval(sprintf('save -append %s event task;',savefname));
fprintf('done.\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Removing path to the subfunctions, and finalizing the script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rmpath(genpath(fullfile(rootDir,'..','Common')));
rmpath(fullfile(rootDir,'..','Generation'));
clear all; clear mex; clear global;
diary off;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% tell the experimenter that the measurements are completed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
  for ii=1:1:3, Snd('Play',sin(2*pi*0.2*(0:900)),8000); end
catch
  % do nothing
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Catch the errors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

catch lasterror
  % this "catch" section executes in case of an error in the "try" section
  % above.  Importantly, it closes the onscreen window if its open.
  Screen('CloseAll');

  if exist('dparam','var')
    if isstructmember(dparam,'ExpMode')
      if strcmpi(dparam.ExpMode,'propixxmono') || strcmpi(dparam.ExpMode,'propixxstereo')
        if Datapixx('IsViewpixx3D')
          Datapixx('DisableVideoLcd3D60Hz');
          Datapixx('RegWr');
        end
        Datapixx('Close');
      end
    end
  end

  ShowCursor();
  Priority(0);
  GammaResetPTB(1.0);
  tmp=lasterror; %#ok
  %if exist('event','var'), event=event.get_event(); end %#ok % just for debugging
  diary off;
  fprintf(['\nError detected and the program was terminated.\n',...
           'To check error(s), please type ''tmp''.\n',...
           'Please save the current variables now if you need.\n',...
           'Then, quit by ''dbquit''\n']);
  keyboard;
  rmpath(genpath(fullfile(rootDir,'..','Common')));
  rmpath(fullfile(rootDir,'..','Generation'));
  clear all; clear mex; clear global;
  return
end % try..catch


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% That's it - we're done
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return;
% end % function ibar_fixtask
