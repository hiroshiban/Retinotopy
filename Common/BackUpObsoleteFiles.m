function [new_fname,backup_fname]=BackUpObsoleteFiles(tgt_dir,tgt_fname,backup_prefix)

% Backups already-existing file(s) in the target directory by adding some file-prefix.
% function BackUpObsoleteFiles(tgt_dir,tgt_fname,:backup_prefix)
% (: is optional)
%
% This function detects all the target files in a specific directory and
% backups them by adding a prefix you set at the end of their file names.
%
% [example]
% When tgt_dir='../HB_results/';, and you have 3 files below in tgt_dir.
% 1. results_run01.mat
% 2. results_run01_old.mat
% 3. results_run01_old_old.mat
% You are now wanting to save a new file named 'results_run01.mat' after
% backuping the old file listed above.
%
% To achieve this, you can run
% >> tgt_fname='results_run01.mat';
% >> backup_prefix='_old';
% >> BackUpObsoleteFiles(tgt_dir,tgt_fname,backup_prefix);
%
% Then, the files above (1-3) will be first renamed as
% 1. results_run01_old.mat
% 2. results_run01_old_old.mat
% 3. results_run01_old_old_old.mat
% And you can save your new file as 'results_run01.mat' now.
%
% [input]
% tgt_dir       : taret directory to be looked for. should be set with a relative path format.
%                 e.g. tgt_dir='../../HB/results/';
% tgt_fname     : target file name to be backuped. e.g. tgt_fname='params_run01.mat';
% backup_prefix : (optional) file prefix to be added to backup the old taget files.
%                 '_old' by default.
%
% [output]
% new_fname     : the renamed(backuped) file name(s), cell structure
% old_fname     : the corresponding original file name(s), cell structure
%
%
% Created    : "2013-11-19 13:56:33 ban (ban.hiroshi@gmail.com)"
% Last Update: "2013-11-22 18:22:21 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<2, help(mfilename()); return; end
if nargin<3 || isempty(backup_prefix), backup_prefix='_old'; end

% check directory
if ~exist(fullfile(pwd,tgt_dir),'dir'), error('can not find target directory. check input variable.'); end

% processing
tmpfname=fullfile(pwd,tgt_dir,tgt_fname); backup_fname=''; backup_counter=0;
while exist(tmpfname,'file')
  backup_counter=backup_counter+1;
  backup_fname{backup_counter}=tmpfname;
  [tmppath,tmpfname,tmpext]=fileparts(backup_fname{backup_counter});
  tmpfname=fullfile(tmppath,[tmpfname,backup_prefix,tmpext]);
end

new_fname='';
if ~isempty(backup_fname)
  for ii=length(backup_fname):-1:1
    [tmppath,tmpfname,tmpext]=fileparts(backup_fname{ii});
    new_fname{ii}=fullfile(tmppath,[tmpfname,backup_prefix,tmpext]);
    movefile(backup_fname{ii},new_fname{ii});
  end
end

return
