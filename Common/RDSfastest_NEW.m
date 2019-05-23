function [imgL,imgR]=RDSfastest_NEW(posL,posR,wdot,bdot,dotalpha,dotDens,bgcolor,skipzero_flg,avoid_bias_flg,use_mex_flg)

% function [imgL,imgR]=RDSfastest_NEW(posL,posR,wdot,bdot,dotalpha,dotDens,bgcolor,skipzero_flg,avoid_bias_flg,use_mex_flg)
%
% Generate left/right Random Dot Stereogram (RDS) Image (fastest version without any duplicated processing)
% The generated image are the same size with heightfield image.
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
% skipzero_flg : a flag that decides whether the random dots are filled in the
%               background (zero-disparity) regions or not.
%               if 1, the zero-disparity regions are masked and put not RDS.
% avoid_bias_flg : whether avoiding dot overlaps and density biases due to the shifts of dots
%               as much as possible.
% use_mex_flg : whether using a mex function to put white and black dots.
%
% [output]
% imgL        : generated image(s) for left eye, [row,col], same size with posL/posR
% imgR        : generated image(s) for right eye, [row,col], same size with posL/posR
%
% !!! NOTICE !!!
% for speeding up image generation process,
% I will not put codes for nargin checks.
% Please be careful.
%
% Created:     "2010-04-03 14:05:21 ban"
% Last Update: "2019-05-17 16:13:35 ban"

% --- generate RDS images
imgL=double(bgcolor*ones(size(posL)));
imgR=double(bgcolor*ones(size(posL)));

% create initial random dot image
randXY=randi(round(100/dotDens),size(posL));
randXY(mod(randXY,round(100/dotDens))~=0)=0;
randXY(randXY~=0)=1;
if skipzero_flg, randXY(posL==0 & posR==0)=0; end % mask the regions to be processed
idx=shuffle(find(randXY==1));

% create ID field
idXY=NaN(size(randXY));
idXY(idx)=1:numel(idx);

if avoid_bias_flg

  % create left/right images, taking biases of dot density in the image into account
  %% left image(s)
  tmp=NaN*ones(size(randXY));
  hiddensurf=ones(size(randXY));
  pos=unique(posL(~isnan(posL)))';
  for k=pos % from near to far % min(min(posL)):max(max(posL))
    if k<0
      level=size(randXY,2)+k;
      TT=[idXY(:,level+1:end),idXY(:,1:level)];
    elseif k>0
      level=k;
      TT=[idXY(:,level+1:end),idXY(:,1:level)];
    elseif k==0
      TT=idXY;
    end
    tidx=find(posL==k);
    tmp(tidx)=TT(tidx).*hiddensurf(tidx);
    hiddensurf(tidx)=NaN;
    %imshow(tmp,[0,255]); drawnow(); pause(0.1); % DEBUG code
  end
  if use_mex_flg
    imgLids=uint32(tmp);
  else
    imgLids=tmp;
  end

  %% right image(s)
  tmp=NaN*ones(size(randXY));
  hiddensurf=ones(size(randXY));
  pos=unique(posR(~isnan(posR)))';
  for k=pos % from near to far % min(min(posR)):max(max(posR))
    if k<0
      level=size(randXY,2)+k;
      TT=[idXY(:,level+1:end),idXY(:,1:level)];
    elseif k>0
      level=k;
      TT=[idXY(:,level+1:end),idXY(:,1:level)];
    elseif k==0
      TT=idXY;
    end
    tidx=find(posR==k);
    tmp(tidx)=TT(tidx).*hiddensurf(tidx);
    hiddensurf(tidx)=NaN;
    %imshow(tmp,[0,255]); drawnow(); pause(0.1); % DEBUG code
  end

  if use_mex_flg
    imgRids=uint32(tmp);
  else
    imgRids=tmp;
  end

else % avoid_bias_flg

  % without considering biases of dot density in the image
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
  %imgLids=tmpL;
  %imgRids=tmpR;

  if use_mex_flg
    imgLids=uint32(tmpL);
    imgRids=uint32(tmpR);
  else
    imgLids=tmpL;
    imgRids=tmpR;
  end

end % if avoid_bias_flg

if use_mex_flg

  % replace dots to ovals with MEX

  %ids_idx=shuffle(find(logical(imgLids)));
  ids_idx=sort(find(logical(imgLids)));
  noise_dot_num=0;%round(numel(ids_idx)*noise_psc/100); % convert noise_psc to the number of dots;
  imgL=ReplaceDots2Ovals(imgLids,ids_idx,noise_dot_num,wdot,bdot,dotalpha,bgcolor,1); % MEX function

  %ids_idx=shuffle(find(logical(imgRids)));
  ids_idx=sort(find(logical(imgRids)));
  noise_dot_num=0;%round(numel(ids_idx)*noise_psc/100); % convert noise_psc to the number of dots
  imgR=ReplaceDots2Ovals(imgRids,ids_idx,noise_dot_num,wdot,bdot,dotalpha,bgcolor,0); % MEX function

else % if use_mex_flg

  % replace dots to ovals without MEX

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

end % if use_mex_flg

imgL=uint8(imgL);
imgR=uint8(imgR);

return;

%% subfunction
function [Y,index]=shuffle(X)
% [Y,index]=shuffle(X)
%
% Randomly sorts X.
% If X is a vector, sorts all of X, so Y=X(index).
% If X is an m-by-n matrix, sorts each column of X, so
% for j=1:n, Y(:,j)=X(index(:,j),j).

[null,index]=sort(rand(size(X)));
[n,m]=size(X);
Y=zeros(size(X));

if (n == 1 || m == 1)
  Y=X(index);
else
  for j=1:m
    Y(:,j) =X(index(:,j),j);
  end
end
