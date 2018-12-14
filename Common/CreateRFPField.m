function field=CreateRFPField(fieldSize,spf,amp,Afrq,nfrq,startangle,meanval,pix_per_deg,flip)

% Creates a Radial-Frequency-Pattern image.
% function field=CreateRFPField(fieldSize,spf,amp,Afrq,nfrq,startangle,meanval,pix_per_deg,flip)
%
% This function generates a Radial-Frequency-Pattern field with values varying between -amp and amp
%
% [input]
% fieldSize   : the size of the graing in degrees, [row,col]
% spf         : the spatial frequency of the grating in cpd, [val]
% amp         : amplitude of gratings, [val]
% Afrq        : amplitude of radial field modulation, [val]
% nfrq        : frequency of radial frequency pattern, [val]
% startangle  : start angle of the radial frequency modulation, [val]
% meanval     : baseline magnitude of gratings, [val]
% pix_per_deg : pixels per degree, [val]
% flip        : [1|-1], sin wave is flipped or not
%
% [output]
% field       : exponential image, double format, [row,col]
%
% Created: "2010-04-03 15:03:25 ban"
% Last Update: "2013-11-22 23:05:41 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(fieldSize), fieldSize=8; end
if nargin<2 || isempty(spf), spf=3; end
if nargin<3 || isempty(amp), amp=1; end
if nargin<4 || isempty(Afrq), Afrq=0.3; end
if nargin<5 || isempty(nfrq), nfrq=5; end
if nargin<6 || isempty(startangle), startangle=0; end
if nargin<7 || isempty(meanval), meanval=0; end
if nargin<8 || isempty(pix_per_deg), pix_per_deg=40; end
if nargin<9 || isempty(flip), flip=1; end

% convert to pixels and radians
nw=fieldSize*spf;
fieldSize=round(fieldSize.*pix_per_deg);

% create exponential
step=pi*2./(fieldSize-1);
[x,y]=meshgrid(-pi:step:pi,-pi:step:pi);
theta=atan2(y,x)+startangle*pi/180;
ramp=sqrt(x.^2+y.^2).*(1+Afrq*sin(nfrq*theta));

% create images
field=amp*sin(flip*ramp*nw)+meanval;

return;
