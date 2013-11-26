function [imgL,imgR]=RDSbyOval(heightfield,dotRadius,dotDens,imgNum,...
                               colors,ipd,vdist,pix_per_cm,oversampling_ratio,display_flag,save_flag)

% Generates left/right Random-Dot-Stereogram images using oval textures, not dots.
% function [imgL,imgR]=RDSbyOval(heightfield,dotRadius,dotDens,imgNum,...
%                                colors,ipd,vdist,pix_per_cm,oversampling_ratio,display_flag,save_flag)
%
% Generate left/right Random Dot (2 colors) Stereogram (RDS) Images based on heightfield.
% This function takes 'Hidden Surface Problem' (HSP) into account, but slower than 'RDSbyOvalFinest'
% The generated images are the same size with heightfield image.
% The procedure to generate RDS images are as below.
%    1. create random dot image
%    2. add disparity to the dots and generate left/right-eye images
%    3. replace dots to ovals
%
% [input]
% heightfield : height field to generate RDS, [row,col]
%               *NOTICE* the unit of the height should be cm
% dotRadius   : the radius of random dot [row,col](cm)
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
% [imgL,imgR]=RDSbyOvalFinest(field,0.05,3,1,[255,0,128],6.4,50,57,1,0);
%
% Created: "2010-04-03 14:05:21 ban"
% Last Update: "2013-11-23 00:05:24 ban (ban.hiroshi@gmail.com)"

% --- input variable check
if nargin<1, help RDSbyOval; return; end
if nargin<2 || isempty(dotRadius), dotRadius=[0.05,0.05]; end
if nargin<3 || isempty(dotDens), dotDens=10; end
if nargin<4 || isempty(imgNum), imgNum=1; end
if nargin<5 || isempty(colors), colors=[255,0,128]; end
if nargin<6 || isempty(ipd), ipd=6.4; end
if nargin<7 || isempty(vdist), vdist=65; end
if nargin<8 || isempty(pix_per_cm), 
  % cm per pix
  % 1 inch = 2.54 cm, my PC's display is 1920x1200, 15.4 inch.
  % So, 15.4(inch)*2.54(cm) / sqrt(1920^2+1200^2) (pix) = XXX cm/pixel
  cm_per_pix=15.4*2.54/sqrt(1920^2+1200^2);
  pix_per_cm=1/cm_per_pix;
end
if nargin<9 || isempty(oversampling_ratio), oversampling_ratio=1; end
if nargin<10 || isempty(display_flag), display_flag=0; end
if nargin<11 || isempty(save_flag), save_flag=0; end

if numel(dotRadius)==1, dotRadius=[dotRadius,dotRadius]; end

if numel(colors)~=3
  error('RDSbyOval requires 3colors [0-255(dot1),0-255(dot2),0-255(background)]. Check input variable.');
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

% --- generate base dot
dotSize=round(dotRadius*pix_per_cm*2); % radius(cm) --> diameter(pix)
basedot=double(MakeFineOval(dotSize,[colors(1:2) 0],colors(3),1.2,2,1,0,0));
wdot=basedot(:,:,1);     % get only gray scale image (white)
bdot=basedot(:,:,2);     % get only gray scale image (black)
dotalpha=basedot(:,:,4)./max(max(basedot(:,:,4))); % get alpha channel value 0-1.0;

% --- initializing
imgL=cell(imgNum,1);
imgR=cell(imgNum,1);
for n=1:1:imgNum
  imgL{n}=colors(3)*ones(size(heightfield));
  imgR{n}=colors(3)*ones(size(heightfield));
end

% --- generate RDS images
for n=1:1:imgNum

  % create initial random dot image
  randXY=randi(round(oversampling_ratio*100/dotDens),size(heightfield));
  randXY(randXY~=round(oversampling_ratio*100/dotDens))=0;
  randXY(logical(randXY))=1;
  %randXY(randXY==0)=colors(3); % background;
  idxs=find(randXY==1);
  
  % create ID field
  % prevent ovals' overlapping problem
  idxs=shuffle(idxs);
  idXY=NaN*ones(size(randXY));
  %for ii=1:1:size(row,1), idXY(row(ii),col(ii))=idx(ii); end % much faster than using sub2ind
  idXY(idxs)=1:size(idxs);
  
  %% left image(s)
  tmp=NaN*ones(size(randXY));
  hiddensurf=ones(size(randXY));
  pos=unique(posL(~isnan(posL)))';
  for k = pos % from near to far % min(min(posL)):max(max(posL))
    if k<0
      level = size(randXY,2)+k;
      TT = [idXY(:,level+1:end) idXY(:,1:level)];
    elseif k>0
      level = k;
      TT = [idXY(:,level+1:end) idXY(:,1:level)];
    elseif k==0
      TT = idXY;
    end
    tmp(posL==k) = TT(posL==k).*hiddensurf(posL==k);
    hiddensurf(posL==k) = NaN;
    %imshow(tmp,[0,255]); drawnow(); pause(0.1); % DEBUG code
  end
  imgLids=tmp;
  
  %% right image(s)
  tmp=NaN*ones(size(randXY));
  hiddensurf=ones(size(randXY));
  pos=unique(posR(~isnan(posR)))';
  for k = pos % from near to far % min(min(posR)):max(max(posR))
    if k<0
      level = size(randXY,2)+k;
      TT = [idXY(:,level+1:end) idXY(:,1:level)];
    elseif k>0
      level = k;
      TT = [idXY(:,level+1:end) idXY(:,1:level)];
    elseif k==0
      TT = idXY;
    end
    tmp(posR==k) = TT(posR==k).*hiddensurf(posR==k);
    hiddensurf(posR==k) = NaN;
    %imshow(tmp,[0,255]); drawnow(); pause(0.1); % DEBUG code
  end
  imgRids=tmp;
  
  %% replace dots to ovals
  %[comval,Lid,Rid]=intersect(imgLids(:),imgRids(:));
  
  %[rowL,colL]=ind2sub(size(imgLids),Lid);
  [rowL,colL]=find(~isnan(imgLids));
  for rr=1:1:size(rowL,1)
    % select white/black dot
    if mod(imgLids(rowL(rr),colL(rr)),2) %mod(comval(rr),2)
      dot=wdot;
    else
      dot=bdot;
    end
    
    % set ovals to the left image
    idxr=max(1,rowL(rr)-round(size(dot,1)/2)+1):min(rowL(rr)+round(size(dot,1)/2),size(imgL{n},1));
    idxc=max(1,colL(rr)-round(size(dot,2)/2)+1):min(colL(rr)+round(size(dot,2)/2),size(imgL{n},2));
    
    if 1 <= rowL(rr)-round(size(dot,1)/2)
      didxr=1:min(size(dot,1),size(idxr,2));
    else
      if rowL(rr)+round(size(dot,1)/2) <= size(imgL{n},1)
        didxr=round(size(dot,1)/2)-rowL(rr)+1:size(dot,1);
      else
        didxr=round(size(dot,1)/2)-rowL(rr)+1:size(idxr,1);
      end
    end
    
    if 1<=colL(rr)-round(size(dot,2)/2)
      didxc=1:min(size(dot,2),size(idxc,2));
    else
      if colL(rr)+round(size(dot,2)/2) <= size(imgL{n},2)
        didxc=round(size(dot,2)/2)-colL(rr)+1:size(dot,2);
      else
        didxc=round(size(dot,2)/2)-colL(rr)+1:size(idxr,2);
      end
    end

    % put ovals considering alpha value
    imgL{n}(idxr,idxc)=(1-dotalpha(didxr,didxc)).*imgL{n}(idxr,idxc)+dotalpha(didxr,didxc).*dot(didxr,didxc);
  end
  
  %[rowR,colR]=ind2sub(size(imgRids),Rid);
  [rowR,colR]=find(~isnan(imgRids));
  for rr=1:1:size(rowR,1)
    % select white/black dot
    if mod(imgRids(rowR(rr),colR(rr)),2) %mod(comval(rr),2)
      dot=wdot;
    else
      dot=bdot;
    end
    
    % prevent edge removal problem
    idxr=max(1,rowR(rr)-round(size(dot,1)/2)+1):min(rowR(rr)+round(size(dot,1)/2),size(imgR{n},1));
    idxc=max(1,colR(rr)-round(size(dot,2)/2)+1):min(colR(rr)+round(size(dot,2)/2),size(imgR{n},2));
    
    if 1 <= rowR(rr)-round(size(dot,1)/2)
      didxr=1:min(size(dot,1),size(idxr,2));
    else
      if rowR(rr)+round(size(dot,1)/2) <= size(imgR{n},1)
        didxr=round(size(dot,1)/2)-rowR(rr)+1:size(dot,1);
      else
        didxr=round(size(dot,1)/2)-rowR(rr)+1:size(idxr,1);
      end
    end
    
    if 1<=colR(rr)-round(size(dot,2)/2)
      didxc=1:min(size(dot,2),size(idxc,2));
    else
      if colR(rr)+round(size(dot,2)/2) <= size(imgR{n},2)
        didxc=round(size(dot,2)/2)-colR(rr)+1:size(dot,2);
      else
        didxc=round(size(dot,2)/2)-colR(rr)+1:size(idxr,2);
      end
    end

    % put ovals considering alpha value
    imgR{n}(idxr,idxc)=(1-dotalpha(didxr,didxc)).*imgR{n}(idxr,idxc)+dotalpha(didxr,didxc).*dot(didxr,didxc);
  end
  
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

%% subfunction
function [Y,index] = shuffle(X)
% [Y,index] = shuffle(X)
%
% Randomly sorts X.
% If X is a vector, sorts all of X, so Y = X(index).
% If X is an m-by-n matrix, sorts each column of X, so
% for j=1:n, Y(:,j)=X(index(:,j),j).

[null,index] = sort(rand(size(X)));
[n,m] = size(X);
Y = zeros(size(X));

if (n == 1 || m == 1)
  Y = X(index);
else
  for j = 1:m
    Y(:,j)  = X(index(:,j),j);
  end
end
