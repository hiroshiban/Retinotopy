function [checkerboard,bincheckerboard,mask]=ecc_GenerateCheckerBoard1D(edges,width,startangle,pix_per_deg,nwedges,nrings,phase)

% Generates checkerboard patterns (annulus-based subdivision) with an individual ID number on each patch.
% function [checkerboard,bincheckerboard,mask]=ecc_GenerateCheckerBoard1D(edges,width,startangle,pix_per_deg,nwedges,nrings,phase)
%
% This function generates 2 checkerboards (annulus-based subdivision) with an individual ID number on each patch.
% Each of two checkers have the compensating values of its counterpart.
% Multiple start angles are acceptable and will be processed at once, saving computational time.
%
% [input]
% edges       : checkerboard min/max radius and width along eccentricity in deg, [3(min,max,ringwidth) x n]
%               please see the codes below to check the default values.
% width       : checker width along polar angle in deg, [val], 360 by default
% startangle  : checker board start angle, from right horizontal meridian, clockwise, 0 by default.
% pix_per_deg : pixels per degree, [val], 40 by default.
% nwedges     : number of wedges, [val], 48 by default.
% nrings      : number of rings, [val], 2 by default.
% phase       : (optional) checker's phase, 0 by default.
%
% [output]
% checkerboard :   output grayscale checkerboard, cell structure, {numel(startangle)}.
%                  each pixel shows each checker patch's ID or background(0)
% binchckerboard : (optional) binary (1/2=checker-patterns, 0=background) checkerboard patterns,
%                  cell structure, {numel(startangle)}.
% mask           : (optional) checkerboard regional mask, cell structure, logical
%
%
% Created    : "2011-04-12 11:12:37 ban"
% Last Update: "2018-11-27 09:15:57 ban"

%% check the input variables
if nargin<1 || isempty(edges)
  edges=[0.00, 0.50, 1.00; 0.00, 0.75, 1.00; 0.00, 1.00, 1.00; 0.25, 1.25, 1.00; 0.50, 1.50, 1.00;
         0.75, 1,75, 1,00; 1.00, 2.00, 1.00; 1.25, 2.25, 1.00; 1.50, 2.50, 1.00; 1.75, 2.75, 1.00;
         2.00, 3.00, 1.00; 2.25, 3.25, 1.00; 2.50, 3.50, 1.00; 2.75, 3.75, 1.00; 3.00, 4.00, 1.00;
         3.25, 4.25, 1.00; 3.50, 4.50, 1.00; 3.75, 4.75, 1.00; 4.00, 5.00, 1.00; 4.25, 5.25, 1.00;
         4.50, 5.50, 1.00; 4.75, 5.75, 1.00; 5.00, 6.00, 1.00; 5.25, 6.00, 1.00; 5.50, 6.00, 1.00];
end
if nargin<2 || isempty(width), width=360; end
if nargin<3 || isempty(startangle), startangle=0; end
if nargin<4 || isempty(pix_per_deg), pix_per_deg=40; end
if nargin<5 || isempty(nwedges), nwedges=48; end
if nargin<6 || isempty(nrings), nrings=2; end
if nargin<7 || isempty(phase), phase=0; end

%% parameter adjusting

% convert deg to pixels
edges=edges.*pix_per_deg;

% convert deg to radians
startangle=mod(startangle*pi/180,2*pi);
width=width*pi/180;
%if phase>width/nwedges, phase=mod(phase,width/nwedges); end
phase=phase*pi/180;

% add small lim in checkerboard image, this is to avoid unwanted juggy edges
imsize_ratio=1.02;

%% generate base angle (radian) image

% base xy distance image
maxR=max(edges(:,2));
[xx,yy]=meshgrid((0:imsize_ratio*2*maxR)-imsize_ratio*maxR,(0:imsize_ratio*2*maxR)-imsize_ratio*maxR);
%if mod(size(xx,1),2), xx=xx(1:end-1,:); yy=yy(1:end-1,:); end
%if mod(size(xx,2),2), xx=xx(:,1:end-1); yy=yy(:,1:end-1); end

% calculate radius
r=sqrt(xx.^2+yy.^2); % radius

% convert distance field to radians and degree fields
thetafield=mod(atan2(yy,xx)-startangle+phase,2*pi);

%% processing

checkerboard=cell(size(edges,1),1);
if nargout>=2, bincheckerboard=cell(size(edges,1),1); end
if nargout>=3, mask=cell(size(edges,1),1); end

for rr=1:1:size(edges,1)

  rmin=edges(rr,1);
  rmax=edges(rr,2);
  ringwidth=edges(rr,3);

  % calculate inner regions
  minlim=startangle;
  maxlim=mod(startangle+width,2*pi);
  if minlim==maxlim % whole annulus
    inidx=find( (rmin<=r & r<=rmax) );
  elseif minlim>maxlim
    inidx=find( (rmin<=r & r<=rmax) & ( (minlim<=thetafield & thetafield<2*pi) | (0<=thetafield & thetafield<=maxlim) ) );
  else
    inidx=find( (rmin<=r & r<=rmax) & ( (minlim<=thetafield) & (thetafield<=maxlim) ) );
  end

  % calculate binary class (-1/1) along polar angle for checkerboard (wedge)
  th=thetafield(inidx);
  cidp=zeros(size(thetafield));
  cidp(inidx)=ceil(th/width*nwedges); % checker id, polar angle

  % correct wedge IDs
  % if phase~=0
  %   cidp(inidx)=mod(cidp(inidx)-(2*pi/(width/nwedges)-1),2*pi/(width/nwedges))+1;
  %   minval=unique(cidp); minval=minval(2); % not 1 because the first value is 0 = background;
  %   cidp(cidp>0)=cidp(cidp>0)-minval+1;
  %   true_nwedges=numel(unique(cidp))-1; % -1 is to omit 0 = background;
  % else
  %   true_nwedges=nwedges;
  % end

  % calculate binary class (-1/1) along eccentricity for checkerboard (annulus)
  radii=linspace(rmin,rmin+ringwidth,nrings+1); radii(1)=[]; % annulus width
  cide=zeros(size(xx)); % checker id, eccentricity
  for i=length(radii):-1:1
    cide(rmin<r & r<=min(radii(i),rmax))=i;
  end

  % generate checker's ID
  checkerboard{rr}=zeros(size(thetafield));
  %checkerboard{rr}(inidx)=cidp(inidx)+(cide(inidx)-1)*true_nwedges;
  checkerboard{rr}(inidx)=cidp(inidx)+(cide(inidx)-1)*nwedges;

  % delete outliers
  checkerboard{rr}(checkerboard{rr}<0)=0;

  % generate a binary (1/2=checker-patterns and 0=background) checkerboard
  if nargin>=2
    rings=zeros(size(cide));
    rings(inidx)=2*mod(cide(inidx),2)-1; % -1/1 class

    wedges=zeros(size(cidp));
    wedges(inidx)=2*mod(cidp(inidx),2)-1; % -1/1 class

    bincheckerboard{rr}=zeros(size(thetafield));
    bincheckerboard{rr}(inidx)=wedges(inidx).*rings(inidx);
    bincheckerboard{rr}(r>rmax)=0;
    bincheckerboard{rr}(bincheckerboard{rr}<0)=2;
  end

  % generate mask
  if nargout>=3, mask{rr}=logical(checkerboard{rr}); end

end % for rr=1:1:size(edges,1)

return
