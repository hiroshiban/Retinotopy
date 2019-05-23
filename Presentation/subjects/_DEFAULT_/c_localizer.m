% ************************************************************
% This is the stimulus parameter file for the clocalizer retinotopy stimulus
% Programmed by Hiroshi Ban Dec 19 2018
% ************************************************************

%%% stimulus parameters
sparam.nwedges     = 30;  % number of wedge subdivisions along polar angle
sparam.nrings      = 8;   % number of ring subdivisions along eccentricity angle
sparam.width       = 360; % wedge width in deg along polar angle
sparam.phase       = 0;   % phase shift in deg
sparam.startangle  = 0;   % presentation start angle in deg, from right-horizontal meridian, ccw

sparam.maxRad      = 7.5; % maximum radius of  annulus (degrees)
sparam.minRad      = 0;   % minimum
sparam.tgtRad      = [2.7,3.8]; % target eccentricity

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

%%% duration in msec for each cycle & repetitions
% Here, the stimulus presentation protocol is defined as below.
% initial_fixation_time(1) ---> block_duration-rest_duration (the target pattern) ---> rest_duration (blank) --->
%   block_duration-rest_duration (the compensating pattern of the target) ---> rest_duration (blank) ---> block_duration-rest_duration (the target pattern) --->
%     rest_duration (blank) ---> block_duration-rest_duration (the compensating pattern) ---> ... (repeated numRepeats in total) ---> initial_fixation_time(2)
% Therefore, one_stimulation_cycle = block_duration x 2 (note: in this period, stimulation = block_duration-rest_duration)

sparam.block_duration=32000; % msec, a presentation duration of the target or its compensating pattern
sparam.rest_duration =16000; % msec, stimulation = block_duration-rest_duration
sparam.numRepeats=6;

%%% object-image presentation parameters, only for i* object-image-based retinotopy stimuli (e.g. iretinotopy_fixtask)
sparam.flip_duration=250; % msec
sparam.nimg=120; % number of images to be presented at a frame
sparam.imRatio=[0.2,0.5]; % image magnification ratio, [min, max] (0.0-1.0), the image sizes are randomly selected whithin this range

%%% set number of frames to flip the screen
% Here, I set the number as large as I can to minimize vertical cynching error.
% the final 2 is for 2 times repetitions of the flicker
% Set 1 if you want to flip the display at each vertical sync, but not recommended as it uses much CPU power
%sparam.waitframes = Screen('FrameRate',0)*(2*sparam.block_duration/1000) / (2*(sparam.block_duration-sparam.rest_duration)/1000) / ( (size(sparam.colors,1)-1)*2 );
sparam.waitframes = 60*(2*sparam.block_duration/1000) / (2*(sparam.block_duration-sparam.rest_duration)/1000) / ( (size(sparam.colors,1)-1)*2 );

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
