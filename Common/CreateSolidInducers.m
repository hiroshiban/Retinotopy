function [imgL,imgR,maskL,maskR]=CreateSolidInducers(stimSize,fieldSize,theta_deg,orient_deg,colors,ipd,vdist,...
                                         pix_per_deg,oversampling_ratio,display_flag,save_flag)

% Creates a solid rectangular depth inducers.
% function [imgL,imgR,maskL,maskR]=CreateSolidInducers(stimSize,theta_deg,orient_deg,colors,ipd,vdist,...
%                                          pix_per_deg,oversampling_ratio,display_flag,save_flag)
%
%
% Created    : "2012-03-14 14:56:13 ban"
% Last Update: "2013-11-22 23:04:41 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(stimSize), stimSize=8; end
if nargin<2 || isempty(fieldSize), fieldSize=12; end
if nargin<3 || isempty(theta_deg), theta_deg=45; end
if nargin<4 || isempty(orient_deg), orient_deg=0; end
if nargin<5 || isempty(colors), colors=[128,192]; end % colors=[background,target]
if nargin<6 || isempty(ipd), ipd=6.4; end
if nargin<7 || isempty(vdist), vdist=65; end
if nargin<8 || isempty(pix_per_deg), pix_per_deg=40; end
if nargin<9 || isempty(oversampling_ratio), oversampling_ratio=1; end
if nargin<10 || isempty(display_flag), display_flag=1; end
if nargin<11 || isempty(save_flag), save_flag=0; end

if numel(stimSize)==1, stimSize=[stimSize,stimSize]; end
if numel(fieldSize)==1, fieldSize=[fieldSize,fieldSize]; end

% convert pixels and radians
stimSize=round(pix_per_deg*stimSize);
fieldSize=round(pix_per_deg*fieldSize);
theta_deg=theta_deg*pi/180;
orient_deg=orient_deg*pi/180;

% set base position
pos=zeros(4,4);
pos(1,:)=[  1,  1,  0,  1]; pos(2,:)=[ -1,  1,  0,  1];
pos(3,:)=[ -1, -1,  0,  1]; pos(4,:)=[  1, -1,  0,  1];

% scaling
pos(:,1)=oversampling_ratio*pos(:,1).*stimSize(2)/2;
pos(:,2)=pos(:,2).*stimSize(1)/2;

% rotation matrix (affine transformation) along x-axis (slant tilt)
RotMatX=makehgtform('xrotate',theta_deg);
RotMatZ=makehgtform('zrotate',orient_deg);

% rotation matrix (affine transformation) along y-axis as to orthogonal to the left/right view sight
RotMatL=makehgtform('yrotate',atan(ipd/2/vdist));
RotMatR=makehgtform('yrotate',-atan(ipd/2/vdist));

% apply rotations
posL=pos*RotMatX*RotMatZ*RotMatL;
posR=pos*RotMatX*RotMatZ*RotMatR;

% generate whole stimulus field
step=1;
[x,y]=meshgrid(0:step:fieldSize(2),0:step:fieldSize(1));
x=x-fieldSize(2)/2; y=y-fieldSize(1)/2;
if mod(size(x,1),2), x=x(1:end-1,:); end
if mod(size(x,2),2), x=x(:,1:end-1); end
if mod(size(y,1),2), y=y(1:end-1,:); end
if mod(size(y,2),2), y=y(:,1:end-1); end

% generate left/right images
imgL=colors(1)*ones(size(x));
imgR=colors(1)*ones(size(x));

if ((posL(3,2)-posL(2,2))/(posL(3,1)-posL(2,1)))>=0 && ((posL(4,2)-posL(1,2))/(posL(4,1)-posL(1,1)))>=0
  imgL( y<((posL(1,2)-posL(2,2))/(posL(1,1)-posL(2,1)))*(x-posL(1,1))+posL(1,2) & ...
        y<((posL(2,2)-posL(3,2))/(posL(2,1)-posL(3,1)))*(x-posL(2,1))+posL(2,2) & ...
        y>((posL(4,2)-posL(3,2))/(posL(4,1)-posL(3,1)))*(x-posL(3,1))+posL(3,2) & ...
        y>((posL(1,2)-posL(4,2))/(posL(1,1)-posL(4,1)))*(x-posL(1,1))+posL(1,2) )=colors(2);
elseif ((posL(3,2)-posL(2,2))/(posL(3,1)-posL(2,1)))>=0 && ((posL(4,2)-posL(1,2))/(posL(4,1)-posL(1,1)))<0
  imgL( y<((posL(1,2)-posL(2,2))/(posL(1,1)-posL(2,1)))*(x-posL(1,1))+posL(1,2) & ...
        y<((posL(2,2)-posL(3,2))/(posL(2,1)-posL(3,1)))*(x-posL(2,1))+posL(2,2) & ...
        y>((posL(4,2)-posL(3,2))/(posL(4,1)-posL(3,1)))*(x-posL(3,1))+posL(3,2) & ...
        y<((posL(1,2)-posL(4,2))/(posL(1,1)-posL(4,1)))*(x-posL(1,1))+posL(1,2) )=colors(2);
elseif ((posL(3,2)-posL(2,2))/(posL(3,1)-posL(2,1)))<0 && ((posL(4,2)-posL(1,2))/(posL(4,1)-posL(1,1)))<0
  imgL( y<((posL(1,2)-posL(2,2))/(posL(1,1)-posL(2,1)))*(x-posL(1,1))+posL(1,2) & ...
        y>((posL(2,2)-posL(3,2))/(posL(2,1)-posL(3,1)))*(x-posL(2,1))+posL(2,2) & ...
        y>((posL(4,2)-posL(3,2))/(posL(4,1)-posL(3,1)))*(x-posL(3,1))+posL(3,2) & ...
        y<((posL(1,2)-posL(4,2))/(posL(1,1)-posL(4,1)))*(x-posL(1,1))+posL(1,2) )=colors(2);
elseif ((posL(3,2)-posL(2,2))/(posL(3,1)-posL(2,1)))<0 && ((posL(4,2)-posL(1,2))/(posL(4,1)-posL(1,1)))>=0
  imgL( y<((posL(1,2)-posL(2,2))/(posL(1,1)-posL(2,1)))*(x-posL(1,1))+posL(1,2) & ...
        y>((posL(2,2)-posL(3,2))/(posL(2,1)-posL(3,1)))*(x-posL(2,1))+posL(2,2) & ...
        y>((posL(4,2)-posL(3,2))/(posL(4,1)-posL(3,1)))*(x-posL(3,1))+posL(3,2) & ...
        y>((posL(1,2)-posL(4,2))/(posL(1,1)-posL(4,1)))*(x-posL(1,1))+posL(1,2) )=colors(2);
end

if ((posR(3,2)-posR(2,2))/(posR(3,1)-posR(2,1)))>=0 && ((posR(4,2)-posR(1,2))/(posR(4,1)-posR(1,1)))>=0
  imgR( y<((posR(1,2)-posR(2,2))/(posR(1,1)-posR(2,1)))*(x-posR(1,1))+posR(1,2) & ...
        y<((posR(2,2)-posR(3,2))/(posR(2,1)-posR(3,1)))*(x-posR(2,1))+posR(2,2) & ...
        y>((posR(4,2)-posR(3,2))/(posR(4,1)-posR(3,1)))*(x-posR(3,1))+posR(3,2) & ...
        y>((posR(1,2)-posR(4,2))/(posR(1,1)-posR(4,1)))*(x-posR(1,1))+posR(1,2) )=colors(2);
elseif ((posR(3,2)-posR(2,2))/(posR(3,1)-posR(2,1)))>=0 && ((posR(4,2)-posR(1,2))/(posR(4,1)-posR(1,1)))<0
  imgR( y<((posR(1,2)-posR(2,2))/(posR(1,1)-posR(2,1)))*(x-posR(1,1))+posR(1,2) & ...
        y<((posR(2,2)-posR(3,2))/(posR(2,1)-posR(3,1)))*(x-posR(2,1))+posR(2,2) & ...
        y>((posR(4,2)-posR(3,2))/(posR(4,1)-posR(3,1)))*(x-posR(3,1))+posR(3,2) & ...
        y<((posR(1,2)-posR(4,2))/(posR(1,1)-posR(4,1)))*(x-posR(1,1))+posR(1,2) )=colors(2);
elseif ((posR(3,2)-posR(2,2))/(posR(3,1)-posR(2,1)))<0 && ((posR(4,2)-posR(1,2))/(posR(4,1)-posR(1,1)))<0
  imgR( y<((posR(1,2)-posR(2,2))/(posR(1,1)-posR(2,1)))*(x-posR(1,1))+posR(1,2) & ...
        y>((posR(2,2)-posR(3,2))/(posR(2,1)-posR(3,1)))*(x-posR(2,1))+posR(2,2) & ...
        y>((posR(4,2)-posR(3,2))/(posR(4,1)-posR(3,1)))*(x-posR(3,1))+posR(3,2) & ...
        y<((posR(1,2)-posR(4,2))/(posR(1,1)-posR(4,1)))*(x-posR(1,1))+posR(1,2) )=colors(2);
elseif ((posR(3,2)-posR(2,2))/(posR(3,1)-posR(2,1)))<0 && ((posR(4,2)-posR(1,2))/(posR(4,1)-posR(1,1)))>=0
  imgR( y<((posR(1,2)-posR(2,2))/(posR(1,1)-posR(2,1)))*(x-posR(1,1))+posR(1,2) & ...
        y>((posR(2,2)-posR(3,2))/(posR(2,1)-posR(3,1)))*(x-posR(2,1))+posR(2,2) & ...
        y>((posR(4,2)-posR(3,2))/(posR(4,1)-posR(3,1)))*(x-posR(3,1))+posR(3,2) & ...
        y>((posR(1,2)-posR(4,2))/(posR(1,1)-posR(4,1)))*(x-posR(1,1))+posR(1,2) )=colors(2);
end

if oversampling_ratio~=1
  imgL=imresize(imgL,round([1,1/oversampling_ratio].*size(imgL)));
  imgR=imresize(imgR,round([1,1/oversampling_ratio].*size(imgR)));
end

imgL=uint8(imgL);
imgR=uint8(imgR);

% generate masks
maskL=ones(size(imgL));
maskL(imgL~=colors(1))=0;
maskR=ones(size(imgR));
maskR(imgR~=colors(1))=0;

% display the generated images
if display_flag
  figure; hold on;
  M = [imgL 127*ones(size(imgL,1),20) imgR 127*ones(size(imgL,1),20) imgL];
  im_h = imagesc(M,[0 255]);
  axis off
  % truesize is necessary to avoid automatic scaling
  size_one2one(im_h);
  colormap(gray);
  shg;
end

% save the generated images
if save_flag
  save inducers.mat imgL imgR;
end

return
