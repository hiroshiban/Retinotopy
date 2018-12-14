function field=CreateWaveField(fieldSize,spf,amp,Afrq,nfrq,meanval,orient_deg,pix_per_deg,flip)

% Creates a wavy grating field image.
% function field=CreateWaveField(fieldSize,spf,amp,Afrq,nfrq,meanval,orient_deg,pix_per_deg,flip)
%
% This function creates oriented wavy gratings with values varying between -amp and amp
%
% [input]
% fieldSize   : the size of the graing in degrees, [deg]
% spf         : the spatial frequency of the grating in cpd, [val]
% amp         : amplitude of gratings, [val]
% Afrq        : amplitude of wave field modulation, [val]
% nfrq        : frequency of wave pattern, [val]
% meanval     : baseline magnitude of gratings, [val]
% orient_deg  : the orientation of the grating in degrees, [deg]
%               0 at the upper vertical meridian, ccw
% pix_per_deg : pixels per degree, [val]
% flip        : [1|-1], sin wave is flipped or not
%
% [output]
% field       : wave grating image, double format, [row,col]
%
% Created: "2010-04-03 16:26:51 ban"
% Last Update: "2013-11-22 23:01:15 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(fieldSize), fieldSize=8; end
if nargin<2 || isempty(spf), spf=3; end
if nargin<3 || isempty(amp), amp=1; end
if nargin<4 || isempty(Afrq), Afrq=0.3; end
if nargin<5 || isempty(nfrq), nfrq=3; end
if nargin<6 || isempty(meanval), meanval=0; end
if nargin<7 || isempty(orient_deg), orient_deg=45; end
if nargin<8 || isempty(pix_per_deg), pix_per_deg=40; end
if nargin<9 || isempty(flip), flip=1; end

% convert to pixels and radians
nw=fieldSize*spf;
fieldSize=round(fieldSize.*pix_per_deg);
orient_deg=orient_deg*pi/180;

% create grating
step=pi*2./(fieldSize-1);
[x,y]=meshgrid(-pi:step:pi, -pi:step:pi);

% rotate x,y coordinate
ramp1=cos(orient_deg)*x-sin(orient_deg)*y;
% create orthogonal axis
ramp2=sin( nfrq*(cos(orient_deg+pi/2)*x-sin(orient_deg+pi/2)*y) );
% generate wavy field
ramp=ramp1+Afrq*ramp2;

% create images
field=amp*sin(flip*ramp*nw)+meanval;

return
