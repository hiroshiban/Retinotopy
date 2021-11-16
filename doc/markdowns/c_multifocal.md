````MATLAB
% ************************************************************
% Thi is the stimulus parameter file for multifocal retinotopy.
% Please change the parameters below.
% For multifocal/multifocald/multifocalf/multifocali/
%     multifocaldf/multifocalwindows stimuli.
% Programmed by Hiroshi Ban   November 29 2018
% ************************************************************

%%% stimulus parameters
sparam.nwedges     = 36;   % number of wedge subdivisions along polar angle
sparam.nrings      = 9;    % number of ring subdivisions along eccentricity angle
sparam.width       = 360;  % wedge width in deg along polar angle
sparam.ndivsP      = 12;   % number of visual field subdivisions along polar angle
sparam.ndivsE      = 3;    % number of visual field subdivisions along eccentricity
sparam.phase       = 0;    % phase shift in deg
sparam.startangle  = 0;    % presentation start angle in deg, from right-horizontal meridian, ccw

sparam.maxRad      = 7.5;  % maximum radius of  annulus (degrees)
sparam.minRad      = 0;    % minumum

sparam.dimratio    = 0.4; % luminance dim ratio for the checker-pattern change detection task

% checkerboard colors, this variable is only for c* stimulus presentation scripts (e.g. cretinotopy)
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

%%% RDS parameters, these are only for d* stimulus presentation scripts (e.g dretinotopy_fixtask)
sparam.RDSdepth = [ -12, 12, 5]; % binocular disparity in arcmins, [min, max, #steps(from min to max)]
sparam.RDSDense=0.5; % dot density in the RDS images to be generated (percentage)
sparam.RDSradius=0.05; % dot radius in deg
sparam.RDScolors=[255,0,128]; % dot colors in the RDS, [color1, color2, background (grayscale)]
sparam.RDSbackground=0; % 1 = with background, 0 = no background
sparam.RDStaskmagnitude=2; % ratio (x2, x3, etc against the sparam.RDSdepth([1,2])) of the depth maginitude in the change-detection task

%%% generate stimulus presentation design

% generating 0/1 sequence using m-sequence
% ms=mseq(baseVal,powerVal,shift,whichSeq,balance_flag,user_taps).
% here, shift and whichSeq should be set if you want to use a specific stimulus presentation order.
% if these values are not set, shift=1 and whichSeq=ceil(rand(1)*length(tap)) are used as defult,
% which means the different m-sequences are generated each time when the mseq() function is called.
% or if you want to provide a specific stimulus presentation order, please set sparam.design as a
% fixed matrix as below (sparam.design should be [ndivsE*ndivsP,numel(mseq(2,8))]).
%
% % sparam.design=[
%     0,1,1,0,1,1,1,1,0,1,...;
%     1,1,0,0,0,0,0,0,1,1,...;
%     1,1,0,1,1,1,1,0,1,1,...];

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

clear tmp_design tmp_shift shift shift_counter mmmm;

%%% duration in msec for each trial
sparam.trial_duration=2000; % msec
sparam.rest_duration=0; % stimulation = trial_duration-rest_duration

sparam.numTrials=size(sparam.design,2);

%%% object-image presentation parameters, only for i* object-image-based retinotopy stimuli (e.g. iretinotopy_fixtask)
sparam.flip_duration=250; % msec
sparam.nimg=120; % number of images to be presented at a frame
sparam.imRatio=[0.2,0.5]; % image magnification ratio, [min, max] (0.0-1.0), the image sizes are randomly selected whithin this range
sparam.imdepth=[-12,12]; % disparities (arcmins) added to the images, effective only in a stereo mode (e.g. shutter, dual, parallel etc)

%%% set number of frames to flip the screen
% Here, I set the number as large as I can to minimize vertical cynching error.
% the final 2 is for 2 times repetitions of flicker
% Set 1 if you want to flip the display at each vertical sync, but not recommended as it uses much CPU power
%sparam.waitframes = Screen('FrameRate',0)*((sparam.trial_duration-sparam.rest_duration)/1000) / ( (size(sparam.colors,1)-1)*2 );
sparam.waitframes = 60*((sparam.trial_duration-sparam.rest_duration)/1000) / ( (size(sparam.colors,1)-1)*2 );

%%% fixation period in msec before/after presenting the target stimuli, integer
% must set a value more than 1 TR for initializing the frame counting.
sparam.initial_fixation_time=[4000,4000];

%%% fixation size & color
sparam.fixtype=1; % 1: circular, 2: rectangular, 3: concentric fixation point
sparam.fixsize=4; % radius in pixels
sparam.fixcolor=[255,255,255];

%%% background color
sparam.bgcolor=sparam.colors(1,:); %[0,0,0];

%%% RGB for background patches
% 1x3 matrices
sparam.patch_color1=[255,255,255];
sparam.patch_color2=[0,0,0];

%%% for converting degree to pixels
run(fullfile(fileparts(mfilename('fullpath')),'sizeparams'));
%sparam.pix_per_cm=57.1429;
%sparam.vdist=65;
%sparam.ipd=6.5;
````
