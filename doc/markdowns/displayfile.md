````MATLAB
% ************************************************************
% This is the display configuration file for the retinotopy stimuli
% Programmed by Hiroshi Ban Nov 01 2013
% ************************************************************

% display mode, one of "mono", "dual", "dualcross", "dualparallel", "cross", "parallel", "redgreen", "greenred",
% "redblue", "bluered", "shutter", "topbottom", "bottomtop", "interleavedline", "interleavedcolumn", "propixxmono", "propixxstereo"
dparam.ExpMode='mono';%'dualparallel';%'mono';

dparam.scrID=1; % screen ID, generally 0 for a single display setup, 1 for dual display setup

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
dparam.ScrHeight=1080;

%% the resolution of the screen width
dparam.ScrWidth=1920;

% whether forcing to use specific frame rate, if 0, the frame rate wil bw computed in the ImagesShowPTB function.
% if non zero, the value is used as the screen frame rate.
dparam.force_frame_rate=60;

% whther skipping the PTB's vertical-sync signal test. if 1, the sync test is skipped
dparam.skip_sync_test=0;
````
