function GammaResetPTB(luminance_ratio)

% Resets display gamma with PTB Screen() function.
% function GammaResetPTB(:luminance_ratio)
% (: is optional)
%
% Resets gamma tables to a default (linear, no gamma applied) setting using PTB Screen() function.
%
% [input]
% luminance_ratio : gain(s) of the luminance, 0.0-1.0. a scalar or 1x3 vector (RGB). 1.0 by default.
%                    I recommend to use this option only when gamma-level is adjusted by hardware
%                    or device settings. I can not confirm the validity of this option on a computer
%                    whose gamma is software-adjusted.
%
% [output]
% no output variable
%
% [dependency]
% Psychtoolbox by Denis Pelli et al. version 3.x or above. Should be installed independently.
%
% !!!NOTICE!!!
% If the luminance_ratio is too small, the general graphics driver can not handle it to assign voltage,
% and will result in error. luminance_ratio>=0.5 is recommended.
%
%
% Created    : "2011-09-06 17:44:10 banh"
% Last Update: "2013-11-22 18:51:04 ban (ban.hiroshi@gmail.com)"

% check input variable
if nargin<1, luminance_ratio=1.0; end

if numel(luminance_ratio)==1, luminance_ratio=repmat(luminance_ratio,1,3); end
if size(luminance_ratio,1)==3, luminance_ratio=luminance_ratio'; end

% generate default gamma table (no correction)
gamma_table=([luminance_ratio(1)*linspace(0.0,1.0,256);luminance_ratio(2)*linspace(0.0,1.0,256);luminance_ratio(3)*linspace(0.0,1.0,256)])';

% applying the default gamma table
screencount=size(Screen('Screens'),2)-1;
for ii=0:screencount, Screen('LoadNormalizedGammaTable',ii,gamma_table); end

return
