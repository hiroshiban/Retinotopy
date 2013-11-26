function field=CreateRectField(outer_fieldSize,inner_fieldSize,inner_height,pix_per_deg,fine_coefficient)

% Creates a rectangular height field.
% function field=CreateRectField(outer_fieldSize,inner_fieldSize,inner_height,pix_per_deg,fine_coefficient)
%
% Creates rectangular height field
% 
% [input]
% outer_fieldSize  : the size of the field in degrees, [row,col] (deg)
% inner_fieldSize  : the size of the field in degrees, [row,col] (deg)
% inner_height     : plane height in pix, [val]
%                    if the value is minus, near surface is generated.
% pix_per_deg : pixels per degree, [pixels]
% fine_coefficient : (optional) if larger, the generated oval become finer,
%                    but comsumes much CPU power. [val]
%                    (default=1, as is, no tuning)
%
% [output]
% field       : rectangular height field image, double format, [row,col]
% 
%
% Created    : "2010-06-14 12:20:56 ban"
% Last Update: "2013-11-22 18:39:08 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin < 4, help CreateRectField; return; end
if nargin < 5, fine_coefficient=1; end

if numel(outer_fieldSize)==1, outer_fieldSize=[outer_fieldSize,outer_fieldSize]; end
if numel(inner_fieldSize)==1, inner_fieldSize=[inner_fieldSize,inner_fieldSize]; end

% convert to pixels and radians
outer_fieldSize=round(outer_fieldSize.*pix_per_deg).*[1,fine_coefficient];
if mod(outer_fieldSize(1),2), outer_fieldSize(1)=outer_fieldSize(1)-1; end
if mod(outer_fieldSize(2),2), outer_fieldSize(2)=outer_fieldSize(2)-1; end

inner_fieldSize=round(inner_fieldSize.*pix_per_deg).*[1,fine_coefficient];
if mod(inner_fieldSize(1),2), inner_fieldSize(1)=inner_fieldSize(1)-1; end
if mod(inner_fieldSize(2),2), inner_fieldSize(2)=inner_fieldSize(2)-1; end

% create rectangular field
field=zeros(outer_fieldSize.*[1,fine_coefficient]);

rowidx=(size(field,1)-inner_fieldSize(1))/2+1:(size(field,1)+inner_fieldSize(1))/2;
colidx=(size(field,2)-inner_fieldSize(2))/2+1:(size(field,2)+inner_fieldSize(2))/2;

field(rowidx,colidx)=inner_height;

return
