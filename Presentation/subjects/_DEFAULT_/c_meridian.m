% ************************************************************
% This_is_the_stimulus_parameter_file_for_retinotopyChecker_experiment.
% Please_change_the_parameters_below.
% retinotopyDepthfMRI.m
% Programmed_by_Hiroshi_Ban___Dec_12_2018
% ************************************************************

% "sparam" means "stimulus generation parameters"

%%% stimulus parameters
sparam.nwedges     = 4;     % number of wedge subdivisions along polar angle
sparam.nrings      = 4;     % number of ring subdivisions along eccentricity angle
sparam.width       = 24;    % wedge width in deg along polar angle
sparam.phase       = 0;     % phase shift in deg

sparam.maxRad      = 8;     % maximum radius of  annulus (degrees)
sparam.minRad      = 0;     % minumum

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
sparam.cycle_duration=32000; % msec
sparam.block_duration=16000; % msec, a block duration in which the wedge along the horizontal or vertical meridian is presented, rest_duration = spara.cycle_duration-2*sparam.block_duration
sparam.numRepeats=6;

%%% set number of frames to flip the screen
% Here, I set the number as large as I can to minimize vertical cynching error.
% the final 2 is for 2 times repetitions of flicker
% Set 1 if you want to flip the display at each vertical sync, but not recommended due to much CPU power
sparam.waitframes = Screen('FrameRate',0)*(sparam.cycle_duration/1000) / (sparam.cycle_duration/1000) / ( (size(sparam.colors,1)-1)*2 );
% sparam.waitframes = 1;

%%% fixation period in msec before/after presenting the target stimuli, integer
% must set a value more than 1 TR for initializing the frame counting.
sparam.initial_fixation_time=[4000,4000];

%%% fixation size & color
sparam.fixsize=4; % radius in pixels
sparam.fixcolor=[255,255,255];

%%% background color
sparam.bgcolor=sparam.colors(1,:); %[0,0,0];

%%% RGB for background patches
% 1x3 matrices
sparam.patch_color1=[255,255,255];
sparam.patch_color2=[0,0,0];

%%% for converting degree to pixels
%sparam.pix_per_cm=57.1429;
%sparam.vdist=65;
run([fileparts(mfilename('fullpath')) filesep() 'sizeparams']);
