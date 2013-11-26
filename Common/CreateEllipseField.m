function field=CreateEllipseField(fieldSize,spf,ab,angle,amp,meanval,pix_per_deg,flip)

% Creates an ellipse field image.
% function field=CreateEllipseField(fieldSize,spf,ab,angle,amp,meanval,pix_per_deg,flip)
%
% Generate Ellipse field with values varying between -amp and amp
%
% [input]
% fieldSize   : the size of the graing in degrees, [row,col]
% spf         : the spatial frequency of the grating in cpd, [val]
% ab          : length along x- and y-axis, [x,y]
% angle       : rotation angle, [deg]
% amp         : amplitude of gratings, [val]
% meanval     : baseline magnitude of gratings, [val]
% pix_per_deg : pixels per degree, [val]
% flip        : [1|-1], sin wave is flipped or not
%
% [output]
% field       : ellipse image, double format, [row,col]
%
% Created    : "2013-08-29 11:48:56 ban"
% Last Update: "2013-11-22 18:45:15 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(fieldSize), fieldSize=8; end
if nargin<2 || isempty(spf), spf=3; end
if nargin<3 || isempty(ab), ab=[1,2]; end
if nargin<4 || isempty(angle), angle=30; end
if nargin<5 || isempty(amp), amp=1; end
if nargin<6 || isempty(meanval), meanval=0; end
if nargin<7 || isempty(pix_per_deg), pix_per_deg=40; end
if nargin<8 || isempty(flip), flip=1; end

% convert to pixels and radians
nw=fieldSize*spf;
fieldSize=round(fieldSize.*pix_per_deg);

% convert deg to rad. -1 is required just for simplicity in rotating ellipse as described below.
angle=-1*angle*pi/180;

% create exponential
step=pi*2./(fieldSize-1);
[x,y]=meshgrid(-pi:step:pi, -pi:step:pi);

% generate rotated ellipse
F11=cos(angle)^2/ab(1)^2+sin(angle)^2/ab(2)^2;
F12=cos(angle)*sin(angle)*(-1/ab(1)^2+1/ab(2)^2);
F22=sin(angle)^2/ab(1)^2+cos(angle)^2/ab(2)^2;
ramp=sqrt(F11*(x.^2)+2*F12*(x.*y)+F22*(y.^2));

% create images
field=amp*sin(flip*ramp*nw)+meanval;

return;
