function [checkerboard,bincheckerboard,mask]=CreatePolarCheckerBoardIDs(rmin,rmax,width,startangle,pix_per_deg,nwedges,nrings,phase)

% Generates checkerboard patterns (polar angle-based subdivision) with an individual ID number on each patch.
% function [checkerboard,bincheckerboard,mask]=CreatePolarCheckerBoardIDs(rmin,rmax,width,startangle,pix_per_deg,nwedges,nrings,phase)
%
% This function generates checkerboards (polar angle-based subdivision) with an individual ID number on each patch.
% Each of two checkers have the compensating values of its counterpart.
% Multiple start angles are acceptable and will be processed at once, saving computational time.
%
% [input]
% rmin        : checkerboard's minimum radius in deg, [val], 0 by default.
% rmax        : checkerboard's maximum radius in deg, [val], 6 by default.
% width       : checker width in deg, [val], 48 by default.
% startangle  : checker board start angle, from right horizontal meridian, clockwise
%               *** multiple start angles are acceptable ***
%               e.g. [0,12,24,36,...], 0 by default.
% pix_per_deg : pixels per degree, [val], 40 by default.
% nwedges     : number of wedges, [val], 4 by default.
% nrings      : number of rings, [val], 8 by default.
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
% Last Update: "2018-11-26 19:47:48 ban"

%% check the input variables
if nargin<1 || isempty(rmin), rmin=0; end
if nargin<2 || isempty(rmax), rmax=6; end
if nargin<3 || isempty(width), width=48; end
if nargin<4 || isempty(startangle), startangle=0; end
if nargin<5 || isempty(pix_per_deg), pix_per_deg=40; end
if nargin<6 || isempty(nwedges), nwedges=4; end
if nargin<7 || isempty(nrings), nrings=8; end
if nargin<8 || isempty(phase), phase=0; end

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


%% processing

% base xy distance field
[xx,yy]=meshgrid((0:1:imsize_ratio*2*rmax)-imsize_ratio*rmax,(0:1:imsize_ratio*2*rmax)-imsize_ratio*rmax);
%if mod(size(xx,1),2), xx=xx(1:end-1,:); yy=yy(1:end-1,:); end
%if mod(size(xx,2),2), xx=xx(:,1:end-1); yy=yy(:,1:end-1); end

% convert distance field to radians and degree fields
thetafield=mod(atan2(yy,xx),2*pi);

% calculate binary class (-1/1) along eccentricity for checkerboard (anuulus)
radii=linspace(rmin,rmax,nrings+1); radii(1)=[]; % annulus width
r=sqrt(xx.^2+yy.^2); % radius
cid=zeros(size(xx)); % checker id, eccentricity
for i=length(radii):-1:1
  cid(rmin<r & r<=radii(i))=i;
end

% calculate binary class (-1/1) along polar angle for checkerboard (wedge)
% and generate checkerboards
checkerboard=cell(numel(startangle),1);
if nargout>=2, bincheckerboard=cell(numel(startangle),1); end
if nargout>=3, mask=cell(numel(startangle),1); end

for aa=1:1:numel(startangle)

  % !!!NOTICE!!!
  % We need to create each checkerboard following the procedures below
  %  1. generate radian angle field
  %  2. rotate it based on startangle & phase
  %  3. generate checkerboard IDs
  % This consumes much CPU power and time, but it is definitely important.
  %
  % To use imrotate after creating one image may look more sophisticated, but we
  % should not do that. This is because when we use imrotate (or fast_rotate)
  % or Screen('DrawTexture',....,rotangle,...), the displayed image will result
  % in low quality with juggy artefact along checker edges.

  done_flag=0;

  % just flip dimension and copy, if the currect checkerboard is one of
  % 180 deg flipped version of previously generated checkerboards.
  % this is to save calculation time
  if aa>=2
    for tt=1:1:aa-1
      %if startangle(aa)==mod(startangle(tt)+pi,2*pi)
      if abs(startangle(aa)-mod(startangle(tt)+pi,2*pi))<0.01 % this is to avoid round off error
        %fprintf('#%d checkerboard is generated by just copying/flipping from #%d checkerboard\n',aa,tt); % debug code
        checkerboard{aa}=flipdim(flipdim(checkerboard{tt},2),1);
        if nargout>=2, bincheckerboard{aa}=flipdim(flipdim(bincheckerboard{tt},2),1); end
        if nargout>=3, mask{aa}=flipdim(flipdim(mask{tt},2),1); end
        done_flag=1;
        break;
      end
    end
  end

  if ~done_flag

    % calculate inner regions
    minlim=startangle(aa);
    maxlim=mod(startangle(aa)+width,2*pi);
    if minlim==maxlim % whole annulus
      inidx=find( (rmin<=r & r<=rmax) );
    elseif minlim>maxlim
      inidx=find( (rmin<=r & r<=rmax) & ( (minlim<=thetafield & thetafield<2*pi) | (0<=thetafield & thetafield<=maxlim) ) );
    else
      inidx=find( (rmin<=r & r<=rmax) & ( (minlim<=thetafield) & (thetafield<=maxlim) ) );
    end

    % calculate wedge IDs
    th=thetafield(inidx)-startangle(aa)+phase;
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

    % calcuate ring IDs
    cide=cid;

    % generate checker's ID
    checkerboard{aa}=zeros(size(thetafield));
    checkerboard{aa}(inidx)=cidp(inidx)+(cide(inidx)-1)*true_nwedges;

    % exclude outliers
    %checkerboard{aa}(r<rmin | rmax<r)=0;
    checkerboard{aa}(checkerboard{aa}<0)=0;

    % generate a binary (1/2=checker-patterns and 0=background) checkerboard
    if nargin>=2
      rings=zeros(size(cide));
      rings(inidx)=2*mod(cide(inidx),2)-1; % -1/1 class;

      wedges=zeros(size(cidp));
      wedges(inidx)=2*mod(cidp(inidx),2)-1; % -1/1 class

      bincheckerboard{aa}=zeros(size(thetafield));
      bincheckerboard{aa}(inidx)=wedges(inidx).*rings(inidx);
      bincheckerboard{aa}(r>rmax)=0;
      bincheckerboard{aa}(bincheckerboard{aa}<0)=2;
    end

    % generate mask
    if nargout>=3, mask{aa}=logical(checkerboard{aa}); end

  end % if ~done_flag

end % for aa=1:1:numel(startangle)

return
