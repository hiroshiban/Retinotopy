function dlocalizer(subjID,exp_mode,acq,displayfile,stimulusfile,gamma_table,overwrite_flg,force_proceed_flag)

% Random-Dot-Stereogram(RDS)-defined checkerboard stimulus with checker-patch depth change detection tasks, for localizing specific retinotopic (iso-eccentricity) regions.
% function dlocalizer(subjID,exp_mode,acq,:displayfile,:stimulusfile,:gamma_table,:overwrite_flg,:force_proceed_flag)
% (: is optional)
%
% - This function generates and presents Random-Dot-Stereogram(RDS)-defined checkerboard
%   stimulus for measuring/estimating cortical representations of a specific
%   subregion of the visual field. Specifically, the target checkerboard which
%   covers specific visual subfield and its compensating patterns are alternatively
%   presented. You can also use this script to measure a cannonical hemodynamic
%   response function shape subject-by-subject or to evaluate BOLD signal and
%   fMR-image quality.
%
% - This script shoud be used with MATLAB Psychtoolbox version 3 or above.
%
% - Depth-change detection task: one of the checks of the checkerboard pattern
%   randomly appears to be more depthy compared to the other checkers.
%   An observer has to press the button if s/he detects this luminance change.
%   Response keys are defined in displayfile.
%
% [note]
% Behavioral task of (function_name)_fixtask is to detect changes of luminance
% of the central fixation point, while the task in (function_name_alone) is to
% detect changes of depth of one of the patches in the checkerboard stimuli.
% Here, the central fixation task is more easy to sustain the stable fixation
% on the center of the screen and may be suitable for naive/non-expert
% participants with minimizing unwilling eye movements. However, some studies
% have reported that attention to the target stimulus (lead by checker-patch depth
% change detection task) is required to get reliable retinotopic representations
% in higher-order visual areas.
%
%
% Created    : "2019-05-23 10:50:26 ban"
% Last Update: "2023-11-06 16:53:24 ban"
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
% exp_mode      : experiment mode acceptable in this script is only "localizer"
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
%    as ./subjects/(subjID)/results/(date)/(subjID)_dlocalizer_results_run_(run_num).mat
%
%
% [example]
% >> dlocalizer('HB','localizer',1,'ret_display.m','ret_checker_stimulus_exp1.m')
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
% % This is the stimulus parameter file for the clocalizer retinotopy stimulus
% % Programmed by Hiroshi Ban Dec 19 2018
% % ************************************************************
%
% %%% stimulus parameters
% sparam.nwedges     = 30;     % number of wedge subdivisions along polar angle
% sparam.nrings      = 8;     % number of ring subdivisions along eccentricity angle
% sparam.width       = 360;    % wedge width in deg along polar angle
% sparam.phase       = 0;    % phase shift in deg
% sparam.startangle  = 0;     % presentation start angle in deg, from right-horizontal meridian, ccw
%
% sparam.maxRad      = 6.5;    % maximum radius of  annulus (degrees)
% sparam.minRad      = 0;      % minimum
% sparam.tgtRad      = [3.5,5,5];  % target eccentricity, [min,max]
%
% %%% RDS parameters
% sparam.RDSdepth = [ -12, 12, 5]; % binocular disparity in arcmins, [min, max, #steps(from min to max)]
% sparam.RDSDense=0.5; % dot density in the RDS images to be generated (percentage)
% sparam.RDSradius=0.05; % dot radius in deg
% sparam.RDScolors=[255,0,128]; % dot colors in the RDS, [color1, color2, background (grayscale)]
% sparam.RDSbackground=0; % 1 = with background, 0 = no background
% sparam.RDStaskmagnitude=2; % ratio (x2, x3, etc against the sparam.RDSdepth([1,2])) of the depth maginitude in the change-detection task
%
% %%% duration in msec for each cycle & repetitions
% % Here, the stimulus presentation protocol is defined as below.
% % initial_fixation_time(1) ---> block_duration-rest_duration (the target pattern) ---> rest_duration (blank) --->
% %   block_duration-rest_duration (the compensating pattern of the target) ---> rest_duration (blank) ---> block_duration-rest_duration (the target pattern) --->
% %     rest_duration (blank) ---> block_duration-rest_duration (the compensating pattern) ---> ... (repeated numRepeats in total) ---> initial_fixation_time(2)
% % Therefore, one_stimulation_cycle = block_duration x 2 (note: in this period, stimulation = block_duration-rest_duration)
%
% sparam.block_duration=16000; % msec, a presentation duration of the target or its compensating pattern
% sparam.rest_duration =16000; % msec, rest after each block
% sparam.numRepeats=6;
%
% %%% set number of frames to flip the screen
% % Here, I set the number as large as I can to minimize vertical cynching error.
% % the final 2 is for 2 times repetitions of the flicker
% % Set 1 if you want to flip the display at each vertical sync, but not recommended as it uses much CPU power
% %sparam.waitframes = Screen('FrameRate',0)*(2*sparam.block_duration/1000) / (2*(sparam.block_duration-sparam.rest_duration)/1000) / ( (size(sparam.colors,1)-1)*2 );
% sparam.waitframes = 60*(2*sparam.block_duration/1000) / (2*(sparam.block_duration-sparam.rest_duration)/1000) / ( (size(sparam.colors,1)-1)*2 );
%
% %%% fixation period in msec before/after presenting the target stimuli, integer
% % must set a value more than 1 TR for initializing the frame counting.
% sparam.initial_fixation_time=[4000,4000];
%
% %%% fixation size & color
% sparam.fixtype=1; % 1: circular, 2: rectangular, 3: concentric fixation point
% sparam.fixsize=12; % radius in pixels
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

% check the aqcuisition number. up to 10 design files can be used
if acq<1, error('Acquistion number must be integer and greater than zero'); end

% check the experiment mode (stimulus type)
if ~strcmpi(exp_mode,'localizer'), error('exp_mode acceptable in this script is only "localizer". check the input variable.'); end

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
%%%% Add paths to the subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% add paths to the subfunctions
addpath(genpath(fullfile(rootDir,'..','Common')));
addpath(fullfile(rootDir,'..','Generation'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% For a log file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get date
today=datestr(now,'yymmdd');

% result directry & file
resultDir=fullfile(rootDir,'subjects',num2str(subjID),'results',today);
if ~exist(resultDir,'dir'), mkdir(resultDir); end

% record the output window
logfname=fullfile(resultDir,[num2str(subjID),'_dlocalizer_results_run_',num2str(acq,'%02d'),'.log']);
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
         'nwedges',24,...
         'nrings',8,...
         'width',360,...
         'phase',0,...
         'startangle',0,...
         'maxRad',8,...
         'minRad',0,...
         'tgtRad',[3.5,5.5],...
         'RDSdepth',[-12,12,5],...
         'RDSDense',0.5,...
         'RDSradius',0.05,...
         'RDScolors',[255,0,128],...
         'RDSbackground',0,...
         'RDStaskmagnitude',2,...
         'block_duration',16000,...
         'rest_duration',16000,...
         'numRepeats',6,...
         'waitframes',4,... % Screen('FrameRate',0)*(2*sparam.block_duration/1000) / (2*(sparam.block_duration-sparam.rest_duration)/1000) / ( (size(sparam.colors,1)-1)*2 )
         'initial_fixation_time',[4000,4000],...
         'fixtype',1,...
         'fixsize',12,...
         'fixcolor',[255,255,255],...
         'bgcolor',[128,128,128],... % sparam.colors(1,:);
         'bgtype',1,...
         'patch_size',[30,30],...
         'patch_num',[20,40],...
         'patch_color1',[255,255,255],...
         'patch_color2',[0,0,0],...
         'pix_per_cm',57.1429,...
         'vdist',65);

% change unit from msec to sec.
sparam.initial_fixation_time = sparam.initial_fixation_time./1000; %#ok

% change unit from msec to sec.
sparam.block_duration = sparam.block_duration./1000;
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
fprintf('Cycle Duration(sec)    : %d\n',2*sparam.block_duration);
fprintf('Block Duration(sec)    : %d x 2 (target/compensating)\n',sparam.block_duration-sparam.rest_duration);
fprintf('Rest  Duration(sec)    : %d\n',sparam.rest_duration);
fprintf('Repetitions(cycles)    : %d\n',sparam.numRepeats);
fprintf('Frame Flip(per VerSync): %d\n',sparam.waitframes);
fprintf('Total Time (sec)       : %d\n',sum(sparam.initial_fixation_time)+sparam.numRepeats*2*sparam.block_duration);
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
% sparam.width, sparam.phase, and sparam.startangle are used in deg formats

% sec to number of frames
nframe_fixation=round(sparam.initial_fixation_time.*dparam.fps./sparam.waitframes);
nframe_stim=round((sparam.block_duration-sparam.rest_duration)*dparam.fps/sparam.waitframes);
nframe_rest=round(sparam.rest_duration*dparam.fps/sparam.waitframes);

% !!!NOTICE!!!
% Two lines below are from cretinotopy.m
% nframe_rotation=round((sparam.cycle_duration-sparam.rest_duration)*dparam.fps/(360/sparam.rotangle)/sparam.waitframes);
% nframe_flicker=round(nframe_rotation/sparam.RDSdepth(3)/4);
% nframe_flicker should be adjusted to match with these parameters.
nframe_flicker=round(round((60-0)*dparam.fps/(360/12)/sparam.waitframes)/sparam.RDSdepth(3)/4); %60,0,30 are from CCW/CW parameters.
nframe_task=round(nframe_flicker*sparam.RDSdepth(3)*4/2);

%% initialize chackerboard parameters

% adjust size ratio considering full-screen effect
if dparam.fullscr
  % here, use width information alone, assuming that the pixel is square
  ratio_wid=( winRect(3)-winRect(1) )/dparam.ScrWidth;
  %ratio_hei=( winRect(4)-winRect(2) )/dparam.ScrHeight;

  % min/max radius of annulus
  rmin=sparam.minRad*ratio_wid; % !!! degree, not pixel or cm !!!
  rmax=sparam.maxRad*ratio_wid;
  rtgt=sparam.tgtRad.*ratio_wid;
else
  rmin=sparam.minRad;
  rmax=sparam.maxRad;
  rtgt=sparam.tgtRad;
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
[tmp_checkerboardID,tmp_checkerboard]=pol_GenerateCheckerBoard1D(rmin,rmax,sparam.width,sparam.startangle,sparam.pix_per_deg,...
                                        sparam.nwedges,sparam.nrings,sparam.phase);

% generating two compensating masks
tmpmask=CreateWedgeMask(rmin,rmax,rtgt(1),rtgt(2),sparam.width,sparam.startangle,sparam.pix_per_deg);
tmpmask{1}(tmpmask{1}>0)=255; tmpmask{2}(tmpmask{2}>0)=255;

checkerboardID=cell(2,1);
checkerboard=cell(2,1);
checkertexture=cell(2,1);
for pp=1:1:2
  checkerboardID{pp}=tmp_checkerboardID{1};
  checkerboardID{pp}(tmpmask{pp}<255)=0; % set the background ID to the outer region

  checkerboard{pp}=tmp_checkerboard{1};
  checkerboard{pp}(tmpmask{pp}<255)=0; % set the background ID to the outer region
end
clear tmp_checkerboardID tmp_checkerboard tmpmask;

%% update number of patches and number of wedges, taking into an account of checkerboard phase shift

% here, all parameters are generated for each checkerboard
% This looks circuitous, duplicating procedures, and it consumes more CPU and memory.
% 'if' statements may be better.
% However, to decrease the number of 'if' statement after starting stimulus
% presentation as possible as I can, I will do adopt this circuitous procedures.
patchids=cell(2,1); % 2 = target and its comensating patterns

% in the bar presentation, the number of patches/wedges are different over time
% because a part of the bar can be occluded by the circular aperture mask.
% therefore, we have to re-compute the patches and the corresponding IDs here.
for pp=1:1:2 % 2 = target and its comensating patterns
  tmp_checks=unique(checkerboardID{pp})';
  patchids{pp}=tmp_checks(2:end); % omit background id
end
clear tmp_checks;

%% generate a circular mask
if ~sparam.RDSbackground
  for nn=1:1:2, checkerboard{nn}(~logical(checkerboard{nn}))=NaN; end
end

% generating the first RDS
[XY,colors]=GetDotPositionsRDS(checkerboard{1},[0,sparam.RDSdepth(1),sparam.RDSdepth(2)],sparam.RDSDense,...
                               sparam.RDScolors(1:2),sparam.ipd,sparam.vdist,sparam.pix_per_cm);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Debug codes
%%%% saving the stimulus images as *.png format files and enter the debug (keyboard) mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%% DEBUG codes start here
if strfind(upper(subjID),'DEBUG')

  Screen('CloseAll');

  save_dir=fullfile(resultDir,'images_dlocalizer');
  if ~exist(save_dir,'dir'), mkdir(save_dir); end

  % open a new window for drawing stimuli
  stimRect=[0,0,size(checkerboard{1},2),size(checkerboard{1},1)];
  [winPtr,winRect]=Screen('OpenWindow',dparam.scrID,sparam.bgcolor,CenterRect(stimRect,Screen('Rect',dparam.scrID)));

  % set OpenGL
  priorityLevel=MaxPriority(winPtr,'WaitBlanking');
  Priority(priorityLevel);
  AssertOpenGL();
  Screen('BlendFunction', winPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  % processing
  for cc=1:1:sparam.numRepeats
    for nn=1:1:2
      for rr=1:1:round(nframe_stim/(nframe_flicker*sparam.RDSdepth(3)))
        for mm=1:1:sparam.RDSdepth(3) % depth steps

          % generate/get dot positions/colors
          if sparam.RDSdepth(3)~=1
            depth1=sparam.RDSdepth(1)+(mm-1)*(sparam.RDSdepth(2)-sparam.RDSdepth(1))/(sparam.RDSdepth(3)-1);
            depth2=sparam.RDSdepth(2)-(mm-1)*(sparam.RDSdepth(2)-sparam.RDSdepth(1))/(sparam.RDSdepth(3)-1);
          else
            depth1=sparam.RDSdepth(1);
            depth2=sparam.RDSdepth(2);
          end
          [XY,colors]=GetDotPositionsRDS(checkerboard{nn},[0,depth1,depth2],sparam.RDSDense,...
                                         sparam.RDScolors(1:2),sparam.ipd,sparam.vdist,sparam.pix_per_cm);

          for pp=1:1:2 % left and right images
            Screen('FillRect',winPtr,sparam.bgcolor,stimRect); % wipe the background just in case
            Screen('DrawDots',winPtr,XY{pp},2*sparam.RDSradius*sparam.pix_per_deg,colors{pp},[0,0],3); % RDS

            % flip the window
            Screen('DrawingFinished',winPtr);
            Screen('Flip',winPtr,[],[],[],1);

            % get the current frame and save it
            imwrite(Screen('GetImage',winPtr,winRect),fullfile(save_dir,sprintf('checkerboard_%s_cycle_%02d_pos_%02d_%02d_depth_%02d_%02d.png',sparam.mode,cc,nn,rr,mm,pp)),'png');
          end
        end
      end
    end
  end

  Screen('CloseAll');
  save(fullfile(save_dir,sprintf('stimulus_%s.mat',sparam.mode)),'checkerboard','sparam','dparam');
  keyboard;

end % if strfind(upper(subjID),'DEBUG')
% %%%%%% DEBUG code ends here


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Generating depth detection task parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% set task variables
% flag to decide in which period (first half or second half) the disparity task is applied
% about task_flg:
% 1, task is added in the first half period
% 2, task is added in the second half period
task_flg=randi(2,[ceil(sparam.numRepeats*2*(nframe_stim+nframe_rest)/nframe_task),1]);

% flag whether presenting disparity task
do_task=zeros(ceil(sparam.numRepeats*2*(nframe_stim+nframe_rest)/nframe_task),1);
do_task(1)=0; % no task for the first presentation
for ii=2:1:ceil(sparam.numRepeats*2*(nframe_stim+nframe_rest)/nframe_task)
  if do_task(ii-1)==1
    do_task(ii)=0;
  else
    do_task(ii)=round(rand(1,1));
  end
end

% variable to store the current task array order
task_id=1;

% variable to store task position
task_pos=cell(2,1); % 2 = target and its comensating patterns
for pp=1:1:2
  task_pos{pp}=[];
  for nn=1:1:ceil(sparam.numRepeats*2*(nframe_stim+nframe_rest)/nframe_task)
    tmp_id=shuffle(patchids{pp});
    task_pos{pp}=[task_pos{pp},tmp_id(1)];
  end
end

% flag to index the first task frame
firsttask_flg=0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initializing checkerboard color management parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% checkerboard depth id
depth_id=1;


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
    aperture_size=[2*( p_height*ceil( size(checkerboard{1},1)/2*( (winRect(4)-winRect(2))/dparam.ScrHeight ) /p_height ) ),...
                   2*( p_width*ceil( size(checkerboard{1},2)/2*( (winRect(3)-winRect(1))/dparam.ScrWidth ) /p_width ) )];
  else
    aperture_size=[2*( p_height*ceil(size(checkerboard{1},1)/2/p_height) ),...
                   2*( p_width*ceil(size(checkerboard{1},2)/2/p_width) )];
  end

  bgimg=CreateBackgroundImage([dparam.ScrHeight,dparam.ScrWidth],aperture_size,sparam.patch_size,sparam.bgcolor,sparam.patch_color1,sparam.patch_color2,sparam.fixcolor,sparam.patch_num,0,0,0);
else
  error('sparam.bgtype should be 1 or 2. check the input variable.');
end

background=Screen('MakeTexture',winPtr,bgimg{1});


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

% compute Random-Dot-Stereogram image center
if strcmpi(dparam.ExpMode,'cross') || strcmpi(dparam.ExpMode,'parallel') || ...
   strcmpi(dparam.ExpMode,'topbottom') || strcmpi(dparam.ExpMode,'bottomtop')
  half_flg=1;
else
  half_flg=0;
end
dotCenter=[diff(winRect([1,3])),diff(winRect([2,4]))]./2-[diff(stimRect([1,3])),diff(stimRect([2,4]))]./2;


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
  Screen('DrawTexture',winPtr,fix{2},[],CenterRect(fixRect,winRect));
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
  Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
  Screen('DrawTexture',winPtr,fix{1},[],CenterRect(fixRect,winRect)); % fix{1} is valis as no task in the first period
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

% wait for the initial fixation
for ff=1:1:nframe_fixation(1)
  for nn=1:1:nScr
    Screen('SelectStereoDrawBuffer',winPtr,nn-1);
    Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
    Screen('DrawTexture',winPtr,fix{1},[],CenterRect(fixRect,winRect));
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
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% The Trial Loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for cc=1:1:sparam.numRepeats

  %% stimulus presentation loop
  for pp=1:1:2 % 2 = the target and its compensating patterns
    for ff=1:1:nframe_stim+nframe_rest

      % preparaing the next stimulus
      if ff<=nframe_stim && ~mod(ff,nframe_flicker)

        % generate a checkerboard texture with/without a depth detection task
        if do_task(task_id) && ...
          ( ( task_flg(task_id)==1 && (mod(ff,2*nframe_task)<=nframe_task && mod(ff,2*nframe_task)~=0) ) || ...
            ( task_flg(task_id)==2 && (mod(ff,2*nframe_task)>nframe_task || mod(ff,2*nframe_task)==0) ) )
          tidx=find(checkerboardID{pp}==task_pos{pp}(task_id));
          cval=checkerboard{pp}(tidx(ceil(numel(tidx)/2))); % ceil(numel(tidx)/2) is required as sometimes tidx(1) is located at the edge of the checkerboard which gives NaN.
          checkerboard{pp}(tidx)=3; % as IDs of the original checkerboard are 0|1|2, 3 is assigned to the task patch.
        else
          tidx=[];
        end

        if sparam.RDSdepth(3)~=1
          depth1=sparam.RDSdepth(1)+(depth_id-1)*(sparam.RDSdepth(2)-sparam.RDSdepth(1))/(sparam.RDSdepth(3)-1);
          depth2=sparam.RDSdepth(2)-(depth_id-1)*(sparam.RDSdepth(2)-sparam.RDSdepth(1))/(sparam.RDSdepth(3)-1);
        else
          depth1=sparam.RDSdepth(1);
          depth2=sparam.RDSdepth(2);
        end

        if ~isempty(tidx)
          if cval==1
            [XY,colors]=GetDotPositionsRDS(checkerboard{pp},[0,depth1,depth2,sparam.RDStaskmagnitude*(-1)*abs(sparam.RDSdepth(1))],sparam.RDSDense,...
                                           sparam.RDScolors(1:2),sparam.ipd,sparam.vdist,sparam.pix_per_cm);
          else % if cval==2
            [XY,colors]=GetDotPositionsRDS(checkerboard{pp},[0,depth1,depth2,sparam.RDStaskmagnitude*(-1)*abs(sparam.RDSdepth(2))],sparam.RDSDense,...
                                           sparam.RDScolors(1:2),sparam.ipd,sparam.vdist,sparam.pix_per_cm);
          end
          checkerboard{pp}(tidx)=cval; % put the checkerboard ID back to the default
        else
          [XY,colors]=GetDotPositionsRDS(checkerboard{pp},[0,depth1,depth2],sparam.RDSDense,...
                                         sparam.RDScolors(1:2),sparam.ipd,sparam.vdist,sparam.pix_per_cm);
        end
      end % if ff<=nframe_stim && ~mod(ff,nframe_flicker)

      %% display the current frame
      for nn=1:1:nScr
        Screen('SelectStereoDrawBuffer',winPtr,nn-1);
        Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect)); % background
        if ff<=nframe_stim
          if half_flg
            Screen('DrawDots',winPtr,XY{nn}./2,sparam.RDSradius*sparam.pix_per_deg,colors{nn},dotCenter,3); % RDS
          else
            Screen('DrawDots',winPtr,XY{nn},2*sparam.RDSradius*sparam.pix_per_deg,colors{nn},dotCenter,3); % RDS
          end
        end
        Screen('DrawTexture',winPtr,fix{1},[],CenterRect(fixRect,winRect)); % the central fixation oval
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
      while GetSecs()<vbl+sparam.initial_fixation_time(1)+(cc-1)*2*sparam.block_duration+(pp-1)*sparam.block_duration+((ff-1)*sparam.waitframes-0.5)*dparam.ifi, [resps,event]=resps.check_responses(event); end
      Screen('Flip',winPtr,[],[],[],1);

      if pp==1 && ff==1
        event=event.add_event(sprintf('Cycle: %d',cc),[]);
        fprintf(sprintf('Cycle: %03d...\n',cc));
      end

      if ff<=nframe_stim && firsttask_flg==1 && ( do_task(task_id) && ...
         ( ( task_flg(task_id)==1 && (mod(ff,2*nframe_task)<=nframe_task && mod(ff,2*nframe_task)~=0) ) || ...
           ( task_flg(task_id)==2 && (mod(ff,2*nframe_task)>nframe_task || mod(ff,2*nframe_task)==0) ) ) ), event=event.add_event('Depth Task',[]); end

      %% exit from the loop if the final frame is displayed
      if pp==2 && ff==nframe_stim+nframe_rest && cc==sparam.numRepeats, continue; end

      %% update IDs

      % flickering checkerboard
      if ff<=nframe_stim
        if ~mod(ff,nframe_flicker) % depth change
          depth_id=depth_id+1;
          if depth_id>sparam.RDSdepth(3), depth_id=1; end
        end

        %% update task. about task_flg: 1, task is added in the first half period. 2, task is added in the second half period
        if ~mod(ff,nframe_task), task_id=task_id+1; firsttask_flg=0; end
        firsttask_flg=firsttask_flg+1;
      else
        depth_id=1;
        firsttask_flg=0;
      end
    end % for ff=1:1:nframe_stim+nframe_rest
  end % for pp=1:1:2 % 2 = the target and its compensating patterns

end % for cc=1:1:sparam.numRepeats


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Final Fixation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for nn=1:1:nScr
  Screen('SelectStereoDrawBuffer',winPtr,nn-1);
  Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
  Screen('DrawTexture',winPtr,fix{1},[],CenterRect(fixRect,winRect));
  if dparam.onset_punch(1), Screen('FillRect',winPtr,[0,0,0],CenterRect([0,0,psize,psize],winRect)+punchoffset); end

  % blue line for stereo sync
  if strcmpi(dparam.ExpMode,'propixxstereo')
    Screen('FillRect',winPtr,[0,0,255],blueRectOn(nn,:));
    Screen('FillRect',winPtr,[0,0,0],blueRectOff(nn,:));
  end
end
Screen('DrawingFinished',winPtr);
while GetSecs()<vbl+sparam.initial_fixation_time(1)+sparam.numRepeats*2*sparam.block_duration-0.5*dparam.ifi, [resps,event]=resps.check_responses(event); end
Screen('Flip',winPtr,[],[],[],1);
event=event.add_event('Final Fixation',[]);
fprintf('\nfixation\n');

% wait for the initial fixation
for ff=1:1:nframe_fixation(2)
  for nn=1:1:nScr
    Screen('SelectStereoDrawBuffer',winPtr,nn-1);
    Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
    Screen('DrawTexture',winPtr,fix{1},[],CenterRect(fixRect,winRect));
    if dparam.onset_punch(1), Screen('FillRect',winPtr,[0,0,0],CenterRect([0,0,psize,psize],winRect)+punchoffset); end

    % blue line for stereo sync
    if strcmpi(dparam.ExpMode,'propixxstereo')
      Screen('FillRect',winPtr,[0,0,255],blueRectOn(nn,:));
      Screen('FillRect',winPtr,[0,0,0],blueRectOff(nn,:));
    end
  end
  Screen('DrawingFinished',winPtr);
  while GetSecs()<vbl+sparam.initial_fixation_time(1)+sparam.numRepeats*2*sparam.block_duration+(ff*sparam.waitframes-0.5)*dparam.ifi, [resps,event]=resps.check_responses(event); end
  Screen('Flip',winPtr,[],[],[],1);
end

% the final clock up
while GetSecs()-the_experiment_start<sum(sparam.initial_fixation_time)+sparam.numRepeats*2*sparam.block_duration
  [resps,event]=resps.check_responses(event);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Experiment & scanner end here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

experimentDuration=GetSecs()-the_experiment_start;
event=event.add_event('End',[]);
fprintf('\n');
fprintf('Experiment Completed: %.2f/%.2f secs\n',experimentDuration,...
        sum(sparam.initial_fixation_time)+sparam.numRepeats*2*sparam.block_duration);
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
savefname=fullfile(resultDir,[num2str(subjID),'_dlocalizer_results_run_',num2str(acq,'%02d'),'.mat']);

% backup the old file(s)
if ~overwrite_flg
  BackUpObsoleteFiles(fullfile('subjects',num2str(subjID),'results',today),...
                      [num2str(subjID),'_dlocalizer_results_run_',num2str(acq,'%02d'),'.mat'],'_old');
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
% end % function dlocalizer
