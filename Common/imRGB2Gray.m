function [img,fnames]=imRGB2Gray(tgt_dir,img_ext,img_inc_prefix,img_exc_prefix,display_flg,save_flg)

% Converts input RGB images to grayscale ones.
% function [img,fnames]=imRGB2Gray(tgt_dir,:img_ext,:img_inc_prefix,:img_exc_prefix,:display_flg,:save_flg)
% (: is optional)
%
% This function reads RGB images and convert them to grayscale ones.
%
% [input]
% tgt_dir        : target directory that includes images you want to process.
%                  should set with a relative path format, e.g. tgt_dir='../images/image01';
% img_ext        : image file extension(s), cell structure or string. '.jpg' by default
% img_inc_prefix : image file prefix(s) that is to be included in processing,
%                  cell structure or string, '*' by default.
% img_exc_prefix : image file prefix(s) that is to be excluded from processing,
%                  cell structure or string, empty by default.
% display_flg    : whether displaying the converted image [0|1]. 0 by default.
% save_flg       : whether saving the converted image [0|1]. 0 by default.
%
% [output]
% img            : converted grayscale images, cell structure
% fnames         : the corresponding file names that are converted.
%
%
% Created    : "2013-11-14 16:54:40 ban"
% Last Update: "2013-11-22 23:23:22 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(tgt_dir), help(mfilename()); return; end
if nargin<2 || isempty(img_ext), img_ext='.jpg'; end
if nargin<3 || isempty(img_inc_prefix), img_inc_prefix='*'; end
if nargin<4 || isempty(img_exc_prefix), img_exc_prefix=''; end
if nargin<5 || isempty(display_flg), display_flg=0; end
if nargin<6 || isempty(save_flg), save_flg=0; end

if ~iscell(img_ext), img_ext={img_ext}; end
if ~iscell(img_inc_prefix), img_inc_prefix={img_inc_prefix}; end
if ~iscell(img_exc_prefix), img_exc_prefix={img_exc_prefix}; end

if save_flg, save_prefix='_gray'; end

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

      % convert RGB to grayscale image
      timg=imread(tmpfnames{kk});
      if numel(size(timg))==3 % if the target is a RGB image
        img_counter=img_counter+1;
        img{img_counter}=rgb2gray(timg);
        fnames{img_counter}=tmpfnames{kk};
      else
        [dummy,fname,ext]=fileparts(tmpfnames{kk});
        fprintf('\nimage:%s%s is already grayscale. skipping.\n',fname,ext);
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
