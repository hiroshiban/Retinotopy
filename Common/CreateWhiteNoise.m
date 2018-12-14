function img = CreateWhiteNoise(idims, sdims, num, noiseM, noiseV, save_flag, show_flag)

% Creates white noise patch image(s).
% function img = CreateWhiteNoise(idims, sdims, num)
%
% This function generates white noise patch image
%
% <input>
% idims : image dimension [row,col] to create, [240,320] as default
% sdims : patch size [row,col], [8,8] as default
% num   : the number of image files you want to create, 1 as default
% noiseM: mean intensity of the noise image, 0 as default
% noiseV: variance of noise, 0.01 as default
% save_flag : if 1, the created noise patterns
%             will be saved as BMP files.
% show_flag : if 1, the created noise patterns
%             are showed in the figure windows.
%
% * NOTICE mod(idims,sdims) should be 0
%          mod(mdims,2) should be 0
%
% <output>
% img   : output images, rectangular white noises
%
% July 04 2007 Hiroshi Ban

% check input variable
if nargin < 1, idims=[240,320]; sdims=[4,4]; end
if nargin < 2, sdims=[8,8]; end
if nargin < 3, num=1; end
if nargin < 4, noiseM=64; end
if nargin < 5, noiseV=0.01; end
if nargin < 6, save_flag=0; end
if nargin < 7, show_flag=1; end
if length(idims)==1, idims=[idims,idims]; end
if length(sdims)==1, sdims=[sdims,sdims]; end

% matrix dimension check
if mod(idims(1),sdims(1)) || mod(idims(2),sdims(2))
  error('matrix dimension mismatch. idims is not dividable by sdims');
end

mdims=idims./sdims;

% create initial mean gray images & noise images
imap=noiseM*ones(idims(1),idims(2)); % mean gray map

img=ones(idims(1),idims(2),num);
for ii=1:1:num
  % segment initial mean maps
  tmp=reshape(imap,[sdims(1),mdims(1),sdims(2),mdims(2)]); % sdims(1)*mdims(1)*sdims(2)*mdims(2)
  tmp=permute(tmp,[1 3 2 4]); % sdims(1) * sdims(2) * mdims(1) * mdims(2)
  tmp=reshape(tmp,[sdims(1),sdims(2),prod(mdims)]);

  % create noise map
  nmap=imnoise(uint8(noiseM*ones(mdims)),'gaussian',0,noiseV);
  tmpn=reshape(nmap,[1,mdims(2),1,mdims(1)]);
  tmpn=permute(tmpn,[1,3,2,4]); % 1 * 1 * mdims(1) * mdims(2)
  tmpn=reshape(tmpn,[1,1,prod(mdims)]);

  % add noises to image patches (segments)
  for jj=1:1:prod(mdims)
    tmp(:,:,jj)=tmpn(1,1,jj);
  end

  % reshape back
  tmp = reshape(tmp, [sdims(1),sdims(2),mdims(1),mdims(2)]);
  tmp = ipermute(tmp, [1 3 2 4]);
  img(:,:,ii) = reshape(tmp,idims);
end

img=uint8(img);
if save_flag
  for ii=1:1:num
    % write rimg to BMP
    eval(sprintf('imwrite(img(:,:,ii),''noise_%04d.jpg'',''jpg'',''Quality'',100);',ii));
  end
end

if show_flag
  for ii=1:1:num
    figure;
    imshow(img(:,:,ii));
    axis off;
  end
end

return
