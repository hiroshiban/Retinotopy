function field=CreatePlaneField(fieldSize,plane_height,pix_per_deg,fine_coefficient)

% Creates a plane height field.
% function field=CreatePlaneField(fieldSize,plane_height,pix_per_deg,fine_coefficient)
%
% This function creates a simple plane height field.
% 
% [input]
% fieldSize   : the size of the field in degrees, [row,col] (deg)
% plane_height: ratio of plane height for 'cylinder_rad', [val]
%               the generated cylinder's height is cylinder_rad*cylinder_height
%               if the value is minus, the concave surface is generated.
%               (default is convex surface)
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
% Created    : "2010-06-14 12:20:56 ban"
% Last Update: "2013-11-22 18:41:10 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<3, help CreatePlaneField; return; end
if nargin<4, fine_coefficient=1.0; end

% convert to pixels and radians
fieldSize=round(fieldSize.*pix_per_deg);

% create plane field
step=1/fine_coefficient;
[x,y]=meshgrid(0:step:fieldSize(2),0:1:fieldSize(1)); % oversampling along x-axis
if mod(size(y,1),2), y=y(1:end-1,:); end
if mod(size(y,2),2), y=y(:,1:end-1); end

field=plane_height*ones(size(y));

return
