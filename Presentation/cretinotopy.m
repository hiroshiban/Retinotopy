function cretinotopy(subjID,exp_mode,acq,displayfile,stimulusfile,gamma_table,overwrite_flg,force_proceed_flag)

% Color/luminance-defined Checkerboard retinotopy stimulus with checker-patch luminance change-detection tasks.
% function cretinotopy(subjID,exp_mode,acq,:displayfile,:stimulusfile,:gamma_table,:overwrite_flg,:force_proceed_flag)
% (: is optional)
%
% This function generates and presents color/luminance-defined checkerboard stimulus
% to measure cortical retinotopy and to delineate retinotopic borders.
%
% - Acquired fMRI data evoked by this stimulus will be utilized
%   to delineate retinotopic visual area borders (conventional retinotopy)
% - This script shoud be used with MATLAB Psychtoolbox version 3 or above.
% - Stimulus presentation timing are controled by vertical synch signals
%
%
% Created    : "2013-11-25 11:34:59 ban"
% Last Update: "2018-11-29 12:18:04 ban"
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
%  - ccw   : checkerboard wedge rotated counter-clockwise
%  - cw    : checkerboard wedge rotated clockwise
%  - exp   : checkerboard anuulus expanding from fovea
%  - cont  : checkerboard annulus contracting from periphery
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
%    as ./subjects/(subjID)/results/(date)/(subjID)_cretinotopy_(exp_mode)_results_run_(run_num).mat
%
%
% [example]
% >> cretinotopy('HB','ccw',1,'ret_display.m','ret_checker_stimulus_exp1.m')
%
% [About displayfile]
% The contents of the displayfile are as below.
% (The file includs 6 lines of headers and following display parameters)
%
% (an example of the displayfile)
%
% % ************************************************************
% % This_is_the_display_file_for_retinotopy_Checker_experiment.
% % Please_change_the_parameters_below.
% % retinotopyDepthfMRI.m
% % Programmed_by_Hiroshi_Ban___November_01_2013
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
% % This_is_the_stimulus_parameter_file_for_retinotopyChecker_experiment.
% % Please_change_the_parameters_below.
% % retinotopyDepthfMRI.m
% % Programmed_by_Hiroshi_Ban___April_11_2011
% % ************************************************************
%
% % "sparam" means "stimulus generation parameters"
%
% %%% stimulus parameters
% sparam.nwedges     = 4;     % number of wedge subdivisions along polar angle
% sparam.nrings      = 4;     % number of ring subdivisions along eccentricity angle
% sparam.width       = 48;    % wedge width in deg along polar angle
% sparam.phase       = 0;     % phase shift in deg
% sparam.rotangle    = 12;    % rotation angle in deg
% sparam.startangle  = -sparam.width/2;     % presentation start angle in deg, from right-horizontal meridian, ccw
%
% sparam.maxRad      = 8;    % maximum radius of  annulus (degrees)
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
% sparam.cycle_duration=60000; % msec
% sparam.rest_duration =0; % msec, rest after each cycle, stimulation = cycle_duration-eccrest
% sparam.numRepeats=6;
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
% %sparam.pix_per_cm=57.1429;
% %sparam.vdist=65;
% run([fileparts(mfilename('fullpath')) filesep() 'sizeparams']);
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
% One of checkerboard patches sometimes (randomly) becomes darker.
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
if ~strcmpi(exp_mode,'ccw') && ~strcmpi(exp_mode,'cw') && ~strcmpi(exp_mode,'exp') && ~strcmpi(exp_mode,'cont')
  error('exp_mode should be one of "ccw", "cw", "exp", and "cont". check the input variable.');
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
logfname=fullfile(resultDir,[num2str(subjID),'_cretinotopy_',exp_mode,'_results_run_',num2str(acq,'%02d'),'.log']);
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
         'nwedges',4,...
         'nrings',4,...
         'width',48,...
         'phase',0,...
         'rotangle',12,...
         'startangle',-48/2,...
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
         'cycle_duration',60000,...
         'rest_duration',0,...
         'numRepeats',6,...
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
sparam.cycle_duration = sparam.cycle_duration./1000;
sparam.rest_duration  = sparam.rest_duration./1000;

% set the other parameters
dparam.RunScript = mfilename();
sparam.RunScript = mfilename();

%% check varidity of parameters
fprintf('checking validity of stimulus generation/presentation parameters...');
if mod(360,sparam.rotangle), error('mod(360,sparam.rotangle) should be 0. check input variables.'); end
if mod(sparam.width,sparam.rotangle), error('mod(sparam.width,sparam.rotangle) should be 0. check input variables.'); end
disp('done.');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Displaying the presentation parameters you set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('The Presentation Parameters are as below.');
fprintf('\n');
disp('************************************************');
disp('****** Script, Subject, Acquistion Number ******');
eval(sprintf('disp(''Running Script Name    : %s'');',mfilename()));
eval(sprintf('disp(''Subject ID             : %s'');',subjID));
eval(sprintf('disp(''Acquisition Number     : %d'');',acq));
disp('********* Run Type, Display Image Type *********');
eval(sprintf('disp(''Display Mode           : %s'');',dparam.ExpMode));
eval(sprintf('disp(''use Full Screen Mode   : %d'');',dparam.fullscr));
eval(sprintf('disp(''Start Method           : %d'');',dparam.start_method));
if dparam.start_method==4
  eval(sprintf('disp(''Custom Trigger         : %d'');',dparam.custom_trigger));
end
disp('*************** Screen Settings ****************');
eval(sprintf('disp(''Screen Height          : %d'');',dparam.ScrHeight));
eval(sprintf('disp(''Screen Width           : %d'');',dparam.ScrWidth));
disp('*********** Stimulation Periods etc. ***********');
eval(sprintf('disp(''Fixation Time(sec)     : %d & %d'');',sparam.initial_fixation_time(1),sparam.initial_fixation_time(2)));
eval(sprintf('disp(''Cycle Duration(sec)    : %d'');',sparam.cycle_duration));
eval(sprintf('disp(''Rest  Duration(sec)    : %d'');',sparam.rest_duration));
eval(sprintf('disp(''Repetitions(cycles)    : %d'');',sparam.numRepeats));
eval(sprintf('disp(''Frame Flip(per VerSync): %d'');',sparam.waitframes));
eval(sprintf('disp(''Total Time (sec)       : %d'');',sum(sparam.initial_fixation_time)+sparam.numRepeats*sparam.cycle_duration));
disp('**************** Stimulus Type *****************');
eval(sprintf('disp(''Experiment Mode        : %s'');',sparam.mode));
disp('************ Response key settings *************');
eval(sprintf('disp(''Reponse Key #1         : %d = %s'');',dparam.Key1,KbName(dparam.Key1)));
eval(sprintf('disp(''Reponse Key #2         : %d = %s'');',dparam.Key2,KbName(dparam.Key2)));
disp('************************************************');
fprintf('\n');
disp('Please carefully check before proceeding.');
fprintf('\n');


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
nframe_cycle=round((sparam.cycle_duration-sparam.rest_duration)*dparam.fps/sparam.waitframes);
nframe_rest=round(sparam.rest_duration*dparam.fps/sparam.waitframes);
nframe_rotation=round((sparam.cycle_duration-sparam.rest_duration)*dparam.fps/(360/sparam.rotangle)/sparam.waitframes);
nframe_flicker=round(nframe_rotation/sparam.ncolors/4);
nframe_task=round(nframe_rotation/2);

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
if strcmpi(sparam.mode,'ccw') || strcmpi(sparam.mode,'cw')

  sparam.npositions=360/sparam.rotangle;
  startangles=zeros(sparam.npositions,1);
  for nn=1:1:sparam.npositions, startangles(nn)=sparam.startangle+(nn-1)*sparam.rotangle; end

  [checkerboardID,checkerboard]=pol_GenerateCheckerBoard1D(rmin,rmax,sparam.width,startangles,sparam.pix_per_deg,...
                                                           sparam.nwedges,sparam.nrings,sparam.phase);

elseif strcmpi(sparam.mode,'exp') || strcmpi(sparam.mode,'cont')

  sparam.npositions=(sparam.cycle_duration-sparam.rest_duration)/(sparam.cycle_duration/(360/sparam.rotangle));
  eccedge=(rmax-rmin)/( sparam.npositions-1 );
  eccwidth=eccedge*(sparam.width/sparam.rotangle);

  %% !!! NOTICE !!!
  % update some parameters here for 'exp' or 'cont' mode
  nframe_rotation=round((sparam.cycle_duration-sparam.rest_duration)*dparam.fps/sparam.npositions/sparam.waitframes);
  nframe_flicker=round(nframe_rotation/sparam.ncolors/4);
  nframe_task=round(nframe_rotation/2);

  % get annuli's min/max lims
  ecclims=zeros(sparam.npositions,3);
  for nn=1:1:sparam.npositions %1:1:sparam.npositions
    minlim=rmin+(nn-1)*eccedge-eccwidth/2;
    if minlim<rmin, minlim=rmin; end
    maxlim=rmin+(nn-1)*eccedge+eccwidth/2;
    if maxlim>rmax, maxlim=rmax; end

    ecclims(nn,:)=[minlim,maxlim,eccwidth];
  end

  [checkerboardID,checkerboard]=ecc_GenerateCheckerBoard1D(ecclims,360,sparam.startangle,sparam.pix_per_deg,...
                                                           round(360*sparam.nwedges/sparam.width),sparam.nrings,sparam.phase);

end % if strcmpi(sparam.mode,'ccw') || strcmpi(sparam.mode,'cw')

%% update number of patches and number of wedges, taking into an account of checkerboard phase shift

% here, alll parameters are generated for each checkerboard
% This looks circuitous, duplicating procedures, and it consumes more CPU and memory.
% 'if' statements may be better.
% However, to decrease the number of 'if' statement after starting stimulus
% presentation as possible as I can, I will do adopt this circuitous procedures.
true_npatches=cell(sparam.npositions,1);
true_nwedges=cell(sparam.npositions,1);
patchids=cell(sparam.npositions,1);

if strcmpi(sparam.mode,'ccw') || strcmpi(sparam.mode,'cw')
  % for ccw & cw, the number of patches/wedges are same over time
  tmp_checks=unique(checkerboardID{1})';
  for nn=1:1:sparam.npositions
    true_npatches{nn}=numel(tmp_checks)-1; % -1 is to omit background id
    true_nwedges{nn}=true_npatches{nn}/sparam.nrings;
    patchids{nn}=tmp_checks;
    patchids{nn}=patchids{nn}(2:end); % omit background id
  end
  clear tmp_checks;
else
  % for exp & cont, the number of patches/wedges are different over time especially
  % when the annulus comes around the smallest/largest regions
  if sparam.nrings==1
    tmp_checks=unique(checkerboardID{1})';
    tmp_npatches=numel(tmp_checks)-1; % -1 is to omit background id
    tmp_nwedges=360/(sparam.width/sparam.nwedges);
    tmp_ids=tmp_checks(2:end);
    for nn=1:1:sparam.npositions
      true_npatches{nn}=tmp_npatches;
      true_nwedges{nn}=tmp_nwedges;
      patchids{nn}=tmp_ids; % omit background id;
    end
    clear tmp_checks tmp_npatches tmp_nwedges tmp_ids;
  else
    for nn=1:1:sparam.npositions
      tmp_checks=unique(checkerboardID{nn})';
      true_npatches{nn}=numel(tmp_checks)-1; % -1 is to omit background id
      true_nwedges{nn}=360/(sparam.width/sparam.nwedges);
      patchids{nn}=tmp_checks;
      patchids{nn}=patchids{nn}(2:end); % omit background id;
    end
    clear tmp_checks;
  end
end

%% flip all data for ccw/cont
if strcmpi(sparam.mode,'ccw') || strcmpi(sparam.mode,'cont')

  tmp_checkerboardID=cell(sparam.npositions,1);
  for nn=1:1:sparam.npositions, tmp_checkerboardID{nn}=checkerboardID{sparam.npositions-(nn-1)}; end
  checkerboardID=tmp_checkerboardID;
  clear tmp_checkerboardID;

  tmp_checkerboard=cell(sparam.npositions,1);
  for nn=1:1:sparam.npositions, tmp_checkerboard{nn}=checkerboard{sparam.npositions-(nn-1)}; end
  checkerboard=tmp_checkerboard;
  clear tmp_checkerboard;

  tmp_true_npatches=cell(sparam.npositions,1);
  for nn=1:1:sparam.npositions, tmp_true_npatches{nn}=true_npatches{sparam.npositions-(nn-1)}; end
  true_npatches=tmp_true_npatches;
  clear tmp_true_npatches;

  tmp_true_nwedges=cell(sparam.npositions,1);
  for nn=1:1:sparam.npositions, tmp_true_nwedges{nn}=true_nwedges{sparam.npositions-(nn-1)}; end
  true_nwedges=tmp_true_nwedges;
  clear tmp_true_nwedges;

  tmp_patchids=cell(sparam.npositions,1);
  for nn=1:1:sparam.npositions, tmp_patchids{nn}=patchids{sparam.npositions-(nn-1)}; end
  patchids=tmp_patchids;
  clear tmp_patchids;

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initializing Color Lookup-Talbe (CLUT)
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
      CLUT{cc,pp}(4,1:3)=sparam.dimratio.*sparam.colors(2*cc,:);
      CLUT{cc,pp}(5,1:3)=sparam.dimratio.*sparam.colors(2*cc+1,:);
    else
      CLUT{cc,pp}(2,1:3)=sparam.colors(2*cc+1,:);
      CLUT{cc,pp}(3,1:3)=sparam.colors(2*cc,:);
      CLUT{cc,pp}(4,1:3)=sparam.dimratio.*sparam.colors(2*cc+1,:);
      CLUT{cc,pp}(5,1:3)=sparam.dimratio.*sparam.colors(2*cc,:);
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
  for nn=1:1:sparam.npositions
    figure; hold on;
    imfig=imagesc(flipdim(checkerboard{nn},1),[0,true_npatches{nn}]);
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
%%%% Generating contrast detection task parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% set task variables
% flag to decide in which period (first half or second half) the disparity task is applied
% about task_flg:
% 1, task is added in the first half period
% 2, task is added in the second half period
task_flg=randi(2,[round(sparam.numRepeats*nframe_cycle/nframe_task),1]);

% flag whether presenting disparity task
do_task=zeros(round(sparam.numRepeats*nframe_cycle/nframe_task),1);
do_task(1)=0; % no task for the first presentation
for ii=2:1:round(sparam.numRepeats*nframe_cycle/nframe_task)
  if do_task(ii-1)==1
    do_task(ii)=0;
  else
    do_task(ii)=round(rand(1,1));
  end
end

% variable to store the current task array order
task_id=1;

% variable to store task position
task_pos=cell(sparam.npositions,1);
for nn=1:1:sparam.npositions
  task_pos{nn}=randi(true_npatches{nn},[round(sparam.numRepeats*nframe_cycle/nframe_task),1]);
end

%% set some flags

% checkerboard color id
color_id=1;

% checkerboard compensating color id
compensate_id=1;

% flag to index the first task frame
firsttask_flg=0;

% variable to store the current rotation/disparity id
stim_pos_id=1;


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
%%%% Creating the central fixation, cross images (left/right)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create fixation cross images
fix=CreateFixationImgCircular(4*sparam.fixsize,sparam.fixcolor,sparam.bgcolor,4*sparam.fixsize,0,0);
wait_fix=CreateFixationImgCircular(4*sparam.fixsize,[64,64,64],sparam.bgcolor,4*sparam.fixsize,0,0);
fix=imresize(fix,0.25);
wait_fix=imresize(wait_fix,0.25);

wait_fcircle=Screen('MakeTexture',winPtr,wait_fix);
fcircle=Screen('MakeTexture',winPtr,fix);


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
end

bgRect  = [0, 0, bgSize]; % used to display background images;
stimRect= [0, 0, stimSize];
fixRect = [0, 0, fixSize]; % used to display the central fixation point


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
  Screen('DrawTexture',winPtr,wait_fcircle,[],CenterRect(fixRect,winRect));
end
Screen('DrawingFinished',winPtr);
Screen('Flip', winPtr,[],[],[],1);

% prepare the next frame for the initial fixation period
for nn=1:1:nScr
  Screen('SelectStereoDrawBuffer',winPtr,nn-1);
  Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
  Screen('DrawTexture',winPtr,fcircle,[],CenterRect(fixRect,winRect));
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

% wait for the initial fixation
for ff=1:1:nframe_fixation(1)-1 % -1 is to omit the first frame period above, %-1 is for the first stimulus frame
  for nn=1:1:nScr
    Screen('SelectStereoDrawBuffer',winPtr,nn-1);
    Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
    Screen('DrawTexture',winPtr,fcircle,[],CenterRect(fixRect,winRect));
  end
  Screen('DrawingFinished',winPtr);
  Screen('Flip',winPtr,vbl+(ff*sparam.waitframes-0.5)*dparam.ifi,[],[],1);
  [resps,event]=resps.check_responses(event);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% The Trial Loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for cc=1:1:sparam.numRepeats
  % NOTE: as this event will be logged before the first flip in the trial,
  % it will be faster by sparam.waitframes in the record of the event. Please be careful.
  event=event.add_event(sprintf('Cycle: %d',cc),[],the_experiment_start-sparam.waitframes*dparam.ifi);
  fprintf(sprintf('Cycle: %03d...\n',cc));

  %% rest perioed

  if strcmpi(sparam.mode,'cw') || strcmpi(sparam.mode,'cont')
    for ff=1:1:nframe_rest
      for nn=1:1:nScr
        Screen('SelectStereoDrawBuffer',winPtr,nn-1);
        % background & the central fixation
        Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
        Screen('DrawTexture',winPtr,fcircle,[],CenterRect(fixRect,winRect));
      end

      % flip the window
      Screen('DrawingFinished',winPtr);
      Screen('Flip',winPtr,vbl+sparam.initial_fixation_time(1)+(cc-1)*sparam.cycle_duration+((ff-1)*sparam.waitframes-0.5)*dparam.ifi,[],[],1);
      [resps,event]=resps.check_responses(event);
    end
  end

  %% stimulus presentation loop
  for ff=1:1:nframe_cycle

    % generate a checkerboard texture with/without a luminance detection task
    if do_task(task_id) && ...
      ( ( task_flg(task_id)==1 && mod(ff,nframe_rotation)<=nframe_rotation/2 ) || ...
        ( task_flg(task_id)==2 && mod(ff,nframe_rotation)>nframe_rotation/2 ) )
      tidx=find(checkerboardID{stim_pos_id}==task_pos{stim_pos_id}(task_id));
      checkerboard{stim_pos_id}(tidx)=checkerboard{stim_pos_id}(tidx)+2; % here +2 is for a dim checker pattern. for details, please see codes in generating CLUT.
      checkertexture=Screen('MakeTexture',winPtr,checkerboard{stim_pos_id});
    else
      tidx=[];
      checkertexture=Screen('MakeTexture',winPtr,checkerboard{stim_pos_id});
    end

    %% display the current frame
    for nn=1:1:nScr
      Screen('SelectStereoDrawBuffer',winPtr,nn-1);
      Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect)); % background
      DrawTextureWithCLUT(winPtr,checkertexture,CLUT{color_id,compensate_id},[],CenterRect(stimRect,winRect)); % checkerboard
      Screen('DrawTexture',winPtr,fcircle,[],CenterRect(fixRect,winRect)); % the central fixation oval
    end

    % put the checkerboard ID back to the default
    if ~isempty(tidx), checkerboard{stim_pos_id}(tidx)=checkerboard{stim_pos_id}(tidx)-2; end

    % flip the window
    Screen('DrawingFinished',winPtr);
    if strcmpi(sparam.mode,'cw') || strcmpi(sparam.mode,'cont')
      Screen('Flip',winPtr,vbl+sparam.initial_fixation_time(1)+(cc-1)*sparam.cycle_duration+sparam.rest_duration+((ff-1)*sparam.waitframes-0.5)*dparam.ifi,[],[],1);
    else
      Screen('Flip',winPtr,vbl+sparam.initial_fixation_time(1)+(cc-1)*sparam.cycle_duration+((ff-1)*sparam.waitframes-0.5)*dparam.ifi,[],[],1);
    end
    if do_task(task_id) && firsttask_flg==1, event=event.add_event('Luminance Task',[]); end

    % clean up
    Screen('Close',checkertexture);

    %% exit from the loop if the final frame is displayed

    if ff==nframe_cycle && cc==sparam.numRepeats, continue; end

    %% update IDs

    % flickering checkerboard
    if ~mod(ff,nframe_flicker) % color reversal
      compensate_id=mod(compensate_id,2)+1;
    end

    if ~mod(ff,2*nframe_flicker) % color change
      color_id=color_id+1;
      if color_id>sparam.ncolors, color_id=1; end
    end

    % stimulus position id for the next presentation
    if ~mod(ff,nframe_rotation)
      stim_pos_id=stim_pos_id+1;
      if stim_pos_id>sparam.npositions, stim_pos_id=1; end
    end

    %% update task. about task_flg: 1, task is added in the first half period. 2, task is added in the second half period
    if ~mod(ff,nframe_task), task_id=task_id+1; firsttask_flg=0; end
    firsttask_flg=firsttask_flg+1;

    % get responses
    [resps,event]=resps.check_responses(event);

  end % for ff=1:1:cycle_frames

  %% rest perioed

  if strcmpi(sparam.mode,'ccw') || strcmpi(sparam.mode,'exp')
    for ff=1:1:nframe_rest
      for nn=1:1:nScr
        Screen('SelectStereoDrawBuffer',winPtr,nn-1);
        % background & the central fixation
        Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
        Screen('DrawTexture',winPtr,fcircle,[],CenterRect(fixRect,winRect));
      end

      % flip the window
      Screen('DrawingFinished',winPtr);
      Screen('Flip',winPtr,vbl+sparam.initial_fixation_time(1)+(cc-1)*sparam.cycle_duration+(sparam.cycle_duration-sparam.rest_duration)+((ff-1)*sparam.waitframes-0.5)*dparam.ifi,[],[],1);
      [resps,event]=resps.check_responses(event);
    end
  end

end % for cc=1:1:sparam.numRepeats


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Final Fixation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for nn=1:1:nScr
  Screen('SelectStereoDrawBuffer',winPtr,nn-1);
  Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
  Screen('DrawTexture',winPtr,fcircle,[],CenterRect(fixRect,winRect));
end
Screen('DrawingFinished',winPtr);
Screen('Flip',winPtr,vbl+sparam.initial_fixation_time(1)+sparam.numRepeats*sparam.cycle_duration-0.5*dparam.ifi,[],[],1); % the first flip
event=event.add_event('Final Fixation',[]);
fprintf('\nfixation\n');

% wait for the initial fixation
for ff=1:1:nframe_fixation-1 % -1 is to omit the first frame period above, %-1 is for the first stimulus frame
  for nn=1:1:nScr
    Screen('SelectStereoDrawBuffer',winPtr,nn-1);
    Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
    Screen('DrawTexture',winPtr,fcircle,[],CenterRect(fixRect,winRect));
  end
  Screen('DrawingFinished',winPtr);
  Screen('Flip',winPtr,vbl+sparam.initial_fixation_time(1)+sparam.numRepeats*sparam.cycle_duration+(ff*sparam.waitframes-0.5)*dparam.ifi,[],[],1);
  [resps,event]=resps.check_responses(event);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Experiment & scanner end here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

experimentDuration=GetSecs()-the_experiment_start+sparam.waitframes*dparam.ifi;
event=event.add_event('End',[],the_experiment_start-sparam.waitframes*dparam.ifi);
disp(' ');
fprintf('Experiment Completed: %.2f/%.2f secs\n',experimentDuration,...
        sum(sparam.initial_fixation_time)+sparam.numRepeats*sparam.cycle_duration);
disp(' ');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Write data into file for post analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% saving the results
fprintf('saving data...');

% save data
savefname=fullfile(resultDir,[num2str(subjID),'_cretinotopy_',sparam.mode,'_results_run_',num2str(acq,'%02d'),'.mat']);

% backup the old file(s)
if ~overwrite_flg
  BackUpObsoleteFiles(fullfile('subjects',num2str(subjID),'results',today),...
                      [num2str(subjID),'_cretinotopy_',sparam.mode,'_results_run_',num2str(acq,'%02d'),'.mat'],'_old');
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
  if exist('event','var'), event=event.get_event(); end %#ok % just for debugging
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
% end % function cretinotopy
