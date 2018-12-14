function img=MakeFineOval(imsize,color,bgcolor,bg_expand_ratio,fine_coefficient,gauss_flag,show_flag,save_flag)

% Genrates a beautiful oval image with an antialiasing option.
% function img=MakeFineOval(imsize,color,bgcolor,show_flag,save_flag)
%
% Generates oval image with clear curve based on antialiasing.
% This funcion consumes much CPU power than MakeOval function.
% 
% [input]
% imsize   : size of the oval, [raw_pix,col_pix]
% color    : color of the oval, [r,g,b]
% bgcolor  : color of the background, [r,g,b]
% bg_expand_ratio : expand ratio of backgound
%            if 1, the generated image is the same size with imsize
%            if more than 1, the edge of background is expanded
%            and generated image size will be imsize*bg_expand_ratio
%            defaul value is 1
% fine_coefficient : if larger, the generated oval become finer,
%                    but comsumes much CPU power. [val](default=5)
% gauss_flag : if 1, the image will be passed with gauussian filter
%              default=1
% show_flag: if 1, the generated images are displayed. [1/0]
% save_flag: if 1, the generated images are saved. [1/0]
%
% [output]
% img      : oval image, [row x col x rgba]
%
% Created    : "2010-06-11 10:44:46 ban"
% Last Update: "2013-11-22 23:32:51 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin < 1, imsize=[32,32]; end
if nargin < 2, color=[255,255,255]; end
if nargin < 3, bgcolor=[128,128,128]; end
if nargin < 4, bg_expand_ratio=1; end
if nargin < 5, fine_coefficient=5; end
if nargin < 6, gauss_flag=1; end
if nargin < 7, show_flag=1; end
if nargin < 8, save_flag=0; end

if numel(imsize)==1, imsize=[imsize,imsize]; end
if numel(color)==1, color=[color,color,color]; end
if numel(bgcolor)==1, bgcolor=[bgcolor,bgcolor,bgcolor]; end
if bg_expand_ratio<1, bg_expand_ratio=1; end

% color values check
if max(color)>255 || min(color)<0
    error('color values error. color should be set 0-255');
end

% adjust size
imsize=round(imsize/2+1); % to avoid 'shaggy' problem, see also line#77
oimsize=round(imsize.*bg_expand_ratio);

% dissociate inner/outer region of the oval
step=1/fine_coefficient;
[x,y]=meshgrid(-oimsize(2):step:oimsize(2),-oimsize(1):step:oimsize(1));
if mod(size(x,1),2), x=x(1:end-1,:); y=y(1:end-1,:); end
if mod(size(x,2),2), x=x(:,1:end-1); y=y(:,1:end-1); end

idx=logical( 1>=( x.^2/imsize(2).^2 + y.^2/imsize(1).^2 ) );
idxbg=logical( 1<( x.^2/imsize(2).^2 + y.^2/imsize(1).^2 ) );

% generate oval image
img=zeros(size(x,1),size(x,2),4);

% set oval & background color
tmp=zeros(size(x));
for ii=1:1:3
  tmp(idxbg)=bgcolor(ii);
  tmp(idx)=color(ii);
  img(:,:,ii)=tmp;
end

% set alpha channel
alphac=zeros(size(x));
%alphac(idx)=255;
alphac( 1>=( x.^2/round(imsize(2)-1).^2 + y.^2/round(imsize(1)-1).^2 ) )=255; % to avoid 'shaggy' problem
img(:,:,4)=alphac;

if gauss_flag
  % gaussian filtering
  % create gaussian kernel, using fspecial('gaussian',winwidth,sd);
  h = fspecial('gaussian',max(imsize),3);
  
  % apply gaussian filter
  %img=imfilter(uint8(img),h,0); % for speeding up
  img=imfilter(uint8(img),h,'replicate'); % for speeding up
else
  img=uint8(img);
end

% resizing
img=imresize(img,step,'bilinear'); % not bicubic

%img=uint8(img);

% show image
if show_flag
  figure;
  imid1=imshow(uint8(img(:,:,1:3)));
  drawnow;
  set(imid1,'AlphaData',double(img(:,:,4)./255));
  %axis off;
end

% save image data
if save_flag
  save oval.mat img;
end

return
