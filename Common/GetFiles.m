function filenames=GetFiles(target_fullpath_dir,extension,prefix)

% Searches and gets files we want under the target directory (recursive and wildcard search is available).
% function filenames=GetFils(target_fullpath_dir,prefix)
%
% [example]
% >> vtcfiles=GetFiles('c:/fmri_analysis/CastingShadow/HB/zk09_091','*.vtc')
%
% [about]
% This function returns the cell strucure of
% name of files specified by 'prefix'
%
% [input]
% target_fullpath_dir : Target directory that contains files
%                       you want
%                       Target directory should be specified as full-
%                       path format, e.g. 'C:/home/ban/scripts/'
% extension  : extension of files you want to get
%              e.g. "*.vtc"
%              multiple files, e.g. 'CD'
%
% [output]
% filenames  : cell structure of file names
%
% [dependency]
% 1. wildcardsearch.m
% enable reg-exp search of files
%
%
% Created    : "2010-06-09 11:32:50 ban"
% Last Update: "2013-11-22 23:32:19 ban (ban.hiroshi@gmail.com)"

% check the input variables
if nargin < 2, help(mfilename()); return; end
if nargin < 3, prefix=''; end

% check whether the target directory exists
if ~exist(target_fullpath_dir,'dir')
  error('can not find target directory: %s',target_fullpath_dir);
end

% extension check
if ~strcmp(extension,'*')
  if ~strcmp(extension(1),'*'), extension=['*',extension]; end
  %if ~strcmp(extension(2),'.'), extension=['*.',extension(2:end)]; end
end

% get file names
filenames=wildcardsearch(target_fullpath_dir,[prefix,extension]);

% error check
if isempty(filenames)
  error('can not find any ''%s%s'' file in %s',prefix,extension,target_fullpath_dir);
end

return
