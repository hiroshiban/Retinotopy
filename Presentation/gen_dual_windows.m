function stim_windows=gen_dual_windows(subjID,exp_mode,acq,displayfile,stimulusfile,overwrite_pix_per_deg,TR)

% Generates retinotopy stimulus (polar wedge + eccentricity annulus) windows for pRF (population receptive field) analysis.
% function stim_windows=gen_dual_windows(subjID,exp_mode,acq,:displayfile,:stimulusfile,:overwrite_pix_per_deg,:TR)
% (: is optional)
%
% This function generates stimulus windows corresponding to the color/luminance-defined
% checkerboard cdual(polar wedge + eccentricity annulus) stimuli.
% The generated stimulus windows will be utilized to generate pRF (population receptive field) models.
% reference: Population receptive field estimates in human visual cortex.
%            Dumoulin, S.O. and Wandell, B.A. (2008). Neuroimage 39(2):647-660.
%
%
% Created    : "2019-01-25 12:30:39 ban"
% Last Update: "2019-01-25 16:22:24 ban"
%
%
%
% [input variables]
% sujID         : ID of subject, string, such as 's01'
%                 you also need to create a directory ./subjects/(subj) and put displayfile and stimulusfile there.
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
%    as ./subjects/(subjID)/pRF/(date)/(subjID)_stimulus_window_dual_(exp_mode)_run_XX.mat
%
%
% [example]
% >> stim_windows=gen_dual_windows('HB','ccwexp',1,'retinotopy_display.m','c_pol.m',10,2);
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
% % This is the stimulus parameter file for the dual (wedge + annulus) retinotopy stimulus
% % Programmed by Hiroshi Ban Jan 25 2019
% % ************************************************************
%
% % "sparam" means "stimulus generation parameters"
%
% %%% stimulus parameters
% sparam.pol_width       = 48;    % wedge width in deg along polar angle
% sparam.pol_rotangle    = 12;    % rotation angle in deg
% sparam.pol_startangle  = -sparam.pol_width/2-90; % presentation start angle in deg, from right-horizontal meridian, ccw
%
% sparam.ecc_width       = sparam.pol_width/2;
% sparam.ecc_rotangle    = sparam.pol_rotangle;
% sparam.ecc_startangle  = -sparam.ecc_width/2-90;  % presentation start angle in deg, from right-horizontal meridian, ccw (actually this value is not used for the eccentricity stimuli (exp and cont))
%
% sparam.maxRad      = 6.0    % maximum radius of  annulus (degrees)
% sparam.minRad      = 0;    % minumum
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
% %%% fixation period in msec before/after presenting the target stimuli, integer
% % must set a value more than 1 TR for initializing the frame counting.
% sparam.initial_fixation_time=[4000,4000];
%
% %%% fixation size & color
% sparam.fixsize=12; % radius in pixels
% sparam.fixcolor=[255,255,255];
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
if nargin<6 || isempty(overwrite_pix_per_deg), overwrite_pix_per_deg=[]; end
if nargin<7 || isempty(TR), TR=2; end

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
logfname=fullfile(resultDir,[num2str(subjID),'_stimulus_window_dual_',exp_mode,'_run_',num2str(acq,'%02d'),'.log']);
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
         'pol_width',48,...
         'pol_rotangle',12,...
         'pol_startangle',-48/2-90,...
         'ecc_width',48,...
         'ecc_rotangle',12,...
         'ecc_startangle',-48/2-90,...
         'maxRad',8,...
         'minRad',0,...
         'pol_cycle_duration',60000,...
         'pol_rest_duration',0,...
         'pol_numRepeats',6,...
         'ecc_cycle_duration',40000,...
         'ecc_rest_duration',8000,...
         'ecc_numRepeats',9,...
         'initial_fixation_time',[4000,4000],...
         'fixsize',12,...
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
fprintf('Total Time (sec)       : %d\n',sum(sparam.initial_fixation_time)+sparam.pol_numRepeats*sparam.pol_cycle_duration);
fprintf('**************** Stimulus Type *****************\n');
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
nTR_rotation=round((sparam.pol_cycle_duration-sparam.pol_rest_duration)/(360/sparam.pol_rotangle)/sparam.TR);
nTR_whole=round((sum(sparam.initial_fixation_time)+sparam.pol_cycle_duration*sparam.pol_numRepeats)/sparam.TR);

% initialize chackerboard parameters
rmin=sparam.minRad+sparam.fixsize/sparam.pix_per_deg; % omit the central fixation point
rmax=sparam.maxRad;

sparam.pol_npositions=360/sparam.pol_rotangle;
sparam.ecc_npositions=sparam.pol_npositions*(sparam.ecc_cycle_duration-sparam.ecc_rest_duration)/(sparam.pol_cycle_duration-sparam.pol_rest_duration);

disp('done.');
disp(' ');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Generating checkerboard patterns
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('generating stimulus patterns...');

%%% a wedge for polar representation
startangles=zeros(sparam.pol_npositions,1);
for nn=1:1:sparam.pol_npositions, startangles(nn)=sparam.pol_startangle+(nn-1)*sparam.pol_rotangle; end

[dummy1,dummy2,pol_checkerboard]=pol_GenerateCheckerBoard1D(rmin,rmax,sparam.pol_width,startangles,sparam.pix_per_deg,1,1,0);
clear dummy1 dummy2;

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

[dummy1,dummy2,ecc_checkerboard]=ecc_GenerateCheckerBoard1D(ecclims,360,sparam.ecc_startangle,sparam.pix_per_deg,1,1,0);
clear dummy1 dummy2;

%% flip all data for ccw/cont
if ~isempty(strfind(sparam.mode,'ccw'))

  tmp_checkerboard=cell(sparam.pol_npositions,1);
  for nn=1:1:sparam.pol_npositions, tmp_checkerboard{nn}=pol_checkerboard{sparam.pol_npositions-(nn-1)}; end
  pol_checkerboard=tmp_checkerboard;
  clear tmp_checkerboard;

end

if ~isempty(strfind(sparam.mode,'cont'))

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
  else % if ~isempty(strfind(sparam.mode,'cw'))
    pol_checkerboard=[repmat({zeros(size(pol_checkerboard{1}))},nrest,1);pol_checkerboard];
  end
end

% put the rest period for eccentricity patterns
nrest=sparam.ecc_npositions/(sparam.ecc_cycle_duration-sparam.ecc_rest_duration)*sparam.ecc_rest_duration;
if nrest>0
  if ~isempty(strfind(sparam.mode,'cont'))
    ecc_checkerboard=[repmat({zeros(size(ecc_checkerboard{1}))},nrest,1);ecc_checkerboard];
  else % if ~isempty(strfind(sparam.mode,'ecc'))
    ecc_checkerboard=[ecc_checkerboard;repmat({zeros(size(ecc_checkerboard{1}))},nrest,1)];
  end
end

% multiply the patterns for the pol_subrepeats
pol_checkerboard=repmat(pol_checkerboard,pol_subrepeats,1);

% initialize the final checkerboard by eccentricity patterns
checkerboard=repmat(ecc_checkerboard,ecc_subrepeats,1);

% overwrite the polar patterns
for nn=1:1:length(pol_checkerboard)
  checkerboard{nn}(pol_checkerboard{nn}~=0)=pol_checkerboard{nn}(pol_checkerboard{nn}~=0);
end
clear pol_checkerboard ecc_checkerboard;

% generate the final checkerboard patterns
subrepeats=ceil(sparam.pol_numRepeats/pol_subrepeats);
checkerboard=repmat(checkerboard,[subrepeats,1]);

% cut the patterns that exceeds the whole stimulus presentation trials
if length(checkerboard) > sparam.pol_cycle_duration*sparam.pol_numRepeats/(sparam.pol_cycle_duration/sparam.pol_npositions)
  checkerboard=checkerboard(1:sparam.pol_cycle_duration*sparam.pol_numRepeats/(sparam.pol_cycle_duration/sparam.pol_npositions));
end

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
%%%% Initial Fixation Period
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('storing stimulus patterns...');
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

for cc=1:1:length(checkerboard)

  %% stimulus presentation loop
  counterend=TRcounter+nTR_rotation-1;
  for ff=TRcounter:1:counterend
    % set the current checkerboard
    stim_windows(:,:,ff)=checkerboard{cc};

    TRcounter=TRcounter+1;
    fprintf('%03d ',ff); if mod(ff,20)==0, fprintf('\n'); end
    if display_flg
      imagesc(stim_windows(:,:,ff),[0,1]); title(sprintf('Frame(TR): %03d',ff)); colormap(gray); axis equal; axis off; drawnow; pause(pause_dur);
    end
  end % for ff=TRcounter:1:counterend

end % for cc=1:1:length(checkerboard)


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

disp('done.');
disp(' ');
close all;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Write data into file for post analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% saving the results
fprintf('saving data...');
savefname=fullfile(resultDir,[num2str(subjID),'_stimulus_window_dual_',sparam.mode,'_run_',num2str(acq,'%02d'),'.mat']);
eval(sprintf('save %s subjID sparam dparam stim_windows;',savefname));
disp('done.');


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
% end % function gen_dual_window
