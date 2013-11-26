function img = CreateWBnoise(idims, sdims, num, save_flag, show_flag)

% Creates a white/black patch-based noise image.
% function img = CreateWBnoise(idims, sdims, num)
% 
% This function generates white/black patch-based noise image
% 
% <input>
% idims : image dimension [row,col] to create
% sdims : patch size [row,col]
% num   : the number of image files you want to create
% save_flag : if 1, the created noise patterns
%             will be saved as BMP files.
% show_flag : if 1, the created noise patterns
%             are showed in the figure windows.
% 
% * NOTICE mod(idims,sdims) should be 0
%          mod(mdims,2) should be 0
% 
% <output>
% img   : output image W/B mosaic noise
% 
% Nov. 29 2006 Hiroshi Ban

% check input variable
if nargin < 1, idims=[480,640]; sdims=[4,4]; end
if nargin < 2, sdims=[4,4]; end
if nargin < 3, num=1; end
if nargin < 4, save_flag=0; end
if nargin < 5, show_flag=1; end
if length(idims)==1, idims=[idims,idims]; end
if length(sdims)==1, sdims=[sdims,sdims]; end

% matrix dimension check
if mod(idims(1),sdims(1)) || mod(idims(2),sdims(2))
    error('matrix dimension mismatch. idims is not dividable by sdims');
end

mdims=idims./sdims;

% create initial checker board -- a dice (pane) image
tcb = [zeros(1,sdims(1)) ones(1,sdims(1))]; % Temporal CheckerBoard
tcb = repmat(tcb,sdims(2),1);
tcb = [tcb; fliplr(tcb)];

cb = repmat(tcb,mdims(1)/2,mdims(2)/2); % dice image

img=ones(idims(1),idims(2),num);
for ii=1:1:num
	% randomize dice image
	tmp = reshape(cb,[sdims(1),mdims(1),sdims(2),mdims(2)]); % sdims(1)*mdims(1)*sdims(2)*mdims(2)
	tmp = permute(tmp, [1 3 2 4]); % sdims(1) * sdims(2) * mdims(1) * mdims(2)
	tmp = reshape(tmp, [sdims(1),sdims(2),prod(mdims)]);
	% shuffle checker board
	sidx=randperm(prod(mdims)); % shuffle index
	tmp = tmp(:,:,sidx,:); % shuffle image
	% reshape back
	tmp = reshape(tmp, [sdims(1),sdims(2),mdims(1),mdims(2)]);
	tmp = ipermute(tmp, [1 3 2 4]);
	img(:,:,ii) = reshape(tmp,idims);
end

if save_flag
    for ii=1:1:num
		% write rimg to BMP
		eval(sprintf('imwrite(img(:,:,ii),''noise_%03d.bmp'',''bmp'');',ii));
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
