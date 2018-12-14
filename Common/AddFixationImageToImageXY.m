function img=AddFixationImageToImageXY(tgtimg,fiximg,position)

% Adds a circular fixation point at any position of the inupt image.
% function img=AddFixationImageToImage(tgtimg,fiximg,position)
%
% This function adds a fixation image on the target image
%
% [example]
% >> fiximg=MakeFineOval(6,[255,0,0],127,1,5,1,0,0);
% >> img=AddFixationImageToImageXY(tgtimg,fiximg,[0,0]);
%
% [input]
% tgtimg      : input image to be added the fixation [row,col,1|3(grayscale|RGB)]
% fiximg      : input image to be added the fixation [row,col,1|3|4(grayscale|RGB|RGBA)]
% position    : position of the fixation, from the center of the image [row,col]
%               from left to right --- X+
%               from top to bottom --- Y+
%
% [output]
% img         : output image with circular fixation at the position you specified
%
% Created    : "2013-09-03 16:47:11 ban"
% Last Update: "2013-11-22 18:24:56 ban (ban.hiroshi@gmail.com)"

if nargin<2, help(mfilename()); return; end
if nargin<3, position=[0,0]; end

% check image dimensions & fixcolor dimensions
if numel(position)==1, position=[position position]; end
if size(tgtimg,3)==1 && (size(fiximg,3)==3 || size(fiximg,3)==4), tgtimg=repmat(tgtimg,[1,1,3]); end
if size(tgtimg,3)==3 && size(fiximg,3)==1, fiximg=repmat(fiximg,[1,1,3]); end

% get position
sz=[size(fiximg,1),size(fiximg,2)];
x=round((size(tgtimg,2)-sz(2))/2+position(2));
y=round((size(tgtimg,1)-sz(1))/2+position(1));

% processing
img=double(tgtimg);
if size(fiximg,3)~=4
  img(x:x+sz(2)-1,y:y+sz(1)-1,:)=fiximg;
else
  mask=double(repmat(fiximg(:,:,4),[1,1,3]));
  mask=mask./max(mask(:));
  img(x:x+sz(2)-1,y:y+sz(1)-1,:)=(1-mask).*img(x:x+sz(2)-1,y:y+sz(1)-1,:)+mask.*double(fiximg(:,:,1:3));
end
img=uint8(img);

return
