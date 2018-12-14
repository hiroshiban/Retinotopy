function [filenames,originalnames]=ReplaceFilenameSequentially(target_dir,sequence_fmt,extension,prefix_inc_tgt,prefix_exc_tgt)

% Replaces target files following a specified sequential file name format.
% function [filenames,originalnames]=ReplaceFilenameSequentially(target_dir,:sequence_fmt,:extension,...
%                                                                :prefix_inc_tgt,:prefix_exc_tgt)
% (: is optional)
%
% [example]
% >> ReplaceFilenameSequentially('/HB/zk09_091','file_%02d','*.vtc','','ZK','');
%
% [about]
% This function renames all the taget files with sequential names.
% like, hb_test_run_01.vtc, HB_test_run_02.vtc ---> run_01.vtc, run_02.vtc
%
% [input]
% target_dir     : Target directory that contains VTC files
%                  e.g. '/HB/zk09_091'
%                  Target directory should be specified as such
%                  the current directory where this function is
%                  called is the origin.
% sequence_fmt   : (optional) file name format. e.g. 'run_%02d'. %~d is required for sequential file naming.
%                  'file_%03d' by default.
% extension      : (optional) extension of files you want to get, e.g. '*.vtc'. '*' by default.
% prefix_inc_tgt : (optional) file prefix to specify target files, e.g. 'HB'. empty by default
% prefix_exc_tgt : (optional) file prefix to exclude from the processing, e.g. '_test'. empty by default.
%
% [output]
% filenames      : cell structure of file names after replacing
% originalnames  : cell structure of the original file names
%
% [dependency]
% 1. wildcardsearch.m
% enable reg-exp search of files
%
%
% Created    : "2013-11-14 14:14:05 ban"
% Last Update: "2013-11-22 23:55:50 ban (ban.hiroshi@gmail.com)"

% check the input variables
if nargin<1 || isempty(target_dir), help(mfilename()); return; end
if nargin<2 || isempty(sequence_fmt), sequence_fmt='file_%03d'; end
if nargin<3 || isempty(extension), extension='*'; end
if nargin<4 || isempty(prefix_inc_tgt), prefix_inc_tgt=''; end
if nargin<5 || isempty(prefix_exc_tgt), prefix_exc_tgt=''; end

% extension check
if ~strcmp(extension,'*')
  if ~strcmp(extension(1),'*'), extension=['*',extension]; end
  %if ~strcmp(extension(2),'.'), extension=['*.',extension(2:end)]; end
end

% get vtc files from the directories in the VTC_dir
tmpfiles=GetFiles(fullfile(pwd,target_dir),extension,prefix_inc_tgt);

% exclude files whose name include prefix_exc_tgt
file_counter=0; tgtfiles='';
for ii=1:1:length(tmpfiles)
  [dummy,fname]=fileparts(tmpfiles{ii});
  if ~isempty(prefix_exc_tgt) & strfind(fname,prefix_exc_tgt), continue; end %#ok
  file_counter=file_counter+1;
  tgtfiles{file_counter}=tmpfiles{ii};
end
clear file_counter;

if isempty(tgtfiles)
  fprintf('can not find any target file in tgt_dir. finalizing...');
  filenames='';
  return
end

% display message
message=sprintf('Target : %s',fullfile(pwd,target_dir));
disp(message);

% processing
originalnames=cell(length(tgtfiles),1);
filenames=cell(length(tgtfiles),1);
for ii=1:1:length(tgtfiles)

  [path,originalnames{ii},ext]=fileparts(tgtfiles{ii});
  filenames{ii}=sprintf(sequence_fmt,ii);

  message=sprintf('processing : %s%s --> %s%s',originalnames{ii},ext,filenames{ii},ext);
  disp(message);

  % matlab movefile function is quite slow in some situations
  % since it copies the file first
  %movefile(tgtfiles{ii},[tgtfiles{ii},'_tmp'],'f');
  %movefile([tgtfiles{ii},'_tmp'],filenames{ii},'f');

  % so use the external dos-command
  eval(sprintf('dos(''rename "%s" "%s"'');',tgtfiles{ii},[filenames{ii},ext]));

end

return
