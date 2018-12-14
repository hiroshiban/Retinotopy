function CreateHardLinkFile(target_dir,infformat,output_dir)

% Creates hard links in the target directory to the target files.
% function CreateHardLinkFile(target_dir,infformat,output_dir)
%
% Create HardLink of the specific files located
% under the target directory
%
% [example]
% CreateHardLinkFile('\HB\zk09_091\05_zk09_091.MP\','*.vtc','\HB2\zk09_091\05_zk09_091.MP\')
%
% [input]
% target_dir : Target directory that contains infformat files
%              e.g. '\CD\zk08_382'
%              Target directory should be specified as such
%              the current directory where this function is
%              called is the origin.
% infformat  : input file format
% output_dir : directory in which the hard lined files are strored
%
% [requirement]
% 1. wildcardsearch.m
% 2. shell command, ln
%
% Created    : "2010-06-07 14:45:07 ban"
% Last Update: "2013-11-22 18:42:45 ban (ban.hiroshi@gmail.com)"

% check the input variables
if nargin < 3, help(mfilename()); return; end

srcdir=fullfile(pwd,target_dir);
tgtdir=fullfile(pwd,output_dir);

% get target files
tfiles=GetFiles(srcdir,infformat);

% create output directory
if ~exist(tgtdir,'dir'), mkdir(tgtdir); end

fprintf('target: %s\n',tgtdir);
% create hardlink files, main loops
for ii=1:1:length(tfiles)

  % get input file name
  tfile=tfiles{ii};
  fprintf('processing: %s\n',tfile);

  % set output file format & name
  [odir,ofname,oext]=fileparts(tfile);
  if strcmp(srcdir,tgtdir)
    ofile=strcat(tgtdir,filesep(),ofname,'_hlink',oext);
  else
    ofile=strcat(tgtdir,filesep(),ofname,oext);
  end
  fprintf('linking as: %s\n',ofile);

  % create hard link copy
  %eval(sprintf('!ln "%s" "%s"',tfile,ofile));
  % Here, I use special 'ln' command to allow hardlink for directories under Windows 7 strict user permission
  eval(sprintf('!%s/bin/ln "%s" "%s"',strrep(fileparts(mfilename('fullpath')),'\','/'),tfile,ofile));

end % for ii, ifile
disp('done.');
