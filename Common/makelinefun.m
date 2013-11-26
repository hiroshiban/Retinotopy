function fun = makelinefun(x1,y1,x2,y2,o)

% Returns a function handle to generates line segment(s) to be plotted on the image.
% function fun = makelinefun(x1,y1,x2,y2,o)
%
% USAGE:
%
% f = makelinefun(0,0,6,9);
% xy = f(4)
%
%   xy =
%       0     2     4     6
%       0     3     6     9
%
%       f = makelinefun(0,0,6,9);
% [x,y] = f(4)
%
%   x =
%       0     2     4     6
%   y =
%       0     3     6     9
%
%ref http://stackoverflow.com/questions/13209373/matlab-straight-line-between-2-points-with-n-points-between
%
%
% Created    : "2013-10-21 ban"
% Last Update: "2013-11-22 23:43:17 ban (ban.hiroshi@gmail.com)"

if nargin < 5
  o = 1;
end
if o == 2,
  fun  = @(N) deal(linspace(x1,x2,N), linspace(y1,y2,N));
else
  fun  = @(N) [linspace(x1,x2,N) ; linspace(y1,y2,N)];
end
