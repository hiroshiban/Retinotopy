function stim_windows=gen_retinotopy_windows(subjID,exp_mode,acq,displayfile,stimulusfile,overwrite_pix_per_deg,TR)

% Generates retinotopy stimulus (polar/eccentricity) windows for pRF (population receptive field) analysis.
% function stim_windows=gen_retinotopy_windows(subjID,exp_mode,acq,:displayfile,:stimulusfile,:overwrite_pix_per_deg,:TR)
% (: is optional)
%
% - This function generates stimulus windows corresponding to the color/luminance-defined
%   checkerboard retinotopy stimuli (rotating wedge and expanding/contracting annulus).
%   The generated stimulus windows can be used to generate pRF (population receptive field) models.
%
%   references: 1. Population receptive field estimates in human visual cortex.
%                  Dumoulin, S.O. and Wandell, B.A. (2008). Neuroimage, 39(2), 647-660.
%               2. Borders of multiple visual areas in humans revealed by functional magnetic resonance imaging.
%                  Sereno MI, Dale AM, Reppas JB, Kwong KK, Belliveau JW, Brady TJ, Rosen BR, Tootell RB. (1995).
%                  Science 268(5212), 889-893.
%               3. fMRI of human visual cortex.
%                  Engel SA, Rumelhart DE, Wandell BA, Lee AT, Glover GH, Chichilnisky EJ, Shadlen MN. (1994).
%                  Nature, 369(6481), 525.
%               4. Visual field maps in human cortex.
%                  Wandell BA, Dumoulin SO, Brewer AA. (2007). Neuron, 56(2), 366-383.
%
%
% Created    : "2011-12-03 19:01:09 ban"
% Last Update: "2021-03-29 15:49:53 ban"
%
%
% [input variables]
% sujID         : ID of subject, string, such as 's01'
%                 you also need to create a directory ./subjects/(subj) and put displayfile and stimulusfile there.
% exp_mode      : experiment mode that you want to run, one of
%  - ccw   : checkerboard wedge rotated counter-clockwise
%  - cw    : checkerboard wedge rotated clockwise
%  - exp   : checkerboard anuulus expanding from fovea
%  - cont  : checkerboard annulus contracting from periphery
% acq           : acquisition number (design file number),
%                 an integer, such as 1, 2, 3, ...
% displayfile   : (optional) display condition file,
%                 *.m file, such as 'RetDepth_display_fmri.m'
%                 the same display file for cretinotopy is acceptable
% stimulusfile  : (optional) stimulus condition file,
%                 *.m file, such as 'RetDepth_stimulus_exp1.m'
%                 the same stimulus file for cretinotopy is acceptable
% overwrite_pix_per_deg : (optional) pixels-per-deg value to overwrite the sparam.pix_per_deg
%                 if not specified, sparam.pix_per_deg is used to reconstruct
%                 stim_windows.
%                 This is useful to reconstruct stim_windows with less memory space
%                 1/pix_per_deg = spatial resolution of the generated visual field,
%                 e.g. when pix_per_deg=20, then, 1 pixel = 0.05 deg.
%                 empty (use sparam.pix_per_deg) by default
% TR            : (optional) TR used in fMRI scans, in sec, 2 by default
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
% % ************************************************************
% % This is the display configuration file for the retinotopy stimuli
% % Programmed by Hiroshi Ban Nov 01 2013
% % ************************************************************
%
% %%% the resolution of the screen height
% dparam.ScrHeight=1200;
%
% %% the resolution of the screen width
% dparam.ScrWidth=1920;
%
%
% [About stimulusfile]
% The contents of the stimulusfile are as below.
% (The file includs 6 lines of headers and following stimulus parameters)
%
% (an example of the stimulusfile)
%
% % ************************************************************
% % This is the stimulus parameter file for the phase-encoded retinotopy stimulus
% % Programmed by Hiroshi Ban Apr 01 2011
% % ************************************************************
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
% %%% fixation period in msec before/after presenting the target stimuli, integer
% % must set a value more than 1 TR for initializing the frame counting.
% sparam.initial_fixation_time=[4000,4000];
%
% %%% fixation size & color
% sparam.fixsize=12; % radius in pixels
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
% [reference]
% for stmulus generation, see ../Generation & ../Common directories.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Check the input variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear global; clear mex;
if nargin<3, help(mfilename()); return; end
if nargin<4 || isempty(displayfile), displayfile=[]; end
if nargin<5 || isempty(stimulusfile), stimulusfile=[]; end
if nargin<6 || isempty(overwrite_pix_per_deg), overwrite_pix_per_deg=[]; end
if nargin<7 || isempty(TR), TR=2; end

% check the aqcuisition number. up to 10 design files can be used
if acq<1, error('Acquistion number must be integer and greater than zero'); end

% check the experiment mode (stimulus type)
if ~strcmpi(exp_mode,'ccw') && ~strcmpi(exp_mode,'cw') && ~strcmpi(exp_mode,'exp') && ~strcmpi(exp_mode,'cont')
  error('exp_mode should be one of "ccw", "cw", "exp", and "cont". check the input variable.');
end

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
resultDir=fullfile(rootDir,'subjects',num2str(subjID),'pRF',today);
if ~exist(resultDir,'dir'), mkdir(resultDir); end

% record the output window
logfname=fullfile(resultDir,[num2str(subjID),'_stimulus_window_',exp_mode,'_run_',num2str(acq,'%02d'),'.log']);
diary(logfname);
warning off; %#ok warning('off','MATLAB:dispatcher:InexactCaseMatch');


%%%%% try & catch %%%%%
try


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Validate dparam (displayfile) and sparam (stimulusfile) structures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% organize dparam
dparam=struct(); % initialize
if ~isempty(displayfile), run(fullfile(rootDir,'subjects',subjID,displayfile)); end % load specific dparam parameters configured for each of the participants
dparam=ValidateStructureFields(dparam,... % validate fields and set the default values to missing field(s)
         'ScrHeight',1200,...
         'ScrWidth',1920);

% organize sparam
sparam=struct(); % initialize
sparam.mode=exp_mode;
if ~isempty(stimulusfile), run(fullfile(rootDir,'subjects',subjID,stimulusfile)); end % load specific sparam parameters configured for each of the participants
sparam=ValidateStructureFields(sparam,... % validate fields and set the default values to missing field(s)
         'width',48,...
         'rotangle',12,...
         'startangle',-48/2,...
         'maxRad',8,...
         'minRad',0,...
         'cycle_duration',60000,...
         'rest_duration',0,...
         'numRepeats',6,...
         'initial_fixation_time',[4000,4000],...
         'fixsize',12,...
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
fprintf('done.\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Displaying the presentation parameters you set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('The Presentation Parameters are as below.\n\n');
fprintf('************************************************\n');
fprintf('*************** Script, Subject ****************\n');
fprintf('Date & Time            : %s\n',strcat([datestr(now,'yymmdd'),' ',datestr(now,'HH:mm:ss')]));
fprintf('Running Script Name    : %s\n',mfilename());
fprintf('Subject ID             : %s\n',subjID);
fprintf('Acquisition Number     : %d\n',acq);
fprintf('*************** Screen Settings ****************\n');
fprintf('Screen Height          : %d\n',dparam.ScrHeight);
fprintf('Screen Width           : %d\n',dparam.ScrWidth);
fprintf('*********** Stimulation periods etc. ***********\n');
fprintf('Fixation Time(sec)     : %d & %d\n',sparam.initial_fixation_time(1),sparam.initial_fixation_time(2));
fprintf('Cycle Duration(sec)    : %d\n',sparam.cycle_duration);
fprintf('Rest  Duration(sec)    : %d\n',sparam.rest_duration);
fprintf('Repetitions(cycles)    : %d\n',sparam.numRepeats);
fprintf('******** The number of experiment, imgs ********\n');
fprintf('Experiment Mode        : %s\n',sparam.mode);
fprintf('************************************************\n\n');
fprintf('Please carefully check before proceeding.\n\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initializing variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Initializing stimulus generation variables...');

% difine constant variables
display_flg=1;
pause_dur=0.2;

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

nTR_fixation=round(sparam.initial_fixation_time./sparam.TR);
nTR_cycle=round((sparam.cycle_duration-sparam.rest_duration)/sparam.TR);
nTR_rest=round(sparam.rest_duration/sparam.TR);
nTR_rotation=round((sparam.cycle_duration-sparam.rest_duration)/(360/sparam.rotangle)/sparam.TR);
nTR_whole=round((sum(sparam.initial_fixation_time)+sparam.cycle_duration*sparam.numRepeats)/sparam.TR);

%% initialize chackerboard parameters
rmin=sparam.minRad+sparam.fixsize/sparam.pix_per_deg; % omit the central fixation point
rmax=sparam.maxRad;

% variable to store the current rotation/disparity id
stim_pos_id=1;

fprintf('done.\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Generating checkerboard patterns
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('generating stimulus patterns...');

%% generate checkerboard patterns
if strcmpi(sparam.mode,'ccw') || strcmpi(sparam.mode,'cw')

  sparam.npositions=360/sparam.rotangle;
  startangles=zeros(sparam.npositions,1);
  for nn=1:1:sparam.npositions, startangles(nn)=sparam.startangle+(nn-1)*sparam.rotangle; end

  [dummy1,dummy2,checkerboard]=pol_GenerateCheckerBoard1D(rmin,rmax,sparam.width,startangles,sparam.pix_per_deg,1,1,0);
  clear dummy1 dummy2;

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

  [dummy1,dummy2,checkerboard]=ecc_GenerateCheckerBoard1D(ecclims,360,sparam.startangle,sparam.pix_per_deg,1,1,0);
  clear dummy1 dummy2;

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

fprintf('done.\n');


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

fprintf('storing stimulus patterns...\n');
fprintf('Frames(TR):\n');

% generate images in the fixation periods
counterend=TRcounter+nTR_fixation(1)-1;
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

  end % for ff=TRcounter:1:counterend

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
counterend=TRcounter+nTR_fixation(1)-1;
for ff=TRcounter:1:counterend
  stim_windows(:,:,ff)=0;
  TRcounter=TRcounter+1;
  fprintf('%03d ',ff); if mod(ff,20)==0, fprintf('\n'); end
  if display_flg
    imagesc(stim_windows(:,:,ff),[0,1]); title(sprintf('Frame(TR): %03d',ff)); colormap(gray); axis equal; axis off; drawnow; pause(pause_dur);
  end
end

fprintf('done.\n');
close all;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Write data into file for post analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% saving the results
fprintf('saving data...');
savefname=fullfile(resultDir,[num2str(subjID),'_stimulus_window_',sparam.mode,'_run_',num2str(acq,'%02d'),'.mat']);
eval(sprintf('save %s subjID sparam dparam stim_windows;',savefname));
fprintf('done.\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Remove paths to the subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
  tmp=lasterror; %#ok
  diary off;
  fprintf(['\nError detected and the program was terminated.\n',...
           'To check error(s), please type ''tmp''.\n',...
           'Please save the current variables now if you need.\n',...
           'Then, quit by ''dbquit''\n']);
  keyboard;
  rmpath(genpath(fullfile(rootDir,'..','Common')));
  rmpath(fullfile(rootDir,'..','Generation'));
  %clear global; clear mex; clear all; close all;
  return
end % try..catch


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% That's it - we're done
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return;
% end % function gen_retinotopy_window
