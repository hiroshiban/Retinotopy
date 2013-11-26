function pstart=WaitingStimulusPresentation(mode,tgt_key)

% Waits for the start of stimulus presentation.
% function pstart=WaitingStimulusPresentation(mode,:tgt_key)
% (: is optional)
%
% This function waits for stimulus presentation.
%
% [input]
% mode    : method to start the stimulus presentation
%           0:ENTER/SPACE, 1:Left-mouse button, 2:the first MR trigger pulse (CiNet),
%           3:waiting for a MR trigger pulse (BUIC) -- checking onset of pin #11 of the parallel port
%           or 4:custom key trigger (wait for a key input that you specify as tgt_key).
%           0 by default.
% tgt_key : target key that you specify to detect a trigger. a character.
%           the stimulus presentation will start when it gets tgt_key pressed.
%           's' by default. But note that the tgt_key is used only when you set mode to 4.
%
% [output]
% pstart : 0 when some error happens, 1 when the presentation start correctly
%
%
% Created    : "2013-11-08 09:25:02 ban"
% Last Update: "2013-11-22 23:50:33 ban (ban.hiroshi@gmail.com)"

% check input variable
if nargin<1 || isempty(mode), mode=0; end
if nargin<2 || isempty(tgt_key), tgt_key='s'; end
if isempty(intersect(mode,0:1:3))
  error('mode should be 0:enter/space, 1:left-mouse button, or 2:waiting the first MR trigger. check input variable.');
end

pstart=0;
if mode==0 % in the lab or test, start with button press (SPACE or RETURN key)
  while pstart==0
    [keyIsDown,junk4,keyCode]=KbCheck;
    if keyCode(KbName('space')) || keyCode(KbName('return')), pstart=1; end
  end
elseif mode==1 % left-mouse button
  while pstart==0
    [x,y,mousebutton]=GetMouse();
    if mousebutton(1), pstart=1; end
  end
elseif mode==2 % MR trigger at CiNet
  while pstart==0
    [keyIsDown,junk4,keyCode]=KbCheck;
    if keyCode(KbName('t')) || keyCode(KbName('T')), pstart=1; end
  end
elseif mode==3 % waiting the first MR trigger from parallel port (BUIC)
  cleanpport(); %clear all parallel pins
  dio=digitalio('parallel','LPT1');  % set up parallel port
  addline(dio,1:16,'in');
  addline(dio,0,'out');
  pins=getvalue(dio);
  while pins(11)==0
    pins=getvalue(dio);
    if(pins(11)), pstart=1; break; end
  end
elseif mode==4 % custom key trigger
  while pstart==0
    [keyIsDown,junk4,keyCode]=KbCheck;
    if keyCode(KbName(tgt_key)), pstart=1; end
  end
end % if mode

return
