function cmap=cmapOWP(num_colors)

% Generates a Orange-White-Purple colormap.
% function cmaps=cmapOWP(num_colors)
%
% This function generates Orange-White-Purple colormap which will be useful
% to visualize negative-zero-positive values such as correlation matrix
%
% [input]
% num_colors : the number of colors you want to generate
%
% [output]
% cmaps      : Orange-White-Purple colormaps with num_colors step
%
% [reference]
% the original code is from Dr A.E. Welchman
%
%
% Created    : "2011-07-06 12:54:33 banh"
% Last Update: "2013-11-26 11:19:45 ban (ban.hiroshi@gmail.com)"

if nargin<1 || isempty(num_colors), num_colors=256; end

n=fix(0.5*num_colors);
r=[(0:1:n-1)/n/2+0.5,ones(1,n)];
g=[(0:1:n-1)/(n-1),(n-1:-1:0)/n/2+0.5];
b=[ones(1,n),(n-1:-1:0)/n];
cmap=[r(:),g(:),b(:)];

return
