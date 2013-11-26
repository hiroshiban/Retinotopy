function rings=mkRingField(dims,radii,org)

% Creates a ring field image.
% function rings=mkRingField(dims,radii,org)
%
% This function generates a ring field
%
% [input]
% dims     : size of the image in pixels, [x,y]
% radii    : vector radius(1) --> 1
% org      : (optional) origin, center of matrix
%
% [output]
% rings    : output ring field
%
%
% Created    : "2011-04-11 11:27:29 ban"
% Last Update: "2013-11-22 23:37:51 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<2, help mkRing; return; end
if nargin<3 || isempty(org)
  org=(dims+1)/2; % center of matrix (x,y)=(0,0);
end

if length(org)==1, org=[org,org]; end
if length(dims)==1, dims=[dims,dims]; end

% processing
[x,y]=meshgrid((1:dims(1))-org(1),(1:dims(1))-org(2));
r=sqrt(x.^2+y.^2); % radius

rings=zeros(dims);
for i=length(radii):-1:1
  rings(r<=radii(i))=i;
end

return
