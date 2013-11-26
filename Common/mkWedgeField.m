function [wedges,th]=mkWedgeField(dims,nwedges,phase,org)

% Creates a wedge field image.
% function [wedges,th]=mkWedgeField(dims,nwedges,phase,org)
%
% This function generates a wedge field
%
% [input]
% dims     : size of the image in pixels, [x,y]
% nwedges  : number of wedges
% phase    : (optional) phase in deg, starts from right horizontal meridian(HM), clockwise
%            e.g. phase 270 starts from upper VM to clockwise
% org      : (optional) origin, center of matrix
%
% [output]
% wedges   : wedges, clock wise from right horizontal meridian
% th       : angle, 0<=th<2*pi, clock wise from right HM + phase
%
%
% Created    : "2011-04-11 11:20:41 ban"
% Last Update: "2013-11-22 23:37:36 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<2, help mkWedge; return; end
if nargin<3 || isempty(phase), phase=0; end
if nargin<4 || isempty(org)
  org=(dims+1)/2; % center of matrix (x,y)=(0,0);
end

if size(org,1)==1, org=[org,org]; end
if length(dims)==1, dims=[dims,dims]; end

% processing
[x,y]=meshgrid((1:dims(1))-org(1),(1:dims(1))-org(2));
th=mod( atan2(y,x)-deg2rad(phase),2*pi);
wedges=ceil(th/(2*pi)*nwedges);

return
