function cmap=cmapCWM(num_colors)

% Generates a Cyan-White-Magenda colormap.
% function cmaps=cmapCWM(num_colors)
%
% This function generates Cyan-White-Magenda colormap which will be useful
% to visualize negative-zero-positive values such as correlation matrix
%
% [input]
% num_colors : the number of colors you want to generate
%
% [output]
% cmaps      : Cyan-White-Magenda colormaps with num_colors step
%
% [reference]
% the original code is from Dr A.E. Welchman
%
%
% Created    : "2011-07-06 12:54:33 banh"
% Last Update: "2013-11-26 11:20:06 ban (ban.hiroshi@gmail.com)"

if nargin<1 || isempty(num_colors), num_colors=256; end

n=fix(0.5*num_colors);
r=[ones(1,n),(n-1:-1:0)/n];
g=[(0:1:n-1)/n,ones(1,n)];
b=[(0:1:n-1)/n/2+0.5,ones(1,n)];
cmap=[r(:),g(:),b(:)];

return
