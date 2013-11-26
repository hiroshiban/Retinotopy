function img=MakeOval(imsize,color,bgcolor,bg_expand_ratio,show_flag,save_flag)

% Generates an oval image.
% function img=MakeOval(imsize,color,bgcolor,show_flag,save_flag)
%
% This function generates an oval image
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
% show_flag: if 1, the generated images are displayed. [1/0]
% save_flag: if 1, the generated images are saved. [1/0]
%
% [output]
% img      : oval image, [row x col x rgba]
%
% Created    : "2010-06-11 10:44:46 ban"
% Last Update: "2013-11-22 23:39:30 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin < 1, imsize=[32,32]; end
if nargin < 2, color=[255,255,255]; end
if nargin < 3, bgcolor=[128,128,128]; end
if nargin < 4, bg_expand_ratio=1; end
if nargin < 5, show_flag=1; end
if nargin < 6, save_flag=0; end

if numel(imsize)==1, imsize=[imsize,imsize]; end
if numel(color)==1, color=[color,color,color]; end
if numel(bgcolor)==1, bgcolor=[bgcolor,bgcolor,bgcolor]; end
if bg_expand_ratio<1, bg_expand_ratio=1; end

% color values check
if max(color)>255 || min(color)<0
    error('color values error. color should be set 0-255');
end

% adjust size
imsize=imsize/2;
if mod(imsize,2), imsize=imsize+1; end

oimsize=round(imsize.*bg_expand_ratio);
if mod(oimsize,2), oimsize=oimsize+1; end

% dissociate inner/outer region of the oval
[x,y]=meshgrid(-oimsize(2):oimsize(2),-oimsize(1):oimsize(1));
idx=logical( 1>=( x.^2/imsize(2).^2 + y.^2/imsize(1).^2 ) );
idxbg=logical( 1<( x.^2/imsize(2).^2 + y.^2/imsize(1).^2 ) );

% generate oval image
img=zeros(size(x,1),size(x,2),4);
tmp=zeros(size(x));
for ii=1:1:3
  tmp(idxbg)=bgcolor(ii);
  tmp(idx)=color(ii);
  img(:,:,ii)=tmp;
end
alphac=zeros(size(x)); alphac(idx)=255;
img(:,:,4)=alphac;

%img=uint8(img);

% show image
if show_flag
  figure;
  imid=imshow(uint8(img(:,:,1:3)));
  set(imid,'AlphaData',double(img(:,:,4)./255));
  axis off;
end

% save image data
if save_flag
  save oval.mat img;
end

return
