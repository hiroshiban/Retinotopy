function filenames=RemovePrefixFromFilename(target_dir,extension,prefix_tgt,prefix_remove)

% Removes a specific prefix from the target file names.
% function filenames=RemovePrefixFromFilename(target_dir,extension,prefix_tgt,prefix_remove)
%
% [example]
% >> RemovePrefixFromFilename('/HB/zk09_091','*.vtc','HB_')
%
% [about]
% This function searches 'prefix_remove' string and removes it from the specified files
% If no prefix_remove is found, do nothing.
% like, HB_test.vtc ---> test_partial.vtc
%
% !!!NOTICE!!!
% If prefix_remove is not specified, only original file names
% will be returned.
%
% [input]
% target_dir : Target directory that contains VTC files
%              e.g. '/HB/zk09_091'
%              Target directory should be specified as such
%              the current directory where this function is
%              called is the origin.
% extension  : extension of files you want to get
%              e.g. '*.vtc'
% prefix_tgt : (optional) string to determine the target 
%              from multiple files, e.g. 'HB'
% prefix_remove: (optional) string to be added at the head of file, e.g. 'HB_'
%
% [output]
% filenames  : cell structure of file names with being removed prefix_remove
%
% [dependency]
% 1. wildcardsearch.m
% enable reg-exp search of files
%
%
% Created    : "2010-06-09 11:32:50 ban"
% Last Update: "2013-11-22 23:56:17 ban (ban.hiroshi@gmail.com)"

% check the input variables
if nargin < 2, help RemovePrefixFromFilename; return; end

% extension check
if ~strcmp(extension(1),'*'), extension=['*',extension]; end

% get vtc files from the directories in the VTC_dir
tgtfiles=GetFiles(fullfile(pwd,target_dir),extension,prefix_tgt);

if strcmp(prefix_remove,'')
  filenames=tgtfiles;
  return;
end

% remove prefix from the files.
filenames=cell(length(tgtfiles),1);
for ii=1:1:length(tgtfiles)

  [path,fname,ext]=fileparts(tgtfiles{ii});
  fname=strrep(fname,prefix_remove,'');
  filenames{ii}=[path,filesep(),fname,ext];
  
  % skip if the file names before/after removing processing are the same
  if strcmp(tgtfiles{ii},filenames{ii}), continue; end
  
  % rename files
  movefile(tgtfiles{ii},filenames{ii},'f');

  % % copy files
  % copyfile(tgtfiles{ii},filenames{ii});
  
end
