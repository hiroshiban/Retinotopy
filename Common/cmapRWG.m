function cmap=cmapRWG(num_colors)

% Generates a Red-White-Green colormap.
% function cmaps=cmapRWG(num_colors)
%
% This function generates Red-White-Green colormap which will be useful
% to visualize negative-zero-positive values such as correlation matrix
%
% [input]
% num_colors : the number of colors you want to generate
%
% [output]
% cmaps      : Red-White-Green colormaps with num_colors step
%
% [reference]
% the original code is from Dr A.E. Welchman
%
%
% Created    : "2011-07-06 12:54:33 banh"
% Last Update: "2013-11-26 11:21:06 ban (ban.hiroshi@gmail.com)"

if nargin<1 || isempty(num_colors), num_colors=256; end

n=fix(0.5*num_colors);
r=[(0:1:n-1)/n,ones(1,n)];
g=[ones(1,n),(n-1:-1:0)/n];
b=[(0:n-1)/n,(n-1:-1:0)/n];
cmap=[r(:),g(:),b(:)];

return
