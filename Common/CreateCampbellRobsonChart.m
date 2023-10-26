function [crcimg,limitval]=CreateCampbellRobsonChart(img_size,sfs,contrasts,center,amplitude,pix_per_deg,limitBpc)

% fucntion [crcimg,limitval]=CreateCampbellRobsonChart(img_size,:sfs,:contrasts,:center,:amplitude,:pix_per_deg,:limitBpc)
% (: is optional)
%
% This function generates a Campbell-Robson Chart, aka Contrast-Sensitivity function.
% The output "crcimg" contains the image of the standard CSF.
%
% ref: Campbell, F. W., and Robson, J. G. (1964).
%      Application of Fourier analysis to the modulation response of the eye.
%      J. Opt. Soc. Am. 54:581.
%      https://physoc.onlinelibrary.wiley.com/doi/10.1113/jphysiol.1968.sp008574
%
% The output image can be used to measure observers' individual contrast sensitivity functions roughly.
% Hoever, please be careful in interpretations and also see the report below.
%
% ref: Tardif, J., Watson, M.R., Giaschi, D., Gosselin, F. (2021).
%      The Curve Visible on the Campbell-Robson Chart Is Not the Contrast Sensitivity Function.
%      Front. Neurosci., Vol 15
%      https://www.frontiersin.org/articles/10.3389/fnins.2021.626466/full#B10
%
%
% [input]
% img_size  : the output image size, [row,col] in visual angle (degree).
% sfs       : (optional) spatial frequency (cycles per img_size(2)) range, [min,max]. [1,77] by default.
% contrasts : (optional) the ouput image contrast, [min,max]. [1/512,1] by default.
% center    : (optional) image maen value, grayscale, [val]. 127/255 by default.
% amplitude : (optional) image amplitude, [val]. 127/255 by default.
% pix_per_deg : (optional) pixels per degree, [val]. 40 by default.
% limitBpc  : (optional) Assumed bit depths of display -> Used to calculate the
%             "limitLine" return argument, [val]. 8 by default.
%
% [output]
% crcimg    : Campbell Robson Chart.
% limitval  : the pixel row above which there is no  useful content anymore,
%             due to limited bit resolution of output device.
%
% [example]
% >> img=CreateCampbellRobsonChart([8,16],[1,77],[1/1024,1],127/255,127/255,67,8);
%
% [reference]
% BitsPlusCSFDemo.m in Psychtoolbox (PTB3).
%
%
% Created    : "2023-01-31 17:22:09 ban"
% Last Update: "2023-02-08 18:13:16 ban"

%% checking the input Variables
if nargin<1 || isempty(img_size), help(mfilename()); end
if nargin<2 || isempty(sfs), sfs=[1,77]; end
if nargin<3 || isempty(contrasts), contrasts=[1/512,1]; end
if nargin<4 || isempty(center), center=127/255; end
if nargin<5 || isempty(amplitude), amplitude=127/255; end
if nargin<6 || isempty(pix_per_deg), pix_per_deg=40; end
if nargin<7 || isempty(limitBpc), limitBpc=8; end

if numel(img_size)==1, img_size=[img_size,img_size]; end

if numel(sfs)~=2, error('sfs should be [min,max]. check the inputat variable.'); end
if numel(contrasts)~=2, error('contrasts should be [min,max]. check the input variable.'); end
if numel(center)~=1, error('center should be a scalar. check the input variable.'); end
if numel(amplitude)~=1, error('amplitude should be a scalar. check the input variable.'); end
if numel(pix_per_deg)~=1, error('pix_per_deg should be a scalar. check the input variable.'); end
if numel(limitBpc)~=1, error('limitBpc should be a scalar. check the input variable.'); end

%% initialization

img_size=round(img_size.*pix_per_deg);

% multiplying factor per step for sweeping contrast along image y-axis
contrast_bump=(contrasts(2)/contrasts(1))^(1.0/img_size(1));

% multiplying factor per step for spatial frequency along image x-axis
sfrequency_bump=(sfs(2)/sfs(1))^(1.0/img_size(2));

%% processing

% generating Contrast/Spatial-Frequency image fields
[xx,yy]=meshgrid(0:1:img_size(2)-1,0:1:img_size(1)-1);
CT=contrasts(1)*(contrast_bump.^yy);
SF=(sfs(1)/img_size(2))*(sfrequency_bump.^xx);

% drawing the output Campbell-Robson Chart on the image canvas
crcimg=center+amplitude*CT.*sin(2.0*pi.*SF.*xx);

% 'limitval' is the pixel row where contrast drops below the level that
% can be diplayed on a 'limitForBpc' bpc display. Derived from BitsPlusCSFDemo.m in PTB3.
limitval=find(CT(:,1)>=1.0/(2^(limitBpc-0)),1);

return
