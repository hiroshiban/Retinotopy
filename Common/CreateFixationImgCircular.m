function fix=CreateFixationImgCircular(fixsize,fixcolor,bgcolor,circlesize,show_flag,save_flag)

% Creates a circular fixation image for a monocular display setting.
% function fiximg=CreateFixationImgCircular(fixsize,fixcolor,bgcolor,circlesize,show_flag,save_flag)
%
% Create fixation-cross images for left/right eyes
%
% [input]
% fixsize    : radius of the fixation with background, [pixel]
% fixcolor   : color of the fixation cross, [r,g,b]
% bgcolor    : color of the background, [r,g,b]
% circlesize : radius of the actual fixation point, [pixel]
% show_flag  : if 1, the generated images are displayed. [1/0]
% save_flag  : if 1, the generated images are saved. [1/0]
%
% [output]
% imgL     : fixation image for left eye
% imgR     : fixation image for right eye
%
% Created    : "2012-08-05 23:47:20 ban"
% Last Update: "2013-11-22 18:44:19 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin < 1, fixsize=32; end
if nargin < 2, fixcolor=[255,255,255]; end
if nargin < 3, bgcolor=[128,128,128]; end
if nargin < 4, circlesize=24; end
if nargin < 5, show_flag=1; end
if nargin < 6, save_flag=0; end

% generate xy coordinates
[x,y]=meshgrid(1:2*fixsize,1:2*fixsize);
x=x-fixsize; y=y-fixsize;
r=sqrt(x.*x+y.*y);

% create the circular background
alphac=r; alphac(r>fixsize)=0; alphac(r<=fixsize)=255;
bgcircle=zeros([2*fixsize,2*fixsize,4]);
for ii=1:1:3, bgcircle(:,:,ii)=bgcolor(ii); end
bgcircle(:,:,4)=alphac; % alpha channel

% create the central fixation point
for ii=1:1:3
  tmp=bgcircle(:,:,ii);
  tmp(r<circlesize)=fixcolor(ii);
  bgcircle(:,:,ii)=tmp;
end

fix=uint8(bgcircle);

if show_flag
  figure;

  imid1=imshow(fix(:,:,1:3));
  set(imid1,'AlphaData',double(fix(:,:,4)./255));
  hold on;

end

if save_flag
  save FixationImg.mat fix;
end
