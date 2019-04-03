function [filenames,dirnames]=ReplaceFilename(target_dir,extension,prefix_tgt,prefix_to_be_replaced,prefix_replace,prefix_exclude)

% Replaces a target word in the file name to the specified one.
% function filenames=ReplaceFilename(target_dir,extension,:prefix_tgt,:prefix_to_be_replaced,:prefix_replace,:prefix_exclude)
% (: is optional)
%
% [example]
% >> ReplaceFilename('/HB/zk09_091','*.vtc','','ZK','zk')
%
% [about]
% This function replaces a specified word in file name
% like, hb_test_partial.vtc ---> HB_test_partial.vtc
% Directory name is also acceptable
%
% !!! NOTICE !!!
% If prefix_replace is not specified, only original file names
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
% prefix_tgt : (optional) file prefix to specify target, e.g. 'HB', empty by default
% prefix_to_be_replaced: (optional) string to be replaced, e.g. 'ZK', empty by default (NO replacement)
% prefix_replace: (optional) string to replace prefix_to_be_replaced, e.g. 'zk', empty by default (NO replacement)
% prefix_exclude: (optional) string to specify files to be excluded from the processing
%                 e.g. 'test'. empty by default.
%
% [output]
% filenames  : cell structure of file names after replacing
%              prefix_to_be_replaced by prefix_replace
% dirnames   : cell structure of directory names after replacing
%              prefix_to_be_replaced by prefix_replace
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
% Created    : "2010-08-19 16:02:21 banh"
% Last Update: "2019-03-08 10:35:07 ban"

% check the input variables
if nargin<2, help(mfilename()); return; end
if nargin<3 || isempty(prefix_tgt), prefix_tgt=''; end
if nargin<4 || isempty(prefix_to_be_replaced), prefix_to_be_replaced=''; end
if nargin<5 || isempty(prefix_replace), prefix_replace=''; end
if nargin<6 || isempty(prefix_exclude), prefix_exclude=''; end

if isempty(prefix_to_be_replaced)
  error('prefix_to_be_replaced is empty. check input variable.');
end

% extension check
if ~strcmp(extension,'*')
  if ~strcmp(extension(1),'*'), extension=['*',extension]; end
  %if ~strcmp(extension(2),'.'), extension=['*.',extension(2:end)]; end
end

% get target files and directories
tmpfiles=GetFiles(fullfile(pwd,target_dir),extension,prefix_tgt);

% exclude files whose names include prefix_exclude
file_counter=0; tgtfiles='';
for ii=1:1:length(tmpfiles)
  [dirpath,fname]=fileparts(tmpfiles{ii});
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
tmpfiles=tgtfiles;
clear file_counter tgtfiles;

% display message
fprintf('Target : %s\n',fullfile(pwd,target_dir));

% initialize variables
filenames=''; dirnames='';
fileidx=0; diridx=0;
tgtfiles=''; tgtdirs='';
tgtfilelength=NaN; tgtdirlength=NaN;

% separate the target to directory & files
for ii=1:1:length(tmpfiles)
  if strcmp(tmpfiles{ii}(end),filesep())
    diridx=diridx+1;
    tgtdirs{diridx}=tmpfiles{ii};
    tgtdirlength(diridx)=numel(find(tgtdirs{diridx}==filesep()));
  else
    fileidx=fileidx+1;
    tgtfiles{fileidx}=tmpfiles{ii};
    tgtfilelength(fileidx)=numel(find(tgtfiles{fileidx}==filesep()));
  end
end

% sort dir & file structure by length of directory tree
if ~isnan(tgtdirlength)
  [dummy,idx]=sort(tgtdirlength,'descend'); %#ok
  tmp=cell(length(tgtdirs),1);
  for ii=1:1:length(tgtdirs), tmp{ii}=tgtdirs{idx(ii)}; end
  tgtdirs=tmp; clear tmp;
end

if ~isnan(tgtfilelength)
  [dummy,idx]=sort(tgtfilelength,'descend'); %#ok
  tmp=cell(length(tgtfiles),1);
  for ii=1:1:length(tgtfiles), tmp{ii}=tgtfiles{idx(ii)}; end
  tgtfiles=tmp; clear tmp;
end

% return the original file names, if prefix_replace is not specified
if strcmp(prefix_replace,'')
  filenames=tgtfiles;
  dirnames=tgtdirs;
  return
end

% replace file names
if ~isnan(tgtfilelength)
  filenames=cell(length(tgtfiles),1);
  for ii=1:1:length(tgtfiles)

    [path,fname,ext]=fileparts(tgtfiles{ii});
    filenames{ii}=[path,filesep(),strrep(fname,prefix_to_be_replaced,prefix_replace),ext];

    % rename file
    if ~strcmp(tgtfiles{ii},filenames{ii})

      fprintf('processing : %s%s --> %s%s\n',fname,ext,strrep(fname,prefix_to_be_replaced,prefix_replace),ext);

      % matlab movefile function is quite slow in some situations
      % since it copies the file first
      %movefile(tgtfiles{ii},[tgtfiles{ii},'_tmp'],'f');
      %movefile([tgtfiles{ii},'_tmp'],filenames{ii},'f');

      % so use the external dos-command
      [dummy,fname,ext]=fileparts(filenames{ii}); %#ok
      eval(sprintf('dos(''rename "%s" "%s"'');',tgtfiles{ii},[fname,ext]));
    end

  end
end

% replace dir names
if ~isnan(tgtdirlength)
  dirnames=cell(length(tgtdirs),1);
  for ii=1:1:length(tgtdirs)

    idx=find(tgtdirs{ii}==filesep(),2,'last'); idx=idx(1);
    dname=strrep(tgtdirs{ii}(idx:end),filesep(),'');
    dirnames{ii}=[tgtdirs{ii}(1:idx),strrep(dname,prefix_to_be_replaced,prefix_replace)];

    % rename directory
    if ~strcmp(tgtdirs{ii},dirnames{ii})

      fprintf('processing : %s --> %s\n',dname,strrep(dname,prefix_to_be_replaced,prefix_replace));

      % matlab movefile fucntion is quite slow in some situations
      % since it copies the file first
      %movefile(tgtdirs{ii},[tgtdirs{ii}(1:end-1),'_tmp'],'f');
      %movefile([tgtdirs{ii}(1:end-1),'_tmp'],dirnames{ii},'f');

      % so use the external dos-command
      tpath=fileparts(dirnames{ii});
      dname=strrep(dirnames{ii},[tpath,filesep()],'');
      eval(sprintf('dos(''rename "%s" "%s"'');',tgtdirs{ii},dname));
    end

  end
end

return
