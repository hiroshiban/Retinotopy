function stim_windows=gen_bar_windows(subjID,exp_mode,acq,displayfile,stimulusfile,overwrite_pix_per_deg,TR)

% Generates bar stimulus windows for pRF (population receptive field) analysis.
% function stim_windows=gen_bar_windows(subjID,exp_mode,acq,:displayfile,:stimulusfile,:overwrite_pix_per_deg,:TR)
% (: is optional)
%
% - This function generates stimulus windows corresponding to the color/luminance-defined
%   checkerboard bar stimuli, sweeping periodically over the whole visual field. The
%   generated stimulus windows can be used to generate pRF (population receptive field) models.
%
%   reference: Population receptive field estimates in human visual cortex.
%              Dumoulin, S.O. and Wandell, B.A. (2008). Neuroimage 39(2), 647-660.
%
%
% Created    : "2018-11-22 15:33:55 ban"
% Last Update: "2019-02-22 17:28:36 ban"
%
%
% [input variables]
% sujID         : ID of subject, string, such as 's01'
%                 you also need to create a directory ./subjects/(subj) and put displayfile and stimulusfile there.
% exp_mode      : experiment mode acceptable in this script is only "bar"
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
%    as ./subjects/(subjID)/pRF/(date)/(subjID)_stimulus_window_bar_run_XX.mat
%
%
% [example]
% >> stim_windows=gen_bar_windows('HB','bar',1,'bar_display.m','bar_stimuli.m',10,2);
%
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
% % This is the stimulus parameter file for the pRF bar stimulus
% % Programmed by Hiroshi Ban Nov 20 2018
% % ************************************************************
%
% % "sparam" means "stimulus generation parameters"
%
% %%% stimulus parameters
% sparam.ndivsL      = 24;  % number of bar subdivisions along the bar's long axis
% sparam.ndivsS      = 3;   % number of bar subdivisions along the bar's  short axis
% sparam.width       = 1.5; % bar width in deg
% sparam.phase       = 0;   % phase shift in deg along the bar's short axis
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
% sparam.fieldSize   = 12; % stimulation field size in deg, [row,col]. circular region with sparam.fieldSize is stimulated.
%
% %%% duration in msec for each cycle & repetitions
% sparam.cycle_duration=40000; % msec
% sparam.rest_duration =8000; % msec, rest after each cycle, stimulation = cycle_duration-eccrest
% sparam.numRepeats=1;
%
% %%% fixation period in msec before/after presenting the target stimuli, integer
% % must set a value more than 1 TR for initializing the frame counting.
% sparam.initial_fixation_time=[4000,4000];
%
% %%% fixation size & color
% sparam.fixsize=4; % radius in pixels
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
logfname=fullfile(resultDir,[num2str(subjID),'_stimulus_window_bar_run_',num2str(acq,'%02d'),'.log']);
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
         'ndivsL',24,...
         'ndivsS',3,...
         'width',1.5,...
         'phase',0,...
         'rotangles',[0,45,90,135,180,225,270,315],...
         'steps',16,...
         'fieldSize',12,...
         'cycle_duration',40000,...
         'rest_duration',8000,...
         'numRepeats',1,...
         'initial_fixation_time',[4000,4000],...
         'fixsize',4,...
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Displaying the presentation parameters you set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('The Presentation Parameters are as below.\n\n');
fprintf('************************************************\n');
fprintf('*************** Script, Subject ****************\n');
fprintf('Running Script Name    : %s'');',mfilename());
fprintf('Subject ID             : %s'');',subjID);
fprintf('Acquisition Number     : %d'');',acq);
fprintf('*************** Screen Settings ****************\n');
fprintf('Screen Height          : %d'');',dparam.ScrHeight);
fprintf('Screen Width           : %d'');',dparam.ScrWidth);
fprintf('*********** Stimulation periods etc. ***********\n');
fprintf('Fixation Time(sec)     : %d & %d'');',sparam.initial_fixation_time(1),sparam.initial_fixation_time(2));
fprintf('Cycle Duration(sec)    : %d'');',sparam.cycle_duration);
fprintf('Rest  Duration(sec)    : %d'');',sparam.rest_duration);
fprintf('Repetitions(cycles)    : %d'');',sparam.numRepeats);
fprintf('******** The number of experiment, imgs ********\n');
fprintf('Experiment Mode        : %s'');',sparam.mode);
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
nTR_movement=round((sparam.cycle_duration-sparam.rest_duration)/sparam.steps/sparam.TR);
nTR_whole=round((sum(sparam.initial_fixation_time)+sparam.cycle_duration*numel(sparam.rotangles)*sparam.numRepeats)/sparam.TR);

% variable to store the current rotation/disparity id
stim_pos_id=1;

fprintf('done.\n\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Generating checkerboard patterns
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('generating stimulus patterns...');

%% generate checkerboard patterns
[dummy1,dummy2,checkerboard]=bar_GenerateCheckerBar1D(sparam.fieldSize,sparam.width,sparam.rotangles,sparam.steps,...
                                                      sparam.pix_per_deg,sparam.ndivsL,sparam.ndivsS,sparam.phase);
clear dummy1 dummy2;

% % convert logical data to double format to process gaussian filter at the later stage
% for aa=1:1:numel(sparam.rotangles)
%   for nn=1:1:sparam.steps
%     checkerboard{aa,nn}=double(checkerboard{aa,nn});
%   end
% end

%% initialize stimulus windows
%stim_windows=zeros([round(size(checkerboard{1,1})),nTR_whole]);
stim_windows=false([round(size(checkerboard{1,1})),nTR_whole]);
TRcounter=1; % TR counter

fprintf('done.\n\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initilize figure window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if display_flg
  %scrsz = get(0,'ScreenSize');
  figure('Name',sprintf('stimulus window: %s',exp_mode),'NumberTitle','off');
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
  for aa=1:1:numel(sparam.rotangles) % loop for angle directions

    %% stimulus presentation loop
    counterend=TRcounter+nTR_cycle-1;
    for ff=TRcounter:1:counterend

      % set the current checkerboard
      stim_windows(:,:,ff)=checkerboard{aa,stim_pos_id};

      TRcounter=TRcounter+1;
      fprintf('%03d ',ff); if mod(ff,20)==0, fprintf('\n'); end
      if display_flg
        imagesc(stim_windows(:,:,ff),[0,1]); title(sprintf('Frame(TR): %03d',ff)); colormap(gray); axis equal; axis off; drawnow; pause(pause_dur);
      end

      % exit from the loop if the final frame is displayed
      if ff==counterend && aa==numel(sparam.rotangles), continue; end

      % stimulus position id for the next presentation
      if ~mod(ff-nTR_rest*(cc-1),nTR_movement)
        stim_pos_id=stim_pos_id+1;
        if stim_pos_id>sparam.steps, stim_pos_id=1; end
      end

    end % for ff=TRcounter:1:counterend

    %% rest perioed
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

  end % for aa=1:1:numel(sparam.rotangles) % loop for angle directions
end % for cc=1:1:sparam.numRepeats


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Final Fixation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% generate images in the fixation periods
counterend=TRcounter+nTR_fixation(2)-1;
for ff=TRcounter:1:counterend
  stim_windows(:,:,ff)=0;
  TRcounter=TRcounter+1;
  fprintf('%03d ',ff); if mod(ff,20)==0, fprintf('\n'); end
  if display_flg
    imagesc(stim_windows(:,:,ff),[0,1]); title(sprintf('Frame(TR): %03d',ff)); colormap(gray); axis equal; axis off; drawnow; pause(pause_dur);
  end
end

fprintf('done.\n\n');
close all;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Write data into file for post analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% saving the results
fprintf('saving data...');
savefname=fullfile(resultDir,[num2str(subjID),'_stimulus_window_bar_run_',num2str(acq,'%02d'),'.mat']);
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
  fprintf(['\nErrror detected and the program was terminated.\n',...
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
% end % function gen_bar_windows
