function ovalimg=ConvertRandomDots2RandomOvals(dotimg,ovalRadius,colors,pix_per_cm,display_flag,save_flag)

% Converts each of random dots to a shaded oval texture.
% function ovalimg=ConvertRandomDots2RandomOvals(dotimg,ovalRadius,colors,pix_per_cm,display_flag,save_flag)
%
% this function replaces random dot image to random white/black OVAL image
%
% !!!NOTICE!!!
% This function does not take into account of paired-images relation (such as left/right images)
% So, if you want to generate Random Dot Stereo grams, please use
% 'RDSbyOval' or 'RDS2colors'/'ConvertRandomDots2RandomOvalsLR'
%
% [input]
% dotimg     : images of random dots (white(255) = dot to be replaced to oval), cell [row,col]
% ovalRadius : radius of oval, [row(cm),col(cm)]
% colors : colors of ovals and background, [oval1(0-255),oval2(0-255),background(0-255)]
% pix_per_cm : pixels per cm, [val]
% display_flag: if 1, the generated images will be displayed, [0/1]
% save_flag   : if 1, the generated images will be saved as RDS_imgs.mat, [0/1]
%
% [output]
% ovalimg    : images of random ovals
%
% 
% Created    : "2010-06-14 13:52:23 ban"
% Last Update: "2013-11-22 18:38:26 ban (ban.hiroshi@gmail.com)"

% add path
addpath(fullfile(pwd,'Common'));

% check input variables
if nargin<1 || isempty(dotimg), help ConvertDots2Ovals; return; end
if nargin<2 || isempty(ovalRadius), ovalRadius=0.05; end
if nargin<3 || isempty(colors), colors=[0,255,128]; end
if nargin<4 || isempty(pix_per_cm)
  % cm per pix
  % 1 inch = 2.54 cm, my PC's display is 1920x1200, 15.4 inch.
  % So, 15.4(inch)*2.54(cm) / sqrt(1920^2+1200^2) (pix) = XXX cm/pixel
  % cm_per_pix=15.4*2.54/sqrt(1920^2+1200^2);
  pix_per_cm= 1 / (15.4*2.54/sqrt(1920^2+1200^2));
end
if nargin<4 || isempty(display_flag), display_flag=1; end
if nargin<5 || isempty(save_flag), save_flag=0; end

if numel(ovalRadius)==1, ovalRadius=[ovalRadius,ovalRadius]; end

% generate base ovals
dotSize=round(ovalRadius*pix_per_cm*2); % radius(cm) --> diameter(pix)
basedot=double(MakeFineOval(dotSize,[colors(1:2) 0],colors(3),1.2,2,1,0,0));
wdot=basedot(:,:,1);     % get only gray scale image (white)
bdot=basedot(:,:,2);     % get only gray scale image (black)
dotalpha=basedot(:,:,4)./max(max(basedot(:,:,4))); % get alpha channel value 0-1.0;

% convert to cell object
if ~iscell(dotimg), dotimg={dotimg}; end

% initialize
ovalimg=cell(length(dotimg),1);
for ii=1:1:length(dotimg), ovalimg{ii}=double(colors(3)*ones(size(dotimg{ii}))); end

% generate oval dots images
for ii=1:1:length(dotimg)
  
  % get xy-positions of dots from dotimg
  [row,col]=find(dotimg{ii}==255);
  % prevent overlapping problem
  [row,idx]=shuffle(row);
  col=col(idx);
  
  % replace dots to ovals
  for rr=1:1:size(row,1)
    
    % select white/black dot
    if mod(randi(2),2)
      dot=wdot;
    else
      dot=bdot;
    end
    
    % prevent edge removal problem
    idxr=max(1,row(rr)-round(size(dot,1)/2)+1):min(row(rr)+round(size(dot,1)/2),size(dotimg{ii},1));
    idxc=max(1,col(rr)-round(size(dot,2)/2)+1):min(col(rr)+round(size(dot,2)/2),size(dotimg{ii},2));
    
    if 1 <= row(rr)-round(size(dot,1)/2)
      didxr=1:min(size(dot,1),size(idxr,2));
    else
      if row(rr)+round(size(dot,1)/2) <= size(dotimg{ii},1)
        didxr=round(size(dot,1)/2)-row(rr)+1:size(dot,1);
      else
        didxr=round(size(dot,1)/2)-row(rr)+1:size(idxr,1);
      end
    end
    
    if 1<=col(rr)-round(size(dot,2)/2)
      didxc=1:min(size(dot,2),size(idxc,2));
    else
      if col(rr)+round(size(dot,2)/2) <= size(dotimg{ii},2)
        didxc=round(size(dot,2)/2)-col(rr)+1:size(dot,2);
      else
        didxc=round(size(dot,2)/2)-col(rr)+1:size(idxr,2);
      end
    end
    
    % put ovals considering alpha value
    ovalimg{ii}(idxr,idxc)=(1-dotalpha(didxr,didxc)).*ovalimg{ii}(idxr,idxc)+dotalpha(didxr,didxc).*dot(didxr,didxc);
    
  end % for rr=1:1:size(row,1)
  
  ovalimg{ii}=uint8(ovalimg{ii});

end % for ii=1:1:length(dotimg)

% --- plot the results
if display_flag
  figure; hold on;
  for n=1:1:length(dotimg)
    imshow(ovalimg{n},[0,255]);
    colormap(gray);
    shg;
  end
end

% --- save the results
if save_flag
  save RDSoval_imgs.mat ovalimg;
end

% rm path
rmpath(fullfile(pwd,'Common'));

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
