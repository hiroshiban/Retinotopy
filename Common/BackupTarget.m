function BackupTarget(tgt,rm_str)

% function BackupTarget(tgt,rm_str)
%
% This function backups the target directory in ~/backups/(yymmdd)
% after removing files specified in rm_str (wild-card specifications
% are acceptable, cell structure).
%
% [input]
% tgt    : target directory/file name specified in a relative path format.
% rm_str : directory/file prefix to be excluded from the backups,
%          cell structure, e.g. rm_str={'*.ai','*.docx','admesy_usbtmc.dll','Calibrator.dll'};
%          empty by default.
%
% [output]
% no output variable
% the backup file is stored as ~/backups/(yymmdd)/(tgt_dir)
%
%
% Created    : "2012-05-14 13:21:36 ban"
% Last Update: "2013-12-13 16:41:07 ban"

% check input variables
if nargin<1 || isempty(tgt), help(mfilename()); return; end
if nargin<2 || isempty(rm_str), rm_str=[]; end

if ~exist(fullfile(pwd,tgt),'dir') || ~exist(fullfile(pwd,tgt),'file')
  error('target directory/file not found. check input variable.');
end

% generate target directory/file to the backup directory
save_dir=fullfile(pwd,'backups',sprintf('%s',datestr(now,'yymmdd')));
if ~exist(save_dir,'dir'), mkdir(save_dir); end

% copy the target
fprintf('copying the target to the backup directory...');
[path,tgtname,tgtext]=fileparts(tgt);

iswin=0; tstr=mexext();
if strcmp(tstr(end-2:end),'w32') || strcmp(tstr(end-2:end),'w64'), iswin=1; end
if iswin
  dos(sprintf('xcopy /I /S /Q %s %s',strrep(fullfile(pwd,tgt),' ','\ '),strrep(fullfile(save_dir,[tgtname,tgtext]),' ','\ ')));
else
  eval(sprintf('!cp -rf %s %s',fullfile(pwd,tgt),fullfile(save_dir,[tgtname,tgtext])));
  %copyfile(fullfile(pwd,tgt),fullfile(save_dir,[tgtname,tgtext]),'f');
end
disp('done.');

% remove directories/files
for ii=1:1:length(rm_str)
  tgtfiles=wildcardsearch(fullfile(save_dir,tgt),rm_str{ii});
  for jj=1:1:length(tgtfiles)
    if exist(tgtfiles{jj},'dir') || exist(tgtfiles{jj},'file')
      [path,fname,fext]=fileparts(tgtfiles{jj});
      if isdir(tgtfiles{jj})
        fprintf('removing: %s%s...',fname,fext);
        rmdir(tgtfiles{jj},'s');
      else
        fprintf('removing: %s%s...',fname,fext);
        delete(tgtfiles{jj});
      end
      disp('done.');
    end
  end
end
disp('backup completed.')

return
