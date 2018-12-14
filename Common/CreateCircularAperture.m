function img=CreateCircularAperture(fieldSize,apertureSize,gauss_params,pix_per_deg,fine_coefficient,show_flg,save_flg)

% Creates a circular apertures that can be used to mask the other images.
% function img=CreateCircularAperture(fieldSize,apertureSize,gauss_params,pix_per_deg,fine_coefficient,show_flg,save_flg)
%
% Generates circular aperture field.
%
% [input]
% fieldSize    : the size of the field in degrees, [row,col]
% apertureSize : the size of the circular aperture in degrees, [row,col]
% gauss_params : gaussian filter parameters, [width_in_deg,sd_in_deg].
%                if not 0, gaussian filter will be applied on the edge of the aperture. [0,0] by default.
% pix_per_deg  : pixels per degree, [pixels]. 40 by default.
% fine_coefficient : if larger, the generated oval become finer,
%                    but comsumes much CPU power. [val](default=5)
% show_flg     : if 1, the generated images are displayed. [1/0]
% save_flg     : if 1, the generated images are saved. [1/0]
%
% [output]
% img          : oval image, [row x col]. [0.0-1.0] binary mask.
%                can be used for image mask
%
%
% Created    : "2013-08-29 11:49:49 ban"
% Last Update: "2013-11-22 18:35:46 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(fieldSize), fieldSize=8; end
if nargin<2 || isempty(apertureSize), apertureSize=6; end
if nargin<3 || isempty(gauss_params), gauss_params=[0,0]; end
if nargin<4 || isempty(pix_per_deg), pix_per_deg=40; end
if nargin < 5 || isempty(fine_coefficient), fine_coefficient=5; end
if nargin < 7 || isempty(show_flg), show_flg=1; end
if nargin < 8 || isempty(save_flg), save_flg=0; end

if numel(fieldSize)==1, fieldSize=[fieldSize,fieldSize]; end
if numel(apertureSize)==1, apertureSize=[apertureSize,apertureSize]; end
if numel(gauss_params)==1, error('gauss_params should be [width,sd]. check input variable.'); end

% convert to pixels and radians
fieldSize=round(fieldSize./2*pix_per_deg);
apertureSize=round(apertureSize./2*pix_per_deg);
gauss_params=gauss_params.*pix_per_deg;

% dissociate inner/outer region of the oval
step=1/fine_coefficient;
[x,y]=meshgrid(-fieldSize(2):step:fieldSize(2),-fieldSize(1):step:fieldSize(1));
if mod(size(x,1),2), x=x(1:end-1,:); y=y(1:end-1,:); end
if mod(size(x,2),2), x=x(:,1:end-1); y=y(:,1:end-1); end

idx=logical( 1>=( x.^2/apertureSize(2).^2 + y.^2/apertureSize(1).^2 ) );
%idxbg=logical( 1<( x.^2/apertureSize(2).^2 + y.^2/apertureSize(1).^2 ) );

% generate oval image
img=zeros(size(x)); img(idx)=255.0;

if gauss_params(1)~=0
  % gaussian filtering
  % create gaussian kernel, using fspecial('gaussian',winwidth,sd);
  h = fspecial('gaussian',gauss_params(1),gauss_params(2));

  % apply gaussian filter
  %img=imfilter(uint8(img),h,0); % for speeding up
  img=imfilter(uint8(img),h,'replicate'); % for speeding up;
end

% resizing
img=imresize(img,step,'bilinear'); % not bicubic
img=double(img)./255;

% show image
if show_flg
  figure;
  imshow(img,[0,1]);
  drawnow;
  %axis off;
end

% save image data
if save_flg
  save aperture.mat img;
end

return
