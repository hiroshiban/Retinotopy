function stim_windows=gen_multifocal_windows(subjID,exp_mode,acq,displayfile,stimulusfile,overwrite_pix_per_deg,TR)

% Generates multi-focal retinotopy stimulus windows for GLM modeling or pRF (population receptive field) analysis.
% function stim_windows=gen_multifocal_windows(subjID,exp_mode,acq,:displayfile,:stimulusfile,:overwrite_pix_per_deg,:TR)
% (: is optional)
%
% This function generates stimulus windows corresponding to the color/luminance-defined
% multifocal retinotopy checkerboard stimuli. The generated stimulus windows will be utilized
% to generate GLM or pRF (population receptive field) models.
% reference: Multifocal fMRI mapping of visual cortical areas.
%            Vanni, S., Henriksson, L., James, A.C. (2005). Neuroimage, 27(1), 95-105.
%
% Created    : "2018-11-29 12:27:34 ban"
% Last Update: "2018-12-01 13:37:12 ban"
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
% exp_mode      : experiment mode acceptable in this script is only "multifocal"
%                 this variable is set just to make the input formats similar with the other functions.
% acq           : acquisition number (design file number),
%                 an integer, such as 1, 2, 3, ...
% displayfile   : (optional) display condition file,
%                 *.m file, such as 'RetDepth_display_fmri.m'
%                 the same display file for cretinotopy is acceptable
% stimulusfile  : (optional) stimulus condition file,
%                 *.m file, such as 'RetDepth_stimulus_exp1.m'
%                 the same stimulus file for cretinotopy is acceptable
% overwrite_pix_per_deg : (optional) pixels-per-deg value to overwrite the
%                 sparam.pix_per_deg. if not specified, sparam.pix_per_deg is
%                 used to reconstruct stim_windows.
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
%    as ./subjects/(subjID)/pRF/(date)/(subjID)_stimulus_window_multifocal_run_XX.mat
%
%
% [example]
% >> stim_windows=gen_multifocal_windows('HB','bar',1,'multifocal_display.m','multifocal_stimuli.m',10,2);
%
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
% % This_is_the_stimulus_parameter_file_for_retinotopy_Checker_experiment.
% % Please_change_the_parameters_below.
% % retinotopyDepthfMRI.m
% % Programmed_by_Hiroshi_Ban___November_29_2018
% % ************************************************************
%
% %%% stimulus parameters
% sparam.nwedges     = 36;   % number of wedge subdivisions along polar angle
% sparam.nrings      = 9;    % number of ring subdivisions along eccentricity angle
% sparam.width       = 360;  % wedge width in deg along polar angle
% sparam.ndivsP      = 12;   % number of visual field subdivisions along polar angle
% sparam.ndivsE      = 3;    % number of visual field subdivisions along eccentricity
% sparam.phase       = 0;    % phase shift in deg
% sparam.startangle  = 0;    % presentation start angle in deg, from right-horizontal meridian, ccw
%
% sparam.maxRad      = 6.0;  % maximum radius of  annulus (degrees)
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
% %%% generate stimulus presentation design
%
% % generating 0/1 sequence using m-sequence generation algorithm
% % ms=mseq(baseVal,powerVal,shift,whichSeq,balance_flag,user_taps).
% % here, shift and whichSeq should be set if you want to use a specific stimulus presentation order.
% % if these values are not set, shift=1 and whichSeq=ceil(rand(1)*length(tap)) are used as defult,
% % which means the different m-sequences are generated each time when the mseq() function is called.
% % or if you want to provide a specific stimulus presentation order, please set sparam.design as a
% % fixed matrix as below (sparam.design should be [ndivsE*ndivsP,numel(mseq(2,8))]).
% %
% % % sparam.design=[
% %     0,1,1,0,1,1,1,1,0,1,...;
% %     1,1,0,0,0,0,0,0,1,1,...;
% %     1,1,0,1,1,1,1,0,1,1,...];
%
% tmp_design=mseq(2,8,1,1); % to provide a specific stimulation order, the third and fourth variables are explicitly given.
% tmp_shift=[1:sparam.ndivsP*sparam.ndivsE];
% shift=zeros(numel(tmp_shift),1);
% shift_counter=1;
% while ~isempty(tmp_shift)
%   if mod(shift_counter,2)
%     shift(shift_counter)=tmp_shift(1);
%     tmp_shift(1)=[];
%   else
%     shift(shift_counter)=tmp_shift(floor(numel(tmp_shift/2)));
%     tmp_shift(floor(numel(tmp_shift/2)))=[];
%   end
%   shift_counter=shift_counter+1;
% end
%
% sparam.design=zeros(numel(shift),numel(tmp_design));
% for mmmm=1:1:numel(shift), sparam.design(mmmm,:)=tmp_design([shift(mmmm):end,1:shift(mmmm)-1]); end
%
% clear tmp_design tmp_shift shift shift_counter mmmm;
%
% %%% duration in msec for each trial
% sparam.trial_duration=2000; % msec
% sparam.rest_duration=0;
%
% sparam.numTrials=size(sparam.design,2);
%
% %%% set number of frames to flip the screen
% % Here, I set the number as large as I can to minimize vertical cynching error.
% % the final 2 is for 2 times repetitions of flicker
% % Set 1 if you want to flip the display at each vertical sync, but not recommended due to much CPU power
% %sparam.waitframes = Screen('FrameRate',0)*((sparam.trial_duration-sparam.rest_duration)/1000) / ( (size(sparam.colors,1)-1)*2 );
% sparam.waitframes = 60*((sparam.trial_duration-sparam.rest_duration)/1000) / ( (size(sparam.colors,1)-1)*2 );
% %sparam.waitframes = 1;
%
% %%% fixation period in msec before/after presenting the target stimuli, integer
% % must set a value more than 1 TR for initializing the frame counting.
% sparam.initial_fixation_time=[4000,4000];
%
% %%% fixation size & color
% sparam.fixsize=4; % radius in pixels
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
% run([fileparts(mfilename('fullpath')) filesep() 'sizeparams']);
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

% check the aqcuisition number
if acq<1, error('Acquistion number must be integer and greater than zero'); end

% check the experiment mode (stimulus type)
if ~strcmpi(exp_mode,'multifocal'), error('exp_mode acceptable in this script is only "multifocal". check the input variable.'); end

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
logfname=fullfile(resultDir,[num2str(subjID),'_stimulus_window_multifocal_run_',num2str(acq,'%02d'),'.log']);
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
         'nwedges',36,...
         'nrings',9,...
         'width',360,...
         'ndivsP',12,...
         'ndivsE',3,...
         'phase',0,...
         'startangle',0,...
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
         'trial_duration',2000,...
         'rest_duration',0,...
         'rest_duration',0,...
         'numTrials',255,...
         'waitframes',6,... % Screen('FrameRate',0)*((sparam.trial_duration-sparam.rest_duration)/1000) / ( (size(sparam.colors,1)-1)*2 );
         'initial_fixation_time',[4000,4000],...
         'fixsize',12,...
         'fixcolor',[255,255,255],...
         'bgcolor',[128,128,128],... % sparam.colors(1,:);
         'patch_color1',[255,255,255],...
         'patch_color2',[0,0,0],...
         'pix_per_cm',57.1429,...
         'vdist',65);

% set the stimulus presentation design based on M-sequences
if ~isstructmember(sparam,'design') || isempty(sparam.design)
  tmp_design=mseq(2,8,1,1); % to provide a specific stimulation order, the third and fourth variables are explicitly given.
  tmp_shift=[1:sparam.ndivsP*sparam.ndivsE];
  shift=zeros(numel(tmp_shift),1);
  shift_counter=1;
  while ~isempty(tmp_shift)
    if mod(shift_counter,2)
      shift(shift_counter)=tmp_shift(1);
      tmp_shift(1)=[];
    else
      shift(shift_counter)=tmp_shift(floor(numel(tmp_shift/2)));
      tmp_shift(floor(numel(tmp_shift/2)))=[];
    end
    shift_counter=shift_counter+1;
  end

  sparam.design=zeros(numel(shift),numel(tmp_design));
  for mmmm=1:1:numel(shift), sparam.design(mmmm,:)=tmp_design([shift(mmmm):end,1:shift(mmmm)-1]); end

  sparam.numTrials=size(sparam.design,2);

  clear tmp_design tmp_shift shift shift_counter mmmm;
end

% change unit from msec to sec.
sparam.initial_fixation_time=sparam.initial_fixation_time./1000; %#ok

% change unit from msec to sec.
sparam.trial_duration = sparam.trial_duration./1000;
sparam.rest_duration  = sparam.rest_duration./1000;

% set the other parameters
dparam.RunScript = mfilename();
sparam.RunScript = mfilename();


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
eval(sprintf('disp(''Fixation Time(sec)     : %d & %d'');',sparam.initial_fixation_time(1),sparam.initial_fixation_time(2)));
eval(sprintf('disp(''Trial Duration(sec)    : %d'');',sparam.trial_duration));
eval(sprintf('disp(''Rest  Duration(sec)    : %d'');',sparam.rest_duration));
eval(sprintf('disp(''#Trials                : %d'');',sparam.numTrials));
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
nTR_trial=round((sparam.trial_duration-sparam.rest_duration)/sparam.TR);
nTR_rest=round(sparam.rest_duration/sparam.TR);
nTR_whole=round((sum(sparam.initial_fixation_time)+sparam.trial_duration*sparam.numTrials)/sparam.TR);

%% initialize chackerboard parameters
rmin=sparam.minRad+sparam.fixsize/sparam.pix_per_deg; % omit the central fixation point
rmax=sparam.maxRad;

disp('done.');
disp(' ');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Generating checkerboard patterns
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('generating stimulus patterns...');

% [note]
% After this processing, each checkerboard image has checker elements with values as shown below
% 0 = background
% 1 = checker ID 1
% 2 = checker ID 2
% 3 = checker ID 3
% .....
% sparam.npatches = checker ID
% Each patch ID will be associated with a CLUT color of the same ID

% generate the base of the multifocal checkerboard
[dummy1,dummy2,mfcheckerboard]=mf_GenerateCheckerBoard1D(rmin,rmax,sparam.width,sparam.ndivsP,sparam.ndivsE,...
                                                     sparam.startangle,sparam.pix_per_deg,sparam.nwedges,sparam.nrings,sparam.phase);
clear dummy1 dummy2;

% generate all the multifocal checkerboards
checkerboard=cell(sparam.numTrials,1);
for cc=1:1:sparam.numTrials
  checkerboard{cc}=zeros(size(mfcheckerboard));
  mask_idx=find(sparam.design(:,cc)==1);
  for mm=1:1:numel(mask_idx), checkerboard{cc}(mfcheckerboard==mask_idx(mm))=1; end
end
clear mask_idx mfcheckerboard;

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

for cc=1:1:sparam.numTrials

  %% stimulus presentation loop
  counterend=TRcounter+nTR_trial-1;
  for ff=TRcounter:1:counterend
    % set the current checkerboard
    stim_windows(:,:,ff)=checkerboard{cc};

    TRcounter=TRcounter+1;
    fprintf('%03d ',ff); if mod(ff,20)==0, fprintf('\n'); end
    if display_flg
      imagesc(stim_windows(:,:,ff),[0,1]); title(sprintf('Frame(TR): %03d',ff)); colormap(gray); axis equal; axis off; drawnow; pause(pause_dur);
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

end % for cc=1:1:sparam.numTrials


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
savefname=fullfile(resultDir,[num2str(subjID),'_stimulus_window_multifocal_run_',num2str(acq,'%02d'),'.mat']);
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
% end % function gen_bar_windows
