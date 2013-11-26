function physical = CalcPhysicalFromAngularSize(size_deg,viewdist)

% Calculates the corresponding physical size of the stimulus.
% function physical = CalcPhysicalFromAngularSize(size_deg,viewdist)
% 
% calculate physical size of the stimulus (size_deg,viewdist)
% 
% [INPUT]
% size_deg     : the degrees of the stimulus you want to present
% viewdist     : viewing distance from eye to the screen (cm)
% 
% [OUTPUT]
% physical     : pyisical size of the stimulus you want to present (cm)
% 
% June 29 2009 Hiroshi Ban

physical = viewdist * tan(size_deg*180/pi);

return;
