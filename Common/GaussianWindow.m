function img=GaussianWindow(img, sd, pix_per_deg)

% Generates a gaussian window.
% function img=GaussianWindow(img, sd, pix_per_deg)
%
% windows an square image with a Gaussian filter.
% takes as input the image, and the standard deviation of
% the filter in the x and y direction (in degrees) and the
% pixels per degree
% returns as output the filtered image.
%
% [input]
% img         : input image, [row,col]
% sd          : standard deviation of the filter, [deg]
% pix_per_deg : pixels per degree, [pix]
%
% [output]
% img         : output image, gaussian filtered, [row,col]
%
% ref IF 7/2000
%
% Created: "2010-04-03 17:09:15 ban"
% Last Update: "2013-11-22 18:50:11 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1, help GaussianWindow; return; end
if nargin<2 || isempty(sd), sd=1; end
if nargin<3 || isempty(pix_per_deg), pix_per_deg=40; end

filtSize =min(size(img));
sd=sd*pix_per_deg;

%[x,y] = meshgrid(round(-filtSize/2):round(filtSize/2)-1,round(-filtSize/2):round(filtSize/2)-1);
[x,y] = meshgrid(ceil(-filtSize/2):ceil(filtSize/2)-1,ceil(-filtSize/2):ceil(filtSize/2)-1);

filt = exp(-(x.^2+y.^2)/(2*sd.^2));
filt=filt./max(max(filt(:)));
img=img.*filt;

return
