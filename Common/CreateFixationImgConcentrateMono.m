function fix=CreateFixationImgConcentrateMono(fixsize,fixcolor,bgcolor,circlesize,gap,show_flag,save_flag)

% Creates a circular fixation image for a monocular display setting.
% function fiximg=CreateFixationImgConcentrateMono(:fixsize,:fixcolor,:bgcolor,:circlesize,:gap,:show_flag,:save_flag)
% (: is optional)
%
% Create fixation-cross image that is reported to be able to get more stable and sustained
% fixation with minimum eye movements.
% reference: Thaler, L., Shutz, A.C., Goodale, M.A., Gegenfurtner, K.R. (2013).
%            What is the best fixation target? The effect of target shape on stability of fixational eye movements.
%            Vision Research, 76, 31-42.
%            https://www.sciencedirect.com/science/article/pii/S0042698912003380
%
% [input]
% fixsize    : radius of the whole rectangular image, [pixel]. 32 by default.
% fixcolor   : color of the fixation cross, [r,g,b]. [255,255,255] by default.
% bgcolor    : color of the background, [r,g,b]. [128,128,128] by default.
% circlesize : radius of the actual fixation point, [inner_pixel,outer_pixel]. [6,24] by default.
% gap        : gap between inner and the outer circle, [pixel]. 0 by default.
% show_flag  : if 1, the generated images are displayed. [1|0]. 1 by default.
% save_flag  : if 1, the generated images are saved. [1|0]. 0 by default.
%
% [output]
% fix        : fixation image.
%
% [reference]
% 
%
% Created    : "2019-02-12 14:32:02 ban"
% Last Update: "2019-02-19 20:01:55 ban"

% check the input variables
if nargin < 1, fixsize=32; end
if nargin < 2, fixcolor=[255,255,255]; end
if nargin < 3, bgcolor=[128,128,128]; end
if nargin < 4, circlesize=[6,24]; end
if nargin < 5, gap=0; end
if nargin < 6, show_flag=1; end
if nargin < 7, save_flag=0; end

bgcolor=reshape(bgcolor,[1,3]);

if numel(circlesize)~=2
  error('curclesize should be [inner_pixel,outer_pixel]. check the input variable.');
end

% generate xy coordinates
[x,y]=meshgrid(1:2*fixsize,1:2*fixsize);
x=x-fixsize; y=y-fixsize;
r=sqrt(x.*x+y.*y);

% create the circular background
alphac=r; alphac(r>fixsize)=0; alphac(r<=fixsize)=255;
fix=repmat(reshape([bgcolor,1],[1,1,1,4]),[2*fixsize,2*fixsize]);
fix(:,:,4)=alphac; % alpha channel

% create the central fixation point
for ii=1:1:3
  tmp=fix(:,:,ii);
  tmp(r<circlesize(2))=fixcolor(ii);
  tmp( (-circlesize(1)-gap<=x & x<=circlesize(1)+gap) | (-circlesize(1)-gap<=y & y<=circlesize(1)+gap) ) = bgcolor(ii);
  tmp(r<circlesize(1))=fixcolor(ii);
  fix(:,:,ii)=tmp;
  clear tmp;
end

fix=uint8(fix);

if show_flag
  figure;

  imid1=imshow(fix(:,:,1:3));
  set(imid1,'AlphaData',double(fix(:,:,4)./255));
  hold on;

end

if save_flag
  save FixationImg.mat fix;
end
