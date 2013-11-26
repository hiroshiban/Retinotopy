function [imgL,imgR]=RDSfastest_with_acor_noise_MEX(posL,posR,wdot,bdot,dotalpha,dotDens,noise_psc,bgcolor)

% Generates left/right Random-Dot-AntiCorrelated-Stereogram images with noise (MEX-based).
% function [imgL,imgR]=RDSfastest_with_acor_noise(posL,posR,wdot,bdot,dotalpha,dotDens,noise_psc,bgcolor)
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
% noise_psc   : level (percentage) of anti-correlated dots [1-100]
% bgcolor     : background color, grayscale, [0-255]
%
% [output]
% imgL        : generated image(s) for left eye, [row,col]
% imgR        : generated image(s) for right eye, [row,col]
%
% !!! NOTICE !!!
% for speeding up image generation process,
% I will not put codes for nargin checks.
% Please be careful.
%
% Created:     "2010-10-27 13:28:28 ban"
% Last Update: "2013-11-23 00:00:33 ban (ban.hiroshi@gmail.com)"

% create initial random dot image
randXY=randi(round(100/dotDens),size(posL));
randXY(randXY~=round(100/dotDens))=0;
randXY(logical(randXY))=1;
idxs=find(randXY==1);

% create ID field
% prevent ovals' overlapping problem
idxs=shuffle(idxs);
idXY=repmat(uint32(0),size(randXY));
idXY(idxs)=1:size(idxs);

% create left/right images
tmpL=repmat(uint32(0),size(randXY));
tmpR=repmat(uint32(0),size(randXY));
tmpNL=repmat(uint32(0),size(randXY)); % for noise, anticorrelated
tmpNR=repmat(uint32(0),size(randXY)); % for noise, anticorrelated

idx=find(logical(idXY));
[row,col]=ind2sub(size(idXY),idx);

for ii=1:1:size(row,1)

  % here the 'hole' in the image is filled by shifting the dot position cyclically
  if col(ii)+posL(row(ii),col(ii)) < 1
    tmpL(row(ii),col(ii)+posL(row(ii),col(ii))+size(tmpL,2))=idXY(row(ii),col(ii));
    if posL(row(ii),col(ii))~=0
      tmpNL(row(ii),col(ii)+posL(row(ii),col(ii))+size(tmpL,2))=idXY(row(ii),col(ii));
    end
  elseif size(idXY,2) < col(ii)+posL(row(ii),col(ii))
    tmpL(row(ii),col(ii)+posL(row(ii),col(ii))-size(tmpL,2))=idXY(row(ii),col(ii));
    if posL(row(ii),col(ii))~=0
      tmpNL(row(ii),col(ii)+posL(row(ii),col(ii))-size(tmpL,2))=idXY(row(ii),col(ii));
    end
  else
    tmpL(row(ii),col(ii)+posL(row(ii),col(ii)))=idXY(row(ii),col(ii));
    if posL(row(ii),col(ii))~=0
      tmpNL(row(ii),col(ii)+posL(row(ii),col(ii)))=idXY(row(ii),col(ii));
    end
  end

  if col(ii)+posR(row(ii),col(ii)) < 1
    tmpR(row(ii),col(ii)+posR(row(ii),col(ii))+size(tmpR,2))=idXY(row(ii),col(ii));
    if posR(row(ii),col(ii))~=0
      tmpNR(row(ii),col(ii)+posR(row(ii),col(ii))+size(tmpR,2))=idXY(row(ii),col(ii));
    end
  elseif size(idXY,2) < col(ii)+posR(row(ii),col(ii))
    tmpR(row(ii),col(ii)+posR(row(ii),col(ii))-size(tmpR,2))=idXY(row(ii),col(ii));
    if posR(row(ii),col(ii))~=0
      tmpNR(row(ii),col(ii)+posR(row(ii),col(ii))-size(tmpR,2))=idXY(row(ii),col(ii));
    end
  else
    tmpR(row(ii),col(ii)+posR(row(ii),col(ii)))=idXY(row(ii),col(ii));
    if posR(row(ii),col(ii))~=0
      tmpNR(row(ii),col(ii)+posR(row(ii),col(ii)))=idXY(row(ii),col(ii));
    end
  end

end
imgLids=repmat(uint32(0),size(randXY));
imgRids=repmat(uint32(0),size(randXY));
[dummy,idxL,idxR]=intersect(tmpL(:),tmpR(:));
idxL=idxL(2:end); idxR=idxR(2:end); % omit 0
imgLids(idxL)=tmpL(idxL);
imgRids(idxR)=tmpR(idxR);

% generate anticorrelated map
antiLids=repmat(uint32(0),size(randXY)); % for noise, anticorrelated
antiRids=repmat(uint32(0),size(randXY)); % for noise, anticorrelated
antiLids(idxL)=tmpNL(idxL);
antiRids(idxR)=tmpNR(idxR);

% select anticorrelated dots
noise_idxL=find(antiLids~=0);
[noise_idxL,idx_for_R]=shuffle(noise_idxL);
noise_idxR=find(antiRids~=0);
noise_idxR=noise_idxR(idx_for_R); %shuffle(noise_idxR);

noise_dot_num=round(numel(noise_idxL)*noise_psc/100); % convert noise_psc to the number of dots;

noise_idxL=noise_idxL(1:noise_dot_num);
antiLids=repmat(uint32(0),size(randXY)); % for noise, anticorrelated
antiLids(noise_idxL)=1;

noise_idxR=noise_idxR(1:noise_dot_num);
antiRids=repmat(uint32(0),size(randXY)); % for noise, anticorrelated
antiRids(noise_idxR)=1;

% replace dots to ovals
imgL=uint8(ReplaceDots2Ovals_with_acor_noise(imgLids,antiLids,idxL,noise_dot_num,wdot,bdot,dotalpha,bgcolor,1)); % MEX function
imgR=uint8(ReplaceDots2Ovals_with_acor_noise(imgRids,antiRids,idxR,noise_dot_num,wdot,bdot,dotalpha,bgcolor,0)); % MEX function

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
