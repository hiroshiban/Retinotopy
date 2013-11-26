function cmap=cmapBY(num_colors)

% Generates a Blue-Yellow colormap.
% function cmaps=cmapBY(num_colors)
%
% This function generates Blue-Yellow colormap which will be useful
% to visualize negative-zero-positive values such as correlation matrix
%
% [input]
% num_colors : the number of colors you want to generate
%
% [output]
% cmaps      : Blue-Yellow colormaps with num_colors step
%
% [reference]
% the original code is from Dr A.E. Welchman
%
%
% Created    : "2011-07-06 12:54:33 banh"
% Last Update: "2013-11-26 11:20:28 ban (ban.hiroshi@gmail.com)"

if nargin<1 || isempty(num_colors), num_colors=256; end

step=(num_colors+1)/num_colors;
r=[(num_colors:-step:0)/num_colors];
g=[(num_colors:-step:0)/num_colors];
b=[(0:step:num_colors)/num_colors];
cmap=[r(:),g(:),b(:)];

return
