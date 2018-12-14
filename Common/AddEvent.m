function [event,eventcounter]=AddEvent(event,eventcounter,ref_time,name,parameter)

% Adds event name and its parameter to event arrays.
% function [event,eventcounter]=AddEvent(event,eventcounter,ref_time,name,parameter)
%
% This function adds event name and its parameter to event arrays
%
% [input]
% event        : (optional) cell array to store event. see AddEvent.m for details
% eventcounter : (optional) event counter. see AddEvent.m for details
% ref_time     : (optional) reference time to record the key press. The refrence can be set like ref_time=GetSecs();
% name         : name of the event
% parameter    : parameter to be recorded. e.g. 'stim on'
%
% [output]
% event        : updated event
% eventcounter : updated eventcounter
%
%
% Created
% Last Update: "2013-11-22 18:26:00 ban (ban.hiroshi@gmail.com)"

event{eventcounter,1}=GetSecs()-ref_time;
event{eventcounter,2}=name;
event{eventcounter,3}=parameter;
eventcounter=eventcounter+1;

return
