function [checkerboard,mask,checkerID]=CreateCheckerBoard(rmin,rmax,width,startangle,pix_per_deg,nwedges,nrings,colors,phase)

% Creates checkerboards with compensating colors.
% function [checkerboard,mask,checkerID]=...
%    CreateCheckerBoard(rmin,rmax,width,startangle,pix_per_deg,nwedges,nrings,colors,phase)
%
% generates checkerboards with compensating colors
%
% [input]
% rmin        : checkerboard's minimum radius in deg, [val]
% rmax        : checkerboard's maximum radius in deg, [val]
% width       : checker width in deg, [val]
% startangle  : checker board start angle, from right horizontal meridian, clockwise
% pix_per_deg : pixels per degree, [val]
% nwedges     : number of wedges, [val]
% nrings      : number of rings, [val]
% colors      : checkerboard colors, [(1+2*n)x3(RGB)] or [1x3](gray-scale) matrix
%               {RGB checkerboard}
%               1=background color, 2*n=compensating color
%               e.g. colors=[128, 128, 128;
%                            255,   0,   0; 0, 255,   0;
%                            255, 255,   0; 0,   0, 255]
%               then, checkerborad{1,1} with { [255,0,0] vs [0,255,0] }
%                     checkerboard{1,2} with { [0,255,0] vs [255,0,0] }(compensating)
%                     checkerborad{2,1} with { [255,255,0] vs [0,0,255] }
%                     checkerboard{2,2} with { [0,0,255] vs [255,255,0] }(compensating)
%               will be generated.
%               {grayscale checkerboard}
%               colors=[background,check1,check2]
% phase       : (optional) checker's phase
%
% [output]
% checkerboard : output checkerboard, cell structure, {(size(colors,1)-1)/2,2}
%                2 is for compensating colors
% mask        : (optional) checkerboard regional mask, logical
% checkerID   : (optional) each checker patch's ID
%
%
% Created    : "2011-04-14 23:51:29 ban"
% Last Update: "2013-11-22 18:36:03 ban (ban.hiroshi@gmail.com)"


%% check input variables
if nargin<8, help CreateCheckerBoard; return; end
if nargin<9, phase=0; end

if mod(size(colors,1)-1,2)~=0
  error('mod(size(colors,1)-1,2) shoud be 0. check input variable.');
end

if size(colors,1)==1
  isRGB=0;
  fprintf('generating grayscale checkerboard(s)...');
else
  isRGB=1;
  fprintf('generating RGB checkerboard(s)...');
end

% convert deg to pixels
rmin=rmin*pix_per_deg;
rmax=rmax*pix_per_deg;

% convert deg to radians
startangle=mod(startangle*pi/180,2*pi);
width=width*pi/180;
%if phase>width/nwedges, phase=mod(phase,width/nwedges); end
phase=phase*pi/180;

% lims of checkerboard image
imsize_ratio=1.01;


%% processing

% base xy distance field
[xx,yy]=meshgrid((0:1:imsize_ratio*2*rmax)-imsize_ratio*rmax,(0:1:imsize_ratio*2*rmax)-imsize_ratio*rmax);
%if mod(size(xx,1),2), xx=xx(1:end-1,:); yy=yy(1:end-1,:); end
%if mod(size(xx,2),2), xx=xx(:,1:end-1); yy=yy(:,1:end-1); end
r=sqrt(xx.^2+yy.^2); % radius

% convert distance field to radians and degree fields
thetafield=mod(atan2(yy,xx),2*pi);

% calculate checkerboard's inner regions
minlim=startangle;
maxlim=mod(startangle+width,2*pi);
if minlim==maxlim % whole annulus
  inidx=find( (rmin<=r & r<=rmax) );
elseif minlim>maxlim
  inidx=find( (rmin<=r & r<=rmax) & ( (minlim<=thetafield & thetafield<=2*pi) | (0<=thetafield & thetafield<=maxlim) ) );
else
  inidx=find( (rmin<=r & r<=rmax) & ( (minlim<=thetafield) & (thetafield<=maxlim) ) );
end

%(rmin<=r & r<=rmax) &

% calculate binary class (-1/1) along eccentricity for checkerboard (anuulus)
radii=linspace(rmin,rmax,nrings+1); radii(1)=[]; % annulus width
cide=zeros(size(xx)); % checker id, eccentricity
for i=length(radii):-1:1
  cide(rmin<r & r<=radii(i))=i;
end
rings=zeros(size(cide));
rings(inidx)=2*mod(cide(inidx),2)-1; % -1/1 class;

% calculate binary class (-1/1) along eccentricity for checkerboard (anuulus)
th=thetafield(inidx)-startangle+phase;
th=mod(th,2*pi);
cidp=zeros(size(thetafield));
cidp(inidx)=ceil(th/width*nwedges); % checker id, polar angle
wedges=zeros(size(cidp));
wedges(inidx)=2*mod(cidp(inidx),2)-1; % -1/1 class

% generate base checkerboard
basecheckerboard=zeros(size(xx));
basecheckerboard(inidx)=wedges(inidx).*rings(inidx);
basecheckerboard(r>rmax)=0;
[sy,sx]=size(basecheckerboard);

% generate mask
if nargout>=2
  mask=logical(basecheckerboard);
end

% generate checkerboard ID
if nargout==3
  % correct wedge IDs
  if phase~=0 %mod(phase,width/nwedges)~=0
    cidp(inidx)=mod(cidp(inidx)-(2*pi/(width/nwedges)-1),2*pi/(width/nwedges))+1;
    minval=unique(cidp); minval=minval(2); % not 1 because the first value is 0 = background;
    cidp(cidp>0)=cidp(cidp>0)-minval+1;
    true_nwedges=numel(unique(cidp))-1; % -1 is to omit 0 = background;
  else
    true_nwedges=nwedges;
  end

  % generate checkerID
  checkerID=zeros(size(basecheckerboard));
  checkerID(inidx)=cidp(inidx)+(cide(inidx)-1)*true_nwedges;

  % exclude outliers
  %checkerID(r<rmin | rmax<r)=0;
  checkerID(checkerID<0)=0;
end

% generate colored/grayscale checkerboards
if isRGB

  checkerboard=cell((size(colors,1)-1)/2,2);
  checker_id=0;
  for cc=2:2:size(colors,1)-1
    checker_id=checker_id+1;
    for nn=1:1:2 % compensating patterns

      id=-1*(-1)^nn; % id to process 1 & -1

      tmpR=zeros(sy,sx); %basecheckerboard;
      tmpG=zeros(sy,sx); %basecheckerboard;
      tmpB=zeros(sy,sx); %basecheckerboard;

      tmpR(basecheckerboard==id)=colors(cc,1);
      tmpG(basecheckerboard==id)=colors(cc,2);
      tmpB(basecheckerboard==id)=colors(cc,3);

      tmpR(basecheckerboard==-id)=colors(cc+1,1);
      tmpG(basecheckerboard==-id)=colors(cc+1,2);
      tmpB(basecheckerboard==-id)=colors(cc+1,3);

      tmpR(basecheckerboard==0)=colors(1,1);
      tmpG(basecheckerboard==0)=colors(1,2);
      tmpB(basecheckerboard==0)=colors(1,3);

      checkerboard{checker_id,nn}=reshape([tmpR,tmpG,tmpB],[sy,sx,3]);

    end
  end

else % if isRGB

  checkerboard=cell(2,1);
  for nn=1:1:2
    checkerboard{nn}=colors(1)*ones(sy,sx);
    id=-1*(-1)^nn; % id to process 1 & -1
    checkerboard{nn}(basecheckerboard==id)=colors(2);
    checkerboard{nn}(basecheckerboard==-id)=colors(3);
  end

end % if isRGB

disp('done.');

return
