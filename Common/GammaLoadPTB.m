function GammaLoadPTB(gamma_table)

% Loads and sets display gamma-table(s) using PTB Screen() function.
% function GammaLoadPTB(:gamma_table)
% (: is optional)
%
% Loads gamma table(s) and sets it(them) on PTB engine
%
% [input]
% gamma_table : table(s) of gamma-corrected video input values (Color LookupTable).
%               256(8-bits) x 3(RGB) x 1(or 2,3,... when using multiple displays) matrix
%               or a *.mat file specified with a relative path format. e.g. '/gamma_table/gamma1.mat'
%               The *.mat should include a variable named "gamma_table".
%               if you use multiple (more than 1) displays and set 256x3x1 gamma-table, the same
%               table will be applied to all displays. if the number of displays and gamma tables
%               are different (e.g. you have 3 displays and 256x3x!2! gamma-tables), the last
%               gamma_table will be applied to the second and third displays.
%               if empty, normalized gamma table (repmat(linspace(0.0,1.0,256),3,1)) will be applied.
%
% [output]
% no output variable
%
%
% Created    : "12-08-22 02:52:30 ban"
% Last Update: "2013-11-22 18:51:31 ban (ban.hiroshi@gmail.com)"

% check input variable
if nargin<1 || isempty(gamma_table), gamma_table=(repmat(linspace(0.0,1.0,256),3,1))'; end

% load matlab matrix if the input gamma_table is a file.
if ischar(gamma_table)
  if ~exist(fullfile(pwd,gamma_table),'file'), error('can not find gamma table file. check input variable.'); end
  gamma_table=load(fullfile(pwd,gamma_table));
  gamma_table=gamma_table.gamma_table; % just to organize structure...
end

if size(gamma_table,1)==3 && size(gamma_table,2)==256, gamma_table=permute(gamma_table,[2,1,3]); end
if size(gamma_table,1)~=256 || size(gamma_table,2)~=3, error('gamma_table should be 256x3xN matrix. check input variable'); end

% check OS (Windows or the others)
is_windows=false;
winstr=mexext(); winstr=winstr(end-2:end);
if strcmpi(winstr,'w32') || strcmpi(winstr,'w64'), is_windows=true; end

% apply gamma table(s)

% first, applying the first table to whole displays
screencount=size(Screen('Screens'),2)-1;
if screencount==1
  Screen('LoadNormalizedGammaTable',0,gamma_table(:,:,1)); return
else
  for ii=0:1:screencount, Screen('LoadNormalizedGammaTable',ii,gamma_table(:,:,1)); end
end

% then, setting each of gamma tables to each of displays
if is_windows % 0 = whole displays, 1 = the first, 2 = the second, ...
  for ii=2:1:screencount, Screen('LoadNormalizedGammaTable',ii,gamma_table(:,:,min(ii,size(gamma_table,3)))); end
else % 0 = the first display, 1 = the second, ...
  for ii=1:1:screencount, Screen('LoadNormalizedGammaTable',ii,gamma_table(:,:,min(ii+1,size(gamma_table,3)))); end
end

return
