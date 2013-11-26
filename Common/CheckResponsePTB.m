function [key_status,event,eventcounter]=CheckResponsePTB(key_codes,key_status,event,eventcounter,ref_time)

% Get participant's key responses using Psychtoolbox utility functions.
% function [key_status,event,eventcounter]=CheckResponsePTB(key_codes,key_status,:event,:eventcounter,:ref_time)
% (: is optional)
%
% This function checks key press(es) with PTB functions. Used for record observer responses.
%
% [input]
% key_codes    : array of key codes, [1xn] matrix in which keycodes you want to check should be included.
%                'q' and 'escape' are reserved to tell the program to force to quit.
% key_states   : array of key status, [1xn] matrix. generally all 0 by default. 1 when key is down.
% event        : (optional) cell array to store event. see AddEvent.m for details
% eventcounter : (optional) event counter. see AddEvent.m for details
% ref_time     : (optional) reference time to record the key press. The refrence can be set like ref_time=GetSecs();
%
% [output]
% key_states   : updated key_status
% event        : updated event
% eventcounter : updated eventcounter
%
%
% Created    : "2013-11-07 16:33:36 ban"
% Last Update: "2013-11-22 18:28:38 ban (ban.hiroshi@gmail.com)"

%KbName('UnifyKeyNames');
if nargin<3 || isempty(event), event=[]; end
if nargin<4 || isempty(eventcounter), eventcounter=length(event)+1; end
if nargin<5 || isempty(ref_time), ref_time=0; end

[keyIsDown,keysecs,keyCode]=KbCheck();

if keyIsDown

  if ((keyCode(kbName('q'))==1)||(keyCode(kbName('escape'))==1)) % quit events - Q key or ESC
    Screen('CloseAll');
    if nargin>=3, [event,eventcounter]=AddEvent(event,eventcounter,ref_time,'Force quit',[]); end
    finish;
  end

  for ii=1:1:numel(key_codes)
    if keyCode(key_codes(ii))==1 && key_status(ii)==0 % check the target key press and the previous status
      if nargin>=3, [event,eventcounter]=AddEvent(event,eventcounter,ref_time,'Response',sprintf('key%d',ii)); end
      key_status(:)=0; key_status(ii)=1;
    end
  end

else
  key_status(:)=0;

end % keyIsDown

return
