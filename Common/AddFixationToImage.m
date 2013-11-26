function img=AddFixationToImage(img,fixwidthpix,fixcolor)

% Adds a circular fixation point on the center of input image.
% function img=AddFixationToImage(img,fixwidthpix,fixcolor)
% 
% This function adds a circular fixation point on the center of input image
% 
% <input>
% img         : input image to be added the fixation [row,col,1|3(grayscale|RGB)]
% fixwidthpix : radius of the fixation in pixels [val]
% fixcolor    : color of the fixation [val] or [R,G,B]
% 
% <output>
% img         : output image with circular fixation at the center
% 
% July 17 2009 Hiroshi Ban

if nargin<1, help AddFixationToImage; end
if nargin<2, fixwidthpix=8; end
if nargin<3, fixcolor=128; end

% check image dimensions & fixcolor dimensions
if size(fixcolor,2)==1
  fixcolor=[fixcolor fixcolor fixcolor];
end

[x,y]=meshgrid(1:size(img,2),1:size(img,1));
x=x-size(img,2)/2;
y=y-size(img,1)/2;
r=sqrt(x.*x+y.*y);
r(r>fixwidthpix)=255;
r(r<=fixwidthpix)=0;
r=uint8(r);

for ii=1:1:size(img,3)
  tmp=img(:,:,ii);
   tmp(r==0)=fixcolor(ii);
  img(:,:,ii)=tmp;
end
%img=uint8(img);

return
