function field=CreateSphereField(fieldSize,radius,meanval,pix_per_deg,flip)

% Creates a spheric height field image.
% function field=CreateSphereField(fieldSize,radius,meanval,pix_per_deg,flip)
%
% This function generates a spheric field with values varying between -amp and amp
%
% [input]
% fieldSize   : the size of the graing in degrees, [deg]
% radius      : the radius of the sphere in degrees, [deg]
% meanval     : baseline magnitude of gratings, [val]
% pix_per_deg : pixels per degree, [val]
% flip        : [1|-1], depth is flipped or not
%
% [output]
% field       : spheric height image, double format, [row,col]
%
% Created: "2010-04-03 15:03:25 ban"
% Last Update: "2013-11-22 23:03:16 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(fieldSize), fieldSize=8; end
if nargin<2 || isempty(radius), radius=1; end
if nargin<3 || isempty(meanval), meanval=0; end
if nargin<4 || isempty(pix_per_deg), pix_per_deg=40; end
if nargin<5 || isempty(flip), flip=1; end

% convert to pixels and radians
fieldSize=round(fieldSize.*pix_per_deg);
radius=round(radius.*pix_per_deg)^2;

% create distance field
hemifield=round(fieldSize/2);
[x,y]=meshgrid(-hemifield:1:hemifield,-hemifield:1:hemifield);
r=x.^2+y.^2;

% create sphere
tmp=zeros(size(r));
idx=find(r<=radius);
tmp(idx)=sqrt(radius-x(idx).^2-y(idx).^2);

% create images
field=flip*tmp+meanval;

return;
