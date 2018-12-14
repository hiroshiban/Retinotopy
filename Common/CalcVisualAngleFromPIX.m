function vangle=CalcVisualAngleFromPIX(vdist,stim_size_in_pix,cm_per_pix)

% Calculates the corresponding visual angle (deg) from display pixels.
% function vangle=CalcVisualAngleFromPIX(vdist,stim_size_in_pix,cm_per_pix)
%
% [INPUT]
% vdist      : viewing distance, [cm]
% stim_size_in_pix : size of the stimulus in deg [deg]
% cm_per_pix : centi-meter per pixels [cm]
% 
% [OUTPUT]
% vangle     : visual angle in deg
%
% Created    : "2010-06-23 14:56:49 ban" 
% Last Update: "2013-11-22 18:29:42 ban (ban.hiroshi@gmail.com)"

vangle= atan( stim_size_in_pix*cm_per_pix / vdist) * 180 / pi;

return;
