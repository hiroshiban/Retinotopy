function [checkerboard,mask]=CreateEccenCheckerBoardIDs(edges,width,startangle,pix_per_deg,nwedges,nrings,phase)

% Creates a annular-shaped checkerboard pattern each of whose patch has unique ID.
% function [checkerboard,mask]=CreateEccenCheckerBoardIDs(edges,width,startangle,pix_per_deg,nwedges,nrings,phase)
%
% Generates annular-shaped checkerboard ID pattern. Multiple edges are acceptable
%
% [input]
% edges       : checkerboard min/max radius along eccentricity in deg, [min,max]
% width       : checker width along polar angle in deg, [val]
% startangle  : checker board start angle, from right horizontal meridian, clockwise
%               *** multiple start angles are acceptable ***
%               e.g. [0,12,24,36,...]
% pix_per_deg : pixels per degree, [val]
% nwedges     : number of wedges, [val]
% nrings      : number of rings, [val]
% phase       : (optional) checker's phase
%
% [output]
% checkerboard : output grayscale checkerboard, cell structure, {numel(startangle)}
%                each pixel shows each checker patch's ID or background
% mask        : (optional) checkerboard regional mask, cell structure, logical
%
%
% Created    : "2011-04-12 11:12:37 ban"
% Last Update: "2013-11-22 18:45:44 ban (ban.hiroshi@gmail.com)"


%% check input variables
if nargin<6, help CreateEccenCheckerBoardIDs; return; end
if nargin<7, phase=0; end

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
%thetafield=atan2(yy,xx);
thetafield=mod(atan2(yy,xx)-startangle+phase,2*pi);

%% processing

checkerboard=cell(size(edges,1),1);
mask=cell(size(edges,1),1);

for rr=1:1:size(edges,1)

  rmin=edges(rr,1);
  rmax=edges(rr,2);

  % calculate inner regions
  minlim=startangle;
  maxlim=mod(startangle+width,2*pi);
  if minlim==maxlim % whole annulus
    inidx=find( (rmin<=r & r<=rmax) );
  elseif minlim>maxlim
    inidx=find( (rmin<=r & r<=rmax) & ( (minlim<=thetafield & thetafield<=2*pi) | (0<=thetafield & thetafield<=maxlim) ) );
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

  % calculate binary class (-1/1) along eccentricity for checkerboard (anuulus)
  radii=linspace(rmin,rmax,nrings+1); radii(1)=[]; % annulus width
  cid=zeros(size(xx)); % checker id, eccentricity
  for i=length(radii):-1:1
    cid(rmin<r & r<=radii(i))=i;
  end
  cide=cid;

  % generate checker's ID
  checkerboard{rr}=zeros(size(thetafield));
  %checkerboard{rr}(inidx)=cidp(inidx)+(cide(inidx)-1)*true_nwedges;
  checkerboard{rr}(inidx)=cidp(inidx)+(cide(inidx)-1)*nwedges;

  % delete outliers
  checkerboard{rr}(checkerboard{rr}<0)=0;

  % generate mask
  if nargout>=2
    mask{rr}=logical(checkerboard{rr});
  end

end % for rr=1:1:size(edges,1)

return
