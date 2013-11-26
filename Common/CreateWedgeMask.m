function mask=CreateWedgeMask(sz,sz_min,sz_max,pix_per_deg)

% Creates a wedge-shaped mask field whose pixel holds 0/1 value to be used as a mask.
% function mask=CreateWedgeMask(sz,sz_min,sz_max,pix_per_deg)
%
% This function creates a wedge-shaped (Baumkuchen!) mask with 0 & 1 values.
% Mask is located in the first quadrant of the generated image (upper right).
% 
% [input]
% meanval     : baseline magnitude of gratings
% sz          : the whole image size in degrees
%               to be masked with this script's output
% sz_min      : the max size of the mask in degrees
% sz_max      : the min size of the mask in degrees
% pix_per_deg : pixels per degree.
% 
% [output]
% mask        : mask image with 0 & 1
% 
% maskval1=1  : a mask value which let the image through
% maskval2=0  : a mask value which let the image delete
% 
% !!! NOTICE !!!
% for speeding up image generation process,
% I will not put codes for nargin checks.
% Please be careful.
% 
% July 24 2009 Hiroshi Ban

% convert to pixels and radians
sz=round(sz.*pix_per_deg);
%if mod(sz,2)==1, sz=sz+1; end % important for some stimulus conditions

sz_min=round(sz_min.*pix_per_deg);
sz_max=round(sz_max.*pix_per_deg);

% create wedges
[x,y]=meshgrid(1:1:sz,sz:-1:1);
%[x,y]=meshgrid(-sz/2:1:sz/2,-sz/2:1:sz/2); % important for some stimulus conditions
r=sqrt(x.*x+y.*y);

% create wedge-shaped mask
r(r<sz_min | sz_max<r)=0;
r(sz_min<=r & r<=sz_max)=1;

% create images
mask=r;

return
