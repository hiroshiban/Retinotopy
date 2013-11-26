function field=CreateCylinderField(fieldSize,cylinder_rad,cylinder_height,pix_per_deg,fine_coefficient)

% Creats a cylindrical height field image.
% function CreateCylinderField(fieldSize,cylinder_radius_deg,..
%                              cylinder_height_deg,pix_per_deg,fine_coefficient)
%
% Creates cylindrical field
% 
% [input]
% fieldSize   : the size of the field in degrees, [row,col] (deg)
% cylinder_rad: radius of a cylider, [deg]
% cylinder_height: ratio of cylinder height for 'cylinder_rad', [val]
%                  the generated cylinder's height is cylinder_rad*cylinder_height
%                  if the value is minus, the concave surface is generated.
%                  (default is convex surface)
% pix_per_deg : pixels per degree, [pixels]
% fine_coefficient : (optional) if larger, the generated oval become finer,
%                    but comsumes much CPU power. [val]
%                    (default=1, as is, no tuning)
%
% [output]
% field       : cylinder image, double format, [row,col]
% 
% Created    : "2010-06-14 12:20:56 ban"
% Last Update: "2013-11-22 18:45:59 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(fieldSize), fieldSize=8; end
if nargin<2 || isempty(cylinder_rad), cylinder_rad=3; end
if nargin<3 || isempty(cylinder_height), cylinder_height=1; end
if nargin<4 || isempty(pix_per_deg), pix_per_deg=40; end
if nargin<5 || isempty(fine_coefficient), fine_coefficient=1; end

if numel(fieldSize)==1, fieldSize=[fieldSize,fieldSize]; end

% convert to pixels and radians
fieldSize=round(fieldSize.*pix_per_deg);
cylinder_rad=round(cylinder_rad.*pix_per_deg);

% create cylindrical field
step=1/fine_coefficient;
[x,y]=meshgrid(0:step:fieldSize(2),0:step:fieldSize(1));
y=abs(y-fieldSize(1)/2);
if mod(size(y,1),2), y=y(1:end-1,:); end
if mod(size(y,2),2), y=y(:,1:end-1); end

field=zeros(size(y));
field(y<=cylinder_rad)=cylinder_height*sqrt(repmat(cylinder_rad,size(y(y<=cylinder_rad))).^2-y(y<=cylinder_rad).^2);

% adjust the size
if step~=1, field=imresize(field,step,'bilinear'); end

return
