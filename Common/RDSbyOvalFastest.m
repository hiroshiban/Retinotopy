function [imgL,imgR]=RDSbyOvalFastest(posL,posR,wdot,bdot,dotalpha,dotDens,bgcolor)

% Generates left/right Random-Dot-Stereogram images.
% function [imgL,imgR]=RDSbyOvalFastest(posL,posR,wdot,bdot,dotalpha,dotDens,bgcolor)
%
% Generate left/right Random Dot Stereogram (RDS) Image (fastest version without any duplicated processing)
% The generated image are the same size with posL/posR image.
%
% -- modified from RDSbyOval for speeding up and for matching the purpose of the
%    current experiment
%
% [input]
% posL        : position shifts for left RDS image [row,col]
% posR        : position shifts for right RDS image [row,col]
% wdot        : oval 1 to be used in RDS image [row,col]
% bdot        : oval 2 to be used in RDS image [row,col]
% dotalpha    : alpha value of oval 1&2 [row,col] (same size with wdot & bdot)
% dotDens     : density (percentage) of ovals filling the generated RDS image [1-100]
% bgcolor     : background color, grayscale, [0-255]
%
% [output]
% imgL        : generated image(s) for left eye, [row,col]
% imgR        : generated image(s) for right eye, [row,col]
%
% Created:     "2010-04-03 14:05:21 ban"
% Last Update: "2019-05-17 16:16:20 ban"

% check input variables
if nargin<6, help RDSbyOvalFastest; return; end
if nargin<7 || isempty(dotDens), dotDens=2; end
if nargin<8 || isempty(bgcolor), bgcolor=128; end

% check sizes of input data
[r1,c1]=size(posL);
[r2,c2]=size(posR);
if r1~=r2 || c1~=c2, error('the size posL & posR mismatched! Check input variables'); end

[r4,c4]=size(wdot);
[r5,c5]=size(bdot);
if r4~=r5 || c4~=c5, error('the size wdot & bdot mismatched! Check input variables'); end
[r6,c6]=size(dotalpha);
if r4~=r6 || c4~=c6, error('the size wdot/bdot & dotalpha mismatched! Check input variables'); end

% --- generate RDS images
imgL=double(bgcolor*ones(size(posL)));
imgR=double(bgcolor*ones(size(posR)));

% create initial random dot image
randXY=randi(round(100/dotDens),size(posL));
randXY(randXY~=round(100/dotDens))=0;
randXY(logical(randXY))=1;
idxs=find(randXY==1);

% create ID field
% prevent ovals' overlapping problem
idxs=shuffle(idxs);
idXY=NaN*ones(size(randXY));
%for ii=1:1:size(idxs,1), idXY(idxs(ii))=idx(ii); end % much faster than using sub2ind
idXY(idxs)=1:size(idxs);

% create left/right images
tmpL=NaN*ones(size(randXY));
tmpR=NaN*ones(size(randXY));

idx=find(~isnan(idXY));
[row,col]=ind2sub(size(idXY),idx);

for ii=1:1:size(row,1)
  if ~isnan(posL(row(ii),col(ii))) && ~isnan(posR(row(ii),col(ii)))
    % here the 'hole' in the image is filled by shifting the dot position cyclically
    if col(ii)+posL(row(ii),col(ii)) < 1
      tmpL(row(ii),col(ii)+posL(row(ii),col(ii))+size(tmpL,2))=idXY(row(ii),col(ii));
    elseif size(idXY,2) < col(ii)+posL(row(ii),col(ii))
      tmpL(row(ii),col(ii)+posL(row(ii),col(ii))-size(tmpL,2))=idXY(row(ii),col(ii));
    else
      tmpL(row(ii),col(ii)+posL(row(ii),col(ii)))=idXY(row(ii),col(ii));
    end

    if col(ii)+posR(row(ii),col(ii)) < 1
      tmpR(row(ii),col(ii)+posR(row(ii),col(ii))+size(tmpR,2))=idXY(row(ii),col(ii));
    elseif size(idXY,2) < col(ii)+posR(row(ii),col(ii))
      tmpR(row(ii),col(ii)+posR(row(ii),col(ii))-size(tmpR,2))=idXY(row(ii),col(ii));
    else
      tmpR(row(ii),col(ii)+posR(row(ii),col(ii)))=idXY(row(ii),col(ii));
    end
  end
end
imgLids=tmpL;
imgRids=tmpR;

% replace dots to ovals

[rowL,colL]=find(~isnan(imgLids));
for rr=1:1:size(rowL,1)
  % select white/black dot
  if mod(imgLids(rowL(rr),colL(rr)),2) %mod(comval(rr),2)
    dot=wdot;
  else
    dot=bdot;
  end

  % set ovals to the left image
  idxr=max(1,rowL(rr)-round(size(dot,1)/2)+1):min(rowL(rr)+round(size(dot,1)/2),size(imgL,1));
  idxc=max(1,colL(rr)-round(size(dot,2)/2)+1):min(colL(rr)+round(size(dot,2)/2),size(imgL,2));

  if 1 <= rowL(rr)-round(size(dot,1)/2)
    didxr=1:min(size(dot,1),size(idxr,2));
  else
    if rowL(rr)+round(size(dot,1)/2) <= size(imgL,1)
      didxr=round(size(dot,1)/2)-rowL(rr)+1:size(dot,1);
    else
      didxr=round(size(dot,1)/2)-rowL(rr)+1:size(idxr,1);
    end
  end

  if 1<=colL(rr)-round(size(dot,2)/2)
    didxc=1:min(size(dot,2),size(idxc,2));
  else
    if colL(rr)+round(size(dot,2)/2) <= size(imgL,2)
      didxc=round(size(dot,2)/2)-colL(rr)+1:size(dot,2);
    else
      didxc=round(size(dot,2)/2)-colL(rr)+1:size(idxr,2);
    end
  end

  % put ovals considering alpha value
  imgL(idxr,idxc)=(1-dotalpha(didxr,didxc)).*imgL(idxr,idxc)+dotalpha(didxr,didxc).*dot(didxr,didxc);
end

[rowR,colR]=find(~isnan(imgRids));
for rr=1:1:size(rowR,1)
  % select white/black dot
  if mod(imgRids(rowR(rr),colR(rr)),2) %mod(comval(rr),2)
    dot=wdot;
  else
    dot=bdot;
  end

  % prevent edge removal problem
  idxr=max(1,rowR(rr)-round(size(dot,1)/2)+1):min(rowR(rr)+round(size(dot,1)/2),size(imgR,1));
  idxc=max(1,colR(rr)-round(size(dot,2)/2)+1):min(colR(rr)+round(size(dot,2)/2),size(imgR,2));

  if 1 <= rowR(rr)-round(size(dot,1)/2)
    didxr=1:min(size(dot,1),size(idxr,2));
  else
    if rowR(rr)+round(size(dot,1)/2) <= size(imgR,1)
      didxr=round(size(dot,1)/2)-rowR(rr)+1:size(dot,1);
    else
      didxr=round(size(dot,1)/2)-rowR(rr)+1:size(idxr,1);
    end
  end

  if 1<=colR(rr)-round(size(dot,2)/2)
    didxc=1:min(size(dot,2),size(idxc,2));
  else
    if colR(rr)+round(size(dot,2)/2) <= size(imgR,2)
      didxc=round(size(dot,2)/2)-colR(rr)+1:size(dot,2);
    else
      didxc=round(size(dot,2)/2)-colR(rr)+1:size(idxr,2);
    end
  end

  % put ovals considering alpha value
  imgR(idxr,idxc)=(1-dotalpha(didxr,didxc)).*imgR(idxr,idxc)+dotalpha(didxr,didxc).*dot(didxr,didxc);
end

imgL=uint8(imgL);
imgR=uint8(imgR);

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
