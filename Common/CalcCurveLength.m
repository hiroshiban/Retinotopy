function len=CalcCurveLength(func,sp,ep,steps)

% function len=CalcCurveLength(func,sp,ep,:steps)
% (: is optional)
%
% This function computes the length of the curves described by the function defined by the "func" handler.
% for instance, if
% >> func = @(x) exp(x);
% >> sp = 0;
% >> ep = 1000;
% >> steps = 1000;
% then, the curve length of the exp(x) [x is from 0 to 1000] will be returned.
%
% [example]
% >> len=CalcCurveLength(@(x) x.^4 ,0,1,1000);
%
% [input]
% func : a function handler, e.g. func = @(x) exp(x), or func = @(x) x.^2
% sp   : starting point, e.g. sp=0
% ep   : end point, e.g. ep=1000
% steps: (optional) the number of steps, steps=1000; by default.
%
% [output]
% len  : curve length, double
%
%
% Created    : "2023-02-16 14:37:46 ban"
% Last Update: "2023-02-16 14:42:33 ban"

% check the input variable
if nargin<4 || isempty(steps), steps=1000; end

% set the calculation steps
x=linspace(sp,ep,steps+1);
h=(ep-sp)/steps; % the step size h

% compute the length of the curve using the trapezoidal rule
len=sum(sqrt(1+((func(x(2:steps+1))-func(x(1:steps)))./h).^2).*h);

return
