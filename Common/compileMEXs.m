function compileMEXs()

% Compiles all the mex files in this directory.
% function compileMEXs()
%
% Compiles all mex files in Common directory
%
% [dependency]
% wildcardsearch
%
% Created    : "2012-09-19 12:21:12 ban"
% Last Update: "2013-11-22 18:38:47 ban (ban.hiroshi@gmail.com)"

cfiles=wildcardsearch(pwd,'*.cpp');
for ii=1:1:length(cfiles)
  [path,fname,ext]=fileparts(cfiles{ii});
  fprintf('compiling: %s%s...',fname,ext);
  eval(sprintf('mex %s;',cfiles{ii}));
  disp('done.');
end

return;
