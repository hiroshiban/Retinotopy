function field=CreateRectField(outer_fieldSize,inner_fieldSize,gap_fieldSize,in_out_height,pix_per_deg,fine_coefficient)

% Creates a rectangular height field.
% function field=CreateRectField(outer_fieldSize,inner_fieldSize,gap_fieldSize,in_out_height,pix_per_deg,fine_coefficient)
%
% Creates rectangular height field
% 
% [input]
% outer_fieldSize  : the size of the field in degrees, [row,col] (deg)
% inner_fieldSize  : the size of the field in degrees, [row,col] (deg)
% gap_fieldSize    : the size (width) of the gap between inner and outer rectangles, [row,col] (deg)
% in_out_height    : plane heights in pix, [inner_rectangle_height, outer_rectangle_height]
%                    if the value is negative, rectangular plane is located to near.
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
% Last Update: "2018-11-11 16:55:38 ban"

% check input variables
if nargin<5, help(mfilename()); return; end
if nargin<6 || isempty(fine_coefficient), fine_coefficient=1; end

if numel(outer_fieldSize)==1, outer_fieldSize=[outer_fieldSize,outer_fieldSize]; end
if numel(inner_fieldSize)==1, inner_fieldSize=[inner_fieldSize,inner_fieldSize]; end
if numel(gap_fieldSize)==1, gap_fieldSize=[gap_fieldSize,gap_fieldSize]; end
if numel(in_out_height)==1, in_out_height=[in_out_height,0]; end

% convert to pixels and radians
outer_fieldSize=round(outer_fieldSize.*pix_per_deg).*[1,fine_coefficient];
if mod(outer_fieldSize(1),2), outer_fieldSize(1)=outer_fieldSize(1)-1; end
if mod(outer_fieldSize(2),2), outer_fieldSize(2)=outer_fieldSize(2)-1; end

if ~isempty(find(gap_fieldSize>0))
  gap_fieldSize=round((inner_fieldSize+gap_fieldSize).*pix_per_deg).*[1,fine_coefficient];
  if mod(gap_fieldSize(1),2), gap_fieldSize(1)=gap_fieldSize(1)-1; end
  if mod(gap_fieldSize(2),2), gap_fieldSize(2)=gap_fieldSize(2)-1; end
end

inner_fieldSize=round(inner_fieldSize.*pix_per_deg).*[1,fine_coefficient];
if mod(inner_fieldSize(1),2), inner_fieldSize(1)=inner_fieldSize(1)-1; end
if mod(inner_fieldSize(2),2), inner_fieldSize(2)=inner_fieldSize(2)-1; end

% create rectangular field
field=in_out_height(2).*ones(outer_fieldSize);

if ~isempty(find(gap_fieldSize>0))
  rowidx=(size(field,1)-gap_fieldSize(1))/2+1:(size(field,1)+gap_fieldSize(1))/2;
  colidx=(size(field,2)-gap_fieldSize(2))/2+1:(size(field,2)+gap_fieldSize(2))/2;
  field(rowidx,colidx)=NaN;
end

rowidx=(size(field,1)-inner_fieldSize(1))/2+1:(size(field,1)+inner_fieldSize(1))/2;
colidx=(size(field,2)-inner_fieldSize(2))/2+1:(size(field,2)+inner_fieldSize(2))/2;
field(rowidx,colidx)=in_out_height(1);

return
