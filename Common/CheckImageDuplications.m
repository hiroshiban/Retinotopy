function [dupfiles,dup_idx]=CheckImageDuplications(img_dir,img_ext,one_by_one_flg)

% Reads images in the target directory and detect the duplications
% function [dupfiles,dup_idx]=CheckImageDuplications(img_dir,:img_ext,:one_by_one_flg)
% (: is optional)
%
% This function reads all the images in the target directory
% and check whether the duplicated images are included.
%
% [input]
% img_dir   : target directory in which images are included.
%             a relative path format in which the directory where this
%             function is called is the origin. e.g. img_dir='../imgs';
% img_ext   : (optional) file extension of the target image files.
%             e.g. img_ext='.jpg';, empty by default.
% one_by_one_flg : (optional) whether reading images one by one
%                  to save the memory space or reading all at once
%
% [output]
% dupfiles : the duplicated image file names. the first image will be
%            kept as the original and the duplicated ones will be listed.
% dup_idx  : index of the duplicated images
%
% [note]
% a log file will be saved in the directory where this function is called.
%
%
% Created    : "2015-07-24 09:15:27 ban"
% Last Update: "2015-07-24 11:40:04 ban"

% check the input variables
if nargin<1 || isempty(img_dir), help(mfilename()); return; end
if nargin<2 || isempty(img_ext), img_ext=''; end
if nargin<3 || isempty(one_by_one_flg), one_by_one_flg=1; end

img_dir=fullfile(pwd,img_dir);
if ~exist(img_dir,'dir'), error('can not find img_dir. check input variable.'); end

% log file
diary(fullfile(fileparts(mfilename('fullpath')),strcat(mfilename(),'_',datestr(date,'yymmdd'),'.log')));

% processing
fprintf('\n');
imgfiles=wildcardsearch(img_dir,['*',img_ext]);
dup_idx=zeros(length(imgfiles),1);
dup_counter=0;

if one_by_one_flg % read images one by one to save the memory

  for ii=1:1:length(imgfiles)

    if dup_idx(ii)~=0
      continue;
    else
      dup_idx(ii)=ii;
    end

    % read the reference image
    [dummy,imgfname,imgext]=fileparts(imgfiles{ii}); %#ok
    fprintf('reference    : %s%s\n',imgfname,imgext)
    fref=fopen(imgfiles{ii},'rb');
    if fref==-1, error('can not read the target file. check the input variable.'); end
    r_data=fread(fref,Inf,'uint8')';
    fclose(fref);

    unprocessed_idx=(find(dup_idx==0))';
    for jj=unprocessed_idx
      [dummy,imgfname,imgext]=fileparts(imgfiles{jj}); %#ok
      ftgt=fopen(imgfiles{jj},'rb');
      if ftgt==-1, error('can not read the target file. check the input variable.'); end
      t_data=fread(ftgt,Inf,'uint8')';
      fclose(ftgt);

      if numel(r_data)==numel(t_data) && sum(r_data-t_data)==0
        fprintf('  duplicated : %s%s\n',imgfname,imgext);
        dup_idx(jj)=ii;
        dup_counter=dup_counter+1;
        dupfiles{dup_counter}=imgfiles{jj}; %#ok % get duplicated image filename
      end
    end % for jj=unprocessed_idx

  end % for ii=1:1:length(imgfiles)

else % if one_by_one_flg % read all images at once

  % read all image data
  fprintf('reading all images in the target directory...');
  data=cell(length(imgfiles),1);
  for ii=1:1:length(imgfiles)
    fimg=fopen(imgfiles{ii},'rb');
    if fimg==-1, error('can not read the target file %s. check the input variable.',imgfiles{ii}); end
    data{ii}=fread(fimg,Inf,'uint8')';
    fclose(fimg);
  end
  disp('done.');

  for ii=1:1:length(imgfiles)

    if dup_idx(ii)~=0
      continue;
    else
      dup_idx(ii)=ii;
    end

    [dummy,imgfname,imgext]=fileparts(imgfiles{ii}); %#ok
    fprintf('reference    : %s%s\n',imgfname,imgext);

    unprocessed_idx=(find(dup_idx==0))';
    for jj=unprocessed_idx
      if numel(data{ii})==numel(data{jj}) && sum(data{ii}-data{jj})==0
        [dummy,imgfname,imgext]=fileparts(imgfiles{jj}); %#ok
        fprintf('  duplicated : %s%s\n',imgfname,imgext);
        dup_idx(jj)=ii;
        dup_counter=dup_counter+1;
        dupfiles{dup_counter}=imgfiles{jj}; %#ok % get duplicated image filename
      end
    end % for jj=unprocessed_idx

  end % for ii=1:1:length(imgfiles)

end % if one_by_one_flg

diary off;

return
