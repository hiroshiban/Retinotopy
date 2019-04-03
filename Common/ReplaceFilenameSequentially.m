function [filenames,originalnames]=ReplaceFilenameSequentially(target_dir,sequence_fmt,extension,prefix_inc_tgt,prefix_exc_tgt)

% Replaces target files following a specified sequential file name format.
% function [filenames,originalnames]=ReplaceFilenameSequentially(target_dir,:sequence_fmt,:extension,:prefix_inc_tgt,:prefix_exc_tgt)
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
% [note on how to set the 'prefix_*' variable]
% prefix_* can be set flexibly as below.
% 1. a string: setting an including prefix (string) alone
%    e.g. prefix_*='_TDTS6.0';
%         --> processes files whose names contain '_TDTS6.0'
% 2. a {1 x N} cell string: setting including prefix (string) arrays
%    e.g. prefix_*={'_TDTS6.0','_TSS5.0mm'};
%         --> processes files whose names contain '_TDTS6.0s' or '_TSS5.0mm'.
% 3. a {2 x N} cell string: setting including/excluding prefix (string) arrays
%    e.g. prefix_*={{'_TDTS6.0s','_TSS5.0mm'};{'THP'}};
%         --> processes files whose names contain '_TDTS6.0s'
%             or '_TSS5.0mm' but do not contain 'THP'.
%         prefix_*={'';{'_TDTS6.0s'}};
%         --> processes files whose names do not contain '_TDTS6.0s'.
%         prefix_*={'_TSS5.0mm';''};
%         --> processes files whose names contain '_TSS5.0mm'.
%
% [dependency]
% 1. wildcardsearch.m
% enable reg-exp search of files
%
%
% Created    : "2013-11-14 14:14:05 ban"
% Last Update: "2019-03-08 10:35:11 ban"

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

% get target files and directories
tmpfiles=GetFiles(fullfile(pwd,target_dir),extension,prefix_inc_tgt);

% exclude files whose name include prefix_exc_tgt
file_counter=0; tgtfiles='';
for ii=1:1:length(tmpfiles)
  [dummy,fname]=fileparts(tmpfiles{ii});
  if ~isempty(prefix_exclude)
    if strfind(fname,prefix_exclude), continue; end %#ok % the target is file
    if isempty(fname) % the target is directory
      [dummy,dirname]=fileparts(dirpath); %#ok
      if strfind(dirname,prefix_exclude), continue; end %#ok
    end
  end
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
fprintf('Target : %s\n',fullfile(pwd,target_dir));

% processing
originalnames=cell(length(tgtfiles),1);
filenames=cell(length(tgtfiles),1);
for ii=1:1:length(tgtfiles)

  [path,originalnames{ii},ext]=fileparts(tgtfiles{ii});
  filenames{ii}=sprintf(sequence_fmt,ii);

  fprintf('processing : %s%s --> %s%s\n',originalnames{ii},ext,filenames{ii},ext);

  % matlab movefile function is quite slow in some situations
  % since it copies the file first
  %movefile(tgtfiles{ii},[tgtfiles{ii},'_tmp'],'f');
  %movefile([tgtfiles{ii},'_tmp'],filenames{ii},'f');

  % so use the external dos-command
  eval(sprintf('dos(''rename "%s" "%s"'');',tgtfiles{ii},[filenames{ii},ext]));

end

return
