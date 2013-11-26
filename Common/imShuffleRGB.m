function [img,fnames]=imShuffleRGB(tgt_dir,rgb_order,img_ext,img_inc_prefix,img_exc_prefix,display_flg,save_flg)

% Shuffles RGB image color orders (e.g. RGB ---> GRB).
% function [img,fnames]=imShuffleRGB(tgt_dir,:rgb_order,:img_ext,:img_inc_prefix,...
%                                     :img_exc_prefix,:display_flg,:save_flg)
% (: is optional)
%
% This function reads RGB images and shuffles their color order (e.g. RGB ---> GRB).
%
% [input]
% tgt_dir        : target directory that includes images you want to process.
%                  should set with a relative path format, e.g. tgt_dir='../images/image01';
% rgb_order      : shuffled order of RGB. 1x3 matrix.
%                  each pixel's 3 values (RGB intensities) are shuffled and replaced
%                  as those of the other color layers.
%                  for example, when rgb_order=[2,3,1], a RGB image will be a GBR image.
%                  rgb_order=[3,2,1]; by default.
% img_ext        : image file extension(s), cell structure or string. '.jpg' by default
% img_inc_prefix : image file prefix(s) that is to be included in processing,
%                  cell structure or string, '*' by default.
% img_exc_prefix : image file prefix(s) that is to be excluded from processing,
%                  cell structure or string, empty by default.
% display_flg    : whether displaying the converted image [0|1]. 0 by default.
% save_flg       : whether saving the converted image [0|1]. 0 by default.
%
% [output]
% img            : color shuffled images, cell structure
% fnames         : the corresponding file names that are converted.
%
%
% Created    : "2013-11-14 16:53:45 ban"
% Last Update: "2013-11-22 23:19:02 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(tgt_dir), help(mfilename()); return; end
if nargin<2 || isempty(rgb_order), rgb_order=[3,2,1]; end
if nargin<3 || isempty(img_ext), img_ext='.jpg'; end
if nargin<4 || isempty(img_inc_prefix), img_inc_prefix='*'; end
if nargin<5 || isempty(img_exc_prefix), img_exc_prefix=''; end
if nargin<6 || isempty(display_flg), display_flg=0; end
if nargin<7 || isempty(save_flg), save_flg=0; end

if ~iscell(img_ext), img_ext={img_ext}; end
if ~iscell(img_inc_prefix), img_inc_prefix={img_inc_prefix}; end
if ~iscell(img_exc_prefix), img_exc_prefix={img_exc_prefix}; end

if numel(rgb_order)~=3, error('rgb_order should be 1x3 matrix consisted from 1-3. check input variables.'); end
if setdiff(rgb_order,[1,2,3]), error('rgb_order should be a vector randomly ordered from 1-3. check input variables.'); end

if save_flg
  save_prefix='_';
  for ii=1:1:3
    if rgb_order(ii)==1
      save_prefix(ii+1)='R';
    elseif rgb_order(ii)==2
      save_prefix(ii+1)='G';
    elseif rgb_order(ii)==3
      save_prefix(ii+1)='B';
    end
  end
end

% set prefix correctly
for ii=1:1:length(img_ext)
  if ~strcmp(img_ext{ii}(1),'.'), img_ext{ii}=['.',img_ext{ii}]; end
end

% check target directory
tgt_dir=fullfile(pwd,tgt_dir);
if ~exist(tgt_dir,'dir'), error('can not find taget directory. check input variable.'); end

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

      % suffle RGB color order
      timg=imread(tmpfnames{kk});
      if numel(size(timg))==3 % if the target is a RGB image
        img_counter=img_counter+1;
        img{img_counter}=timg(:,:,rgb_order);
        fnames{img_counter}=tmpfnames{kk};
      else
        [dummy,fname,ext]=fileparts(tmpfnames{kk});
        fprintf('\nimage:%s%s is a grayscale one. skipping.\n',fname,ext);
        clear dummy fname ext;
      end

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
