function vergences=CalcVergencesEyeLink(data)

% Calculates vergences from EyeLink eye position XY data extracted from binocular-eye's *.acs file.
% function vergences=calc_vergences_eyelink(data)
%
% [example]
% >> data=ReadEyeLinkASC('eye_positions_bino.asc');     % read a binocular record
% >> vergences=CalcVergencesEyeLink(data(:,[2,3,5,6])); % we need to input X1, X2, Y1,and Y2 data
% >> figure;plot(data(:,1),vergences*180/pi);           % plot vergences in degree
% >> xlabel('time (msec)'); ylabel('angle (deg)');
%
% [input]
% data      : a [sampling_points x 4] matrix. the 4 columns should be
%             x1 : the second column in the target ASC file.
%             x2 : the third  column in the target ASC file.
%             y1 : the fifth  column in the target ASC file.
%             y2 : the sixth  column in the target ASC file.
%
% [output]
% vergences : vergences (radian), a [sampling_points x 1] matrix.
%
%
% Created    : "2014-10-07 15:55:08 ban"
% Last Update: "2014-10-08 11:37:35 ban"

% constants (defined in the EyeLink manual)
f=15000;
ang=57.296;

% calculate vergences
vergences=ang*acos( (f*f+data(:,1)+data(:,2)+data(:,3)+data(:,4)) ./ sqrt((f*f+data(:,1).*data(:,1)+data(:,3).*data(:,3)).*(f*f+data(:,2).*data(:,2)+data(:,4).*data(:,4))) );

return
