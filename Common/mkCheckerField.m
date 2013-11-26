function checkerboard=mkCheckerField(dims,nwedges,nrings,phase,org)

% Creates a checkerboard field image.
% function checkerboard=mkCheckerField(dims,nwedges,nrings,org)
%
% This function generates checkerboard field
%
% [input]
% dims    : size of the image in pixels, [x,y]
% nwedges : number of wedges
% nrings  : number of rings
% phase   : (optional) phase in deg, starts from right horizontal meridian(HM), clockwise
%           e.g. phase 270 starts from upper VM to clockwise
% org     : (optional) origin, center of matrix
%
% [output]
% checkerboard : output checkerboard field
%                [1:nwedges*nring], 0 = background
%
%
% Created    : "2011-04-11 11:48:05 ban"
% Last Update: "2013-11-22 23:38:12 ban (ban.hiroshi@gmail.com)"

%% check input variables
if nargin<3, help mkChecker; return; end
if nargin<4 || isempty(phase), phase=0; end
if nargin<5 || isempty(org)
  org=(dims+1)/2; % center of matrix (x,y)=(0,0)
end

if length(org)==1, org=[org,org]; end
if length(dims)==1, dims=[dims,dims]; end

%% processing

% base image
[x,y]=meshgrid((1:dims(1))-org(1),(1:dims(1))-org(2));

% wedges
th=mod(atan2(y,x)-deg2rad(phase),2*pi);
wedges=2*mod(ceil(th/(2*pi)*nwedges),2)-1;

% rings
radii=linspace(0,dims(1)/2,nrings+1); radii(1)=[]; % annulus width
r=sqrt(x.^2+y.^2); % radius
rings=zeros(dims);
for i=length(radii):-1:1
  rings(r<=radii(i))=2*mod(i,2)-1;
end

% checkerboard
checkerboard=wedges.*rings; %((rings-1)*nwedges+wedges).*(rings>0);
checkerboard(r>dims(1)/2)=0;

return
