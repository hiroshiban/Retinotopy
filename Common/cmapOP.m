function cmap=cmapOP(num_colors)

% Generates a Orange-Purple colormap.
% function cmaps=cmapOP(num_colors)
%
% This function generates Orange-Purple colormap which will be useful
% to visualize negative-zero-positive values such as correlation matrix
%
% [input]
% num_colors : the number of colors you want to generate
%
% [output]
% cmaps      : Orange-Purple colormaps with num_colors step
%
% [reference]
% the original code is from Dr A.E. Welchman
%
%
% Created    : "2011-07-06 12:54:33 banh"
% Last Update: "2013-11-26 11:19:55 ban (ban.hiroshi@gmail.com)"

if nargin<1 || isempty(num_colors), num_colors=256; end

step=(num_colors+1)/num_colors;
r=[(0:step:num_colors)/num_colors/2+0.5];
g=[(0:step:num_colors)/num_colors/2];
b=[(num_colors:-step:0)/num_colors];
cmap=[r(:),g(:),b(:)];

return
