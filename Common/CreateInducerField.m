function [field,mask]=CreateInducerField(fieldSize,theta_deg,orient_deg,inducer_pos,inducer_height,inducer_width,pix_per_deg)

% Creates an oriented circular slant that can be used as an inducer of depth percepts.
% function [field,mask]=CreateInducerField(fieldSize,theta_deg,orient_deg,...
%                                          inducer_pos,inducer_height,inducer_width,pix_per_deg)
%
% Creates oriented slant field
%
% [input]
% fieldSize   : the size of the field in degrees, [row,col] (deg)
% theta_deg   : an angle measured fromh the vertical, [deg]
% orient_deg  : an angle (orientation) of slant,
%               from horizontal meridian, clockwise [deg]
% inducer_pos : position of inducer along x-axis [deg]
% inducer_height : height of inducer along y-axis [deg]
% inducer_width  : width of inducer along x-axis [deg]
% pix_per_deg : pixels per degree, [pixels]
%
% [output]
% field       : grating image, double format, [row,col]
% mask        : mask field, [row,col]
%
% Created    : "2012-03-14 11:10:03 ban"
% Last Update: "2013-11-22 18:42:14 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(fieldSize), fieldSize=8; end
if nargin<2 || isempty(theta_deg), theta_deg=45; end
if nargin<3 || isempty(orient_deg), orient_deg=0; end
if nargin<4 || isempty(inducer_pos), inducer_pos=2; end
if nargin<5 || isempty(inducer_height), inducer_height=6; end
if nargin<6 || isempty(inducer_width), inducer_width=2; end
if nargin<7 || isempty(pix_per_deg), pix_per_deg=40; end

if numel(fieldSize)==1, fieldSize=[fieldSize,fieldSize]; end

% convert to pixels and radians
fieldSize=round(fieldSize.*pix_per_deg);
theta_deg=theta_deg*pi/180;
orient_deg=orient_deg*pi/180;
inducer_pos=round(inducer_pos*pix_per_deg);
inducer_height=round(inducer_height*pix_per_deg);
inducer_width=round(inducer_width*pix_per_deg);

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

% mask the outside region
mask=ones(size(field));
mask(1:ceil((size(mask,1)-inducer_height)/2),:)=0;
mask(ceil((size(mask,1)+inducer_height)/2)+1:end,:)=0;
mask(:,1:ceil((size(mask,2)-2*inducer_pos-inducer_width)/2))=0;
mask(:,ceil((size(mask,2)+2*inducer_pos+inducer_width)/2)+1:end)=0;
mask(:,ceil((size(mask,2)-2*inducer_pos+inducer_width)/2)+1:ceil((size(mask,2)+2*inducer_pos-inducer_width)/2))=0;
field(~mask)=0;

return
