function field=CreateGridField(fieldSize,spf,angle,theta,amp,meanval,pix_per_deg,flip)

% Creates a grid-shaped grating image.
% function field=CreateGridField(fieldSize,spf,angle,amp,meanval,pix_per_deg,flip)
%
% Generate Grid field with values varying between -amp and amp
%
% [input]
% fieldSize   : the size of the graing in degrees, [row,col]
% spf         : the spatial frequency of the grating in cpd, [val]
% angle       : rotation angle, [deg]
% theta       : angles betwee two sine waves, [deg]
% amp         : amplitude of gratings, [val]
% meanval     : baseline magnitude of gratings, [val]
% pix_per_deg : pixels per degree, [val]
% flip        : [1|-1], sin wave is flipped or not
%
% [output]
% field       : exponential image, double format, [row,col]
%
% Created: "2010-04-03 15:03:25 ban"
% Last Update: "2013-11-22 18:43:10 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(fieldSize), fieldSize=8; end
if nargin<2 || isempty(spf), spf=3; end
if nargin<3 || isempty(angle), angle=45; end
if nargin<4 || isempty(theta), theta=90; end
if nargin<5 || isempty(amp), amp=1; end
if nargin<6 || isempty(meanval), meanval=0; end
if nargin<7 || isempty(pix_per_deg), pix_per_deg=40; end
if nargin<8 || isempty(flip), flip=1; end

% convert to pixels and radians
nw=fieldSize*spf;
fieldSize=round(fieldSize.*pix_per_deg);

% convert deg to radians
angle=angle*pi/180;
theta=theta*pi/180;

% create exponential
step=pi*2./(fieldSize-1);
[x,y]=meshgrid(-pi:step:pi, -pi:step:pi);
xx=x.*cos(angle)-y.*sin(angle);
yy=x.*sin(angle+pi/2-theta)+y.*cos(angle+pi/2-theta);

ramp1=amp*sin(flip*xx*nw);
ramp2=amp*sin(flip*yy*nw);

% create images
field=max(ramp1,ramp2)+meanval;

return;
