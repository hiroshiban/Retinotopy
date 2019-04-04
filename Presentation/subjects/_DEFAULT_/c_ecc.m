% ************************************************************
% This_is_the_stimulus_parameter_file_for_retinotopy_Checker_experiment.
% Please_change_the_parameters_below.
% retinotopyDepthfMRI.m
% Programmed_by_Hiroshi_Ban___April_01_2011
% ************************************************************

% !!!IMPORTANT NOTICE!!!
% As for exp/cont mode, some of parameters should match with parameters listed in ccw/cw stimulus files.
% For example, sparam.width shoud not set to 360 but match to value listed in ccw/cw stimulus files.
% This is required to calculate valid annular width in exp/cont modes so that its stimulation duration
% in each visual field point becomes equivalent to that in ccw/cw conditions.
% Then, the stimulus parameters listed in exp/cont stimulus files are automatically adjusted considering
% stimulation period, stimulation cycle etc.
%
% Only the difference between ccw/cw and exp/cont is sparam.rest_duration parameter.
% Generally, it is recommended to use some rest after each expansion/contraction to omit response overlaps
% between retinotopic foveal/peripheral regions

%%% stimulus parameters
sparam.nwedges     = 4;  % number of wedge subdivisions along polar angle
sparam.nrings      = 2;  % number of ring subdivisions along eccentricity angle
sparam.width       = 48; % === SHOULD BE SAME WITH VALUE LISTED IN C_POL.m ===, wedge width in deg along polar angle, for 'exp' & 'cont', this is only used for width calculation
sparam.phase       = 0;  % phase shift in deg
sparam.rotangle    = 12; % === SHOULD BE SAME WITH VALUE LISTED IN C_POL.m ===, rotation angle in deg
sparam.startangle  = -sparam.width/2-90; % presentation start angle in deg, from right-horizontal meridian, ccw

sparam.maxRad      = 7.5; % maximum radius of  annulus (degrees)
sparam.minRad      = 0;   % minumum

sparam.dimratio    = 0.4; % luminance dim ratio for the checker-pattern change detection task

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

%%% duration in msec for each cycle & repetitions
sparam.cycle_duration=60000; % msec;
sparam.rest_duration =10000; % msec, rest after each cycle, stimulation = cycle_duration-rest_duration
sparam.numRepeats=6;

%%% parameters used only for object-image-based retinotopy stimuli
sparam.flip_duration=500; % msec
sparam.nimg=120; % number of images to be presented at a frame
sparam.imRatio=[0.2,0.5]; % image magnification ratio, [min, max] (0.0-1.0), the image sizes are randomly selected whithin this range

%%% set number of frames to flip the screen
% Here, I set the number as large as I can to minimize vertical cynching error.
% the final 2 is for 2 times repetitions of flicker
% Set 1 if you want to flip the display at each vertical sync, but not recommended as it uses much CPU power
%sparam.waitframes = Screen('FrameRate',0)*(sparam.cycle_duration/1000) / (360/sparam.rotangle) / ( (size(sparam.colors,1)-1)*2 );
sparam.waitframes = 60*(sparam.cycle_duration/1000) / (360/sparam.rotangle) / ( (size(sparam.colors,1)-1)*2 );
%sparam.waitframes = 1;

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
