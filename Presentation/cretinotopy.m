function cretinotopy(subjID,exp_mode,acq,displayfile,stimulusfile,gamma_table)

% Color/luminance-defined Checkerboard retinotopy stimulus with checker-patch luminance change-detection tasks.
% function cretinotopy(subjID,exp_mode,acq,:displayfile,:stimulusfile,:gamma_table)
% (: is optional)
%
% This function generates and presents color/luminance-defined checkerboard stimulus
% to measure cortical retinotopy and to delineate retinotopic borders.
%
% - Acquired fMRI data evoked by this stimulus will be utilized
%   to delineate retinotopic visual area borders (conventional retinotopy)
% - This script shoud be used with MATLAB Psychtoolbox version 3 or above.
% - Stimulus presentation timing are controled by vertical synch signals
% - supports 2D stimulus presentation procedure only up to now
%
%
% Created    : "2013-11-25 11:34:59 ban (ban.hiroshi@gmail.com)"
% Last Update: "2013-11-27 17:35:13 ban (ban.hiroshi@gmail.com)"
%
%
%
% [input variables]
% sujID         : ID of subject, string, such as 's01'
%                 !!!!!!!!!!!!!!!!!! IMPORTANT NOTE !!!!!!!!!!!!!!!!!!!!!!!!
%                 !!! if 'debug' (case insensitive) is included          !!!
%                 !!! in subjID string, this program runs as DEBUG mode; !!!
%                 !!! stimulus images are saved as *.png format at       !!!
%                 !!! ~/CurvatureShading/Presentation/images             !!!
%                 !!!!!!!!!!!!!!!!!! IMPORTANT NOTE !!!!!!!!!!!!!!!!!!!!!!!!
%
% exp_mode      : experiment mode that you want to run, one of
%  - ccw   : checkerboard wedge rotated counter-clockwise
%  - cw    : checkerboard wedge rotated clockwise
%  - exp   : checkerboard anuulus expanding from fovea
%  - cont  : checkerboard annulus contracting from periphery
% acq           : acquisition number (design file number),
%                 a integer, such as 1, 2, 3, ...
% displayfile   : (optional) display condition file,
%                 *.m file, such as 'RetDepth_display_fmri.m'
% stimulusfile  : (optional) stimulus condition file,
%                 *.m file, such as 'RetDepth_stimulus_exp1.m'
% gamma_table   : (optional) table(s) of gamma-corrected video input values (Color LookupTable).
%                 256(8-bits) x 3(RGB) x 1(or 2,3,... when using multiple displays) matrix
%                 or a *.mat file specified with a relative path format. e.g. '/gamma_table/gamma1.mat'
%                 The *.mat should include a variable named "gamma_table" consists of a 256x3xN matrix.
%                 if you use multiple (more than 1) displays and set a 256x3x1 gamma-table, the same
%                 table will be applied to all displays. if the number of displays and gamma tables
%                 are different (e.g. you have 3 displays and 256x3x!2! gamma-tables), the last
%                 gamma_table will be applied to the second and third displays.
%                 if empty, normalized gamma table (repmat(linspace(0.0,1.0,256),3,1)) will be applied.
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
%    as ./subjects/(subjID)/results/(date)/(subjID)_fmri_exp1_results_run_(run_num).mat
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
% ************************************************************
% This_is_the_display_file_for_retinotopy_Checker_experiment.
% Please_change_the_parameters_below.
% retinotopyDepthfMRI.m
% Programmed_by_Hiroshi_Ban___November_01_2013
% ************************************************************
%
% % display mode, one of "mono", "dual", "cross", "parallel", "redgreen", "greenred",
% % "redblue", "bluered", "shutter", "topbottom", "bottomtop", "interleavedline", "interleavedcolumn"
% dparam.ExpMode='mono';
% 
% % a method to start stimulus presentation
% % 0:ENTER/SPACE, 1:Left-mouse button, 2:the first MR trigger pulse (CiNet),
% % 3:waiting for a MR trigger pulse (BUIC) -- checking onset of pin #11 of the parallel port,
% % or 4:custom key trigger (wait for a key input that you specify as tgt_key).
% dparam.start_method=2;
% 
% % a pseudo trigger key from the MR scanner when it starts, only valid when dparam.start_method=4;
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
% % stimulus display durations in msec
%
% %%% fixation period in msec before/after presenting the target stimuli, integer (16)
% % must set above 1 TR for initializing the frame counting.
% dparam.initial_fixation_time=16000;
%
%
% [About stimulusfile]
% The contents of the stimulusfile are as below.
% (The file includs 6 lines of headers and following stimulus parameters)
%
% (an example of the stimulusfile)
%
% ************************************************************
% This_is_the_stimulus_parameter_file_for_retinotopyChecker_experiment.
% Please_change_the_parameters_below.
% retinotopyDepthfMRI.m
% Programmed_by_Hiroshi_Ban___April_11_2011
%************************************************************
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
% %%% fixation size & color
% sparam.fixsize=12; % radius in pixels
% sparam.fixcolor=[255,255,255];
%
% %%% background color
% sparam.bgcolor=sparam.colors(1,:); %[0,0,0];
%
% %%% RGB for background patches
% % 1x3 matrices
% sparam.color1=[255,255,255];
% sparam.color2=[0,0,0];
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
%%%% adding path to the subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear global; clear mex;

% add paths to the subfunctions
rootDir=fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(rootDir,'..','Common')));
addpath(fullfile(rootDir,'..','Generation'));

% set stimulus parameters
sparam.mode=exp_mode;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% for log file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get date
today=strrep(datestr(now,'yy/mm/dd'),'/','');

% result directry & file
resultDir=fullfile(rootDir,'subjects',num2str(subjID),'results',today);
if ~exist(resultDir,'dir'), mkdir(resultDir); end

% record the output window
logfname=[resultDir filesep() num2str(subjID) '_cretinotopy_' sparam.mode '_results_run_' num2str(acq,'%02d') '.log'];
diary(logfname);
warning off; %#ok warning('off','MATLAB:dispatcher:InexactCaseMatch');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% for HELP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3, eval(sprintf('help %s',mfilename())); return; end


%%%%% try & catch %%%%%
try


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% check the PTB version
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%PTB_OK=CheckPTBversion(3); % check wether the PTB version is 3
%if ~PTB_OK, error('Wrong version of Psychtoolbox is running. ImagesShowPTB requires PTB ver.3'); end

% debug level, black screen during calibration
Screen('Preference', 'VisualDebuglevel', 3);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Setup random seed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

InitializeRandomSeed();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Reset display Gamma-function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<6 || isempty(gamma_table)
  gamma_table=repmat(linspace(0.0,1.0,256),3,1); %#ok
  GammaResetPTB(1.0);
else
  GammaLoadPTB(gamma_table);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% 1. check input variables,
%%%% 2. read a condition file,
%%%% 3. check the validity of input variables,
%%%% 4. store informascatio about directories & design file,
%%%% 5. and load design & condition file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check the number of nargin
if nargin <= 2
  error('takes at least 3 arguments: cretinotopy(subjID, exp_mode, acq, (:displayfile), (:stimulusfile))');
elseif nargin > 5
  error('takes at most 5 arguments: cretinotopy(subjID, exp_mode, acq, (:displayfile), (:stimulusfile))');
else
  if nargin == 3
    useDisplayFile = false;
    useStimulusFile = false;
  end
  if nargin >= 4
    % reading display (presentation) parameters from file
    if strcmp(displayfile(end-1:end),'.m')
      dfile = [fullfile(rootDir,'subjects',subjID) filesep() displayfile];
    else
      dfile = [fullfile(rootDir,'subjects',subjID) filesep() displayfile '.m'];
    end
    [is_exist, message] = IsExistYouWant(dfile,'file');
    if is_exist
      useDisplayFile = true;
    else
      error(message);
    end
  end
  if nargin == 5
    % reading stimulus generation parameters from file
    if strcmp(stimulusfile(end-1:end),'.m')
      sfile = [fullfile(rootDir,'subjects',subjID) filesep() stimulusfile];
    else
      sfile = [fullfile(rootDir,'subjects',subjID) filesep() stimulusfile '.m'];
    end
    [is_exist, message] = IsExistYouWant(sfile,'file');
    if is_exist
      useStimulusFile = true;
    else
      error(message);
    end
  end
end % if nargin


% check the aqcuisition number. up to 10 design files can be used
if acq<1, error('Acquistion number must be integer and greater than zero'); end

% check condition files

% set display parameters
if useDisplayFile

  % load displayfile
  tdir=fullfile(rootDir,'subjects',subjID);
  run(strcat(tdir,filesep(),displayfile));
  clear tdir;

  % change unit from msec to sec.
  dparam.initial_fixation_time = dparam.initial_fixation_time/1000; %#ok

else  % if useDisplayFile

  % otherwise, set default variables
  dparam.ExpMode='mono';
  dparam.start_method=0;
  dparam.custom_trigger='t';
  dparam.Key1=51; % key 1 (left)
  dparam.Key2=52; % key 2 (right)
  dparam.fullscr='false';
  dparam.ScrHeight=1200;
  dparam.ScrWidth=1920;
  dparam.initial_fixation_time=16;

end % if useDisplayFile

if useStimulusFile

  % load stimulusfile
  tdir=fullfile(rootDir,'subjects',subjID);
  run(strcat(tdir,filesep(),stimulusfile));
  clear tdir;

  % change unit from msec to sec.
  sparam.cycle_duration = sparam.cycle_duration/1000;
  sparam.rest_duration  = sparam.rest_duration/1000;

else  % if useStimulusFile

  % otherwise, set default variables

  %%% stimulus parameters
  sparam.nwedges        = 4;
  sparam.nrings         = 4;
  sparam.width          = 48;
  sparam.phase          = 0;
  sparam.rotangle       = 12;
  sparam.startangle     = -sparam.width/2;

  sparam.maxRad         = 8;
  sparam.minRad         = 0;

  sparam.colors      = [ 128, 128, 128;
                         255,   0,   0;
                           0, 255,   0;
                         255, 255,   0;
                           0,   0, 255;
                         255,   0, 255;
                           0, 255, 255;
                         255, 255, 255;
                           0,   0,   0;
                         255, 128,   0;
                         128,   0, 255;];

  %%% duration in msec for each cycle & repetitions
  sparam.cycle_duration = 60;
  sparam.rest_duration  = 0;
  sparam.numRepeats     = 6;

  %% set number of frames to flip the screen
  sparam.waitframes = Screen('FrameRate',0)*(sparam.cycle_duration/1000) / (360/sparam.rotangle) / ( (size(sparam.colors,1)-1)*2 );

  %%% fixation size & color
  sparam.fixsize        = 12;
  sparam.fixcolor       = [255,255,255];

  %%% background color
  sparam.bgcolor        = sparam.colors(1,:);

  %%% RGB for background patches
  % 1x3 matrices
  sparam.color1         =[255,255,255];
  sparam.color2         =[0,0,0];

  %%% for creating disparity & shadow
  sparam.pix_per_cm     =57.1429;
  sparam.vdist          =65;

end % if useStimulusFile

%% check varidity of parameters
fprintf('checking validity of stimulus generation/presentation parameters...');
if ~strcmpi(sparam.mode,'ccw') && ~strcmpi(sparam.mode,'cw') && ~strcmpi(sparam.mode,'exp') && ~strcmpi(sparam.mode,'cont')
  error('sparam.mode should be one of "ccw", "cw", "exp", and "cont". check input variables.');
end
if mod(360,sparam.rotangle), error('mod(360,sparam.rotangle) should be 0. check input variables.'); end
if mod(sparam.width,sparam.rotangle), error('mod(sparam.width,sparam.rotangle) should be 0. check input variables.'); end
disp('done.');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% displaying the presentation parameters you set
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
eval(sprintf('disp(''Fixation Time(sec)     : %d'');',dparam.initial_fixation_time));
eval(sprintf('disp(''Cycle Duration(sec)    : %d'');',sparam.cycle_duration));
eval(sprintf('disp(''Rest  Duration(sec)    : %d'');',sparam.rest_duration));
eval(sprintf('disp(''Repetitions(cycles)    : %d'');',sparam.numRepeats));
eval(sprintf('disp(''Frame Flip(per VerSync): %d'');',sparam.waitframes));
eval(sprintf('disp(''Total Time (sec)       : %d'');',dparam.initial_fixation_time*2+sparam.numRepeats*sparam.cycle_duration));
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
%%%% initialize response & event logger objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize MATLAB objects for event and response logs
event=eventlogger();
resps=responselogger([dparam.Key1,dparam.Key2]);
resps.unify_keys();
resps.check_responses(event); % load function(s) once before running the main trial loop
resps=resps.disable_jis_key_trouble(); % force to set 0 for the keys that are ON by default.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Wait for user reponse to start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[user_answer,resps]=resps.wait_to_proceed();
if ~user_answer, return; end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initialization of Left & Right screens for binocular presenting/viewing mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[winPtr,winRect,nScr,initDisplay_OK]=InitializePTBDisplays(dparam.ExpMode,sparam.bgcolor,0,[]);
if ~initDisplay_OK, error('Display initialization error. Please check your exp_run parameter.'); end
HideCursor();


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
%%%% initializing MATLAB OpenGL shader API
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

% get display framerates
dparam.fps=Screen('FrameRate',winPtr);
%dparam.ifi=Screen('GetFlipInterval',winPtr);
%if dparam.fps==0, dparam.fps=1/dparam.ifi; end
dparam.ifi=1/dparam.fps;

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
nframe_fixation=round(dparam.initial_fixation_time*dparam.fps/sparam.waitframes);
nframe_cycle=round((sparam.cycle_duration-sparam.rest_duration)*dparam.fps/sparam.waitframes);
nframe_rest=round(sparam.rest_duration*dparam.fps/sparam.waitframes);
nframe_rotation=round((sparam.cycle_duration-sparam.rest_duration)*dparam.fps/(360/sparam.rotangle)/sparam.waitframes);
nframe_flicker=round(nframe_rotation/sparam.ncolors/4);
nframe_task=round(nframe_rotation/2);

%% initialize chackerboard parameters

% adjust size ratio considering full-screen effect
if dparam.fullscr
  % here, use width information alone for simplification
  ratio_wid=( winRect(3)-winRect(1) )/dparam.ScrWidth;
  %ratio_hei=( winRect(4)-winRect(2) )/dparam.ScrHeight;

  % min/max radius of annulus
  rmin=sparam.minRad*ratio_wid; % !!! degree, not pixel or cm !!!
  rmax=sparam.maxRad*ratio_wid;
else
  rmin=sparam.minRad;
  rmax=sparam.maxRad;
end

% number of patches
if strcmpi(sparam.mode,'ccw') || strcmpi(sparam.mode,'cw');
  sparam.npatches=sparam.nwedges*sparam.nrings;
else
  sparam.npatches=360/(sparam.width/sparam.nwedges);
end
if sparam.npatches>255 % 256-background color
  error(['sparam.npatches should be less than 256 since number of elements',...
        ' in a color lookup table is limited to 256 due to OpenGL limitation.',...
        ' check input variable.']);
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
% sparam.npatches = checker ID sparam.npatches
% Each patch ID will be associated with a CLUT color of the same ID
if strcmpi(sparam.mode,'ccw') || strcmpi(sparam.mode,'cw')

  sparam.npositions=360/sparam.rotangle;
  startangles=zeros(sparam.npositions,1);
  for nn=1:1:sparam.npositions, startangles(nn)=sparam.startangle+(nn-1)*sparam.rotangle; end

  checkerboard=pol_GenerateCheckerBoard1D(rmin,rmax,sparam.width,startangles,sparam.pix_per_deg,...
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

  checkerboard=ecc_GenerateCheckerBoard1D(ecclims,360,sparam.startangle,sparam.pix_per_deg,...
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
  tmp_checks=unique(checkerboard{1})';
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
    tmp_checks=unique(checkerboard{1})';
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
      tmp_checks=unique(checkerboard{nn})';
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

%% Make Checkerboard textures

checkertexture=cell(sparam.npositions,1);
for nn=1:1:sparam.npositions
  checkertexture{nn}=Screen('MakeTexture',winPtr,checkerboard{nn});
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initializing Color Lookup-Talbe (CLUT)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [note]
% all checker color/luminance flickering is realized by just flipping CLUT generated here
% to save memory and CPU power

% generate CLUT for each checkerboard in each position
% The procedure looks circuitous but I will do like that because the number of patches/wedges
% in exp/cont conditions are different over time especially when the annulus comes around the smallest/largest regions
CLUT=cell(sparam.npositions,1);
for nn=1:1:sparam.npositions
  CLUT{nn}=cell(1+true_npatches{nn},sparam.ncolors,2); % 1+npatches is base + task CLUTs, 2 is for compensating patterns
end

% generate base CLUT
for nn=1:1:sparam.npositions
  for cc=1:1:sparam.ncolors
    for pp=1:1:2 % compensating checkers

      % initialize, DrawTextureWithCLUT requires [256x4] color lookup table even when we do not use whole 256 colors
      % though DrawTextureWithCLUT does not support alpha transparency up to now...
      CLUT{nn}{1,cc,pp}=zeros(256,4);
      CLUT{nn}{1,cc,pp}(:,4)=1; % default alpha is 1 (no transparent)
      CLUT{nn}{1,cc,pp}(1,:)=[sparam.colors(1,:) 0]; % background LUT, default alpha is 0 (invisible);

      % the complex 'if' statements below are required to create valid checkerboards
      % with flexible sparam.startangle & sparam.phase parameters
      if pp==1
        for vv=patchids{nn}
          if mod(ceil((vv-(min(patchids{nn})-1))/true_nwedges{nn}),2)
            if mod(vv,2)
              CLUT{nn}{1,cc,pp}(vv+1,1:3)=sparam.colors(2*cc,:);
            else
              CLUT{nn}{1,cc,pp}(vv+1,1:3)=sparam.colors(2*cc+1,:);
            end
          else
            if mod(true_nwedges{nn},2)
              if mod(vv,2)
                CLUT{nn}{1,cc,pp}(vv+1,1:3)=sparam.colors(2*cc,:);
              else
                CLUT{nn}{1,cc,pp}(vv+1,1:3)=sparam.colors(2*cc+1,:);
              end
            else
              if mod(vv,2)
                CLUT{nn}{1,cc,pp}(vv+1,1:3)=sparam.colors(2*cc+1,:);
              else
                CLUT{nn}{1,cc,pp}(vv+1,1:3)=sparam.colors(2*cc,:);
              end
            end
          end
        end
      else
        for vv=patchids{nn}
          if mod(ceil((vv-(min(patchids{nn})-1))/true_nwedges{nn}),2)
            if mod(vv,2)
              CLUT{nn}{1,cc,pp}(vv+1,1:3)=sparam.colors(2*cc+1,:);
            else
              CLUT{nn}{1,cc,pp}(vv+1,1:3)=sparam.colors(2*cc,:);
            end
          else
            if mod(true_nwedges{nn},2)
              if mod(vv,2)
                CLUT{nn}{1,cc,pp}(vv+1,1:3)=sparam.colors(2*cc+1,:);
              else
                CLUT{nn}{1,cc,pp}(vv+1,1:3)=sparam.colors(2*cc,:);
              end
            else
              if mod(vv,2)
                CLUT{nn}{1,cc,pp}(vv+1,1:3)=sparam.colors(2*cc,:);
              else
                CLUT{nn}{1,cc,pp}(vv+1,1:3)=sparam.colors(2*cc+1,:);
              end
            end
          end
        end
      end

    end % for pp=1:1:2 % compensating checkers
  end % for cc=1:1:sparam.ncolors
end % for nn=1:1:sparam.npositions

% copy the original CLUT to task CLUTs for initialization
for nn1=1:1:sparam.npositions
  for nn2=2:1:true_npatches{nn1}+1 % = number of task positions
    for cc=1:1:sparam.ncolors
      for pp=1:1:2
        CLUT{nn1}{nn2,cc,pp}=CLUT{nn1}{1,cc,pp};
      end
    end
  end
end

% generate CLUT with task luminance
for nn1=1:1:sparam.npositions
  for nn2=1:1:true_npatches{nn1} % = number of task positions
    for cc=1:1:sparam.ncolors
      for pp=1:1:2 % compensating checkers
        CLUT{nn1}{nn2+1,cc,pp}(nn2+1,1:3)=round(0.7*CLUT{nn1}{nn2+1,cc,pp}(nn2+1,1:3));
      end
    end
  end
end

%% flip CLUT for ccw/cont
if strcmpi(sparam.mode,'ccw') || strcmpi(sparam.mode,'cont')
  tmp_CLUT=cell(sparam.npositions,1);
  for nn=1:1:sparam.npositions, tmp_CLUT{nn}=CLUT{sparam.npositions-(nn-1)}; end
  CLUT=tmp_CLUT;
  clear tmp_CLUT;
end


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
    colormap(CLUT{nn}{1,1,1}(1:true_npatches{nn}+1,1:3)./255);
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
%%%% and Preloading of functions
%%%% Matlab M-Files and especially MEX files do have some additional delay on first invokation
%%%% (Matlab needs to find and load them, compile or link them, they need to perform some
%%%% internal initialization). This can be significant, e.g., multiple hundred milliseconds.
%%%% For time critical studies, use each function once before your trial loop to "preload" the
%%%% function before first use.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% creating target and background images

%%%% Creating background %%%
patch_size=[30,30]; patch_num=[20,20];
%aperture_size=[500,500];

% calculate the central aperture size of the background image
edgeY=mod(dparam.ScrHeight,patch_num(1)); % delete exceeded region
p_height=round((dparam.ScrHeight-edgeY)/patch_num(1)); % height in pix of patch_height + interval-Y

edgeX=mod(dparam.ScrWidth,patch_num(2)); % delete exceeded region
p_width=round((dparam.ScrWidth-edgeX)/patch_num(2)); % width in pix of patch_width + interval-X

aperture_size(1)=2*( p_height*ceil(rmax*sparam.pix_per_deg/p_height) );
aperture_size(2)=2*( p_width*ceil(rmax*sparam.pix_per_deg/p_width) );

bgimg = CreateBackgroundImage([dparam.ScrHeight,dparam.ScrWidth],aperture_size,patch_size,sparam.bgcolor,sparam.color1,sparam.color2,sparam.fixcolor,patch_num,0,0,0);
background = Screen('MakeTexture',winPtr,bgimg{1});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Creating the central fixation, cross images (left/right)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fixlinew=2; % line width of the central fixation
fixlineh=8; % line height of the central fixation

% create fixation cross images
fix=CreateFixationImgCircular(4*sparam.fixsize,sparam.fixcolor,sparam.bgcolor,4*sparam.fixsize,0,0);
wait_fix=CreateFixationImgCircular(4*sparam.fixsize,[64,64,64],sparam.bgcolor,4*sparam.fixsize,0,0);
fix=imresize(fix,0.25);
wait_fix=imresize(wait_fix,0.25);

wait_fcircle=Screen('MakeTexture',winPtr,wait_fix);
fcircle=Screen('MakeTexture',winPtr,fix);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% image size adjusting to match the current display resolutions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if dparam.fullscr
  ratio_wid=( winRect(3)-winRect(1) )/dparam.ScrWidth;
  ratio_hei=( winRect(4)-winRect(2) )/dparam.ScrHeight;
  bgSize = [size(bgimg{1},2)*ratio_wid size(bgimg{1},1)*ratio_hei];
  stimSize=zeros(sparam.npositions,2);
  for nn=1:1:sparam.npositions, stimSize(nn,:) = [size(checkerboard{nn},2)*ratio_wid size(checkerboard{nn},1)*ratio_hei]; end
  fixSize = [2*sparam.fixsize*ratio_wid 2*sparam.fixsize*ratio_hei];
else
  bgSize = [dparam.ScrWidth dparam.ScrHeight];
  stimSize=zeros(sparam.npositions,2);
  for nn=1:1:sparam.npositions, stimSize(nn,:) = [size(checkerboard{nn},2) size(checkerboard{nn},1)]; end
  fixSize = [2*sparam.fixsize 2*sparam.fixsize];
end

% for some display modes in which one screen is splitted into two binocular displays
if strcmpi(dparam.ExpMode,'cross') || strcmpi(dparam.ExpMode,'parallel') || ...
   strcmpi(dparam.ExpMode,'topbottom') || strcmpi(dparam.ExpMode,'bottomtop')
  bgSize=bgSize./2;
  for nn=1:1:sparam.npositions, stimSize(nn,:) = stimSize(nn,:)./2; end
  fixSize=fixSize./2;
end

bgRect = [0 0 bgSize]; % used to display background images;
stimRect=zeros(sparam.npositions,4);
for nn=1:1:sparam.npositions, stimRect(nn,:)=[0 0 stimSize(nn,:)]; end
fixRect=[0 0 fixSize]; % used to display the central fixation point


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
%%%% wait the first trigger pulse from fMRI scanner or start with button pressing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% add time stamp (this also works to load add_event method in memory in advance of the actual displays)
event=event.add_event('Experiment Start',strcat([strrep(datestr(now,'yy/mm/dd'),'/',''),' ',datestr(now,'HH:mm:ss')]),[]);

% waiting for stimulus presentation
resps.wait_stimulus_presentation(dparam.start_method,dparam.custom_trigger);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initial Fixation Period
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vbl=Screen('Flip',winPtr,[],[],[],1); % the first flip
[event,the_experiment_start]=event.set_reference_time(GetSecs());
event=event.add_event('Initial Fixation',[]);

% wait for the initial fixation
for ff=1:1:nframe_fixation-1 % -1 is to omit the first frame period above, %-1 is for the first stimulus frame
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
      Screen('Flip',winPtr,vbl+dparam.initial_fixation_time+(cc-1)*sparam.cycle_duration+((ff-1)*sparam.waitframes-0.5)*dparam.ifi,[],[],1);
      [resps,event]=resps.check_responses(event);
    end
  end

  %% stimulus presentation loop
  for ff=1:1:nframe_cycle

    %% display the current frame
    for nn=1:1:nScr
      Screen('SelectStereoDrawBuffer',winPtr,nn-1);

      % background
      Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));

      % checkerboard with a specified CLUT, drawn by using OpenGL GLSL function
      if do_task(task_id) && ...
         ( ( task_flg(task_id)==1 && mod(ff,nframe_rotation)<=nframe_rotation/2 ) || ...
           ( task_flg(task_id)==2 && mod(ff,nframe_rotation)>nframe_rotation/2 ) )
        DrawTextureWithCLUT(winPtr,checkertexture{stim_pos_id},CLUT{stim_pos_id}{task_pos{stim_pos_id}(task_id)+1,color_id,compensate_id});
      else
        DrawTextureWithCLUT(winPtr,checkertexture{stim_pos_id},CLUT{stim_pos_id}{1,color_id,compensate_id});
      end

      % the central fixation oval
      Screen('DrawTexture',winPtr,fcircle,[],CenterRect(fixRect,winRect));
    end

    % flip the window
    Screen('DrawingFinished',winPtr);
    if strcmpi(sparam.mode,'cw') || strcmpi(sparam.mode,'cont')
      Screen('Flip',winPtr,vbl+dparam.initial_fixation_time+(cc-1)*sparam.cycle_duration+sparam.rest_duration+((ff-1)*sparam.waitframes-0.5)*dparam.ifi,[],[],1);
    else
      Screen('Flip',winPtr,vbl+dparam.initial_fixation_time+(cc-1)*sparam.cycle_duration+((ff-1)*sparam.waitframes-0.5)*dparam.ifi,[],[],1);
    end
    if do_task(task_id) && firsttask_flg==1, event=event.add_event('Luminance Task',[]); end

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
      Screen('Flip',winPtr,vbl+dparam.initial_fixation_time+(cc-1)*sparam.cycle_duration+(sparam.cycle_duration-sparam.rest_duration)+((ff-1)*sparam.waitframes-0.5)*dparam.ifi,[],[],1);
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
Screen('Flip',winPtr,vbl+dparam.initial_fixation_time+sparam.numRepeats*sparam.cycle_duration-0.5*dparam.ifi,[],[],1); % the first flip
event=event.add_event('Final Fixation',[]);

% wait for the initial fixation
for ff=1:1:nframe_fixation-1 % -1 is to omit the first frame period above, %-1 is for the first stimulus frame
  for nn=1:1:nScr
    Screen('SelectStereoDrawBuffer',winPtr,nn-1);
    Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
    Screen('DrawTexture',winPtr,fcircle,[],CenterRect(fixRect,winRect));
  end
  Screen('DrawingFinished',winPtr);
  Screen('Flip',winPtr,vbl+dparam.initial_fixation_time+sparam.numRepeats*sparam.cycle_duration+(ff*sparam.waitframes-0.5)*dparam.ifi,[],[],1);
  [resps,event]=resps.check_responses(event);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Experiment & scanner end here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

experimentDuration=GetSecs()-the_experiment_start+sparam.waitframes*dparam.ifi;
event=event.add_event('End',[],the_experiment_start-sparam.waitframes*dparam.ifi);
disp(' ');
disp(['Experiment Duration was: ', num2str(experimentDuration), ' secs']);
disp(' ');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Write data into file for post analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% saving the results
fprintf('saving data...');

% save data
savefname=[resultDir filesep() num2str(subjID) '_cretinotopy_' sparam.mode '_results_run_' num2str(acq,'%02d') '.mat'];
eval(sprintf('save %s subjID acq sparam dparam event gamma_table;',savefname));
disp('done.');

% calculate & display task performance
fprintf('calculating task accuracy...\n');
correct_event=cell(2,1); for ii=1:1:2, correct_event{ii}=sprintf('key%d',ii); end
[task.numTasks,task.numHits,task.numErrors,task.numResponses,task.RT]=event.calc_accuracy(correct_event);
event=event.get_event(); % convert an event logger object to a cell data structure
eval(sprintf('save -append %s event task;',savefname));
disp('done.');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Cleaning up MATLAB OpenGL shader API
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% just call DrawTextureWithCLUT without any input argument
DrawTextureWithCLUT();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Cleaning up the PTB screen, removing path to the subfunctions, and finalizing the script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Priority(0);
ShowCursor();
Screen('CloseAll');
rmpath(genpath(fullfile(rootDir,'..','Common')));
rmpath(fullfile(rootDir,'..','Generation'));
clear all; clear mex; clear global;
diary off;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Catch the errors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

catch lasterror
  % this "catch" section executes in case of an error in the "try" section
  % above.  Importantly, it closes the onscreen window if its open.
  Screen('CloseAll');
  ShowCursor;
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
  clear global; clear mex; clear all; close all;
  return
end % try..catch


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% that's it - we're done
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return;
% end % function cretinotopy
