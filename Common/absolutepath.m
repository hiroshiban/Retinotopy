function  abs_path = absolutepath( rel_path, act_path )
%ABSOLUTEPATH  returns the absolute path relative to a given startpath.
%   The startpath is optional, if omitted the current dir is used instead.
%   Both argument must be strings.
%
%   Syntax:
%      abs_path = ABSOLUTEPATH( rel_path, start_path )
%   
%   Parameters:
%      rel_path           - Relative path
%      start_path         - Start for relative path  (optional, default = current dir)
%
%   Examples:
%      absolutepath( '.\data\matlab'        , 'C:\local' ) = 'c:\local\data\matlab\'
%      absolutepath( 'A:\MyProject\'        , 'C:\local' ) = 'a:\myproject\'
%
%      absolutepath( '.\data\matlab'        , cd         ) is the same as
%      absolutepath( '.\data\matlab'                     )
%
%   See also:  RELATIVEPATH PATH

%   Jochen Lenz


% 2nd parameter is optional:
if  nargin < 2
   act_path = cd;
end

% Predefine return string:
abs_path = '';

% Make sure strings end by a filesep character:
if  length(act_path) == 0   |   ~isequal(act_path(end),filesep)
   act_path = [act_path filesep];
end
if  length(rel_path) == 0   |   ~isequal(rel_path(end),filesep)
   rel_path = [rel_path filesep];
end

% Convert to all lowercase:
[act_path] = fileparts( lower(act_path) );
[rel_path] = fileparts( lower(rel_path) );

% Create a cell-array containing the directory levels:
act_path_cell = pathparts(act_path);
rel_path_cell = pathparts(rel_path);
abs_path_cell = act_path_cell;

% Combine both paths level by level:
while  length(rel_path_cell) > 0
   if  isequal( rel_path_cell{1} , '.' )
      rel_path_cell(  1) = [];
   elseif  isequal( rel_path_cell{1} , '..' )
      abs_path_cell(end) = [];
      rel_path_cell(  1) = [];
   else
      abs_path_cell{end+1} = rel_path_cell{1};
      rel_path_cell(1)     = [];
   end
end

% Put cell array into string:
for  i = 1 : length(abs_path_cell)
   abs_path = [abs_path abs_path_cell{i} filesep];
end

return

% -------------------------------------------------

function  path_cell = pathparts(path_str)

path_str = [filesep path_str filesep];
path_cell = {};

sep_pos = findstr( path_str, filesep );
for i = 1 : length(sep_pos)-1
   path_cell{i} = path_str( sep_pos(i)+1 : sep_pos(i+1)-1 );
end

return