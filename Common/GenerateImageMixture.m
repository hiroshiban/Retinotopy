function img=GenerateImageMixture(img1,img2,img1_ratio,display_flg,save_flg)

% Combines two input images to a mixtured image.
% function img=GenerateImageMixture(img1,img2,img1_ratio,display_flg,save_flg)
%
% This function generates a mixtured image from two image inputs.
% mixtured ratio is controlled by img1_ratio (0.0-1.0) parameter.
% e.g. img(x,y) = img1(x,y)*img1_ratio + img2(x,y)*(1-img1_ratio)
%
% [input]
% img1 : input image 1, [row,col], grayscale or RGB image
% img2 : input image 2, [row,col]
%        !NOTE! if the size of img2 is smaller than img1, img2 will be adjusted to img1 size.
% img1_ratio  : ratio of image1 pixel value in the output image
%              scalar or [size(img1,1) x size(img,2)] matrix. 0.5 by default.
% display_flg : whether displaying the generated image, [0|1]. 1 by default.
% save_flg    : whether saving the generated image, [0|1]. 0 by default.
%
% [output]
% img  : output mixtured image, [row,col]
%
%
% Created    : "2013-08-29 11:47:43 ban"
% Last Update: "2013-11-22 23:12:26 ban (ban.hiroshi@gmail.com)"

% check input variable
if nargin<2, help(mfilename()); return; end
if nargin<3 || isempty(img1_ratio), img1_ratio=0.5; end
if nargin<4 || isempty(display_flg), display_flg=1; end
if nargin<5 || isempty(save_flg), save_flg=0; end

% checking and adjusting img1_ratio
if numel(img1_ratio)~=1
  if size(img1,1)~=size(img1_ratio,1) || size(img1,2)~=size(img1_ratio,2)
    error('size of img1_ratio does not match with size of img1. check input variable.');
  end
end
img1_ratio=double(img1_ratio);

if ~isempty(find(img1_ratio>1.05,1)) || ~isempty(find(img1_ratio<-0.05,1)) % adjusted by 0.05 just for some filter effects
  disp('img1_ratio seems to exceed 0.0-1.0. scaling...');
  img1_ratio=(img1_ratio-min(img1_ratio(:)))./(max(img1_ratio(:)-min(img1_ratio(:))));
end

% adjust input image
if size(img1,1)~=size(img2,1) || size(img1,2)~=size(img2,2)
  img2=imresize(img2,[size(img1,1),size(img1,2)],'bicubic');
end

if size(img1,3)==1 && size(img2,3)==3 % img1 is grayscale, whereas img2 is RGB
  img1=repmat(img1,[1,1,3]);
elseif size(img1,3)==3 && size(img2,3)==1 % img1 is RGB, whereas img2 is grayscale
  img2=repmat(img2,[1,1,3]);
end

% generate mixtured image
img=zeros(size(img1));
for ii=1:1:size(img1,3)
  img(:,:,ii)=double(img1(:,:,ii)).*img1_ratio+double(img2(:,:,ii)).*(1-img1_ratio);
end
img=uint8(img);

% displaying the mixtured image
if display_flg
  figure; imshow(img,[0,255]);
end

% save the mixtured image
if save_flg
  save mixtured.mat img;
end

return
