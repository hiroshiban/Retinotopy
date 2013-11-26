function field=CreateSlantField(fieldSize,theta_deg,orient_deg,pix_per_deg)

% Creates a slant height field image.
% function field=CreateSlantField(fieldSize,theta_deg,orient_deg,pix_per_deg)
%
% This function creates an oriented slant field image.
%
% [input]
% fieldSize   : the size of the field in degrees, [row,col] (deg)
% theta_deg   : an angle measured fromh the vertical, [deg]
% orient_deg  : an angle (orientation) of slant,
%               from horizontal meridian, clockwise [deg]
% pix_per_deg : pixels per degree, [pixels]
%
% [output]
% field       : grating image, double format, [row,col]
%
% Created    : "2010-06-11 12:32:41 ban"
% Last Update: "2013-11-22 23:05:06 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(fieldSize), fieldSize=8; end
if nargin<2 || isempty(theta_deg), theta_deg=45; end
if nargin<3 || isempty(orient_deg), orient_deg=0; end
if nargin<4 || isempty(pix_per_deg), pix_per_deg=40; end

if numel(fieldSize)==1, fieldSize=[fieldSize,fieldSize]; end

% convert to pixels and radians
fieldSize=round(fieldSize.*pix_per_deg);
theta_deg=theta_deg*pi/180;
orient_deg=orient_deg*pi/180;

% create slant field
step=1;
[x,y]=meshgrid(0:step:fieldSize(2),0:step:fieldSize(1));
x=x-fieldSize(2)/2; y=y-fieldSize(1)/2;
if mod(size(x,1),2), x=x(1:end-1,:); end
if mod(size(x,2),2), x=x(:,1:end-1); end
if mod(size(y,1),2), y=y(1:end-1,:); end
if mod(size(y,2),2), y=y(:,1:end-1); end
z = x*cos(orient_deg) - y*sin(orient_deg);

field=z*tan(theta_deg);

return
