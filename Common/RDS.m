function [imgL,imgR]=RDS(heightfield,dotDens,imgNum,colors,ipd,...
                         vdist,pix_per_cm,oversampling_ratio,display_flag,save_flag)

% Generates left/right Random-Dot-Stereogram images.
% function [imgL,imgR]=RDS(heightfield,dotDens,imgNum,ipd,...
%                          vdist,pix_per_cm,oversampling_ratio,display_flag,save_flag)
%
% Generate left/right Random Dot Stereogram (RDS) Images based on heightfield.
% The generated images are the same size with heightfield image.
%
% [input]
% heightfield : height field to generate RDS, [row,col]
%               *NOTICE* the unit of the height should be cm
% dotDens     : density of the random dots, [percent(1-100,integer)]
% imgNum      : the number of images to be generated, [num]
% colors      : dot/background colors, [0-255(dot1),0-255(dot2),0-255(background)]
% ipd         : distance between left/right pupils, [cm]
% vdist       : visual distance from screen to eyes, [cm]
% pix_per_cm  : pixels per cm
% oversampling_ratio : if above 1, oversampling of heightfield & disparity position
%                      is conducted. [val](default,1)
% display_flag: if 1, the generated images will be displayed, [0/1]
% save_flag   : if 1, the generated images will be saved as RDS_imgs.mat, [0/1]
%
% [output]
% imgL        : generated image(s) for left eye, cells [row,col]
% imgR        : generated image(s) for right eye, cells [row,col]
% 
% [example]
% field=CreateExpField([480,480],3,1);
% [imgL,imgR]=RDS(field,30,1,[128,0],6.4,50,57,1,0);
%
% Created: "2010-04-03 14:05:21 ban"
% Last Update: "2013-11-23 00:05:40 ban (ban.hiroshi@gmail.com)"

% --- input variable check
if nargin<1, help RDS; return; end
if nargin<2 || isempty(dotDens), dotDens=10; end
if nargin<3 || isempty(imgNum), imgNum=1; end
if nargin<4 || isempty(colors), colors=[255,0,128]; end
if nargin<5 || isempty(ipd), ipd=6.4; end
if nargin<6 || isempty(vdist), vdist=65; end
if nargin<7 || isempty(pix_per_cm), 
  % cm per pix
  % 1 inch = 2.54 cm, my PC's display is 1920x1200, 15.4 inch.
  % So, 15.4(inch)*2.54(cm) / sqrt(1920^2+1200^2) (pix) = XXX cm/pixel
  cm_per_pix=15.4*2.54/sqrt(1920^2+1200^2);
  pix_per_cm=1/cm_per_pix;
end
if nargin<8 || isempty(oversampling_ratio), oversampling_ratio=1; end
if nargin<9 || isempty(display_flag), display_flag=0; end
if nargin<10 || isempty(save_flag), save_flag=0; end

if numel(colors)~=3
  error('RDS requires 3colors [0-255(dot1),0-255(dot2),0-255(background)]. Check input variable.');
end

% adjust parameters for oversampling
if oversampling_ratio~=1
  heightfield=imresize(heightfield,oversampling_ratio,'bilinear');
  dotDens=dotDens/oversampling_ratio;
  ipd=ipd*oversampling_ratio;
  vdist=vdist*oversampling_ratio;
  pix_per_cm=pix_per_cm*oversampling_ratio;
end

% --- initalize random seed
%InitializeRandomSeed;

% --- calculate position shifts for each value of heightfield
heightfield=-1*heightfield; % since RayTrace_ScreenPos_X assumes the near position is minus value.
posL=round(RayTrace_ScreenPos_X(heightfield,ipd,vdist,1,pix_per_cm,0));
posR=round(RayTrace_ScreenPos_X(heightfield,ipd,vdist,2,pix_per_cm,0));

% --- generate RDS images
imgL=cell(imgNum,1);
imgR=cell(imgNum,1);
for n=1:1:imgNum

  % create initial random dot image
  randXY=randi(round(oversampling_ratio*100/dotDens),size(heightfield));
  randXY(randXY~=round(oversampling_ratio*100/dotDens))=0;
  randXY(logical(randXY))=1;
  randXY(randXY==0)=colors(3); % background;
  
  % set 2 colors
  [row,col]=find(randXY==1);
  for ii=1:1:size(row,1)
    if mod(randi(2),2)
      randXY(row(ii),col(ii))=colors(1); % dot1;
    else
      randXY(row(ii),col(ii))=colors(2); % dot2;
    end
  end
  
  % left image(s)
  tmp=colors(3)*ones(size(randXY));
  hiddensurf=ones(size(randXY));
  pos=unique(posL(~isnan(posL)))';
  for k = pos % min(min(posL)):max(max(posL))
    if k<0
      level = size(randXY,2)+k;
      TT = [randXY(:,level+1:end) randXY(:,1:level)];
    elseif k>0
      level = k;
      TT = [randXY(:,level+1:end) randXY(:,1:level)];
    elseif k==0
      TT = randXY;
    end
    %tmp(posL==k) = TT(posL==k);
    
    tmp(posL==k) = TT(posL==k).*hiddensurf(posL==k);
    hiddensurf(posL==k) = NaN;
    %imshow(tmp,[0,255]); drawnow(); pause(0.1); % DEBUG code
  end
  imgL{n}=tmp;
  
  % right image(s)
  tmp=colors(3)*ones(size(randXY));
  hiddensurf=ones(size(randXY));
  pos=unique(posR(~isnan(posR)))';
  for k = pos % min(min(posR)):max(max(posR))
    if k<0
      level = size(randXY,2)+k;
      TT = [randXY(:,level+1:end) randXY(:,1:level)];
    elseif k>0
      level = k;
      TT = [randXY(:,level+1:end) randXY(:,1:level)];
    elseif k==0
      TT = randXY;
    end
    %tmp(posR==k) = TT(posR==k);
    
    tmp(posR==k) = TT(posR==k).*hiddensurf(posR==k);
    hiddensurf(posR==k) = NaN;
    %imshow(tmp,[0,255]); drawnow(); pause(0.1); % DEBUG code
  end
  imgR{n}=tmp;
  
  % adjust oversampled image to the original size
  if oversampling_ratio~=1
    imgL{n}=imresize(uint8(imgL{n}),1/oversampling_ratio,'bilinear');
    imgR{n}=imresize(uint8(imgR{n}),1/oversampling_ratio,'bilinear');
  else
    imgL{n}=uint8(imgL{n});
    imgR{n}=uint8(imgR{n});
  end
  
end % for n=1:1:imgNum

% --- plot the results
if display_flag
  figure; hold on;
  for n=1:1:imgNum
    M = [imgL{n} 127*ones(size(imgL{n},1),20) imgR{n} 127*ones(size(imgL{n},1),20) imgL{n}];
    im_h = imagesc(M,[0 255]);
    axis off
    % truesize is necessary to avoid automatic scaling
    size_one2one(im_h);
    colormap(gray);
    shg;
  end
end

% --- save the results
if save_flag
  save RDS_imgs.mat imgL imgR posL posR heightfield;
end

return;
