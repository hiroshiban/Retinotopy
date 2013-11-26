function field=CreateGaborField(fieldSize,spf,amp,meanval,sd,orient_deg,phase_deg,pix_per_deg,flip)

% Creates a gabor patch image.
% function field=CreateGaborField(fieldSize,spf,amp,meanval,sd,orient_deg,pix_per_deg,flip)
%
% Creates oriented gratings with values varying between -amp and amp
%
% [input]
% fieldSize   : the size of the graing in degrees, [deg]
% spf         : the spatial frequency of the grating in cpd, [val]
% amp         : amplitude of gratings, [val]
% meanval     : baseline magnitude of gratings, [val]
% sd          : standard deviation of gaussian filter in deg, [val]
% orient_deg  : the orientation of the grating in degrees, [deg]
%               0 at the upper vertical meridian, ccw
% phase_deg   : the phase shift in degrees, [deg]
% pix_per_deg : pixels per degree, [pixels]
% flip        : [1|-1], sin wave is flipped or not
%
% [output]
% field       : grating image, double format, [row,col]
%
% Created: "2010-04-03 16:26:51 ban"
% Last Update: "2013-11-22 18:43:32 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(fieldSize), fieldSize=8; end
if nargin<2 || isempty(spf), spf=3; end
if nargin<3 || isempty(amp), amp=1; end
if nargin<4 || isempty(meanval), meanval=0; end
if nargin<5 || isempty(sd), sd=3; end
if nargin<6 || isempty(orient_deg), orient_deg=45; end
if nargin<7 || isempty(phase_deg), phase_deg=90; end
if nargin<8 || isempty(pix_per_deg), pix_per_deg=40; end
if nargin<9 || isempty(flip), flip=1; end

% convert to pixels and radians
nw=fieldSize*spf;
fieldSize=round(fieldSize.*pix_per_deg);
orient_deg=orient_deg*pi/180;
phase_deg=phase_deg*pi/180;

% create grating
step=pi*2./(fieldSize-1);
[x,y]=meshgrid((-pi:step:pi)+phase_deg, (-pi:step:pi)+phase_deg);

ramp=cos(orient_deg)*x-sin(orient_deg)*y;
%ramp=cos(orient_deg)*(x+pi)-sin(orient_deg)*y;

% create images
field=amp*sin(flip*ramp*nw)+meanval;

% gaussian filter
field=GaussianWindow(field,sd,pix_per_deg);

return


%% subfunction
function img=GaussianWindow(img, sd, pix_per_deg)

% function img=GaussianWindow(img, sd, pix_per_deg)
%
% windows an square image with a Gaussian filter.
% takes as input the image, and the standard deviation of
% the filter in the x and y direction (in degrees) and the
% pixels per degree
% returns as output the filtered image.
%
% [input]
% img         : input image, [row,col]
% sd          : standard deviation of the filter, [deg]
% pix_per_deg : pixels per degree, [pix]
%
% [output]
% img         : output image, gaussian filtered, [row,col]
%
% ref IF 7/2000
%
% Created: "2010-04-03 17:09:15 ban"
% Last Update: "2010-04-03 17:24:12 ban"

% check input variables
if nargin<1, help GaussianWindow; return; end
if nargin<2 || isempty(sd), sd=1; end
if nargin<3 || isempty(pix_per_deg), pix_per_deg=40; end

filtSize =min(size(img));
sd=sd*pix_per_deg;

%[x,y] = meshgrid(round(-filtSize/2):round(filtSize/2)-1,round(-filtSize/2):round(filtSize/2)-1);
[x,y] = meshgrid(ceil(-filtSize/2):ceil(filtSize/2)-1,ceil(-filtSize/2):ceil(filtSize/2)-1);

filt = exp(-(x.^2+y.^2)/(2*sd.^2));
filt=filt./max(max(filt(:)));
img=img.*filt;

return
