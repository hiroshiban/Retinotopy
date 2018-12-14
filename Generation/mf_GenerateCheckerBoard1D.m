function [checkerboard,bincheckerboard,mfcheckerboard,mask]=mf_GenerateCheckerBoard1D(rmin,rmax,width,ndivsP,ndivsE,startangle,pix_per_deg,nwedges,nrings,phase)

% Generates multi-focal checkerboard patterns (polar angle-based subdivision) with an individual ID number on each patch.
% function [checkerboard,bincheckerboard,mfcheckerboard,mask]=mf_GenerateCheckerBoard1D(:rmin,:rmax,:width,:ndivsP,:ndivsE,:startangle,:pix_per_deg,:nwedges,:nrings,:phase)
% (: is optional)
%
% This function generates multi-focal checkerboards (polar-angle and eccentricity-based subdivisions)
% with an individual ID number on each patch.
% Each of two checkers have the compensating values of its counterpart.
% reference: Multifocal fMRI mapping of visual cortical areas.
%            Vanni, S., Henriksson, L., James, A.C. (2005). Neuroimage, 27(1), 95-105.
%
% [input]
% rmin        : checkerboard's minimum radius in deg, [val], 0 by default.
% rmax        : checkerboard's maximum radius in deg, [val], 6 by default.
% width       : checker width in deg, [val], 360 by default.
% ndivsP      : the number of subdivisions of the visual field along the polar angle (against width (deg)), 12 by default.
%               this value is for subdividing VISUAL FIELD for multi-focal retinotopy stimulation, not for checker pattern subdivisions.
% ndivsE      : the number of subdivisions of the visual field along the eccentricity (rmin-rmax deg), 3 by default.
%               this value is for subdividing VISUAL FIELD for multi-focal retinotopy stimulation, not for checker pattern subdivisions.
% startangle  : checker board start angle, from right horizontal meridian, clockwise, 0 by default.
% pix_per_deg : pixels per degree, [val], 40 by default.
% nwedges     : number of wedges, [val], 36 by default.
%               this value is used for checker pattern subdivisions.
% nrings      : number of rings, [val], 9 by default.
%               this value is used for checker pattern subdivisions.
% phase       : (optional) checker's phase, 0 by default.
%
% [output]
% checkerboard   :   output grayscale checkerboard, cell structure, {numel(startangle)}.
%                    each pixel shows each checker patch's ID or background(0)
% binchckerboard : (optional) binary (1/2=checker-patterns, 0=background) checkerboard patterns,
%                  cell structure, {numel(startangle)}.
% mfcheckerboard : (optional) checkerboard whose checker IDs are subdivided by ndivsP and ndivsE.
%                  the pattern can be used for visual field subdivisions for multi-focal retinotpy stimuli.
% mask           : (optional) checkerboard regional mask, cell structure, logical
%
%
% Created    : "2011-04-12 11:12:37 ban"
% Last Update: "2018-12-11 18:16:38 ban"

%% check the input variables
if nargin<1 || isempty(rmin), rmin=0; end
if nargin<2 || isempty(rmax), rmax=6; end
if nargin<3 || isempty(width), width=360; end
if nargin<4 || isempty(ndivsP), ndivsP=12; end
if nargin<5 || isempty(ndivsE), ndivsE=3; end
if nargin<6 || isempty(startangle), startangle=0; end
if nargin<7 || isempty(pix_per_deg), pix_per_deg=40; end
if nargin<8 || isempty(nwedges), nwedges=36; end
if nargin<9 || isempty(nrings), nrings=9; end
if nargin<10 || isempty(phase), phase=0; end

%% parameter adjusting

% convert deg to pixels
rmin=rmin*pix_per_deg;
rmax=rmax*pix_per_deg;

% convert deg to radians
startangle=mod(startangle*pi/180,2*pi);
width=width*pi/180;
if phase>width/nwedges, phase=mod(phase,width/nwedges); end
phase=phase*pi/180;

% add small lim in checkerboard image, this is to avoid unwanted juggy edges
imsize_ratio=1.01;

% base xy distance field
[xx,yy]=meshgrid((0:1:imsize_ratio*2*rmax)-imsize_ratio*rmax,(0:1:imsize_ratio*2*rmax)-imsize_ratio*rmax);
%if mod(size(xx,1),2), xx=xx(1:end-1,:); yy=yy(1:end-1,:); end
%if mod(size(xx,2),2), xx=xx(:,1:end-1); yy=yy(:,1:end-1); end

% convert distance field to radians and degree fields
thetafield=mod(atan2(yy,xx),2*pi);

%% generating the checkerboard pattern

% calculate binary class (-1/1) along eccentricity for checkerboard (anuulus)
radii=linspace(rmin,rmax,nrings+1); radii(1)=[]; % annulus width
r=sqrt(xx.^2+yy.^2); % radius
cid=zeros(size(xx)); % checker id, eccentricity
for i=length(radii):-1:1
  cid(rmin<r & r<=radii(i))=i;
end

% calculate binary class (-1/1) along polar angle for checkerboard (wedge)

% calculate inner regions
maxlim=mod(startangle+width,2*pi);
if startangle==maxlim % whole annulus
  inidx=find( (rmin<=r & r<=rmax) );
elseif startangle>maxlim
  inidx=find( (rmin<=r & r<=rmax) & ( (startangle<=thetafield & thetafield<2*pi) | (0<=thetafield & thetafield<=maxlim) ) );
else
  inidx=find( (rmin<=r & r<=rmax) & ( (startangle<=thetafield) & (thetafield<=maxlim) ) );
end

% calculate wedge IDs
th=thetafield(inidx)-startangle+phase;
th=mod(th,2*pi);
cidp=zeros(size(thetafield));
cidp(inidx)=ceil(th/width*nwedges); % checker id, polar angle

% correct wedge IDs
if phase~=0 %mod(phase,width/nwedges)~=0
  cidp(inidx)=mod(cidp(inidx)-(2*pi/(width/nwedges)-1),2*pi/(width/nwedges))+1;
  minval=unique(cidp); minval=minval(2); % not 1 because the first value is 0 = background;
  cidp(cidp>0)=cidp(cidp>0)-minval+1;
  true_nwedges=numel(unique(cidp))-1; % -1 is to omit 0 = background;
else
  true_nwedges=nwedges;
end

% generate checker's ID
checkerboard=zeros(size(thetafield));
checkerboard(inidx)=cidp(inidx)+(cid(inidx)-1)*true_nwedges;

% exclude outliers
%checkerboard(r<rmin | rmax<r)=0;
checkerboard(checkerboard<0)=0;

%% generate a binary (1/2=checker-patterns and 0=background) checkerboard

if nargout>=2
  rings=zeros(size(cid));
  rings(inidx)=2*mod(cid(inidx),2)-1; % -1/1 class;

  wedges=zeros(size(cidp));
  wedges(inidx)=2*mod(cidp(inidx),2)-1; % -1/1 class

  bincheckerboard=zeros(size(thetafield));
  bincheckerboard(inidx)=wedges(inidx).*rings(inidx);
  bincheckerboard(r>rmax)=0;
  bincheckerboard(bincheckerboard<0)=2;
end

%% generate a checkerboard subdivided by ndivsP and ndivsE for multi-focal retinotopy stimuli

if nargout>=3
  % calculate binary class (-1/1) along eccentricity for checkerboard (anuulus)
  radii=linspace(rmin,rmax,ndivsE+1); radii(1)=[]; % annulus width
  r=sqrt(xx.^2+yy.^2); % radius
  cid=zeros(size(xx)); % checker id, eccentricity
  for i=length(radii):-1:1
    cid(rmin<r & r<=radii(i))=i;
  end

  % calculate binary class (-1/1) along polar angle for checkerboard (wedge)

  % calculate inner regions
  maxlim=mod(startangle+width,2*pi);
  if startangle==maxlim % whole annulus
    inidx=find( (rmin<=r & r<=rmax) );
  elseif startangle>maxlim
    inidx=find( (rmin<=r & r<=rmax) & ( (startangle<=thetafield & thetafield<2*pi) | (0<=thetafield & thetafield<=maxlim) ) );
  else
    inidx=find( (rmin<=r & r<=rmax) & ( (startangle<=thetafield) & (thetafield<=maxlim) ) );
  end

  % calculate wedge IDs
  th=thetafield(inidx)-startangle+phase;
  th=mod(th,2*pi);
  cidp=zeros(size(thetafield));
  cidp(inidx)=ceil(th/width*ndivsP); % checker id, polar angle

  % correct wedge IDs
  if phase~=0 %mod(phase,width/ndivsP)~=0
    cidp(inidx)=mod(cidp(inidx)-(2*pi/(width/ndivsP)-1),2*pi/(width/ndivsP))+1;
    minval=unique(cidp); minval=minval(2); % not 1 because the first value is 0 = background;
    cidp(cidp>0)=cidp(cidp>0)-minval+1;
    true_nwedges=numel(unique(cidp))-1; % -1 is to omit 0 = background;
  else
    true_nwedges=ndivsE;
  end

  % generate checker's ID
  mfcheckerboard=zeros(size(thetafield));
  mfcheckerboard(inidx)=cidp(inidx)+(cid(inidx)-1)*true_nwedges;
end

%% generate a checkerboard mask
if nargout>=4, mask=logical(checkerboard); end

return
