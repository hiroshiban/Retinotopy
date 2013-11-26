function field=CreateCircularSinusoidalSlantField(fieldSize,theta_deg,orient_deg,sin_amp,sin_cpd,...
                            grating_deg,aperture_deg,fill_val,outer_val,pix_per_deg,fine_coefficient)

% Creates a circular slant field with sinusoidal gratings.
% function field=CreateCircularSinusoidalSlantField(fieldSize,theta_deg,orient_deg,sin_amp,sin_cpd,...
%                                      grating_deg,aperture_deg,fill_val,pix_per_deg,fine_coefficient)
%
% Creates oriented slant with ciruclar aperture
% This function is different from CreateApertureSlantField in that
% the shape of the generated slant is adjusted as to look a perfect circle.
% 
% [input]
% fieldSize   : the size of the field in degrees, [row,col]
% theta_deg   : an angle measured fromh the vertical, [deg]
% orient_deg  : an angle (orientation) of slant,
%               from horizontal meridian, clockwise [deg]
% sin_amp     : amplitude of sinusoidal gratings, [deg]
% sin_cpd     : sinusoidal grating cycles per degree, [val]
% grating_deg : sinusoidal grating orientation, [val]
% aperture_deg: the size of circular aperture in degrees, [deg]
% fill_val    : value to fill the 'hole' of the circular aperture, [val]
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
% Last Update: "2013-11-22 18:35:21 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1  || isempty(fieldSize), fieldSize=8; end
if nargin<2  || isempty(theta_deg), theta_deg=45; end
if nargin<3  || isempty(orient_deg), orient_deg=0; end
if nargin<4  || isempty(sin_amp), sin_amp=1; end
if nargin<5  || isempty(sin_cpd), sin_cpd=2; end
if nargin<6  || isempty(grating_deg), grating_deg=0; end
if nargin<7  || isempty(aperture_deg), aperture_deg=6; end
if nargin<8  || isempty(fill_val), fill_val=NaN; end
if nargin<9  || isempty(outer_val), outer_val=0; end
if nargin<10 || isempty(pix_per_deg), pix_per_deg=40; end
if nargin<11 || isempty(fine_coefficient), fine_coefficient=1; end

if numel(fieldSize)==1, fieldSize=[fieldSize,fieldSize]; end

% convert to pixels and radians
fieldSize=round(fieldSize.*pix_per_deg);
theta_deg=theta_deg*pi/180;
orient_deg=orient_deg*pi/180;
sin_amp=sin_amp.*pix_per_deg;
sin_cpd=sin_cpd./pix_per_deg;
grating_deg=grating_deg*pi/180;
aperture_pix=round(aperture_deg/2*pix_per_deg)^2;

% create base image
step=1/fine_coefficient;
[x,y]=meshgrid(0:step:fieldSize(2),0:step:fieldSize(1));
x=x-fieldSize(2)/2; y=y-fieldSize(1)/2;
if mod(size(x,1),2), x=x(1:end-1,:); y=y(1:end-1,:); end
if mod(size(x,2),2), x=x(:,1:end-1); y=y(:,1:end-1); end

% calculate the new (x,y,z) coordinates for oriented slant
x2=x*cos(orient_deg)-y*sin(orient_deg);
y2=x*sin(orient_deg)+y*cos(orient_deg);

% calculate the new (x,y,z) coordinates for tilted grating
x3=x*cos(grating_deg)-y*sin(grating_deg);

% slant field
field=sin_amp*cos(2*pi*x3*sin_cpd)+x2*tan(theta_deg);

% calculate distance from the central fixation to each position
r=x.*x+y.*y;
r_ellipse=(x2./cos(theta_deg)).^2+y2.^2;

% fill exceeded region so that the height field is a true circular object
field( r_ellipse>aperture_pix & r<aperture_pix )=fill_val;

% create aperture
field(r>=aperture_pix)=outer_val;

% adjust the size
if step~=1, field=imresize(field,step,'bilinear'); end

return
