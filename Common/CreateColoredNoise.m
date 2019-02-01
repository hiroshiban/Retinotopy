function img=CreateColoredNoise(idims,sdims,num,beta,norm_flg,save_flg,show_flg)

% Creates colored (i.e. pink, brown(ian), blue, and white) noise image(s).
% function img = CreateColoredNoise(:idims,:num,:beta,:norm_flg,:save_flg,:show_flg)
% (: is optional)
%
% This function generates colored (1/(f^beta)) noise (such as pink, brown(ian), blue, and white) images.
%
% [input]
% idims    : (optional) image dimension(s) ([row,col] or [a scalar] in pixels) to be created, 256 by default.
%            !!important note!! To avoid any unwilling alias effect, this function tries to first generate
%            colored noise images with the square resolutions, [max(idims),max(idims)]. The generated images
%            are then cropped so as to provide the images with the desired resolution, idims. The cropping
%            may affect the frequency spectrum of the final images. Please be careful. To avoid any bias,
%            please set idims so that idims(1)==idims(2).
% sdims    : (optional) patch size [row,col] or [a scalar], 1 by default. mod(idims,sdims) should be zero.
% num      : (optional) the number of image files you want to create, 1 by default.
% beta     : (optional) the exponent to apply to the amplitude spectrum (1/(f^beta)). 1 (=pink noise) by default.
%            you can set 2 for brownian, -1 for blue, -2 for purple, and 0 for white noises.
% norm_flg : (optional) if 1, the generated noise images are normalized so that their pixels valus
%            are within 0-255. 1 by default.
% save_fag : (optional) if 1, the created noise patterns will be saved as JPG files. 0 by default.
% show_flg : (optional) if 1, the created noise patterns are showed in the figure windows. 1 by default.
%
% [output]
% img   : output images, [idims(1) x idims(2) x num]
%
% [reference]
% this function is inspired by generatepinknoise.m developed by K.Kay.
% https://github.com/kendrickkay/knkutils
%
%
% Created    : "2019-01-28 14:40:28 ban"
% Last Update: "2019-01-28 21:07:54 ban"

% check the input variables
if nargin<1 || isempty(idims), idims=256; end
if nargin<2 || isempty(sdims), sdims=1; end
if nargin<3 || isempty(num), num=1; end
if nargin<4 || isempty(beta), beta=1; end
if nargin<5 || isempty(norm_flg), norm_flg=0; end
if nargin<6 || isempty(save_flg), save_flg=0; end
if nargin<7 || isempty(show_flg), show_flg=1; end

if numel(idims)==1, idims=[idims,idims]; end
if numel(sdims)==1, sdims=[sdims,sdims]; end

% matrix dimension check
if mod(idims(1),sdims(1)) || mod(idims(2),sdims(2)) || ...
   mod(idims(2),sdims(1)) || mod(idims(1),sdims(2))
  error('matrix dimension mismatch. idims is not dividable by sdims');
end

% first, create the square image with the long boundary to simplify the DFT processing
mdim=max(idims)./min(sdims);

% calculate 1/f amplitude matrix
if mod(mdim,2)==0
  [xx,yy]=meshgrid(-mdim/2:mdim/2-1,-mdim/2:mdim/2-1);
else
  [xx,yy]=meshgrid(-(mdim-1)/2:(mdim-1)/2,-(mdim-1)/2:(mdim-1)/2);
end
amp=1./ifftshift(sqrt(xx.^2+yy.^2)).^(beta/sqrt(4)); % not fftshifted

% set the DC component to zero
amp(1,1)=0;

% generate corresponding N-dimensional random phase matrix of multipliers
if ~mod(mdim,2)
  % start by doing the two weird legs
  M=zeros(2,mdim-1,num);                             % initialize in convenient form
  M(:,1:(mdim-2)/2,:)=rand(2,(mdim-2)/2,num)*(2*pi); % fill in the first half with random phase in [0,2*pi]
  M=M-flipdim(M,2);                                  % symmetrize (the mirror gets the negative phase)
  M(:,(mdim-2)/2+1,:)=(rand(2,1,num)>.5)*pi;         % fill in the center (either 0 or pi)

  % putting it all together
  M=[(rand(1,1,num)>.5)*pi,     M(1,:,:);
     permute(M(2,:,:),[2,1,3]), helper(mdim-1,num)];
else
  M=helper(mdim,num);
end

% convert to imaginary numbers
M=exp(j*M);

% unshift
M=ifftshift(ifftshift(M,1),2);

% generate colored-noise image(s)
img=real(ifft2(repmat(amp,[1,1,num]).*M));

% building the patch-image(s)
if sdims(1)~=1 || sdims(2)~=1
  sz=size(img);
  if numel(sz)==2, sz(3)=1; end
  img=reshape(img,[1,prod(sz(1:2)),sz(3)]);
  img=repmat(img,[sdims(1),1,1]);
  img=reshape(img,[sdims(1)*mdim,1,mdim,num]);
  img=repmat(img,[1,sdims(2),1,1]);
  img=reshape(img,[sdims(1)*mdim,sdims(2)*mdim,sz(3)]);
end

% image cropping
if idims(1)<size(img,1)
  img=img(1:idims(1),:,:);
end
if idims(2)<size(img,2)
  img=img(:,1:idims(2),:);
end

% normalization
if norm_flg
  for ii=1:1:num
    timg=img(:,:,ii);
    timg=255.*(timg-min(timg(:)))./(max(timg(:))-min(timg(:)));
    img(:,:,ii)=timg;
  end
  img=uint8(img);
end

% saving
if save_flg
  for ii=1:1:num
    imwrite(img(:,:,ii),sprintf('noise_%04d,jpg',ii),'jpg','Quality',100);
  end
end

% displaying the generated image
if show_flg
  f1=figure();
  for ii=1:1:num
    if norm_flg
      imshow(img(:,:,ii),[0,255]);
    else
      tvals=img(:,:,ii);
      imshow(img(:,:,ii),[min(tvals(:)),max(tvals(:))]);
    end
    axis equal;
    axis off;
    hold off;
    pause(0.05);
  end
  close(f1);
end

return

%% subfunction

% note: this subfunction is from K.Kay's tool.
%       ref:  https://github.com/kendrickkay/knkutils

function f=helper(res,num)

% return a matrix of dimensions <res> x <res> x <num> with appropriate
% random phase values in [0,2*pi].  note that the center (DC component)
% has phase values that are either 0 or pi.  the returned matrix is
% as if fftshift has been called.

f=zeros(res*res,num);          % initialize in convenient form
nn=(res*res-1)/2;              % how many in first half?
f(1:nn,:)=rand(nn,num)*(2*pi); % fill in the first half with random phase in [0,2*pi]
f=reshape(f,[res,res,num]);    % reshape
f=f-flipdim(flipdim(f,1),2);   % symmetrize (the mirror gets the negative phase)
f((res+1)/2,(res+1)/2,:)=(rand(1,1,num)>.5)*pi; % fill in the center (either 0 or pi)

return
