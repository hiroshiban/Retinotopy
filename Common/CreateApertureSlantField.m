function field=CreateApertureSlantField(fieldSize,theta_deg,orient_deg,aperture_deg,outer_val,pix_per_deg,fine_coefficient)

% Creates a slant field that is cut by a circular aperture.
% function field=CreateApertureSlantField(fieldSize,theta_deg,orient_deg,aperture_deg,outer_val,pix_per_deg,fine_coefficient)
%
% Creates oriented slant with ciruclar aperture
% 
% [input]
% fieldSize   : the size of the field in degrees, [row,col]
% theta_deg   : an angle measured fromh the vertical, [deg]
% orient_deg  : an angle (orientation) of slant,
%               from horizontal meridian, clockwise [deg]
% aperture_deg: the size of circular aperture in degrees, [deg]
% outer_val   : value to fill the outer region of slant field, [val]
% pix_per_deg : pixels per degree, [pixels]
% fine_coefficient : (optional) if larger, the generated oval become finer,
%                    but comsumes much CPU power. [val]
%                    (default=1, as is, no tuning)
%
% 
% [output]
% field       : grating image, double format, [row,col]
% 
% Created    : "2010-06-11 12:32:41 ban"
% Last Update: "2013-11-22 18:37:03 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(fieldSize), fieldSize=8; end
if nargin<2 || isempty(theta_deg), theta_deg=45; end
if nargin<3 || isempty(orient_deg), orient_deg=0; end
if nargin<4 || isempty(aperture_deg), aperture_deg=6; end
if nargin<5 || isempty(outer_val), outer_val=0; end
if nargin<6 || isempty(pix_per_deg), pix_per_deg=40; end
if nargin<7 || isempty(fine_coefficient), fine_coefficient=1; end

if numel(fieldSize)==1, fieldSize=[fieldSize,fieldSize]; end

% convert to pixels and radians
fieldSize=round(fieldSize.*pix_per_deg);
theta_deg=theta_deg*pi/180;
orient_deg=orient_deg*pi/180;
aperture_pix=round(aperture_deg/2*pix_per_deg)^2;

% create slant field
step=1/fine_coefficient;
[x,y]=meshgrid(0:step:fieldSize(2),0:step:fieldSize(1));
x=x-fieldSize(2)/2; y=y-fieldSize(1)/2;
if mod(size(x,1),2), x=x(1:end-1,:); y=y(1:end-1,:); end
if mod(size(x,2),2), x=x(:,1:end-1); y=y(:,1:end-1); end
z = x*cos(orient_deg) - y*sin(orient_deg);

field=z*tan(theta_deg);

r=x.*x+y.*y;
field(r>=aperture_pix)=outer_val;

% adjust the size
if step~=1, field=imresize(field,step,'bilinear'); end

return
