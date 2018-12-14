function [img,fnames]=imScramble(tgt_dir,sdims,img_ext,img_inc_prefix,img_exc_prefix,display_flg,save_flg,randseed_flg)

% Scrambles intact input images and generates their mosaic images.
% function [img,fnames]=imScramble(tgt_dir,sdims,:img_ext,:img_inc_prefix,:img_exc_prefix,:display_flg,:save_flg,:randseed_flg)
% (: is optional)
%
% This function makes mosaic images from the input image files.
% The procedure to generate mosaic images was originally wrote by H.Yamashiro as imMosaic.m
%
% [input]
% tgt_dir        : target directory that includes images you want to process.
%                  should set with a relative path format, e.g. tgt_dir='../images/image01';
% sdims          : segment size, a scalar or a 1*2 vector [row,col], [32,32] by default.
% img_ext        : image file extension(s), cell structure or string. '.jpg' by default
% img_inc_prefix : image file prefix(s) that is to be included in processing,
%                  cell structure or string, '*' by default.
% img_exc_prefix : image file prefix(s) that is to be excluded from processing,
%                  cell structure or string, empty by default.
% display_flg    : whether displaying the converted image [0|1]. 0 by default.
% save_flg       : whether saving the converted image [0|1]. 0 by default.
% randseed_flg   : whether initializing random seed, [0|1]. 1 by default.
%
% [output]
% img            : converted scrambled images, cell structure
% fnames         : the corresponding file names that are converted.
%
%
% Created    : "2013-11-14 16:54:03 ban"
% Last Update: "2013-11-22 23:19:40 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(tgt_dir), help(mfilename()); return; end
if nargin<2 || isempty(sdims), sdims=[32,32]; end
if nargin<3 || isempty(img_ext), img_ext='.jpg'; end
if nargin<4 || isempty(img_inc_prefix), img_inc_prefix='*'; end
if nargin<5 || isempty(img_exc_prefix), img_exc_prefix=''; end
if nargin<6 || isempty(display_flg), display_flg=0; end
if nargin<7 || isempty(save_flg), save_flg=0; end
if nargin<8 || isempty(randseed_flg), randseed_flg=1; end

if ~iscell(img_ext), img_ext={img_ext}; end
if ~iscell(img_inc_prefix), img_inc_prefix={img_inc_prefix}; end
if ~iscell(img_exc_prefix), img_exc_prefix={img_exc_prefix}; end

if numel(sdims)==1, sdims=[sdims,sdims]; end
if numel(sdims)~=2, error('sdims should be a scalar or 1x2 matrix. check input variables.'); end

if save_flg, save_prefix='_scr'; end

% set prefix correctly
for ii=1:1:length(img_ext)
  if ~strcmp(img_ext{ii}(1),'.'), img_ext{ii}=['.',img_ext{ii}]; end
end

% check target directory
tgt_dir=fullfile(pwd,tgt_dir);
if ~exist(tgt_dir,'dir'), error('can not find taget directory. check input variable.'); end

% initialize random seed
if randseed_flg, InitializeRandomSeed(); end

fprintf('target: %s\n',tgt_dir);

% get image files
fprintf('converting images...');
img=''; fnames=''; img_counter=0;
for ii=1:1:length(img_ext)
  for jj=1:1:length(img_inc_prefix)
    tmpfnames=wildcardsearch(tgt_dir,[img_inc_prefix{jj},img_ext{ii}]);
    for kk=1:1:length(tmpfnames)

      % check whether the target image is excluded from processing
      exc_flg=0;
      for mm=1:1:length(img_exc_prefix)
        if ~isempty(img_exc_prefix{mm}) && strfind(tmpfnames{kk},img_exc_prefix{mm}), exc_flg=1; break; end
      end
      if exc_flg, continue; end

      % generate mosaic image
      img_counter=img_counter+1;
      img{img_counter}=imread(tmpfnames{kk});

      sz=size(img{img_counter}); if numel(sz)==2, sz(3)=1; end
      dims=sz(1:2);
      if mod(dims(1),sdims(1)) || mod(dims(2),sdims(2)), error('input image can not be divided by sdims'); end
      mdims=dims./sdims;
      tmp=reshape(img{img_counter},[sdims(1),mdims(1),sdims(2),mdims(2),sz(3)]);% sdims(1)*mdims(1)*sdims(2)*mdims(2)
      tmp=permute(tmp,[1,3,2,4,5]); % sdims(1) * sdims(2) * mdims(1) * mdims(2)
      tmp=reshape(tmp,[sdims(1),sdims(2),prod(mdims),sz(3)]);
      sidx=randperm(prod(mdims)); % shuffle index
      tmp=tmp(:,:,sidx,:); % shuffle image
      % reshape back
      tmp=reshape(tmp, [sdims(1),sdims(2),mdims(1),mdims(2),sz(3)]);
      tmp=ipermute(tmp, [ 1 3 2 4 5]);
      img{img_counter}=reshape(tmp,sz);

      fnames{img_counter}=tmpfnames{kk};

    end
  end
end
disp('done.');

% displaying
if display_flg
  fprintf('displaying the converted images...');
  for ii=1:1:length(img)
    figure;
    imshow(img{ii});
  end
  disp('done.');
end

% saving the images
if save_flg
  fprintf('saving the converted images...')
  for ii=1:1:length(img)
    [save_path,save_name,save_ext]=fileparts(fnames{ii});
    imwrite(img{ii},fullfile(save_path,[save_name,save_prefix,save_ext]),strrep(save_ext,'.',''));
  end
  disp('done.');
end

return
