function DisplayTargetInSpecDir(target_dir,fformat,prefix)

% Displays target files in a specific directory.
% function DisplayTargetInSpecDir(target_dir,fformat,prefix)
% 
% [about]
% This function searches files you want and displays their names
% in the specific directory
%
% [example]
% >> DisplayTargetInSpecDir('/HB/zk09_091/','*.prt','design_')
%
% [input]
% target_dir : Target directory that contains "fformat" files
%              e.g. '\CD\zk08_382'
% fformat    : file format you want, you can use reg exp. e.g. '*.prt'
% prefix      : (optional) string to determine the target from 
%              multiple files, e.g. 'CD'
%
% [output]
% no output variable
%
% Last Update: "2013-11-22 22:51:42 ban (ban.hiroshi@gmail.com)"

% get target fileames from target_dir
tfiles=GetFiles(fullfile(pwd,target_dir),ffromat,prefix);

% separate directory & file names
for ii=1:1:length(tfiles)
  [paths{ii},fnames{ii},ext{ii}]=fileparts(tfiles{ii}); %#ok
end

% display target
dirnum=1;
fprintf('dir %03d: %s\n',dirnum,paths{1});
fprintf('  %s%s\n',fnames{1},ext{1});
for ii=2:1:length(fnames)
  if ~strcmp(paths{ii-1},paths{ii})
    dirnum=dirnum+1;
    fprintf('dir %03d: %s\n',dirnum,paths{ii});
  end
  fprintf('  %s%s\n',fnames{ii},ext{ii});
end % for ii, ifile
fprintf('\n');
