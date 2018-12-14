function CreateHardLinkDir(target_dir,output_dir)

% Creates hard links in the target directory to the target directory.
% function CreateHardLinkDir(target_dir,output_dir)
%
% Create HardLink of the target directory as output directory
%
% [example]
% CreateHardLinkDir('\HB\zk09_091\05_zk09_091.MP\','HB_zk09_091.vtc')
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
% Last Update: "2013-11-22 18:42:48 ban (ban.hiroshi@gmail.com)"

% check the input variables
if nargin < 2, help(mfilename()); return; end

srcdir=fullfile(pwd,target_dir);
tgtdir=fullfile(pwd,output_dir);

% get target directory
if ~exist(srcdir,'dir'), error('can not find the target directory'); end

% create output directory
if ~exist(tgtdir,'dir'), mkdir(tgtdir); end

% create hard link copy
fprintf('target: %s to destination: %s...',srcdir,tgtdir);
%eval(sprintf('!ln -df "%s" "%s"',srcdir,tgtdir));
% Here, I use special 'ln' command to allow hardlink for directories under Windows 7 strict user permission
eval(sprintf('!%s/bin/ln -r "%s" "%s"',strrep(fileparts(mfilename('fullpath')),'\','/'),srcdir,tgtdir));

disp('done.');
