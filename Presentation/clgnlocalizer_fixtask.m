function clgnlocalizer_fixtask(subjID,exp_mode,acq,displayfile,stimulusfile,gamma_table)

% Color/luminance-defined checkerboard stimulus for localizing LGN.
% function clgnlocalizer_fixtask(subjID,exp_mode,acq,:displayfile,:stimulusfile,:gamma_table)
% (: is optional)
%
% Color/Luminance-defined checkerboard stimulus for delineating LGN subject-by-subject.
% You can also use this script for checking BOLD signal and fMR-image quality.
%
% [note]
% Behavioral task of LGNlocalizer is to detect changes of luminance of the central
% fixation period, whereas tasks in cretinotopy and cretinotopy_mono etc is to detect
% changes of luminance of one of the patches in the checkerboard stimuli.
% The central fixation task will be suitable for naive participants as it can minimize
% eye movement of untrained observers.
%
% - Acquired fMRI data evoked by this stimulus will be utilized
%   to delineate retinotopic visual area borders (conventional retinotopy)
% - This script shoud be used with MATLAB Psychtoolbox version 3 or above.
% - Stimulus presentation timing are controled by vertical synch signals
%
%
% Created    : "2013-11-25 11:34:54 ban (ban.hiroshi@gmail.com)"
% Last Update: "2015-04-22 16:30:10 ban"
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
% exp_mode      : experiment mode acceptable in this script is only "LGN"
% acq           : acquisition number (design file number),
%                 a integer, such as 1, 2, 3, ...
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
%    as ./subjects/(subjID)/results/(date)/(subjID)_lgn_localizer_results_run_(run_num).mat
%
%
% [example]
% >> clgnlocalizer_fixtask('HB','localizer',1,'ret_display.m','ret_checker_stimulus_exp1.m')
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
% Programmed_by_Hiroshi_Ban___April_01_2011
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
% % ************************************************************
% % This_is_the_stimulus_parameter_file_for_retinotopy_Checker_experiment.
% % Please_change_the_parameters_below.
% % retinotopyDepthfMRI.m
% % Programmed_by_Hiroshi_Ban___April_01_2011
% % ************************************************************
%
% %%% stimulus parameters
% sparam.nwedges     = 15;   % number of wedge subdivisions along polar angle
% sparam.nrings      = 8;    % number of ring subdivisions along eccentricity angle
% sparam.width       = 140;  % wedge width in deg along polar angle
% sparam.phase       = 0;    % phase shift in deg
% sparam.startangle  = 110;  % presentation start angle in deg, from right-horizontal meridian, ccw
%
% sparam.maxRad      = 6.0;    % maximum radius of  annulus (degrees)
% sparam.minRad      = 0;      % minimum
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
% sparam.flickerrepetitions=2; % repetitions of flicker in a second
%
% %%% duration in msec for each cycle & repetitions
% sparam.cycle_duration=32000; % msec
% sparam.rest_duration =16000; % msec, rest (compensating pattern) after each cycle, stimulation = cycle_duration-eccrest
% sparam.numRepeats=6;
%
% %%% set number of frames to flip the screen
% % Here, I set the number as large as I can to minimize vertical cynching error.
% % the final 2 is for 2 times repetitions of flicker
% % Set 1 if you want to flip the display at each vertical sync, but not recommended due to much CPU power
% sparam.waitframes = 4;%Screen('FrameRate',0)*(sparam.cycle_duration/1000) / ((sparam.cycle_duration-sparam.rest_duration)/1000) / ( (size(sparam.colors,1)-1)*2 );
% %sparam.waitframes = 1;
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
% The central fixation point sometimes changes its color from white to gray.
% If you find this contrast difference, press any key.
% Response kes are difined in display file.
%
%
% [reference]
% for stmulus generation, see ../Generation & ../Common directories.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Check input variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear global; clear mex;
if nargin < 3, help(mfilename()); return; end

% check the aqcuisition number. up to 10 design files can be used
if acq<1, error('Acquistion number must be integer and greater than zero'); end
if ~exist(fullfile(pwd,'subjects',subjID),'dir'), error('can not find subj directory. check input variable.'); end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Add paths to the subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% add paths to the subfunctions
rootDir=fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(rootDir,'..','Common')));
addpath(fullfile(rootDir,'..','Generation'));

% set stimulus parameters
sparam.mode=exp_mode;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% For a log file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get date
today=strrep(datestr(now,'yy/mm/dd'),'/','');

% result directry & file
resultDir=fullfile(rootDir,'subjects',num2str(subjID),'results',today);
if ~exist(resultDir,'dir'), mkdir(resultDir); end

% record the output window
logfname=[resultDir filesep() num2str(subjID) '_lgn_localizer_' sparam.mode '_results_run_' num2str(acq,'%02d') '.log'];
diary(logfname);
warning off; %#ok warning('off','MATLAB:dispatcher:InexactCaseMatch');


%%%%% try & catch %%%%%
try


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Check the PTB version
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PTB_OK=CheckPTBversion(3); % check wether the PTB version is 3
if ~PTB_OK, error('Wrong version of Psychtoolbox is running. ImagesShowPTB requires PTB ver.3'); end

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
%%%% 1. Check input variables,
%%%% 2. Read a condition file,
%%%% 3. Check the validity of input variables,
%%%% 4. Store informascatio about directories & design file,
%%%% 5. Load design & condition file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check the number of nargin
if nargin <= 2
  error('takes at least 3 arguments: LGNlocalizer(subjID, exp_mode, acq, (:displayfile), (:stimulusfile), (:gamma_table))');
elseif nargin > 6
  error('takes at most 6 arguments: LGNlocalizer(subjID, exp_mode, acq, (:displayfile), (:stimulusfile), (:gamma_table))');
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
  if nargin >= 5
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
  dparam.initial_fixation_time=[16,16];

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
  sparam.nwedges     = 15;   % number of wedge subdivisions along polar angle
  sparam.nrings      = 8;    % number of ring subdivisions along eccentricity angle
  sparam.width       = 140;  % wedge width in deg along polar angle
  sparam.phase       = 0;    % phase shift in deg
  sparam.startangle  = 110;  % presentation start angle in deg, from right-horizontal meridian, ccw

  sparam.maxRad      = 6.5;  % maximum radius of  annulus (degrees)
  sparam.minRad      = 0;    % minimum

  sparam.colors      = [ 128, 128, 128; % number of colors for compensating flickering checkerboard
                         255,   0,   0; % the first row is background
                           0, 255,   0; % the second to end are patch colors
                         255, 255,   0;
                           0,   0, 255;
                         255,   0, 255;
                           0, 255, 255;
                         255, 255, 255;
                           0,   0,   0;
                         255, 128,   0;
                         128,   0, 255;];
  sparam.flickerrepetitions=2; % repetitions of flicker in a second

  %%% duration in msec for each cycle & repetitions
  sparam.cycle_duration=32000; % msec
  sparam.rest_duration =16000; % msec, rest after each cycle, stimulation = cycle_duration-eccrest
  sparam.numRepeats=6;

  %%% set number of frames to flip the screen
  % Here, I set the number as large as I can to minimize vertical cynching error.
  % the final 2 is for 2 times repetitions of flicker
  % Set 1 if you want to flip the display at each vertical sync, but not recommended due to much CPU power
  sparam.waitframes = Screen('FrameRate',0)*(sparam.cycle_duration/1000) / ((sparam.cycle_duration-sparam.rest_duration)/1000) / ( (size(sparam.colors,1)-1)*2 );
  %sparam.waitframes = 4;

  %%% fixation size & color
  sparam.fixsize=12; % radius in pixels
  sparam.fixcolor=[255,255,255];

  %%% background color
  sparam.bgcolor=sparam.colors(1,:); %[0,0,0];

  %%% RGB for background patches
  % 1x3 matrices
  sparam.color1=[255,255,255];
  sparam.color2=[0,0,0];

  %%% for converting degree to pixels
  sparam.pix_per_cm=57.1429;
  sparam.vdist=65;

end % if useStimulusFile


%% check varidity of parameters
fprintf('checking validity of stimulus generation/presentation parameters...');
if ~strcmpi(sparam.mode,'LGN')
  error('sparam.mode acceptable in this script is only "localizer". check input variables.');
end
disp('done.');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Displaying the presentation parameters you set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('The Presentation Parameters are as below.');
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
eval(sprintf('disp(''Fixation Time(sec)     : [%d,%d]'');',dparam.initial_fixation_time(1),dparam.initial_fixation_time(2)));
eval(sprintf('disp(''Cycle Duration(sec)    : %d'');',sparam.cycle_duration));
eval(sprintf('disp(''Rest  Duration(sec)    : %d'');',sparam.rest_duration));
eval(sprintf('disp(''Repetitions(cycles)    : %d'');',sparam.numRepeats));
eval(sprintf('disp(''Frame Flip(per VerSync): %d'');',sparam.waitframes));
eval(sprintf('disp(''Total Time (sec)       : %d'');',sum(dparam.initial_fixation_time)+sparam.numRepeats*sparam.cycle_duration));
disp('**************** Stimulus Type *****************');
eval(sprintf('disp(''Experiment Mode        : %s'');',sparam.mode));
disp('************ Response key settings *************');
eval(sprintf('disp(''Reponse Key #1         : %d = %s'');',dparam.Key1,KbName(dparam.Key1)));
eval(sprintf('disp(''Reponse Key #2         : %d = %s'');',dparam.Key2,KbName(dparam.Key2)));
disp('************************************************');
fprintf('\n');
disp('Please carefully check before proceeding.');
fprintf('\n');

Screen('Preference', 'SkipSyncTests', 1);


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

[user_answer,resps]=resps.wait_to_proceed();
if ~user_answer, diary off; return; end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initialization of Left & Right screens for binocular presenting/viewing mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[winPtr,winRect,nScr,dparam.fps,dparam.ifi,initDisplay_OK]=InitializePTBDisplays(dparam.ExpMode,sparam.bgcolor,0,[]);
if ~initDisplay_OK, error('Display initialization error. Please check your exp_run parameter.'); end
HideCursor();

%dparam.fps=60; % fps seems to be underestimated slightly. so I need to explicitly set it just in case


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
% sparam.width, sparam.phase, and sparam.startangle are used in deg formats

% number of checkerboard color
sparam.ncolors=(size(sparam.colors,1)-1)/2;

% sec to number of frames
nframe_fixation=round(dparam.initial_fixation_time*dparam.fps/sparam.waitframes);
nframe_cycle=round((sparam.cycle_duration-sparam.rest_duration)*dparam.fps/sparam.waitframes);
nframe_rest=round(sparam.rest_duration*dparam.fps/sparam.waitframes);

% !!!NOTICE!!!
% Two lines below are from cretinotopy.m
% nframe_rotation=round((sparam.cycle_duration-sparam.rest_duration)*dparam.fps/(360/sparam.rotangle)/sparam.waitframes);
% nframe_flicker=round(nframe_rotation/sparam.ncolors/4);
% nframe_flicker should be adjusted to match with these parameters.
nframe_flicker=round(round((60-0)*dparam.fps/(360/12)/sparam.waitframes)/sparam.ncolors/4); %60,0,30 are from CCW/CW parameters.

nframe_task=round(18/sparam.waitframes); % just arbitral, you can change as you like

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
sparam.npatches=sparam.nwedges*sparam.nrings;
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
checkerboard=pol_GenerateCheckerBoard1D(rmin,rmax,sparam.width,sparam.startangle,sparam.pix_per_deg,...
                                        sparam.nwedges,sparam.nrings,sparam.phase);
checkerboard=checkerboard{1};

%% update number of patches and number of wedges, taking into an account of checkerboard phase shift

% here, alll parameters are generated for each checkerboard
% This looks circuitous, duplicating procedures, and it consumes more CPU and memory.
% 'if' statements may be better.
% However, to decrease the number of 'if' statement after starting stimulus
% presentation as much as I can, I will do adopt this circuitous procedures.

% for hrf, the number of patches/wedges are same over time
tmp_checks=unique(checkerboard)';
true_npatches=numel(tmp_checks)-1; % -1 is to omit background id
true_nwedges=true_npatches/sparam.nrings;
patchids=tmp_checks;
patchids=patchids(2:end); % omit background id
clear tmp_checks;

%% Make Checkerboard textures
checkertexture{1}=Screen('MakeTexture',winPtr,checkerboard); % a checkerboard in the left visual hemifield (right LGN localizer)
checkertexture{2}=Screen('MakeTexture',winPtr,flipdim(checkerboard,2)); % a checkerboard in the right visual hemifield (left LGN localizer)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initializing Color Lookup-Talbe (CLUT)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [note]
% all checker color/luminance flickering is realized by just flipping CLUT generated here
% to save memory and CPU power

% generate CLUT for each checkerboard in each position
CLUT=cell(sparam.ncolors,2); % 2 is for compensating patterns

% generate base CLUT
for cc=1:1:sparam.ncolors
  for pp=1:1:2 % compensating checkers

    % initialize, DrawTextureWithCLUT requires [256x4] color lookup table even when we do not use whole 256 colors
    % though DrawTextureWithCLUT does not support alpha transparency up to now...
    CLUT{cc,pp}=zeros(256,4);
    CLUT{cc,pp}(:,4)=1; % default alpha is 1 (no transparent)
    CLUT{cc,pp}(1,:)=[sparam.colors(1,:) 0]; % background LUT, default alpha is 0 (invisible);

    % the complex 'if' statements below are required to create valid checkerboards
    % with flexible sparam.startangle & sparam.phase parameters
    if pp==1
      for vv=patchids
        if mod(ceil((vv-(min(patchids)-1))/true_nwedges),2)
          if mod(vv,2)
            CLUT{cc,pp}(vv+1,1:3)=sparam.colors(2*cc,:);
          else
            CLUT{cc,pp}(vv+1,1:3)=sparam.colors(2*cc+1,:);
          end
        else
          if mod(true_nwedges,2)
            if mod(vv,2)
              CLUT{cc,pp}(vv+1,1:3)=sparam.colors(2*cc,:);
            else
              CLUT{cc,pp}(vv+1,1:3)=sparam.colors(2*cc+1,:);
            end
          else
            if mod(vv,2)
              CLUT{cc,pp}(vv+1,1:3)=sparam.colors(2*cc+1,:);
            else
              CLUT{cc,pp}(vv+1,1:3)=sparam.colors(2*cc,:);
            end
          end
        end
      end
    else
      for vv=patchids
        if mod(ceil((vv-(min(patchids)-1))/true_nwedges),2)
          if mod(vv,2)
            CLUT{cc,pp}(vv+1,1:3)=sparam.colors(2*cc+1,:);
          else
            CLUT{cc,pp}(vv+1,1:3)=sparam.colors(2*cc,:);
          end
        else
          if mod(true_nwedges,2)
            if mod(vv,2)
              CLUT{cc,pp}(vv+1,1:3)=sparam.colors(2*cc+1,:);
            else
              CLUT{cc,pp}(vv+1,1:3)=sparam.colors(2*cc,:);
            end
          else
            if mod(vv,2)
              CLUT{cc,pp}(vv+1,1:3)=sparam.colors(2*cc,:);
            else
              CLUT{cc,pp}(vv+1,1:3)=sparam.colors(2*cc+1,:);
            end
          end
        end
      end
    end

  end % for pp=1:1:2 % compensating checkers
end % for cc=1:1:sparam.ncolors


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Debug codes
%%%% just to save each images as *.png format files.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%% DEBUG codes start here
if strfind(upper(subjID),'DEBUG')

  % just to get stimulus figures
  Screen('CloseAll');
  figure; hold on;
  imfig=imagesc(flipdim(checkerboard,1),[0,true_npatches]);
  axis off; axis square;
  colormap(CLUT{1,1}(1:true_npatches+1,1:3)./255);
  fname=sprintf('checkerboard_%s.png',sparam.mode);
  save_dir=fullfile(pwd,'images');
  if ~exist(save_dir,'dir'), mkdir(save_dir); end
  saveas(imfig,[save_dir,filesep(),fname,'.png'],'png');
  save([save_dir,filesep(),sprintf('checkerboard_%s.mat',sparam.mode)],'checkerboard','sparam','dparam','CLUT');
  keyboard;

end % if strfind(upper(subjID),'DEBUG')
% %%%%%% DEBUG code ends here


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Generating fixation detection task parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% set task variables
% flag to decide whether presenting fixation task
totalframes=sum(nframe_fixation)+(nframe_cycle+nframe_rest)*sparam.numRepeats;
num_tasks=round(totalframes/nframe_task);
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
%%%% Initializing checkerboard management parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% checkerboard color id
color_id=1;

% checkerboard compensating color id
compensate_id=1;


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

% create fixation cross images, first larger fixations are generated, then they are antialiased
% This is required to present a beautiful circle
fix=CreateFixationImgCircular(4*sparam.fixsize,sparam.fixcolor,sparam.bgcolor,4*sparam.fixsize,0,0);
dark_fix=CreateFixationImgCircular(4*sparam.fixsize,[64,64,64],sparam.bgcolor,4*sparam.fixsize,0,0);
task_fix=CreateFixationImgCircular(4*sparam.fixsize,[128,0,0],sparam.bgcolor,4*sparam.fixsize,0,0);

fix=imresize(fix,0.25);
dark_fix=imresize(dark_fix,0.25);

fcircle=cell(2,1); % 1 is for default fixation, 2 is for darker fixation (luminance detection task)
fcircle{1}=Screen('MakeTexture',winPtr,fix);
fcircle{2}=Screen('MakeTexture',winPtr,task_fix);
fcircle{3}=Screen('MakeTexture',winPtr,dark_fix);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Image size adjusting to match the current display resolutions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if dparam.fullscr
  ratio_wid=( winRect(3)-winRect(1) )/dparam.ScrWidth;
  ratio_hei=( winRect(4)-winRect(2) )/dparam.ScrHeight;
  bgSize = [size(bgimg{1},2)*ratio_wid size(bgimg{1},1)*ratio_hei];
  stimSize = [size(checkerboard,2)*ratio_wid size(checkerboard,1)*ratio_hei];
  fixSize = [2*sparam.fixsize*ratio_wid 2*sparam.fixsize*ratio_hei];
else
  bgSize = [dparam.ScrWidth dparam.ScrHeight];
  stimSize = [size(checkerboard,2) size(checkerboard,1)];
  fixSize = [2*sparam.fixsize 2*sparam.fixsize];
end

% for some display modes in which one screen is splitted into two binocular displays
if strcmpi(dparam.ExpMode,'cross') || strcmpi(dparam.ExpMode,'parallel') || ...
   strcmpi(dparam.ExpMode,'topbottom') || strcmpi(dparam.ExpMode,'bottomtop')
  bgSize=bgSize./2;
  stimSize = stimSize./2;
  fixSize=fixSize./2;
end

bgRect = [0 0 bgSize]; % used to display background images;
stimRect=[0 0 stimSize];
fixRect=[0 0 fixSize]; % used to display the central fixation point


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
  Screen('DrawTexture',winPtr,fcircle{3},[],CenterRect(fixRect,winRect));
end
Screen('DrawingFinished',winPtr);
Screen('Flip', winPtr,[],[],[],1);

% prepare the next frame for the initial fixation period
for nn=1:1:nScr
  Screen('SelectStereoDrawBuffer',winPtr,nn-1);
  Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
  Screen('DrawTexture',winPtr,fcircle{1},[],CenterRect(fixRect,winRect)); % fcircle{1} is valis as no task in the first period
end
Screen('DrawingFinished',winPtr);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Wait for the first trigger pulse from fMRI scanner or start with button pressing
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
cur_frames=cur_frames+1;

% wait for the initial fixation
for ff=1:1:nframe_fixation-1 % -1 is to omit the first frame period above
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

for cc=1:1:sparam.numRepeats
  % NOTE: as this event will be logged before the first flip in the trial,
  % it will be faster by sparam.waitframes in the record of the event. Please be careful.
  event=event.add_event(sprintf('Cycle: %d',cc),[],the_experiment_start-sparam.waitframes*dparam.ifi);

  %% stimulus presentation loop
  for ff=1:1:nframe_cycle+nframe_rest

    %% display the current frame
    for nn=1:1:nScr
      Screen('SelectStereoDrawBuffer',winPtr,nn-1);

      % background
      Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));

      % checkerboard with a specified CLUT, drawn by using OpenGL GLSL function
      if ff<=nframe_cycle
        DrawTextureWithCLUT(winPtr,checkertexture{1},CLUT{color_id,compensate_id},[],CenterRect(stimRect,winRect));
      else
        DrawTextureWithCLUT(winPtr,checkertexture{2},CLUT{color_id,compensate_id},[],CenterRect(stimRect,winRect));
      end

      % draw the central fixation with luminance detection task
      Screen('DrawTexture',winPtr,fcircle{task_flg(cur_frames)},[],CenterRect(fixRect,winRect));
    end

    % flip the window
    Screen('DrawingFinished',winPtr);
    Screen('Flip',winPtr,vbl+dparam.initial_fixation_time(1)+(cc-1)*sparam.cycle_duration+((ff-1)*sparam.waitframes-0.5)*dparam.ifi,[],[],1);
    cur_frames=cur_frames+1;

    % update task
    if task_flg(cur_frames)==2 && task_flg(cur_frames-1)==1, event=event.add_event('Luminance Task',[]); end

    %% exit from the loop if the final frame is displayed

    if ff==nframe_cycle+nframe_rest && cc==sparam.numRepeats, continue; end

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

  end % for ff=1:1:cycle_frames+nframe_rest

end % for cc=1:1:sparam.numRepeats


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Final Fixation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for nn=1:1:nScr
  Screen('SelectStereoDrawBuffer',winPtr,nn-1);
  Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
  Screen('DrawTexture',winPtr,fcircle{task_flg(cur_frames)},[],CenterRect(fixRect,winRect));
end
Screen('DrawingFinished',winPtr);
Screen('Flip',winPtr,vbl+dparam.initial_fixation_time(1)+sparam.numRepeats*sparam.cycle_duration-0.5*dparam.ifi,[],[],1); % the first flip;
cur_frames=cur_frames+1;
event=event.add_event('Final Fixation',[]);

% wait for the initial fixation
for ff=1:1:nframe_fixation-1 % -1 is to omit the first frame period above
  for nn=1:1:nScr
    Screen('SelectStereoDrawBuffer',winPtr,nn-1);
    Screen('DrawTexture',winPtr,background,[],CenterRect(bgRect,winRect));
    Screen('DrawTexture',winPtr,fcircle{task_flg(cur_frames)},[],CenterRect(fixRect,winRect));
  end
  Screen('DrawingFinished',winPtr);
  Screen('Flip',winPtr,vbl+dparam.initial_fixation_time(1)+sparam.numRepeats*sparam.cycle_duration+(ff*sparam.waitframes-0.5)*dparam.ifi,[],[],1);
  cur_frames=cur_frames+1;

  % update task
  if task_flg(cur_frames-1)==2 && task_flg(cur_frames-2)==1, event=event.add_event('Luminance Task',[]); end

  [resps,event]=resps.check_responses(event);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Experiment & scanner end here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

experimentDuration=GetSecs()-the_experiment_start+sparam.waitframes*dparam.ifi;
event=event.add_event('End',[],the_experiment_start-sparam.waitframes*dparam.ifi);
disp(' ');
fprintf('Experiment Completed: %.2f/%.2f secs\n',experimentDuration,...
        sum(dparam.initial_fixation_time)+sparam.numRepeats*sparam.cycle_duration);
disp(' ');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Write data into file for post analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% saving the results
fprintf('saving data...');

% save data
savefname=[resultDir filesep() num2str(subjID) '_lgn_localizer_' sparam.mode '_results_run_' num2str(acq,'%02d') '.mat'];
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

Screen('CloseAll');
ShowCursor();
Priority(0);
GammaResetPTB(1.0);
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
%%%%% That's it - we're done
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return;
% end % function LGNlocalizer
