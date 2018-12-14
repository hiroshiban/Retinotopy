function [img,fnames]=imFillRect(tgt_dir,outputsize,fillcolor,img_ext,img_inc_prefix,img_exc_prefix,display_flg,save_flg)

% Fills the extended rectangular background regions of the input images.
% function [img,fnames]=imFillRect(tgt_dir,:outputsize,:fillcolor,:img_ext,:img_inc_prefix,:img_exc_prefix,:display_flg,:save_flg)
% (: is optional)
%
% This function reads RGB images and convert them to grayscale ones.
% If the target image is larger than the outputsize, the input image is cropped to match with the outputsize.
%
% [input]
% tgt_dir        : target directory that includes images you want to process.
%                  should set with a relative path format, e.g. tgt_dir='../images/image01';
% outputsize     : the output image size, [row,col]. [640,640] by default.
% fillcolor      : RGB or grayscale color used to fill the region. 0-255. 127 by default.
% img_ext        : image file extension(s), cell structure or string. '.jpg' by default
% img_inc_prefix : image file prefix(s) that is to be included in processing,
%                  cell structure or string, '*' by default.
% img_exc_prefix : image file prefix(s) that is to be excluded from processing,
%                  cell structure or string, empty by default.
% display_flg    : whether displaying the converted image [0|1]. 0 by default.
% save_flg       : whether saving the converted image [0|1]. 0 by default.
%
% [output]
% img            : filled images, cell structure
% fnames         : the corresponding file names that are converted.
%
%
% Created    : "2013-11-14 16:55:08 ban"
% Last Update: "2013-11-22 23:24:55 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(tgt_dir), help(mfilename()); return; end
if nargin<2 || isempty(outputsize), outputsize=[640,640]; end
if nargin<3 || isempty(fillcolor), fillcolor=127; end
if nargin<4 || isempty(img_ext), img_ext='.jpg'; end
if nargin<5 || isempty(img_inc_prefix), img_inc_prefix='*'; end
if nargin<6 || isempty(img_exc_prefix), img_exc_prefix=''; end
if nargin<7 || isempty(display_flg), display_flg=0; end
if nargin<8 || isempty(save_flg), save_flg=0; end

if ~iscell(img_ext), img_ext={img_ext}; end
if ~iscell(img_inc_prefix), img_inc_prefix={img_inc_prefix}; end
if ~iscell(img_exc_prefix), img_exc_prefix={img_exc_prefix}; end

if numel(outputsize)==1, outputsize=[outputsize,outputsize]; end

if save_flg, save_prefix='_fill'; end

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
      img_counter=img_counter+1;
      img{img_counter}=imread(tmpfnames{kk});

      % get image size parameters
      sz=size(img{img_counter});
      if numel(sz)==3 % RGB image
        if numel(fillcolor)==1
          filling=[fillcolor,fillcolor,fillcolor];
        else
          filling=fillcolor;
        end
        outimg=zeros([outputsize,3]);
        for pp=1:1:3, outimg(:,:,pp)=filling(pp).*ones(outputsize); end
      else % grayscale
        if numel(fillcolor)==1
          filling=fillcolor;
        else
          filling=uint8(mean(fillcolor));
        end
        outimg=filling.*ones(outputsize);
      end

      % filling the region
      sr1=max(1,round((outputsize(1)-sz(1))/2+1)); er1=min(sr1+sz(1)-1,outputsize(1));
      sc1=max(1,round((outputsize(2)-sz(2))/2+1)); ec1=min(sc1+sz(2)-1,outputsize(2));
      sr2=max(1,round((sz(1)-outputsize(1))/2+1)); er2=min(sr2+sz(1)-1,sr2+outputsize(1)-1);
      sc2=max(1,round((sz(2)-outputsize(2))/2+1)); ec2=min(sc2+sz(2)-1,sc2+outputsize(2)-1);
      outimg(sr1:er1,sc1:ec1,:)=img{img_counter}(sr2:er2,sc2:ec2,:);
      img{img_counter}=uint8(outimg);

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
