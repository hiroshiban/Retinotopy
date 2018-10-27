% ************************************************************
% This_is_the_display_file_for_retinotopyDepth_experiment.
% Please_change_the_parameters_below.
% retinotopyDepthfMRI.m
% Programmed_by_Hiroshi_Ban___November_01_2013
% ************************************************************

% display mode, one of "mono", "dual", "dualcross", "dualparallel", "cross", "parallel", "redgreen", "greenred",
% "redblue", "bluered", "shutter", "topbottom", "bottomtop", "interleavedline", "interleavedcolumn"
dparam.ExpMode='mono';%'dualparallel';%'mono';

% a method to start stimulus presentation
% 0:ENTER/SPACE, 1:Left-mouse button, 2:the first MR trigger pulse (CiNet),
% 3:waiting for a MR trigger pulse (BUIC) -- checking onset of pin #11 of the parallel port
% or 4:custom key trigger (wait for a key input that you specify as tgt_key).
dparam.start_method=4;

% a pseudo trigger key from the MR scanner when it starts, valid only when dparam.start_method=4;
dparam.custom_trigger=KbName(84);

% keyboard settings
dparam.Key1=82; % key 1 'r'
dparam.Key2=71; % key 2 'g'

% screen settings

%%% whether displaying the stimuli in full-screen mode or
%%% as is (the precise resolution), 'true' or 'false' (true)
dparam.fullscr=false;

%%% the resolution of the screen height
dparam.ScrHeight=768;

%% the resolution of the screen width
dparam.ScrWidth=1024;

% whether forcing to use specific frame rate, if 0, the frame rate wil bw computed in the ImagesShowPTB function.
% if non zero, the value is used as the screen frame rate.
dparam.force_frame_rate=60;

% stimulus display durations in msec

%%% fixation period in msec before/after presenting the target stimuli, integer (16)
% must set above 1 TR for initializing the frame counting.
dparam.initial_fixation_time=4000;
