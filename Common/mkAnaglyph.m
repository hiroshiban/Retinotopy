function oimg=mkAnaglyph(img1,img2,mode,display_flg,save_flg)

% Generates a red/green or color-optimized anaglyph image (e.g. for stereo viewing).
% function oimg=mkAnaglyph(img1,img2,mode,display_flg,save_flg)
%
% This function generates red/green anaglyph image from img1 & img2
%
% [input]
% img1 : input image 1 with relative path, e.g. '/imgs/scene_left.bmp'
% img2 : input image 2 with relative path, e.g. '/imgs/scene_right.bmp'
% mode : anaglyph mode
%        1: optimized anaglyph
%        2: color anaglyph
%        3: half-color anaglyph
% display_flg : whether displaying the generated image, [0|1]
%               0 (not displaying) by default
% save_flg    : whether saving the generated image, [0|1]
%               0 (not displaying) by default
%
% [output]
% oimg : generated anaglyph image
%
%
% Created    : "2012-01-18 14:13:37 banh"
% Last Update: "2013-11-22 23:39:11 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<3, help mkAnaglyph; return; end
if nargin<4 || isempty(display_flg), display_flg=0; end
if nargin<5 || isempty(save_flg), save_flg=0; end

% loading input images
fprintf('input 1: %s\n',fullfile(pwd,img1));
fprintf('input 2: %s\n',fullfile(pwd,img2));
im1=double(imread(fullfile(pwd,img1)));
im2=double(imread(fullfile(pwd,img2)));

if mode==1
  %% optimized anaglyph
  modestr='optimized';
  trfmtx1=[0,0.7,0.3;0,0,0;0,0,0];
  trfmtx2=[0,0,0;0,1,0;0,0,1];
elseif mode==2
  %% half color anaglyph
  modestr='color';
  trfmtx1=[1,0,0;0,0,0;0,0,0];
  trfmtx2=[0,0,0;0,1,0;0,0,1];
elseif mode==3
  %% color anaglyph
  modestr='half-color';
  trfmtx1=[0.299,0.587,0.114;0,0,0;0,0,0];
  trfmtx2=[0,0,0;0,1,0;0,0,1];
else
  error('mode should be one of 1 (optimized), 2 (color), or 3 (half-color). check input variable');
end

fprintf('generating anaglyph image with %s mode...',modestr);
oimg=zeros(size(im1));
for ii=1:1:size(im1,1)
  for jj=1:1:size(im1,2)
    oimg(ii,jj,:)=trfmtx1*[im1(ii,jj,1);im1(ii,jj,2);im1(ii,jj,3)]+...
                  trfmtx2*[im2(ii,jj,1);im2(ii,jj,2);im2(ii,jj,3)];
  end
end
oimg=uint8(oimg);
disp('done.');

if display_flg
  fprintf('displaying generated anaglyph...');
  figure;
  imshow(oimg);
  disp('done.');
end

if save_flg
  fprintf('saving generated anaglyph as anaglyph_img.bmp...');
  imwrite(oimg,'anaglyph_img.bmp','bmp');
  disp('done.');
end

return
