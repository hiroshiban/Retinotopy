function cmap=cmapWB(num_colors)

% Generates a White-Black colormap.
% function cmaps=cmapWB(num_colors)
%
% This function generates White-Black colormap which will be useful
% to visualize negative-zero-positive values such as correlation matrix
%
% [input]
% num_colors : the number of colors you want to generate
%
% [output]
% cmaps      : White-Gray-Black colormaps with num_colors step
%
% [reference]
% the original code is from Dr A.E. Welchman
%
%
% Created    : "2011-07-06 12:54:33 banh"
% Last Update: "2013-11-26 11:20:51 ban (ban.hiroshi@gmail.com)"

if nargin<1 || isempty(num_colors), num_colors=256; end

%n=fix(0.5*num_colors);
%r=[(0:n)/n,ones(1,n)];
%g=[(0:n)/n,ones(1,n)];
%b=[(0:n)/n,ones(1,n)];

%r=(num_colors:-1:0)/num_colors;
%g=(num_colors:-1:0)/num_colors;
%b=(num_colors:-1:0)/num_colors;

step=(num_colors+1)/num_colors;
r=(0:step:num_colors)/num_colors;
g=(0:step:num_colors)/num_colors;
b=(0:step:num_colors)/num_colors;
cmap=[r(:),g(:),b(:)];

return
