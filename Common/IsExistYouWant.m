function [is_exist, message] = IsExistYouWant(file_or_dir_path, ftype)

% Checks whether the file you want exist or not.
% function [is_exist, message] = IsExistYouWant(file_or_dir_path, ftype)
%
% This function checks wether the file or directory you want exists in the path
%
% [input]
% file_or_dir_path : path to the file you want to check
% ftype            : type --- 'var','builtin','file','dir','class'
%
% [output]
% is_exist         : if the file/directory is find, return 1. [0/1] 
% message          : text message, can be used for displaying warning etc.
%
% Created    : "2010-01-29 13:41:41 ban"
% Last Update: "2013-11-22 23:34:39 ban (ban.hiroshi@gmail.com)"

if nargin < 1
  help(mfilename); return;
end

if nargin < 2

  if exist(file_or_dir_path)
    is_exist = 1;
    message = sprintf('The file or directory check completed.\n%s\n exists.\n', file_or_dir_path);
  else 
    is_exist = 0;
    message = sprintf('The file or directory\n%s\ndoes not exist. Check the directory structure.\n', file_or_dir_path);
  end

else

  if exist(file_or_dir_path,ftype)
    is_exist = 1;
    message = sprintf('The file or directory check completed.\n%s\n exists.\n', file_or_dir_path);
  else 
    is_exist = 0;
    message = sprintf('The file or directory\n%s\ndoes not exist. Check the directory structure.\n', file_or_dir_path);
  end

end
