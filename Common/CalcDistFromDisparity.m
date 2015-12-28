function zdist = CalcDistFromDisparity(ipd,disparity,viewdist)

% Calculates the actual distance (cm) from binocular disparity (arcmin).
% function zdist = CalcDistFromDisparity(ipd,disparity,viewdist)
% 
% [INPUT]
% ipd       : distance between left and right eyes (cm)
% disparity : disparity (arcmin)
% viewdist  : viewing distance from eye to the screen (cm)
%
% [OUTPUT]
% zdist     : distance from the reference plane (cm)
% 
% June 29 2009 Hiroshi Ban

disp_rad = disparity ./ 60 .* 2.*pi ./ 360;
zdist = (viewdist.*viewdist.*disp_rad) ./ (ipd - viewdist.*disp_rad);

return;
