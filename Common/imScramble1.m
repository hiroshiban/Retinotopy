function [simg, sidx] = imScramble1(img,sdims)

% Scrambles an intact input image and generates its mosaic image
% function [simg, sidx] = imScramble1(img,sdims)
% img: image, a m*n or m*n*3 matrix
% Scrambles image (mosaic)
%  [simg, sidx] = imScramble(img,sdims)
% sdims: segment size, a scalar or a 1*2 vector
% simg: scrambled image
% sidx: scrambled index for segments
% 2005/01/14 H.Yamashiro

if length(sdims)==1, sdims=[sdims,sdims]; end
sz=size(img);
if length(sz)==2, sz(3)=1; end
dims=sz(1:2);

if mod(dims(1),sdims(1)) | mod(dims(2),sdims(2))
    error('img is not dividable by sdims');
end

mdims=dims./sdims;

tmp = reshape(img,[sdims(1),mdims(1),sdims(2),mdims(2),sz(3)]);% sdims(1)*mdims(1)*sdims(2)*mdims(2)
tmp = permute(tmp, [ 1 3 2 4 5]); % sdims(1) * sdims(2) * mdims(1) * mdims(2)
tmp = reshape(tmp, [sdims(1),sdims(2),prod(mdims),sz(3)]);
sidx=randperm(prod(mdims)); % shuffle index
tmp = tmp(:,:,sidx,:); % shuffle image
% reshape back
tmp = reshape(tmp, [sdims(1),sdims(2),mdims(1),mdims(2),sz(3)]);
tmp = ipermute(tmp, [ 1 3 2 4 5]);
simg = reshape(tmp,sz);

return

% % for debug
% img=imread('pout.tif');
% img=imresize(img,[256,256]);
% figure; imshow(img);
% simg=imScramble(img,64);
% figure; imshow(simg);
% simg2=imScramble(img,32);
% figure; imshow(simg2);
% simg2=imScramble(img,16);
% figure; imshow(simg2);
