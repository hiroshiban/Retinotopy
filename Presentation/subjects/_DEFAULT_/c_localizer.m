% ************************************************************
% This_is_the_stimulus_parameter_file_for_retinotopy_Checker_experiment.
% Please_change_the_parameters_below.
% retinotopyDepthfMRI.m
% Programmed_by_Hiroshi_Ban___April_01_2011
% ************************************************************

%%% stimulus parameters
sparam.nwedges     = 30;     % number of wedge subdivisions along polar angle
sparam.nrings      = 8;     % number of ring subdivisions along eccentricity angle
sparam.width       = 360;    % wedge width in deg along polar angle
sparam.phase       = 0;    % phase shift in deg
sparam.startangle  = 0;     % presentation start angle in deg, from right-horizontal meridian, ccw

sparam.maxRad      = 6.5;    % maximum radius of  annulus (degrees)
sparam.minRad      = 0;      % minimum
sparam.tgtRad      = [2.7,3.8];  % target eccentricity

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
sparam.flickerrepetitions=2; % repetitions of flicker in a second

%%% duration in msec for each cycle & repetitions
sparam.cycle_duration=32000; % msec
sparam.rest_duration =16000; % msec, rest (compensating pattern) after each cycle, stimulation = cycle_duration-eccrest
sparam.numRepeats=6;

%%% set number of frames to flip the screen
% Here, I set the number as large as I can to minimize vertical cynching error.
% the final 2 is for 2 times repetitions of flicker
% Set 1 if you want to flip the display at each vertical sync, but not recommended due to much CPU power
sparam.waitframes = Screen('FrameRate',0)*(sparam.cycle_duration/1000) / ((sparam.cycle_duration-sparam.rest_duration)/1000) / ( (size(sparam.colors,1)-1)*2 );
%sparam.waitframes = 1;

%%% fixation size & color
sparam.fixsize=4; % radius in pixels
sparam.fixcolor=[255,255,255];

%%% background color
sparam.bgcolor=sparam.colors(1,:); %[0,0,0];

%%% RGB for background patches
% 1x3 matrices
sparam.color1=[255,255,255];
sparam.color2=[0,0,0];

%%% for converting degree to pixels
%sparam.pix_per_cm=57.1429;
%sparam.vdist=65;
run([fileparts(mfilename('fullpath')) filesep() 'sizeparams']);
