function [fMRItriggerStartON, StartWithButtonPressOn] = DecideStartMethod()

% Waits until a participant presses a Y/N key (Y:OK, N:NO).
% function [fMRItriggerStartON, StartWithButtonPressOn] = DecideStartMethod()
%
% Wait for User input to decide how to start the stimulus Presentation
% Answer [y/n] to decide the start method.
% Currently, fMRI trigger will be input from Parallel port #17
%
% [input]
% no input variable
%
% [output]
% fMRItriggerStartON     : if 1, the current fMRI experiment will start
%                          after getting a trigger signal from MRI. [0/1]
% StartWithButtonPressOn : if 1, the current fMRI experiment will start
%                          by pressing ENTER or SPACE key. [0/1]
%
% Created : Feb 04 2010 Hiroshi Ban
% Last Update: "2013-11-22 22:56:22 ban (ban.hiroshi@gmail.com)"

%Check to see if we will send parallel port trigger
fMRItriggerStartON = 0; StartWithButtonPressOn = 0;
while ~fMRItriggerStartON && ~StartWithButtonPressOn
  user_entry = input('Does stimulus presentaiton start by fMRI trigger (at BUIC) ? (y/n) : ', 's');
  if(user_entry == 'y')
    disp('Waiting a trigger from fMRI scanner...');
    fMRItriggerStartON = 1;
    break;
  elseif (user_entry == 'n')
    disp('Start with SPACE or RETURN key...');
    StartWithButtonPressOn = 1;
    break;
  else 
    disp('Please press y or n!'); continue;
  end
end
pause(1.0); % wait for 1 sec.

return
