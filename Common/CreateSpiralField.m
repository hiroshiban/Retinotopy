function field=CreateSpiralField(fieldSize,spf,amp,meanval,start_angle,spiralratio,pix_per_deg,flip)

% Creates a spiral grating field image.
% function field=CreateSpiralField(fieldSize,spf,amp,meanval,start_angle,spiralratio,pix_per_deg,flip)
%
% This function generates a spiral field with values varying between -amp and amp
%
% [input]
% fieldSize   : the size of the graing in degrees, [row,col]
% spf         : the spatial frequency of the grating in cpd, [val]
% amp         : amplitude of gratings, [val]
% meanval     : baseline magnitude of gratings, [val]
% start_angle : start angle of the radial pattern, [deg]
% spiralratio : ratio of the spiral, [deg]
% pix_per_deg : pixels per degree, [val]
% flip        : [1|-1], sin wave is flipped or not
%
% [output]
% field       : radial image, double format, [row,col]
%
% Created    : "2013-08-29 11:48:56 ban"
% Last Update: "2013-11-22 23:02:32 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(fieldSize), fieldSize=8; end
if nargin<2 || isempty(spf), spf=3; end
if nargin<3 || isempty(amp), amp=1; end
if nargin<4 || isempty(meanval), meanval=0; end
if nargin<5 || isempty(start_angle), start_angle=0; end
if nargin<6 || isempty(spiralratio), spiralratio=4; end
if nargin<7 || isempty(pix_per_deg), pix_per_deg=40; end
if nargin<8 || isempty(flip), flip=1; end

% convert to pixels and radians
nw=fieldSize*spf;
fieldSize=round(fieldSize.*pix_per_deg);

% create radial
step=pi*2./(fieldSize-1);
[x,y]=meshgrid(-pi:step:pi, -pi:step:pi);
r=sqrt(x.^2+y.^2);
r=pi*r./max(r(:));

ramp=atan2(y,x)+start_angle*pi/180+r/spiralratio;

% create images
field=amp*sin(flip*ramp*nw)+meanval;

return;
