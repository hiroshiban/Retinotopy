function mask=Create2WedgeMask(sz,sz_min,sz_max,pix_per_deg)

% Creates a wedge-shaped (Baumkuchen!) dual mask with 0 & 1 values.
% mask go through the image on the first and third quadrants (upper right & lower left)
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

% create 2 wedges
[x,y]=meshgrid(-sz/2+1:1:sz/2,-sz/2+1:1:sz/2);
%[x,y]=meshgrid(-sz/2:1:sz/2,-sz/2:1:sz/2); % important for some stimulus conditions
y=-y;
r=sqrt(x.*x+y.*y);

% create wedge-shaped mask
r( ( (x>0 & y<0) | (x<0 & y>0) ) )=0;
r( ( (x<=0 & y<=0) | (x>=0 & y>=0) ) & (r<sz_min | sz_max<r) )=0;
r( ( (x<=0 & y<=0) | (x>=0 & y>=0) ) & (sz_min<=r & r<=sz_max) )=1;

% create images
mask=r;

return
