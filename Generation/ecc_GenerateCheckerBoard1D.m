function [checkerboard,mask]=ecc_GenerateCheckerBoard1D(edges,width,startangle,pix_per_deg,nwedges,nrings,phase)

% Generates checkerboard patterns (annulus-based subdivision) with an individual ID number on each patch.
% function [checkerboard,mask]=ecc_GenerateCheckerBoard1D(edges,width,startangle,pix_per_deg,nwedges,nrings,phase)
%
% This function generates 2 checkerboards (annulus-based subdivision) with an individual ID number on each patch.
% Each of two checkers have the compensating values of its counterpart.
% Multiple start angles are acceptable and will be processed at once, saving computational time.
%
% !!!NOTEICE!!!
% This function is a specially modified version to be used in cretinotopy function
% Please use GenerateCheckerBoard for general purposes.
%
%
% [input]
% edges       : checkerboard min/max radius and width along eccentricity in deg, [3(min,max,ringwidth) x n]
% width       : checker width along polar angle in deg, [val]
% startangle  : checker board start angle, from right horizontal meridian, clockwise
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
% Last Update: "2013-11-26 10:50:13 ban (ban.hiroshi@gmail.com)"


%% check input variables

% no input variable check for speeding up


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
mask=cell(size(edges,1),1);

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

  % generate mask
  if nargout>=2
    mask{rr}=logical(checkerboard{rr});
  end

end % for rr=1:1:size(edges,1)

return
