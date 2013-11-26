function [img,fnames]=imAddNoise(tgt_dir,noiseparams,img_ext,img_inc_prefix,img_exc_prefix,display_flg,save_flg,randseed_flg)

% Adds noises to the input images.
% function [img,fnames]=imAddNoise(tgt_dir,:noiseparams,:img_ext,...
%                                :img_inc_prefix,:img_exc_prefix,:display_flg,:save_flg,:randseed_flg)
% (: is optional)
%
% This function reads RGB/grayscale images and convert them to grayscale ones.
%
% [input]
% tgt_dir        : target directory that includes images you want to process.
%                  should set with a relative path format, e.g. tgt_dir='../images/image01';
% noiseparams    : noise parameters, cell structure. Select one from the belows
%                  {'gaussian',M,V} (mean and SD)
%                  {'localvar',V} (SD)
%                  {'localvar',intensity,var}
%                  {'poisson'}
%                  {'salt & pepper',D} (noise density)
%                  {'speckle',V}
%                  for details, see imnoise.m
%                  noiseparams={'gaussian',0,0.01} by default
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
% img            : noise-added images, cell structure
% fnames         : the corresponding file names that are converted.
%
%
% Created    : "2013-11-14 16:57:54 ban"
% Last Update: "2013-11-22 23:27:40 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(tgt_dir), help(mfilename()); return; end
if nargin<2 || isempty(noiseparams), noiseparams={'gaussian',0,0.01}; end
if nargin<3 || isempty(img_ext), img_ext='.jpg'; end
if nargin<4 || isempty(img_inc_prefix), img_inc_prefix='*'; end
if nargin<5 || isempty(img_exc_prefix), img_exc_prefix=''; end
if nargin<6 || isempty(display_flg), display_flg=0; end
if nargin<7 || isempty(save_flg), save_flg=0; end
if nargin<8 || isempty(randseed_flg), randseed_flg=1; end

if ~iscell(img_ext), img_ext={img_ext}; end
if ~iscell(img_inc_prefix), img_inc_prefix={img_inc_prefix}; end
if ~iscell(img_exc_prefix), img_exc_prefix={img_exc_prefix}; end

if save_flg, save_prefix='_noise'; end

% set noise parameters
if strcmp(noiseparams{1},'gaussian')
  if length(noiseparams)<2, noiseparams{2}=0; end
  if length(noiseparams)<3, noiseparams{3}=0.01; end
elseif strcmp(noiseparams{1},'localvar')
  if length(noiseparams)<2, noiseparams{2}=0.1; end
elseif strcmp(noiseparams{1},'poisson')
  % do nothing
elseif strcmp(noiseparams{1},'salt & pepper')
  if length(noiseparams)<2, noiseparams{2}=0.05; end
elseif strcmp(noiseparams{1},'speckle')
  if length(noiseparams)<2, noiseparams{2}=0.04; end
end

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

      % convert RGB to grayscale image
      img_counter=img_counter+1;
      img{img_counter}=imread(tmpfnames{kk});
      if length(noiseparams)==1
        img{img_counter}=imnoise(img{img_counter},noiseparams{1});
      elseif length(noiseparams)==2
        img{img_counter}=imnoise(img{img_counter},noiseparams{1},noiseparams{2});
      elseif length(noiseparams)==3
        img{img_counter}=imnoise(img{img_counter},noiseparams{1},noiseparams{2},noiseparams{3});
      else
        error('noiseparams are not set correctly. check input variable.');
      end
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
