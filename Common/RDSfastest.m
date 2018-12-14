function [imgL,imgR]=RDSfastest(heightfield,posL,posR,colors,dotDens)

% Generates left/right Random-Dot-Stereogram images.
% function [imgL,imgR]=RDSfastest(heightfield,posL,posR,colors,dotDens)
%
% Generate left/right Random Dot Stereogram (RDS) Image (fastest version without any duplicated processing)
% The generated image are the same size with heightfield image.
%
% -- modified from RDSfast for speeding up and for matching the purpose of the
%    current experiment
%
% [input]
% heightfield : height field to generate RDS, [row,col]
%               *NOTICE* the unit of the height should be cm
% posL        : position shifts for left RDS image [row,col] (same size with heightfield)
% posR        : position shifts for right RDS image [row,col] (same size with heightfield)
% colors      : dot/background colors, [0-255(dot1),0-255(dot2),0-255(background)]
% dotDens     : density (percentage) of ovals filling the generated RDS image [1-100]
%
% [output]
% imgL        : generated image(s) for left eye, [row,col]
% imgR        : generated image(s) for right eye, [row,col]
% 
% Created:     "2010-04-03 14:05:21 ban"
% Last Update: "2013-11-23 00:00:21 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<3, help RDSbyOvalFastest; return; end
if nargin<4 || isempty(colors), colors=[255,0,128]; end 
if nargin<5 || isempty(dotDens), dotDens=10; end

% check sizes of input data
[r1,c1]=size(heightfield);
[r2,c2]=size(posL);
if r1~=r2 || c1~=c2, error('the size heightfield & posL mismatched! Check input variables'); end
[r3,c3]=size(posR);
if r2~=r3 || c2~=c3, error('the size posL & posR mismatched! Check input variables'); end

% --- generate RDS images

% create initial random dot image
randXY=randi(round(100/dotDens),size(heightfield));
randXY(randXY~=round(100/dotDens))=0;
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

% create left/right images
tmpL=colors(3)*ones(size(randXY));
tmpR=colors(3)*ones(size(randXY));

for ii=1:1:size(row,1)
  
  % here the 'hole' in the image is filled by shifting the dot position cyclically
  if col(ii)+posL(row(ii),col(ii)) < 1
    tmpL(row(ii),col(ii)+posL(row(ii),col(ii))+size(tmpL,2))=randXY(row(ii),col(ii));
  elseif size(randXY,2) < col(ii)+posL(row(ii),col(ii))
    tmpL(row(ii),col(ii)+posL(row(ii),col(ii))-size(tmpL,2))=randXY(row(ii),col(ii));
  else
    tmpL(row(ii),col(ii)+posL(row(ii),col(ii)))=randXY(row(ii),col(ii));
  end
  
  if col(ii)+posR(row(ii),col(ii)) < 1
    tmpR(row(ii),col(ii)+posR(row(ii),col(ii))+size(tmpR,2))=randXY(row(ii),col(ii));
  elseif size(randXY,2) < col(ii)+posR(row(ii),col(ii))
    tmpR(row(ii),col(ii)+posR(row(ii),col(ii))-size(tmpR,2))=randXY(row(ii),col(ii));
  else
    tmpR(row(ii),col(ii)+posR(row(ii),col(ii)))=randXY(row(ii),col(ii));
  end
  
end
imgL=uint8(tmpL);
imgR=uint8(tmpR);

return
