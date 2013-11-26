% ************************************************************
% This_is_the_display_file_for_retinotopyDepth_experiment.
% Please_change_the_parameters_below.
% retinotopyDepthfMRI.m
% Programmed_by_Hiroshi_Ban___November_01_2013
% ************************************************************

% display mode, one of "mono", "dual", "cross", "parallel", "redgreen", "greenred",
% "redblue", "bluered", "shutter", "topbottom", "bottomtop", "interleavedline", "interleavedcolumn"
dparam.ExpMode='mono';

% a method to start stimulus presentation
% 0:ENTER/SPACE, 1:Left-mouse button, 2:the first MR trigger pulse (CiNet), 3:waiting for a MR trigger pulse (BUIC) -- checking onset of pin #11 of the parallel port
% or 4:custom key trigger (wait for a key input that you specify as tgt_key).
dparam.start_method=2;

% a pseudo trigger key from the MR scanner when it starts, only valid when dparam.start_method=4;
dparam.custom_trigger='t';

% keyboard settings
dparam.Key1=51; % key 1 (left)
dparam.Key2=52; % key 2 (right)

% screen settings

%%% whether displaying the stimuli in full-screen mode or
%%% as is (the precise resolution), 'true' or 'false' (true)
dparam.fullscr=false;

%%% the resolution of the screen height
dparam.ScrHeight=1024;

%% the resolution of the screen width
dparam.ScrWidth=1280;

% stimulus display durations in msec

%%% fixation period in msec before/after presenting the target stimuli, integer (16)
% must set above 1 TR for initializing the frame counting.
dparam.initial_fixation_time=16000;
