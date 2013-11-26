function [PTB_OK,vertxt] = CheckPTBversion(num_mainver_youwant)

% Checks the version of the currently running Psychtoolbox.
% function [PTB_OK,vertxt] = CheckPTBversion(num_mainver_youwant)
%
% This function checks wether the PTB version you want to use is valid or not
%
% [input]
% num_mainver_youwant : version num you want, [val]
% 
% [output]
% PTB_OK   : if the version of PTB is what you want, return 1. [0/1]
% vertxt   : text message from PTB
%
% Created    : "2010-01-29 13:41:41 ban"
% Last Update: "2013-11-22 18:29:12 ban (ban.hiroshi@gmail.com)"

if nargin < 1
  wantver = num2str(3);
else 
  wantver = num2str(num_mainver_youwant);
end

if ~exist('PsychtoolboxVersion','file')
  warning('MATLAB Psychtoolbox is not installed on this machine!'); %#ok
  PTB_OK=0;
  vertxt='MATLAB Psychtoolbox is not installed on this machine!';
  return
end

ptbver=PsychtoolboxVersion();
% PTB 3 changes the output of this to a char + a struct.
% nasty way of checking is to see if class of ver is char or double - check
% the first character as Matlab complains if the length of the string is
% different
c=class(ptbver);
if c(1)=='c'
  [vertxt,verstruct]=PsychtoolboxVersion();
  ver_ma = verstruct.major; ver_mi = verstruct.minor; ver_po = verstruct.point;
  ptbversion = [num2str(ver_ma) '.' num2str(ver_mi) '.' num2str(ver_po)];
  eval(sprintf('disp (''Using Psychtoolbox %s - make sure this is correct before you continue'');',ptbversion));
else 
  disp('Your PTB''s version is 1 or 2');
  ver_ma = 2;
  vertxt = '';
end

if strcmp(num2str(ver_ma),wantver)
  PTB_OK = 1;
else 
  PTB_OK = 0;
end

return
