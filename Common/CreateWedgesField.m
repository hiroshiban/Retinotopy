function field=CreateWedgeField(fieldSize,radiusMin,radiusMax,height,nwedges,...
                                wedgeangle,rot_angle,pix_per_deg,fine_coefficient)

% Creates a wedge-shaped field image.
% function field=CreateWedgeField(fieldSize,radiusMin,radiusMax,height,nwedges,...
%                                 wedgeangle,rot_angle,pix_per_deg,fine_coefficient)
%
% This function creates a wedge-shaped (Baumkuchen) field image.
% 
% [input]
% fieldSize   : the whole image size in deg, [row,col]
% radiusMin   : the min size of the wedge in degrees, [val]
% radiusMax   : the max size of the wedge in degrees, [val]
% height      : field height, [val]
% nwedges     : the number of wedges in the field, [val]
% wedgeangle  : angle of each wedge in deg, [val]
% rot_angle   : wedge rotation angle along the center of the field in deg, [val]
% pix_per_deg : pixels per degree.
% fine_coefficient : (optional) if larger, the generated field becomes finer
%                    along x- & y-axis but comsumes much CPU power. [val]
%                    (default=1, as is, no tuning)
% 
% [output]
% field       : generated wedge field
%               the drawing start from right horizontal meridian, counter-clockwise
% 
%
% Created    : "2010-08-05 01:15:18 ban"
% Last Update: "2013-11-22 22:57:38 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<8, help CreateWedgeField; return; end
if nargin<9, fine_coefficient=1; end

if numel(fieldSize)==1, fieldSize=[fieldSize,fieldSize]; end
if radiusMin<0, radiusMin=0; end

% calculate gap between adjacent wedges
gap=(360-nwedges*wedgeangle)/nwedges;
if gap<0, error('nwedge*wedgeangle exceeds 360 deg! Check input variables'); end

% convert from deg to pixels
fieldSize=round(fieldSize.*pix_per_deg);

radiusMin=round(radiusMin/2*pix_per_deg);
radiusMax=round(radiusMax/2*pix_per_deg);

% calculate distance & angles
step=1/fine_coefficient; % over sampling
[x,y]=meshgrid(0:step:fieldSize(2),0:step:fieldSize(1));
x=x-fieldSize(2)/2; y=y-fieldSize(1)/2;
if mod(size(x,1),2), x=x(1:end-1,:); y=y(1:end-1,:); end
if mod(size(x,2),2), x=x(:,1:end-1); y=y(:,1:end-1); end
r=sqrt(x.*x+y.*y);
theta=mod(180*atan2(y,x)./pi+360+rot_angle,360); % adjust 0-360 deg

% generate wedge field
field=zeros(size(y));
for ii=1:1:nwedges % wedges
  field( (ii*gap + (ii-1)*wedgeangle <= theta) & ...
         (theta <= ii*gap + ii*wedgeangle) & ...
         (radiusMin < r) & (r < radiusMax) )=height;
end

% image resize
if fine_coefficient>1
  field=imresize(field,step,'bilinear');
end

return
