function fix=CreateFixationImgMono(fixsize,fixcolor,bgcolor,fixlinew,fixlineh,show_flag,save_flag)

% Creates a cross-shaped fixation image for a monocular display setting.
% function fiximg=CreateFixationImgMono(fixsize,fixcolor,bgcolor,fixlinew,fixlineh,show_flag,save_flag)
%
% Create fixation-cross images for left/right eyes
%
% [input]
% fixsize  : radius of the fixation, [pixel]
% fixcolor : color of the fixation cross, [r,g,b]
% bgcolor  : color of the background, [r,g,b]
% fixlinew : line width of the central fixation, [pixel]
% fixlineh : line height of the central fixation, [pixel]
% show_flag: if 1, the generated images are displayed. [1/0]
% save_flag: if 1, the generated images are saved. [1/0]
%
% [output]
% imgL     : fixation image for left eye
% imgR     : fixation image for right eye
%
% Created    : Jan 29 2010 Hiroshi Ban
% Last Update: "2013-11-22 18:44:00 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin < 1, fixsize=32; end
if nargin < 2, fixcolor=[255,255,255]; end
if nargin < 3, bgcolor=[128,128,128]; end
% line width of the central fixation;
if nargin < 4, fixlinew=2; end
% line height of the central fixation;
if nargin < 5, fixlineh=12; end
if nargin < 6, show_flag=1; end
if nargin < 7, save_flag=0; end

% create the outmost circular background
[x,y]=meshgrid(1:2*fixsize,1:2*fixsize);
x=x-fixsize; y=y-fixsize;
r=sqrt(x.*x+y.*y);
alphac=r; alphac(r>fixsize)=0; alphac(r<=fixsize)=255;
bgcircle=zeros([2*fixsize,2*fixsize,4]);
for ii=1:1:3, bgcircle(:,:,ii)=bgcolor(ii); end
bgcircle(:,:,4)=alphac; % alpha channel

% calculate fixation cross's size
bglength=round(2*fixsize); if mod(bglength,2), bglength=bglength+1; end
outlength=round(2*fixsize*sqrt(2)/3); if mod(outlength,2), outlength=outlength+1; end
inlength=round(2*fixsize*sqrt(2)/3)-fixlinew*2; if mod(inlength,2), inlength=inlength+1; end

% create fixation cross parts
fcross_outrect=repmat(1,[outlength,outlength,3]); for ii=1:1:3, fcross_outrect(:,:,ii)=fixcolor(ii); end
fcross_inrect=repmat(1,[inlength,inlength,3]); for ii=1:1:3, fcross_inrect(:,:,ii)=bgcolor(ii); end
fcross_vbar=repmat(1,[fixlineh fixlinew 3]); for ii=1:1:3, fcross_vbar(:,:,ii)=fixcolor(ii); end
fcross_hbar=repmat(1,[fixlinew fixlineh 3]); for ii=1:1:3, fcross_hbar(:,:,ii)=fixcolor(ii); end

% combine them
bgcircle(bglength/2-outlength/2+1:bglength/2+outlength/2,bglength/2-outlength/2+1:bglength/2+outlength/2,1:3)=fcross_outrect;
bgcircle(bglength/2-inlength/2+1:bglength/2+inlength/2,bglength/2-inlength/2+1:bglength/2+inlength/2,1:3)=fcross_inrect;

% add bars on the top & left positions
fix=bgcircle;
fix(bglength/2-outlength/2-size(fcross_vbar,1)/2+1:bglength/2-outlength/2+size(fcross_vbar,1)/2,bglength/2-size(fcross_vbar,2)/2+1:bglength/2+size(fcross_vbar,2)/2,1:3)=fcross_vbar; % top
fix(bglength/2-size(fcross_hbar,1)/2+1:bglength/2+size(fcross_hbar,1)/2,bglength/2-outlength/2-size(fcross_hbar,2)/2+1:bglength/2-outlength/2+size(fcross_hbar,2)/2,1:3)=fcross_hbar; % left
fix(bglength/2+outlength/2-size(fcross_vbar,1)/2+1:bglength/2+outlength/2+size(fcross_vbar,1)/2,bglength/2-size(fcross_vbar,2)/2+1:bglength/2+size(fcross_vbar,2)/2,1:3)=fcross_vbar; % bottom
fix(bglength/2-size(fcross_hbar,1)/2+1:bglength/2+size(fcross_hbar,1)/2,bglength/2+outlength/2-size(fcross_hbar,2)/2+1:bglength/2+outlength/2+size(fcross_hbar,2)/2,1:3)=fcross_hbar; % right
fix=uint8(fix);

if show_flag
  figure;

  imid1=imshow(fix(:,:,1:3));
  set(imid1,'AlphaData',double(fix(:,:,4)./255));
  hold on;

end

if save_flag
  save FixationImg.mat fix;
end
