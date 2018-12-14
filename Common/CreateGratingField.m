function field=CreateGratingField(fieldSize,spf,amp,meanval,orient_deg,phase,pix_per_deg,flip)

% Creates a grating image.
% function field=CreateGratingField(fieldSize,spf,amp,meanval,orient_deg,pix_per_deg,flip)
%
% Creates oriented gratings with values varying between -amp and amp
%
% [input]
% fieldSize   : the size of the graing in degrees, [deg]
% spf         : the spatial frequency of the grating in cpd, [val]
% amp         : amplitude of gratings, [val]
% meanval     : baseline magnitude of gratings, [val]
% orient_deg  : the orientation of the grating in degrees, [deg]
%               0 at the upper vertical meridian, ccw
% phase       : phase of the grating, [deg]
% pix_per_deg : pixels per degree, [val]
% flip        : [1|-1], sin wave is flipped or not
%
% [output]
% field       : grating image, double format, [row,col]
%
% Created: "2010-04-03 16:26:51 ban"
% Last Update: "2015-04-26 15:37:22 ban"

% check input variables
if nargin<1 || isempty(fieldSize), fieldSize=8; end
if nargin<2 || isempty(spf), spf=3; end
if nargin<3 || isempty(amp), amp=1; end
if nargin<4 || isempty(meanval), meanval=0; end
if nargin<5 || isempty(orient_deg), orient_deg=45; end
if nargin<6 || isempty(phase), phase=0; end
if nargin<7 || isempty(pix_per_deg), pix_per_deg=40; end
if nargin<8 || isempty(flip), flip=1; end

% convert to pixels and radians
nw=fieldSize*spf;
fieldSize=round(fieldSize.*pix_per_deg);
orient_deg=orient_deg*pi/180;

% create grating
step=pi*2./(fieldSize-1);
[x,y]=meshgrid(-pi:step:pi, -pi:step:pi); %#ok
x=x+phase/180*pi;
y=y+phase/180*pi;

ramp=cos(orient_deg)*x-sin(orient_deg)*y;

% create images
field=amp*sin(flip*ramp*nw)+meanval;

return
