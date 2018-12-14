function pixels=CalcPixFromVisualAngle(vdist,stim_size_in_angle,cm_per_pix)

% Computes the corresponding display pixels from visual angle.
% function pixels=CalcPixFromVisualAngle(vdist,stim_size_in_angle,cm_per_pix)
%
% [INPUT]
% vdist      : viewing distance, [cm]
% stim_size_in_angle : angle (radius) of the stimulus [deg]
% cm_per_pix : centi-meter per pixels [cm]
%
% [OUTPUT]
% pixels     : stimulus size (radius) in pixels
%
% Created    : "2013-08-29 11:50:08 ban"
% Last Update: "2013-11-22 18:17:45 ban (ban.hiroshi@gmail.com)"

pixels= round(vdist/cm_per_pix*tan(stim_size_in_angle*pi/180));

return;
