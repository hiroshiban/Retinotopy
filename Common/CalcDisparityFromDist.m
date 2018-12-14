function disparity = CalcDisparityFromDist(ipd,zdist,viewdist)

% Calculates binocular disparity (arcmin) from physical distances.
% function disparity = CalcDisparityFromDist(ipd,zdist,viewdist)
% 
% [INPUT]
% ipd       : distance between left and right eyes (cm)
% zdist     : distance from the reference plane (cm)
% viewdist  : viewing distance from eye to the screen (cm)
%
% [OUTPUT]
% disparity : disparity (arcmin)
% 
% June 29 2009 Hiroshi Ban

disparity = ipd * zdist / (viewdist*viewdist + viewdist*zdist) * 360 * 60 / (2 * pi);

return;
