function [imgL,imgR]=RDSfastest_with_noise_MEX(posL,posR,wdot,bdot,dotalpha,dotDens,noise_psc,bgcolor)

% Generates left/right Random-Dot-Stereogram images with noise (MEX-based).
% function [imgL,imgR]=RDSfastest_with_noise(posL,posR,wdot,bdot,dotalpha,dotDens,noise_psc,bgcolor)
%
% This function generates left/right Random Dot Stereogram (RDS) Image (fastest version without any duplicated processing)
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
% Last Update: "2019-05-17 16:15:00 ban"

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

idx=find(logical(idXY));
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

%ids_idx=shuffle(find(logical(imgLids)));
ids_idx=sort(find(logical(imgLids)));
noise_dot_num=round(numel(ids_idx)*noise_psc/100); % convert noise_psc to the number of dots;
imgL=ReplaceDots2Ovals(imgLids,ids_idx,noise_dot_num,wdot,bdot,dotalpha,bgcolor,1); % MEX function

%ids_idx=shuffle(find(logical(imgRids)));
ids_idx=sort(find(logical(imgRids)));
noise_dot_num=round(numel(ids_idx)*noise_psc/100); % convert noise_psc to the number of dots
imgR=ReplaceDots2Ovals(imgRids,ids_idx,noise_dot_num,wdot,bdot,dotalpha,bgcolor,0); % MEX function

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
