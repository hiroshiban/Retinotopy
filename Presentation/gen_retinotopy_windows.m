function stim_windows=gen_retinotopy_windows(subjID,exp_mode,acq,displayfile,stimulusfile,overwrite_pix_per_deg,TR)

% Generates retinotopy stimulus (polar/eccentricity) windows for pRF (population receptive field) analysis.
% function stim_windows=gen_retinotopy_windows(subjID, exp_mode, acq, :displayfile, ...
%                                           :stimulusfile, :overwrite_pix_per_deg, :TR)
% (: is optional)
%
% This function enerates stimulus windows corresponding to the color/luminance-defined
% checkerboard retinotopy stimulus. The generated stimulus windows will be utilized to
% generate pRF (population receptive field) model.
%
%
% Created    : "2011-12-03 19:01:09 ban"
% Last Update: "2016-10-09 18:35:36 ban"
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
%                 the same display file for cretinotopy is acceptable
% stimulusfile  : (optional) stimulus condition file,
%                 *.m file, such as 'RetDepth_stimulus_exp1.m'
%                 the same stimulus file for cretinotopy is acceptable
% overwrite_pix_per_deg : pixels-per-deg value to overwrite the sparam.pix_per_deg
%                 if not specified, sparam.pix_per_deg is used to reconstruct
%                 stim_windows.
%                 This is useful to reconstruct stim_windows with less memory space
%                 1/pix_per_deg = spatial resolution of the generated visual field,
%                 e.g. when pix_per_deg=20, then, 1 pixel = 0.05 deg.
%                 empty (use sparam.pix_per_deg) by default
% TR            : TR used in fMRI scans, in sec, 2 by default
%
% !!! NOTICE !!!!
% displayfile & stimulusfile should be located at
% ./subjects/(subjID)/
% as ./subjects/(subjID)/*_display_fmri.m
%    ./subjects/(subjID)/*_stimuli.m
%
%
% [output variables]
% stim_windows : stimulus windows (logical images) at each TR, [row,col,TRs] matrix
%
%
% [output files]
% 1. result file
%    stored ./subjects/(subjID)/pRF/(date)
%    as ./subjects/(subjID)/pRF/(date)/(subjID)_stimulus_window_(exp_mode)_run_XX.mat
%
%
% [example]
% >> stim_windows=gen_retinotopy_windows('HB','ccw',1,'retinotopy_display.m','c_pol.m',10,2);
%
% [About displayfile]
% The contents of the displayfile are as below.
% (The file includs 6 lines of headers and following display parameters)
%
% (an example of the displayfile)
%
% ************************************************************
% This_is_the_display_file_for_gen_cretinotopy_windows
% Please_change_the_parameters_below.
% retinotopyDepthfMRI.m
% Programmed_by_Hiroshi_Ban___Dec_03_2011
% ************************************************************
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
% % stimulus display durations in msec
%
% %%% fixation period in msec before/after presenting the target stimuli, integer (16)
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
% This_is_the_stimulus_parameter_file_for_gen_cretinotopy_windows
% Please_change_the_parameters_below.
% retinotopyDepthfMRI.m
% Programmed_by_Hiroshi_Ban___Dec_03_2011
%************************************************************
%
% % "sparam" means "stimulus generation parameters"
%
% %%% stimulus parameters
% sparam.nwedges     = 4;     % number of wedge subdivisions along polar angle
% sparam.nrings      = 4;     % number of ring subdivisions along eccentricity angle
% sparam.width       = 48;    % wedge width in deg along polar angle
% sparam.rotangle    = 12;    % rotation angle in deg
% sparam.startangle  = -sparam.width/2;     % presentation start angle in deg, from right-horizontal meridian, ccw
%
% sparam.maxRad      = 8;    % maximum radius of  annulus (degrees)
% sparam.minRad      = 0;    % minumum
%
% %%% duration in msec for each cycle & repetitions
% sparam.cycle_duration=60000; % msec
% sparam.rest_duration =0; % msec, rest after each cycle, stimulation = cycle_duration-eccrest
% sparam.numRepeats=6;
%
% %%% fixation size & color
% sparam.fixsize=12; % radius in pixels
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

clear global; clear mex;

% add paths to the subfunctions
rootDir=fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(rootDir,'..','Common')));
addpath(fullfile(rootDir,'..','Generation'));

% set stimulus parameters
sparam.mode=exp_mode;

% difine constant variables
display_flg=1;
pause_dur=0.2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% For a log file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get date
today=strrep(datestr(now,'yy/mm/dd'),'/','');

% result directry & file
resultDir=fullfile(rootDir,'subjects',num2str(subjID),'pRF',today);
if ~exist(resultDir,'dir'), mkdir(resultDir); end

% record the output window
logfname=[resultDir filesep() num2str(subjID) '_stimulus_window_' sparam.mode '_run_' num2str(acq,'%02d'), '.log'];
diary(logfname);
warning off; %#ok warning('off','MATLAB:dispatcher:InexactCaseMatch');


%%%%% try & catch %%%%%
try


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% 1. Check input variables,
%%%% 2. Read a condition file,
%%%% 3. Check the validity of input variables,
%%%% 4. Store informascatio about directories & design file,
%%%% 5. Load design & condition file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check the number of nargin
if nargin < 3
  error('takes at least 3 arguments: gen_retinotopy_windows(subjID,exp_mode,acq,(:displayfile),(:stimulusfile),(:overwrite_pix_per_deg),(:TR))');
elseif nargin > 7
  error('takes at most 7 arguments: gen_retinotopy_windows(subjID,exp_mode,acq,(:displayfile),(:stimulusfile),(:overwrite_pix_per_deg),(:TR))');
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

if nargin<6 || isempty(overwrite_pix_per_deg), overwrite_pix_per_deg=[]; end
if nargin<7 || isempty(TR), TR=2; end

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
  dparam.ScrHeight=1200;
  dparam.ScrWidth=1920;
  dparam.initial_fixation_time=16;

end % if useDisplayFile

% set stimulus parameters
sparam.mode=exp_mode;

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
  sparam.width          = 48;
  sparam.rotangle       = 12;
  sparam.startangle     = -sparam.width/2;

  sparam.maxRad         = 8;
  sparam.minRad         = 0;

  %%% duration in msec for each cycle & repetitions
  sparam.cycle_duration = 60;
  sparam.rest_duration  = 0;
  sparam.numRepeats     = 6;

  %%% fixation size & color
  sparam.fixsize        = 12;

  %%% for creating disparity & shadow
  sparam.pix_per_cm     =57.1429;
  sparam.vdist          =65;

end % if useStimulusFile


%% check varidity of parameters
disp('checking validity of stimulus generation/presentation parameters...');
if ~strcmpi(sparam.mode,'ccw') && ~strcmpi(sparam.mode,'cw') && ~strcmpi(sparam.mode,'exp') && ~strcmpi(sparam.mode,'cont')
  error('sparam.mode should be one of "ccw", "cw", "exp", and "cont". check input variables.');
end
if mod(360,sparam.rotangle), error('mod(360,sparam.rotangle) should be 0. check input variables.'); end
if mod(sparam.width,sparam.rotangle), error('mod(sparam.width,sparam.rotangle) should be 0. check input variables.'); end
disp('done.');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Displaying the presentation parameters you set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('The Presentation Parameters are as below.');
fprintf('\n');
disp('************************************************');
disp('*************** Script, Subject ****************');
eval(sprintf('disp(''Running Script Name    : %s'');',mfilename()));
eval(sprintf('disp(''Subject ID             : %s'');',subjID));
eval(sprintf('disp(''Acquisition Number     : %d'');',acq));
disp('*************** Screen Settings ****************');
eval(sprintf('disp(''Screen Height          : %d'');',dparam.ScrHeight));
eval(sprintf('disp(''Screen Width           : %d'');',dparam.ScrWidth));
disp('*********** Stimulation periods etc. ***********');
eval(sprintf('disp(''Fixation Time(sec)     : %d'');',dparam.initial_fixation_time));
eval(sprintf('disp(''Cycle Duration(sec)    : %d'');',sparam.cycle_duration));
eval(sprintf('disp(''Rest  Duration(sec)    : %d'');',sparam.rest_duration));
eval(sprintf('disp(''Repetitions(cycles)    : %d'');',sparam.numRepeats));
disp('******** The number of experiment, imgs ********');
eval(sprintf('disp(''Experiment Mode        : %s'');',sparam.mode));
disp('************************************************');
fprintf('\n');
disp('Please carefully check before proceeding.');
fprintf('\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initializing variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Initializing stimulus generation variables...');

%% unit conversion

% cm per pix
sparam.cm_per_pix=1/sparam.pix_per_cm;

% pixles per degree
sparam.pix_per_deg=round( 1/( 180*atan(sparam.cm_per_pix/sparam.vdist)/pi ) );

% overwrite pixels per degree if overwrite_pix_per_deg is given
if ~isempty(overwrite_pix_per_deg)
  % as fixation point is defind by pixels, we need to first resize it based on overwrite_pix_per_deg
  sparam.fixsize=round(sparam.fixsize*overwrite_pix_per_deg/sparam.pix_per_deg);
  sparam.pix_per_deg=overwrite_pix_per_deg;
end

% convert sec to number of TRs

sparam.TR=TR; % TR=2000ms by default

nTR_fixation=round(dparam.initial_fixation_time/sparam.TR);
nTR_cycle=round((sparam.cycle_duration-sparam.rest_duration)/sparam.TR);
nTR_rest=round(sparam.rest_duration/sparam.TR);
nTR_rotation=round((sparam.cycle_duration-sparam.rest_duration)/(360/sparam.rotangle)/sparam.TR);
nTR_whole=round((dparam.initial_fixation_time*2+sparam.cycle_duration*sparam.numRepeats)/sparam.TR);

%% initialize chackerboard parameters
rmin=sparam.minRad+sparam.fixsize/sparam.pix_per_deg; % omit the central fixation point
rmax=sparam.maxRad;

% variable to store the current rotation/disparity id
stim_pos_id=1;

disp('done.');
disp(' ');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Generating checkerboard patterns
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('generating stimulus patterns...');

%% generate checkerboard patterns
if strcmpi(sparam.mode,'ccw') || strcmpi(sparam.mode,'cw')

  sparam.npositions=360/sparam.rotangle;
  startangles=zeros(sparam.npositions,1);
  for nn=1:1:sparam.npositions, startangles(nn)=sparam.startangle+(nn-1)*sparam.rotangle; end

  [dummy,checkerboard]=pol_GenerateCheckerBoard1D(rmin,rmax,sparam.width,startangles,sparam.pix_per_deg,1,1,0);
  clear dummy;

elseif strcmpi(sparam.mode,'exp') || strcmpi(sparam.mode,'cont')

  sparam.npositions=(sparam.cycle_duration-sparam.rest_duration)/(sparam.cycle_duration/(360/sparam.rotangle));
  eccedge=(rmax-rmin)/( sparam.npositions-1 );
  eccwidth=eccedge*(sparam.width/sparam.rotangle);

  %% !!! NOTICE !!!
  % update some parameters here for 'exp' or 'cont' mode
  nTR_rotation=round((sparam.cycle_duration-sparam.rest_duration)/sparam.npositions/sparam.TR);

  % get annuli's min/max lims
  ecclims=zeros(sparam.npositions,3);
  for nn=1:1:sparam.npositions %1:1:sparam.npositions
    minlim=rmin+(nn-1)*eccedge-eccwidth/2;
    if minlim<rmin, minlim=rmin; end
    maxlim=rmin+(nn-1)*eccedge+eccwidth/2;
    if maxlim>rmax, maxlim=rmax; end
    ecclims(nn,:)=[minlim,maxlim,eccwidth];
  end

  [dummy,checkerboard]=ecc_GenerateCheckerBoard1D(ecclims,360,sparam.startangle,sparam.pix_per_deg,1,1,0);
  clear dummy;

end % if strcmpi(sparam.mode,'ccw') || strcmpi(sparam.mode,'cw')

%% flip all data for ccw/cont
if strcmpi(sparam.mode,'ccw') || strcmpi(sparam.mode,'cont')
  tmp_checkerboard=cell(sparam.npositions,1);
  for nn=1:1:sparam.npositions, tmp_checkerboard{nn}=checkerboard{sparam.npositions-(nn-1)}; end
  checkerboard=tmp_checkerboard;
  clear tmp_checkerboard;
end

%% convert logical data to double format to process gaussian filter at the later stage
%for nn=1:1:sparam.npositions, checkerboard{nn}=double(checkerboard{nn}); end

%% initialize stimulus windows
%stim_windows=zeros([round(size(checkerboard{1})),nTR_whole]);
stim_windows=false([round(size(checkerboard{1})),nTR_whole]);
TRcounter=1; % TR counter

disp('done.');
disp(' ');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initilize figure window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if display_flg
  %scrsz = get(0,'ScreenSize');
  figure('Name',sprintf('stimulus window: %s',sparam.mode),'NumberTitle','off');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initial/Final Fixation Period
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('storing stimulus patterns...');
fprintf('Frames(TR):\n');

% generate images in the fixation periods
counterend=TRcounter+nTR_fixation-1;
for ff=TRcounter:1:counterend
  stim_windows(:,:,ff)=0;
  TRcounter=TRcounter+1;
  fprintf('%03d ',ff); if mod(ff,20)==0, fprintf('\n'); end
  if display_flg
    imagesc(stim_windows(:,:,ff),[0,1]); title(sprintf('Frame(TR): %03d',ff)); colormap(gray); axis equal; axis off; drawnow; pause(pause_dur);
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% The Trial Loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for cc=1:1:sparam.numRepeats

  %% rest perioed
  if strcmpi(sparam.mode,'cw') || strcmpi(sparam.mode,'cont')
    if nTR_rest~=0
      counterend=TRcounter+nTR_rest-1;
      for ff=TRcounter:1:counterend
        stim_windows(:,:,ff)=0;
        TRcounter=TRcounter+1;
        fprintf('%03d ',ff); if mod(ff,20)==0, fprintf('\n'); end
        if display_flg
          imagesc(stim_windows(:,:,ff),[0,1]); title(sprintf('Frame(TR): %03d',ff)); colormap(gray); axis equal; axis off; drawnow; pause(pause_dur);
        end
      end
    end
  end

  %% stimulus presentation loop
  counterend=TRcounter+nTR_cycle-1;
  for ff=TRcounter:1:counterend

    % set the current checkerboard
    stim_windows(:,:,ff)=checkerboard{stim_pos_id};

    TRcounter=TRcounter+1;
    fprintf('%03d ',ff); if mod(ff,20)==0, fprintf('\n'); end
    if display_flg
      imagesc(stim_windows(:,:,ff),[0,1]); title(sprintf('Frame(TR): %03d',ff)); colormap(gray); axis equal; axis off; drawnow; pause(pause_dur);
    end

    % exit from the loop if the final frame is displayed
    if ff==counterend && cc==sparam.numRepeats, continue; end

    % stimulus position id for the next presentation
    if strcmpi(sparam.mode,'cw') || strcmpi(sparam.mode,'cont')
      if ~mod(ff-nTR_rest*cc,nTR_rotation)
        stim_pos_id=stim_pos_id+1;
        if stim_pos_id>sparam.npositions, stim_pos_id=1; end
      end
    else
      if ~mod(ff-nTR_rest*(cc-1),nTR_rotation)
        stim_pos_id=stim_pos_id+1;
        if stim_pos_id>sparam.npositions, stim_pos_id=1; end
      end
    end

  end % for ff=1:1:cycle_frames

  %% rest perioed
  if strcmpi(sparam.mode,'ccw') || strcmpi(sparam.mode,'exp')
    if nTR_rest~=0
      counterend=TRcounter+nTR_rest-1;
      for ff=TRcounter:1:counterend
        stim_windows(:,:,ff)=0;
        TRcounter=TRcounter+1;
        fprintf('%03d ',ff); if mod(ff,20)==0, fprintf('\n'); end
        if display_flg
          imagesc(stim_windows(:,:,ff),[0,1]); title(sprintf('Frame(TR): %03d',ff)); colormap(gray); axis equal; axis off; drawnow; pause(pause_dur);
        end
      end
    end
  end

end % for cc=1:1:sparam.numRepeats


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Final Fixation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% generate images in the fixation periods
counterend=TRcounter+nTR_fixation-1;
for ff=TRcounter:1:counterend
  stim_windows(:,:,ff)=0;
  TRcounter=TRcounter+1;
  fprintf('%03d ',ff); if mod(ff,20)==0, fprintf('\n'); end
  if display_flg
    imagesc(stim_windows(:,:,ff),[0,1]); title(sprintf('Frame(TR): %03d',ff)); colormap(gray); axis equal; axis off; drawnow; pause(pause_dur);
  end
end

disp('done.');
disp(' ');
close all;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Write data into file for post analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% saving the results
fprintf('saving data...');
savefname=[resultDir filesep() num2str(subjID) '_stimulus_window_' sparam.mode '_run_' num2str(acq,'%02d'), '.mat'];
eval(sprintf('save %s subjID sparam dparam stim_windows;',savefname));
disp('done.');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Remove paths to the subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
  tmp=lasterror; %#ok
  diary off;
  fprintf(['\nErrror detected and the program was terminated.\n',...
           'To check error(s), please type ''tmp''.\n',...
           'Please save the current variables now if you need.\n',...
           'Then, quit by ''dbquit''\n']);
  keyboard;
  rmpath(genpath(fullfile(rootDir,'..','Common')));
  rmpath(fullfile(rootDir,'..','Generation'));
  clear global; clear mex; clear all; close all;
  return
end % try..catch


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% That's it - we're done
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return;
% end % function gen_retinotopy_window
