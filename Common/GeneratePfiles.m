function GeneratePfiles(tgt_dir,rm_str)

% Generates p-file version of MATLAB directory structure.
% function GeneratePfiles(tgt_dir,rm_str)
%
% This function copy the target MATLAB directory as (target_dir_name)_p,
% reads *.m files in it, and convertes them to p-files
%
% [input]
% tgt_dir : target directory name specified in a relative path format.
% rm_str  : file prefix to be excluded from the conversions,
%           cell structure, e.g. rm_str={'iFit'};
%           empty by default.
%
% [output]
% no output variable
% the backup file is stored as ~/backups/(yymmdd)/(tgt_dir)_p
%
%
% Created    : "2012-05-14 11:03:24 ban"
% Last Update: "2013-12-13 17:39:35 ban"

% check input variables
if nargin<1 || isempty(tgt_dir), help(mfilename()); return; end
if nargin<2 || isempty(rm_str), rm_str=[]; end

if ~exist(fullfile(pwd,tgt_dir),'dir')
  error('target directory not found. check input variable.');
end

% generate target directory/file to the backup directory
pcode_dir=fullfile(pwd,[tgt_dir,'_p']);
if ~exist(pcode_dir,'dir'), mkdir(pcode_dir); end

% copy the target
fprintf('copying the target to the p-code directory...');
iswin=0; tstr=mexext();
if strcmp(tstr(end-2:end),'w32') || strcmp(tstr(end-2:end),'w64'), iswin=1; end
if iswin
  dos(sprintf('xcopy /I /S /Q %s %s',strrep(fullfile(pwd,tgt_dir),' ','\ '),strrep(pcode_dir,' ','\ ')));
else
  eval(sprintf('!cp -rf %s %s',fullfile(pwd,tgt_dir),pcode_dir));
  %copyfile(fullfile(pwd,tgt_dir),pcode_dir,'f');
end
disp('done.');

% convert *.m to *.p
mfs=wildcardsearch(pcode_dir,'*.m');
cdir=pwd;
for ff=1:1:length(mfs)

  % skip files that matches one of the strings in rm_str
  if sum(strfind(mfs{ff},rm_str))~=0, continue; end

  % display message
  [mpath,mfname,mext]=fileparts(mfs{ff});
  message=sprintf('target: %s%s --> %s.p',mfname,mext,mfname);
  disp(message);

  % get a line of function description and endline character(s)
  fid=fopen(mfs{ff},'r');
  tmpline=fgets(fid);
  if strcmp(tmpline(end-1:end),[char(13),char(10)])
    returnchar=[char(13),char(10)];
  elseif strcmp(tmpline(end),char(10))
    returnchar=char(10);
  else
    returnchar=char(13);
  end
  if ~isempty(strfind(tmpline,'function')) && isempty(strfind(tmpline,'% function'))
    funcline=tmpline;
  else
    while 1
      tmpline=fgets(fid);
      if ~isempty(strfind(tmpline,'function')) && isempty(strfind(tmpline,'% function'))
        funcline=tmpline;
        break;
      elseif tmpline==-1 % EOF
        funcline='';
        break;
      end
    end
  end
  fclose(fid);

  % generate *.p file
  cd(mpath);
  hstr=strread(help(mfs{ff}),'%s','delimiter',returnchar);
  pcode(mfs{ff});
  delete(mfs{ff});

  % generate *.m file for help
  fid=fopen(mfs{ff},'w');
  if ~isempty(funcline)
    fprintf(fid,[funcline,returnchar]);
  else
    fprintf(fid,[mfname,returnchar]);
  end
  for ii=1:1:length(hstr)
    if size(returnchar,2)==2
      fprintf(fid,'%s%c%c',['% ',hstr{ii}],returnchar(1),returnchar(2));
    else
      fprintf(fid,'%s%c',['% ',hstr{ii}],returnchar);
    end
  end
  fclose(fid);
  cd(cdir);

end

return
