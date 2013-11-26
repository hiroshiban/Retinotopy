function sizes=imCheckSize(tgt_dir,img_ext,img_inc_prefix,img_exc_prefix)

% Returns the image XY resolutions and sizes of the input images.
% function sizes=imCheckSize(tgt_dir,:img_ext,:img_inc_prefix,:img_exc_prefix)
% (: is optional)
%
% This function reads images and returns their row&col pixel length together
% with their file sizes.
%
% [input]
% tgt_dir        : target directory that includes images you want to process.
%                  should set with a relative path format, e.g. tgt_dir='../images/image01';
% img_ext        : image file extension(s), cell structure or string. '.jpg' by default
% img_inc_prefix : image file prefix(s) that is to be included in processing,
%                  cell structure or string, '*' by default.
% img_exc_prefix : image file prefix(s) that is to be excluded from processing,
%                  cell structure or string, empty by default.
%
% [output]
% sizes          : image information, cell structure
%                  {image_num,file_name,x_resolution,y_resolution,Kbytes}
%
%
% Created    : "2013-11-14 16:57:41 ban"
% Last Update: "2013-11-22 23:27:23 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(tgt_dir), help(mfilename()); return; end
if nargin<2 || isempty(img_ext), img_ext='.jpg'; end
if nargin<3 || isempty(img_inc_prefix), img_inc_prefix='*'; end
if nargin<4 || isempty(img_exc_prefix), img_exc_prefix=''; end

if ~iscell(img_ext), img_ext={img_ext}; end
if ~iscell(img_inc_prefix), img_inc_prefix={img_inc_prefix}; end
if ~iscell(img_exc_prefix), img_exc_prefix={img_exc_prefix}; end

% set prefix correctly
for ii=1:1:length(img_ext)
  if ~strcmp(img_ext{ii}(1),'.'), img_ext{ii}=['.',img_ext{ii}]; end
end

% check target directory
tgt_dir=fullfile(pwd,tgt_dir);
if ~exist(tgt_dir,'dir'), error('can not find taget directory. check input variable.'); end

fprintf('target: %s\n',tgt_dir);
fprintf('getting and writing image file information...\n\n')

% get image files
fid=fopen('img_sizes.txt','w');
if fid==-1, error('can not open img_sizes.txt to write.'); end

% file header
fprintf(fid,'######################################################\n');
fprintf(fid,'#####         Image File Names & Sizes           #####\n');
fprintf(fid,'######################################################\n');
fprintf(fid,'image_num: file_name   x_resolution    y_resolution    Kbytes\n');

% on screen
fprintf('######################################################\n');
fprintf('#####         Image File Names & Sizes           #####\n');
fprintf('######################################################\n');
fprintf('image_num: file_name   x_resolution    y_resolution    Kbytes\n');

sizes=''; img_counter=0;
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

      % load target image, get size information, and write it to the file.
      img_counter=img_counter+1;
      tgtfile=dir(tmpfnames{kk});
      [path1,fname,ext]=fileparts(tmpfnames{kk});
      if img_counter>=2
        path2=fileparts(tmpfnames{kk-1});
      else
        path2='dummy';
      end
      if ~strcmp(path1,path2)
        fprintf(fid,'\ndirectory: %s\n',path1);
        fprintf('\ndirectory: %s\n',path1);
      end

      img=imread(tmpfnames{kk});
      fprintf(fid,'%04d:\t%s\t%d\t%d\t%.2f\n',kk,[fname,ext],size(img,2),size(img,1),tgtfile.bytes/1000);
      fprintf('%04d:\t%s\t%d\t%d\t%.2f\n',kk,[fname,ext],size(img,2),size(img,1),tgtfile.bytes/1000);
      sizes{kk}={kk,[fname,ext],size(img,2),size(img,1),tgtfile.bytes/1000};

    end
  end
end
disp(' ');
disp('done.');

fclose(fid);

return
