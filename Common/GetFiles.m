function filenames=GetFiles(target_dir,extension,prefix,ignore_error_flg,ignore_wildcard_flg)

% Searches and gets file names with a relative/full path format under the target directory (recursive and wildcard search are available).
% function filenames=GetFils(target_dir,extension,:prefix,:ignore_error_flg,:ignore_wildcard_flg)
% (: is optional)
%
% [example]
% >> vtcfiles=GetFiles('c:/fmri_analysis/CastingShadow/HB/zk09_091','*.vtc') % to get all *.vtc files
% >> voifiles=GetFiles(pwd,'*\Sub-Gyral.voi','',1,1); % with putting a file separator, '\', you can only get a file whose name is exactly 'Sub-Gyral.voi'.
%
% [about]
% This function returns a cell strucure of a series of file names searched and
% found by the 'prefix' variable under the 'target_dir' directory. You can also
% omit specific files which contains some prefix to be ignored. For details,
% please see the descriptions of the 'prefix' variable below.
%
% [input]
% target_dir : Target directory that contains files you want to get
%              Target directory should be specified as a full- or relative-
%              path format. e.g. 'C:/home/ban/scripts/' or '../scripts'
%              If this variable is set in a full- (relative-) path format,
%              the output varialbe, filenames, is also returned in a
%              full- (relative-) path format.
% extension  : Extension of files you want to get. e.g. extension='*.vtc'
%              If you want to get directory or no-extension file, please
%              set extension='';
%              You can also set the extension variable with some prefix like
%              extension='*_avg_LH.smp';
% prefix     : (optional) a string or a cell string to specify the target from
%              multiple files, e.g. prefix='CD'; or prefix={'CD','HB'};
%              empty by default.
%
%              <HOW TO SET PREFIX VARIABLE>
%              prefix can be set flexibly as below.
%              1. a string             : setting an including prefix (string) alone
%                 e.g. extension='.vtc'; prefix='_TDTS6.0';
%                         --> returns all *.vtc files whose names contain '_TDTS6.0'
%              2. a {1 x N} cell string: setting including prefix (string) arrays
%                 e.g. extension='.vtc'; prefix={'_TDTS6.0','_TSS5.0mm'};
%                         --> returns all *.vtc files whose names contain
%                             '_TDTS6.0s' or '_TSS5.0mm'.
%              3. a {2 x N} cell string: setting including/excluding prefix (string) arrays
%                 e.g. extension='.vtc'; prefix={{'_TDTS6.0s','_TSS5.0mm'};{'THP'}};
%                         --> returns all *.vtc files whose names contain '_TDTS6.0s'
%                             or '_TSS5.0mm' and do not contain 'THP'.
%                      extension='.vtc'; prefix={'';{'_TDTS6.0s'}};
%                         --> returns all *.vtc files whose names do not contain '_TDTS6.0s'.
%                      extension='.vtc'; prefix={'_TSS5.0mm';''};
%                         --> returns all *.vtc files whose names contain '_TSS5.0mm'.
% ignore_error_flg : (optional) whether ignoring displaying error message when the 'filenames'
%              output is an empry cell. if 1, the checking procedure is ignored. 1 by default.
% ignore_wildcard_flg : (optional) whether ignoring adding '*' at the head of 'extension' and
%              'prefix' string(s). if 1, the extension and prefix will be processed 'as they are'
%              without adding a wildcard regular expression, '*'. 0 by default.
%              More specifically, when this value is 0, 'extension' and 'prefix' are internally
%              converted as extension=['*',extension] and prefix=['*',prefix] (a matrix example,
%              cell input is also processed in the same way).
%
% [output]
% filenames  : a cell structure that contains a series of file names you want
%
% [dependency]
% wildcardsearch.m
% enables reg-exp search of files
%
%
% Created    : "2010-06-09 11:32:50 ban"
% Last Update: "2018-11-27 16:44:42 ban"

% check the input variables
if nargin<2, help(mfilename()); return; end
if nargin<3 || isempty(prefix), prefix=''; end
if nargin<4 || isempty(ignore_error_flg), ignore_error_flg=1; end
if nargin<5 || isempty(ignore_wildcard_flg), ignore_wildcard_flg=0; end

% check whether the target directory exists
if ~exist(target_dir,'dir')
  error('can not find target directory: %s',target_dir);
end

% organize the extension variable
if ~isempty(extension)
  if ~strcmp(extension,'*')
    if ~strcmp(extension(1),'*') && ~ignore_wildcard_flg, extension=['*',extension]; end
    %if ~strcmp(extension(2),'.') && ~ignore_wildcard_flg, extension=['*.',extension(2:end)]; end
  end
end

% organize search and non-search strings
if ~iscell(prefix)
  % organize search string array that is to be searched in wildcardsearch,
  % by adding '*' and "extension" at the head and tail of each string
  if ~isempty(prefix) && ~strcmp(prefix(1),'*') && ~ignore_wildcard_flg, prefix=['*',prefix]; end
  searchstr=[prefix,extension];
  %searchstr=strrep(searchstr,'**','*');

  % organize non-search string array that is to be omitted from searching in wildcardsearch
  nonsearchstr=[];
else
  if size(prefix,1)==1
    % organize search string array that is to be searched in wildcardsearch,
    % by adding '*' and "extension" at the head and tail of each string
    if ~isempty(prefix{1}) && ~strcmp(prefix{1}(1),'*') && ~ignore_wildcard_flg, prefix{1}=['*',prefix{1}]; end
    searchstr=[prefix{1},extension];
    for ii=2:1:length(prefix)
      if ~isempty(prefix{ii}) && ~strcmp(prefix{ii}(1),'*') && ~ignore_wildcard_flg, prefix{ii}=['*',prefix{ii}]; end
      searchstr=[searchstr,';',[prefix{ii},extension]]; %#ok
    end
    %searchstr=strrep(searchstr,'**','*');

    % organize non-search string array that is to be omitted from searching in wildcardsearch
    nonsearchstr=[];
  elseif size(prefix,1)==2
    % separate including and excluding file prefix
    incl_prefix=prefix{1}; if ~iscell(incl_prefix), incl_prefix={incl_prefix}; end

    % organize search string array that is to be searched in wildcardsearch,
    % by adding '*' and "extension" at the head and tail of each string
    if ~isempty(incl_prefix{1}) && ~strcmp(incl_prefix{1}(1),'*') && ~ignore_wildcard_flg, incl_prefix{1}=['*',incl_prefix{1}]; end
    searchstr=[incl_prefix{1},extension];
    for ii=2:1:length(incl_prefix)
      if ~isempty(incl_prefix{ii}) && ~strcmp(incl_prefix{ii}(1),'*') && ~ignore_wildcard_flg, incl_prefix{ii}=['*',incl_prefix{ii}]; end
      searchstr=[searchstr,';',[incl_prefix{ii},extension]]; %#ok
    end
    %searchstr=strrep(searchstr,'**','*');

    % organize non-search string array that is to be omitted from searching in wildcardsearch
    nonsearchstr=prefix{2}; if ~iscell(nonsearchstr), nonsearchstr={nonsearchstr}; end;
    %for ii=1:1:length(nonsearchstr), nonsearchstr=strrep(nonsearchstr,'**','*'); end
  else
    error('prefix should be a string, cell{N}, or cell{2,N}. check the input variable.');
  end
end

% get file names
%if strcmp(relativepath(target_dir),'.\') || strcmp(relativepath(target_dir),'.'), target_dir='.'; end
%filenames=wildcardsearch(target_dir,[prefix,extension]);
if ~ignore_wildcard_flg
  filenames=wildcardsearch(target_dir,searchstr);
else
  filenames=wildcardsearch(target_dir,searchstr,false,true);
end

% omit the files that contain a string defined in nonsearchstr
if ~isempty(nonsearchstr)
  fileidx=true(length(filenames),1);
  for ii=1:1:length(filenames)
    for jj=1:1:length(nonsearchstr)
      if ~isempty(strfind(filenames{ii},nonsearchstr{jj}))
        fileidx(ii)=false;
        continue
      end
    end
  end
  filenames=filenames(fileidx);
end

% check errors
if ~ignore_error_flg
  if isempty(filenames)
    if ~iscell(prefix)
      error('can not find any ''%s%s'' file in %s',prefix,extension,target_dir);
    else
      error('can not find any target file in %s',target_dir);
    end
  end
end

return
