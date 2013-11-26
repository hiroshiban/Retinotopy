function [filenames,dirnames]=AddPrefix2Filename(target_dir,extension,prefix_tgt,prefix_head,prefix_tail)

% Adds user-specified prefix to file names.
% function filenames=AddPrefix2Filename(target_dir,extension,prefix_tgt,prefix_head,prefix_tail)
%
% [example]
% >> AddPrefix2Filename('/HB/zk09_091','*.vtc','zk10_','HB_','_partial')
%
% [about]
% This function adds prefix name to the specified files
% At the head of a file name, prefix_head is added.
% At the tail of a file name, prefix_tail is added.
% like, test.vtc ---> HB_test_partial.vtc
% Directory name is also acceptable
%
% !!!NOTICE!!!
% If prefix_head and/or prefix_tail are not specified, only original file names
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
% prefix_head: (optional) string to be added at the head of file, e.g. 'HB_'
% prefix_tail: (optional) string to be added at the tail of file, e.g. '_partial'
%
% [output]
% filenames  : cell structure of file names with prefix_head & prefix_tail
% dirnames  : cell structure of directory names with prefix_head & prefix_tail
%
% [dependency]
% 1. wildcardsearch.m
% enable reg-exp search of files
%
%
% Created    : "2010-06-09 11:32:50 ban"
% Last Update: "2013-11-22 18:30:43 ban (ban.hiroshi@gmail.com)"

% check the input variables
if nargin < 2, help(mfilename()); return; end
if nargin < 4, prefix_head=''; end
if nargin < 5, prefix_tail=''; end

% extension check
if ~strcmp(extension,'*')
  if ~strcmp(extension(1),'*'), extension=['*',extension]; end
  %if ~strcmp(extension(2),'.'), extension=['*.',extension(2:end)]; end
end

% get vtc files from the directories in the VTC_dir
tmpfiles=GetFiles(fullfile(pwd,target_dir),extension,prefix_tgt);

% display message
message=sprintf('Target : %s',fullfile(pwd,target_dir));
disp(message);

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
  [dummy,idx]=sort(tgtdirlength,'descend');
  tmp=cell(length(tgtdirs),1);
  for ii=1:1:length(tgtdirs), tmp{ii}=tgtdirs{idx(ii)}; end
  tgtdirs=tmp; clear tmp;
end

if ~isnan(tgtfilelength)
  [dummy,idx]=sort(tgtfilelength,'descend');
  tmp=cell(length(tgtfiles),1);
  for ii=1:1:length(tgtfiles), tmp{ii}=tgtfiles{idx(ii)}; end
  tgtfiles=tmp; clear tmp;
end

% return the original file names, if prefix_{head|tail} are not specified
if strcmp(prefix_head,'') && strcmp(prefix_tail,'')
  filenames=tgtfiles;
  dirnames=tgtdirs;
  return;
end

% add prefix to the files.
if ~isnan(tgtfilelength)
  filenames=cell(length(tgtfiles),1);
  for ii=1:1:length(tgtfiles)

    [path,fname,ext]=fileparts(tgtfiles{ii});
    filenames{ii}=[path,filesep(),prefix_head,fname,prefix_tail,ext];

    message=sprintf('processing : %s%s --> %s%s',fname,ext,[prefix_head,fname,prefix_tail],ext);
    disp(message);

    % add prefix
    if ~strcmp(tgtfiles{ii},filenames{ii})
      % matlab movefile function is quite slow in some situations
      % since it copies the file first
      %movefile(tgtfiles{ii},[tgtfiles{ii},'_tmp'],'f');
      %movefile([tgtfiles{ii},'_tmp'],filenames{ii},'f');

      % so use the external dos-command
      [dummy,fname,ext]=fileparts(filenames{ii});
      eval(sprintf('dos(''rename "%s" "%s"'');',tgtfiles{ii},[fname,ext]));
    end

  end
end

% add prefix to the directories
if ~isnan(tgtdirlength)
  dirnames=cell(length(tgtdirs),1);
  for ii=1:1:length(tgtdirs)

    idx=find(tgtdirs{ii}==filesep(),2,'last'); idx=idx(1);
    dname=strrep(tgtdirs{ii}(idx:end),filesep(),'');
    dirnames{ii}=[tgtdirs{ii}(1:idx),prefix_head,dname,prefix_tail];

    message=sprintf('processing : %s --> %s%s%s',dname,prefix_head,dname,prefix_tail);
    disp(message);

    % add prefix
    if ~strcmp(tgtdirs{ii},dirnames{ii})
      % matlab movefile function is quite slow in some situations
      % since it copies the file first
      %movefile(tgtdirs{ii},[tgtdirs{ii}(1:end-1),'_tmp',filesep()],'f');
      %movefile([tgtdirs{ii}(1:end-1),'_tmp',filesep()],dirnames{ii},'f');

      % so use the external dos-command
      tpath=fileparts(dirnames{ii});
      dname=strrep(dirnames{ii},[tpath,filesep()],'');
      eval(sprintf('dos(''rename "%s" "%s"'');',tgtdirs{ii},dname));
    end

  end
end

return
