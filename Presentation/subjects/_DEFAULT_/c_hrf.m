% ************************************************************
% This is the stimulus parameter file for the HRF characterization stimulus
% Programmed by Hiroshi Ban Jan 24 2019
% ************************************************************

%%% stimulus parameters
sparam.nwedges     = 30;     % number of wedge subdivisions along polar angle
sparam.nrings      = 8;     % number of ring subdivisions along eccentricity angle
sparam.width       = 360;    % wedge width in deg along polar angle
sparam.phase       = 0;    % phase shift in deg
sparam.startangle  = 0;     % presentation start angle in deg, from right-horizontal meridian, ccw

sparam.maxRad      = 6.5;    % maximum radius of  annulus (degrees)
sparam.minRad      = 0;    % minumum

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
sparam.rest_duration =16000; % msec, rest after each cycle, stimulation = cycle_duration-eccrest
sparam.numRepeats=6;

%%% set number of frames to flip the screen
% Here, I set the number as large as I can to minimize vertical cynching error.
% the final 2 is for 2 times repetitions of flicker
% Set 1 if you want to flip the display at each vertical sync, but not recommended due to much CPU power
sparam.waitframes = 4;%Screen('FrameRate',0)*(sparam.cycle_duration/1000) / ((sparam.cycle_duration-sparam.rest_duration)/1000) / ( (size(sparam.colors,1)-1)*2 );
%sparam.waitframes = 1;

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
run(fullfile(fileparts(mfilename('fullpath')),'sizeparams'));
%sparam.pix_per_cm=57.1429;
%sparam.vdist=65;
