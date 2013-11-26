function img=AddFixationToImageXY(img,fixwidthpix,fixcolor,position)

% Adds a circular fixation point on the center of input image (RGB image).
% function img=AddFixationToImage(img,fixwidthpix,fixcolor,position)
% 
% This function adds a circular fixation point on the center of input image
% 
% <input>
% img         : input image to be added the fixation [row,col,1|3(grayscale|RGB)]
% fixwidthpix : radius of the fixation in pixels [val]
% fixcolor    : color of the fixation [val] or [R,G,B]
% position    : position of the fixation, from the center of the image [row,col]
%               from left to right --- X+
%               from top to bottom --- Y+
%
% <output>
% img         : output image with circular fixation at the position you specified
% 
% Jan 28 2010 Hiroshi Ban

if nargin<1, help AddFixationToImage; return; end
if nargin<2, fixwidthpix=8; end
if nargin<3, fixcolor=128; end
if nargin<4, position=size(img)/2; end

% check image dimensions & fixcolor dimensions
if length(fixcolor)==1, fixcolor=[fixcolor fixcolor fixcolor]; end
if length(position)==1, position=[position position]; end

[x,y]=meshgrid(1:size(img,2),1:size(img,1));
%x=x-size(img,2)/2;
%y=y-size(img,1)/2;
x=x-size(img,2)/2-position(2);
y=y-size(img,1)/2-position(1);
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
