function oldkey=DisableJISkeyTrouble

% Disables keys which are always ON by default (used to avoid JIS key trouble).
% function DisableJISkeyTrouble
%
% USAGE: [oldkey]=DisableJISkeyTrouble
% OUTPUT: oldkey --- old key ON/OFF info
%
% for Psychtoolbox with JIS or Japanese-106 keyboard
% This script shoud be added for preventing ASCII or Japanese-106 keyboard
% trouble (some meta keys are always ON)
%
% This script disables default-ON Key(s)
% by checking with [keyIsDown, secs, keyCode] = KbCheck();
% and disable default-ON key(s) with DisableKeysForKbCheck([keynumber])
%
% Dec 17 2007 Hiroshi Ban

clear all;
[keyIsDown,secs,keyCode]=KbCheck();
oldkey=DisableKeysForKbCheck(find(keyCode>0));

return
