function [img,point_idx]=GenerateGridDotImage(fieldSize,ranges,dense,jitterratio,mode,nimages,pix_per_deg,display_flg,save_flg)

% Generates a random-jittered grid-dot image.
% function [img,point_idx]=GenerateGridDotImage(fieldSize,ranges,dense,jitterratio,mode,pix_per_deg,display_flg,save_flg)
%
% This function generates a random-jittered grid-dot image in cartesian or polar coordinate space.
%
% [input]
% fieldSize   : the size of the field in degrees, [row,col]
% ranges      : range of the space in which random dots are scatterd.
%               [min(deg_row),max(deg_row);min(deg_col),max(deg_col)] in cartesian coord
%               [min(r_deg),max(r_deg);min(theta_deg),max(theta_deg)] in polar coord
%               !NOTE! the origin is the center of the image
% dense       : percentage of the dot in the space, 2 by default.
% jitterratio : a jitter ratio of each dot position in the grid array.
%               jitter is added as [x_jitter,y_jitter]=[x,y]+jitterratio*unifrnd(-1,1,[1,2]).
%               0.4 by default.
% mode        : 0=cartesian coord, 1=polar coord. 0 by default.
% nimages     : the number of images to be generated. 1 by default.
% pix_per_deg : pixels per degree, [pixels]. 40 by default.
% display_flg : if 1, the generated images are displayed. [1/0]. 1 by default.
% save_flag   : if 1, the generated images are saved. [1/0]. 0 by default.
%
% [output]
% img         : generated random dot images, cell structure, img{nimages}
% point_idx   : random points, cell structure, point_idx{nimages}=[x,y(,z)]
%
%
% Created    : "2013-08-29 11:48:39 ban"
% Last Update: "2013-11-22 23:13:26 ban (ban.hiroshi@gmail.com)"

% check input variable
if nargin<2, help(mfilename()); return; end
if nargin<3 || isempty(dense), dense=5; end
if nargin<4 || isempty(jitterratio), jitterratio=0.4; end
if nargin<5 || isempty(mode), mode=0; end
if nargin<6 || isempty(nimages), nimages=1; end
if nargin<7 || isempty(pix_per_deg), pix_per_deg=40; end
if nargin<8 || isempty(display_flg), display_flg=1; end
if nargin<9 || isempty(save_flg), save_flg=0; end

if mode~=0 && mode~=1
  error('mode should be 0 (cartesian) or 1 (polar). check input variable.');
end

% adjust ranges
if mode==0
  ranges=ranges.*pix_per_deg;
else
  ranges(1,:)=ranges(1,:).*pix_per_deg;
  ranges(2,:)=ranges(2,:).*pi/180;
end

% generate stimulus field
if numel(fieldSize)==1, fieldSize=[fieldSize,fieldSize]; end
fieldSize=round(fieldSize/2.*pix_per_deg);
step=1;
[x,y]=meshgrid(-fieldSize(2):step:fieldSize(2),-fieldSize(1):step:fieldSize(1));
if mod(size(x,1),2), x=x(1:end-1,:); y=y(1:end-1,:); end
if mod(size(x,2),2), x=x(:,1:end-1); y=y(:,1:end-1); end

% calculate centers (X,Y) of each patch
ndots=numel(x)*dense/100;
nrows=ceil(sqrt(ndots));
%ncols=ceil(ndots/nrows);
ncols=nrows; % to fix distance along x- and y-axis.

% set x,y coordinate so that the center of the dot array comes to the center of the image
p_interval=round(max(size(x))/max([nrows,ncols]));
p_edge=round(p_interval/2*jitterratio);

p_X=[flipdim(round((size(x,2)-p_interval)/2)-p_interval:-p_interval:p_edge,2),round((size(x,2)-p_interval)/2):p_interval:size(x,2)-p_edge];
p_Y=[flipdim(round((size(x,1)-p_interval)/2)-p_interval:-p_interval:p_edge,2),round((size(x,1)-p_interval)/2):p_interval:size(x,1)-p_edge];

% initializing
img=cell(nimages,1);
for nn=1:1:nimages, img{nn}=zeros(size(x)); end
point_idx=cell(nimages,1);

% processing
for nn=1:1:nimages
  timg=zeros(size(x));

  % jittering dot position (jitter range -50 to 50%)
  jittervals=unifrnd(-1,1,[numel(p_X),numel(p_Y)]);
  p_Xj=zeros(numel(p_X),numel(p_Y));
  p_Yj=zeros(numel(p_X),numel(p_Y));
  for ii=1:1:numel(p_X)
    for jj=1:1:numel(p_Y)
      p_Xj(ii,jj)=p_X(ii)+jitterratio*p_interval*jittervals(ii,jj);
      p_Yj(ii,jj)=p_Y(jj)+jitterratio*p_interval*jittervals(ii,jj);
    end
  end

  % double to integer
  p_Xj=round(p_Xj); p_Xj(p_Xj==0)=1; p_Xj(p_Xj>size(x,1))=size(x,1);
  p_Yj=round(p_Yj); p_Yj(p_Yj==0)=1; p_Yj(p_Yj>size(x,2))=size(x,2);

  % generate initial grid dot image
  tmp_idx=sub2ind(size(x),p_Yj(:),p_Xj(:));

  % spatial thresholding
  if mode==0
    % in cartesian coordinate
    sv_idx=find( ranges(2,1)<=x(tmp_idx) & x(tmp_idx)<=ranges(2,2) & ranges(1,1)<=y(tmp_idx) & y(tmp_idx)<=ranges(1,2) );
  elseif mode==1
    % in polar coordinate
    z=x(tmp_idx).^2+y(tmp_idx).^2;
    phi=cart2pol(x(tmp_idx),y(tmp_idx));
    phi(phi<0)=phi(phi<0)+2*pi;
    sv_idx=find( ranges(1,1).^2<=z & z<=ranges(1,2).^2 & ranges(2,1)<=phi & phi<=ranges(2,2) );
  end

  % generate the final random dot image
  [y_idx,x_idx]=ind2sub(size(x),tmp_idx(sv_idx));
  point_idx{nn}=[x_idx';y_idx'];
  timg(tmp_idx(sv_idx))=1;
  img{nn}=timg;
end % for nn=1:1:nimages

% displaying the mixtured image
if display_flg
  for nn=1:1:nimages
    figure; imshow(img{nn},[0,1]);
    title(sprintf('generated random grid dot image #%02d',nn));
  end
end

if save_flg
  save rdot.mat img point_idx;
end

return
