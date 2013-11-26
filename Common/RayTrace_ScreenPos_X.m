function x_pixels = RayTrace_ScreenPos_X(zdist_fromScreen, ipd, viewdist, eye, pix_per_cm, xpos_world)

% Calculates the horizontal screen position (in pixels) of a point distance from the visual midline and z-distance.
% function x_pixels = RayTrace_ScreenPos_X(zdist_fromScreen, ipd, viewdist, eye, pix_per_cm, xpos_world)
% 
% This function calculates the horizontal screen position (in pixels) of a point distance xpos_world
% from the visual midline and zdist_fromScreen in infront (-ve) or behind (+ve) the screen
% Equation 2 from Howard and Rogers volume 2, p.541
% 
% [INPUT]
% zdist_fromScreen : distance from the screen (cm)
% ipd              : distance between left and right eyes (cm)
% viewdist         : viewing distance from eye to the screen (cm)
% pix_per_cm       : pixels per 1 centimeter
% eye              : '1/left' or '2/right', 'left' by default
% xpos_world       : x position in the world coordinate, 0 by default
% 
% [OUTPUT]
% x_pixels         : horizontal screen position (pixels)
% 
% June 29 2009 Hiroshi Ban

if nargin < 3
  help RayTrace_ScreenPos_X;
  return;
end
if nargin < 4
  eye = 1;%'left';
end
if nargin < 5
  pix_per_cm=50;
end
if nargin < 6
  xpos_world=0;
end

if eye==1 || strcmp(eye,'left')
  multi = -1;
elseif eye==2 || strcmp(eye,'right')
  multi = 1;
else 
  help RayTrace_ScreenPos_X;
  return;
end

x_pixels = pix_per_cm * ( xpos_world*viewdist + multi* zdist_fromScreen*(ipd/2) ) ./ (viewdist +  zdist_fromScreen);

return;
