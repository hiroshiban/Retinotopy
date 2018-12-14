function [filenames,dirnames]=ReplaceFilename(target_dir,extension,prefix_tgt,...
                                   prefix_to_be_replaced,prefix_replace,prefix_exclude)

% Replaces a target word in the file name to the specified one.
% function filenames=ReplaceFilename(target_dir,extension,prefix_tgt,...
%                                    prefix_to_be_replaced,prefix_replace,prefix_exclude)
%
% [example]
% >> ReplaceFilename('/HB/zk09_091','*.vtc','','ZK','zk')
%
% [about]
% This function replaces a specified word in file name
% like, hb_test_partial.vtc ---> HB_test_partial.vtc
% Directory name is also acceptable
%
% !!!NOTICE!!!
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
% prefix_tgt : (optional) file prefix to specify target, e.g. 'HB'
% prefix_to_be_replaced: (optional) string to be replaced, e.g. 'ZK'
% prefix_replace: (optional) string to replace prefix_to_be_replaced, e.g. 'zk'
% prefix_exclude: (optional) string to specify files to be excluded from the processing
%                 e.g. 'test'. empty by default.
%
% [output]
% filenames  : cell structure of file names after replacing
%              prefix_to_be_replaced by prefix_replace
% dirnames   : cell structure of directory names after replacing
%              prefix_to_be_replaced by prefix_replace
%
% [dependency]
% 1. wildcardsearch.m
% enable reg-exp search of files
%
%
% Created    : "2010-08-19 16:02:21 banh"
% Last Update: "2013-11-22 23:55:54 ban (ban.hiroshi@gmail.com)"

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

% get vtc files from the directories in the VTC_dir
tmpfiles=GetFiles(fullfile(pwd,target_dir),extension,prefix_tgt);

% exclude files whose name include prefix_exclude
file_counter=0; tgtfiles='';
for ii=1:1:length(tmpfiles)
  [dummy,fname]=fileparts(tmpfiles{ii});
  if ~isempty(prefix_exclude) & strfind(fname,prefix_exclude), continue; end %#ok
  file_counter=file_counter+1;
  tgtfiles{file_counter}=tmpfiles{ii};
end
tmpfiles=tgtfiles;
clear file_counter tgtfiles;

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

% return the original file names, if prefix_replace is not specified
if strcmp(prefix_replace,'')
  filenames=tgtfiles;
  dirnames=tgtdirs;
  return;
end

% replace file names
if ~isnan(tgtfilelength)
  filenames=cell(length(tgtfiles),1);
  for ii=1:1:length(tgtfiles)

    [path,fname,ext]=fileparts(tgtfiles{ii});
    filenames{ii}=[path,filesep(),strrep(fname,prefix_to_be_replaced,prefix_replace),ext];

    % rename file
    if ~strcmp(tgtfiles{ii},filenames{ii})

      message=sprintf('processing : %s%s --> %s%s',fname,ext,strrep(fname,prefix_to_be_replaced,prefix_replace),ext);
      disp(message);

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

% replace dir names
if ~isnan(tgtdirlength)
  dirnames=cell(length(tgtdirs),1);
  for ii=1:1:length(tgtdirs)

    idx=find(tgtdirs{ii}==filesep(),2,'last'); idx=idx(1);
    dname=strrep(tgtdirs{ii}(idx:end),filesep(),'');
    dirnames{ii}=[tgtdirs{ii}(1:idx),strrep(dname,prefix_to_be_replaced,prefix_replace)];

    % rename directory
    if ~strcmp(tgtdirs{ii},dirnames{ii})

      message=sprintf('processing : %s --> %s',dname,strrep(dname,prefix_to_be_replaced,prefix_replace));
      disp(message);

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
