function mask=CreateWedgeMask(rmin,rmax,tgtmin,tgtmax,tgtwidth,start_angle,pix_per_deg)

% Creates a wedge-shaped mask with 0 & 1 values.
% function mask=CreateWedgeMask(rmin,rmax,tgtmin,tgtmax,tgtrad,start_angle,pix_per_deg)
%
% This function creates a wedge-shaped mask. The generated mask will be useful to hide specific region
% of the checkerboard etc.
%
% [input]
% rmin        : mask's minimum radius in deg, [val]
% rmax        : mask's maximum radius in deg, [val]
% tgtmin      : minimum deg of the region to be maskd, [val]
% tgtmax      : maximum deg of the region to be maskd, [val]
% tgtwidth    : width of the annulus in deg, [val]
% startangle  : checker board start angle, from right horizontal meridian, clockwise
%               *** multiple start angles are acceptable ***
%               e.g. [0,12,24,36,...]
% pix_per_deg : pixels per degree, [val]
%
% [output]
% mask        : mask image with 0 & 1, 2 cell structure, asis and its compensating
%
%
% Created    : "2009-07-24 12:20:15 ban"
% Last Update: "2018-11-26 18:41:36 ban"

% check the input variables
if nargin<1 || isempty(rmin), rmin=0.0; end
if nargin<2 || isempty(rmax), rmax=8.0; end
if nargin<3 || isempty(tgtmin), tgtmin=2.0; end
if nargin<4 || isempty(tgtmax), tgtmax=4.0; end
if nargin<5 || isempty(tgtwidth), tgtwidth=360; end
if nargin<6 || isempty(start_angle), start_angle=0; end
if nargin<7 || isempty(pix_per_deg), pix_per_deg=40; end

% convert deg to pixels
rmin=rmin*pix_per_deg;
rmax=rmax*pix_per_deg;
tgtmin=tgtmin*pix_per_deg;
tgtmax=tgtmax*pix_per_deg;

% convert deg to radians
start_angle=mod(start_angle*pi/180,2*pi);
tgtwidth=tgtwidth*pi/180;

% add small lim in checkerboard image, this is to avoid unwanted juggy edges
imsize_ratio=1.01;

%% processing

% base xy distance field
[xx,yy]=meshgrid((0:1:imsize_ratio*2*rmax)-imsize_ratio*rmax,(0:1:imsize_ratio*2*rmax)-imsize_ratio*rmax);
%if mod(size(xx,1),2), xx=xx(1:end-1,:); yy=yy(1:end-1,:); end
%if mod(size(xx,2),2), xx=xx(:,1:end-1); yy=yy(:,1:end-1); end

% convert distance field to radians and degree fields
rfield=sqrt(xx.^2+yy.^2);
thetafield=mod(atan2(yy,xx),2*pi);

% get index of the mask field
minlim=start_angle;
maxlim=mod(start_angle+tgtwidth,2*pi);
if minlim==maxlim % whole annulus
  tgtidx=find( rfield>tgtmin & rfield<tgtmax );
elseif minlim>maxlim
  tgtidx=find( (rfield>tgtmin & rfield<tgtmax) & ( (minlim<=thetafield & thetafield<2*pi) | (0<=thetafield & thetafield<=maxlim) ) );
else
  tgtidx=find( (rfield>tgtmin & rfield<tgtmax) & ( (minlim<=thetafield) & (thetafield<=maxlim) ) );
end

mask{1}=zeros(size(xx)); mask{1}(tgtidx)=1;
mask{2}=1-mask{1};

return
