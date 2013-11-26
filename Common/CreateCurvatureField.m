function field=CreateCurvatureField(fieldSize,curvature_rad,curvature_height,pix_per_deg,fine_coefficient)

% Creates 3D-cosine-wave-based curvature fields.
% function CreateCurvatureField(fieldSize,curvature_radius_deg,..
%                               curvature_height_deg,pix_per_deg,fine_coefficient)
%
% Creates curvature field
% 
% [input]
% fieldSize   : the size of the field in degrees, [row,col] (deg)
% curvature_rad: radius of a cylider, [deg]
% curvature_height: ratio of cylinder height for 'curvature_rad', [val]
%                  the generated cylinder's height is curvature_rad*curvature_height
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
% !!! NOTICE !!!
% for speeding up image generation process,
% I will not put codes for nargin checks.
% Please be careful.
%
% Created    : "2010-07-13 15:09:06 ban"
% Last Update: "2013-11-22 18:31:56 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(fieldSize), fieldSize=8; end
if nargin<2 || isempty(curvature_rad), curvature_rad=3; end
if nargin<3 || isempty(curvature_height), curvature_height=1; end
if nargin<4 || isempty(pix_per_deg), pix_per_deg=40; end
if nargin<5 || isempty(fine_coefficient), fine_coefficient=1; end

if numel(fieldSize)==1, fieldSize=[fieldSize,fieldSize]; end

% convert to pixels and radians
fieldSize=round(fieldSize.*pix_per_deg);
curvature_rad=round(curvature_rad.*pix_per_deg)^2;

% create cylindrical field
step=1/fine_coefficient;
[x,y]=meshgrid(0:step:fieldSize(2),0:1:fieldSize(1)); % oversampling along x-axis
x=x-fieldSize(2)/2; y=y-fieldSize(1)/2;
if mod(size(x,1),2), x=x(1:end-1,:); y=y(1:end-1,:); end
if mod(size(x,2),2), x=x(:,1:end-1); y=y(:,1:end-1); end
r=x.*x+y.*y;

field=zeros(size(y));
field(r<=curvature_rad) = curvature_height.*(cos( r(r<=curvature_rad).*pi./sqrt(curvature_rad) )+1)/2;

return
