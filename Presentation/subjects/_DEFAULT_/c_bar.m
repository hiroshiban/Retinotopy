% ************************************************************
% This_is_the_stimulus_parameter_file_for_retinotopyChecker_experiment.
% Please_change_the_parameters_below.
% retinotopyDepthfMRI.m
% Programmed_by_Hiroshi_Ban___November_20_2018
% ************************************************************

% "sparam" means "stimulus generation parameters"

%%% stimulus parameters
sparam.fieldSize   = 15; % stimulation field size in deg. circular region with sparam.fieldSize is stimulated.

sparam.ndivsL      = 18;  % number of bar subdivisions along bar's long axis
sparam.ndivsS      = 2;   % number of bar subdivisions along bar's short axis
sparam.width       = 1.5; % bar width in deg
sparam.phase       = 0;   % phase shift in deg, along bar's short axis

% rotation angles in deg, 0 = right horizontal meridian, counter-clockwise.
% when sparam.rotangles(1)=0, the bar emerges at the right hemifield and sweeps
% the visual field leftwards.
%
% following this parameter, stimulus presentation seuence is defined.
% for instance, is sparam.rotangles   = [0,45,90,135,180,225,270,315];,
% the bar sweeps visual field like
% 1. sparam.rotangles(1)=0   : right to left horizontally, then rest for sparam.rest_duration
% 2. sparam.rotangles(2)=45  : upper right to lower left at 45 deg direction, then rest for sparam.rest_duration
% 3. sparam.rotangles(3)=90  : upper to lower vertically, then rest for sparam.rest_duration
% 4. sparam.rotangles(4)=135 : upper left to lower right at 45 deg direction, then rest for sparam.rest_duration
% ...
% ... to sparam.rotangles(end)
sparam.rotangles   = [0,45,90,135,180,225,270,315,0];

sparam.steps       = 16; % steps in sweeping the visual field (from start to end)

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
sparam.cycle_duration=40000; % msec
sparam.rest_duration =8000; % msec, rest after each cycle, stimulation = cycle_duration-eccrest
sparam.numRepeats=1;

%%% set number of frames to flip the screen
% Here, I set the number as large as I can to minimize vertical cynching error.
% the final 2 is for 2 times repetitions of flicker
% Set 1 if you want to flip the display at each vertical sync, but not recommended due to much CPU power
sparam.waitframes = 60*(sparam.cycle_duration./1000) / sparam.steps / ( (size(sparam.colors,1)-1)*2 );
%sparam.waitframes = Screen('FrameRate',0)*(sparam.cycle_duration./1000) / sparam.steps / ( (size(sparam.colors,1)-1)*2 );

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
run([fileparts(mfilename('fullpath')) filesep() 'sizeparams']);
%sparam.pix_per_cm=57.1429;
%sparam.vdist=65;
