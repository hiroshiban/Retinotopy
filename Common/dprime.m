function [dp,beta]=dprime(phit,pfa)

% Returns the d-prime for a given point p (eg 80%) on the psychometric function.
% function [dp,:beta]=dprime(phit,:pfa)
% (: is optional)
%
% This function returns the d-prime for a given point p (eg 80%) on the psychometric function
%
% [NOTE]
% if only phit is given, dprime function will calculate d-prime based on the fomula below
%
% dp = 2*erfinv(2*phit-1).
%
% otherwise,
%
% dp = norminv(phit))-norminv(pfa)
% beta=normpdf(norminv(phit))./normpdf(norminv(pfa))
%
% [input]
% phit : correct ratio (accuracy)
% pha  : (optional) false alarm ratio
%
% [output]
% dp   : d-prime value(s)
% beta :  beta, criterion value(s)
%
% [reference]
% 1. Green, D.M. & Swets, J.A. (1974). Signal Detection Theory and Psychophysics (2nd Ed.)
%    Huntington, NY: Robert Krieger Publ. Co.
%
%
% Created    : "2012-03-09 16:06:52 banh"
% Last Update: "2013-11-22 18:54:20 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1, help dprime; return; end

% entered as a percentage
conth=0;
if ~isempty(find(1.0<phit & phit<=100,1))
  phit=phit./100;
  conth =1;
elseif ~isempty(find(0.0<=phit & phit<=1.0,1))
  conth=1;
end
phit(phit==1)=0.999;
phit(phit==0)=0.001;

if nargin==2
  contf=0;
  if ~isempty(find(1.0<pfa & pfa<=100,1))
    pfa=pfa./100;
    contf =1;
  elseif ~isempty(find(0.0<=pfa & pfa<=1.0,1))
    contf=1;
  end
  pfa(pfa==1)=0.999;
  pfa(pfa==0)=0.001;

  zhit=norminv(phit);
  zfa=norminv(pfa);
else
  contf=1;
end

% calculate d-prime
if conth && contf
  if nargin==1
    dp=2*erfinv(2*phit-1);
  else
    dp=zhit-zfa;
    if nargout==2
      beta=normpdf(zhit)./normpdf(zfa);
    end
  end
else
  error('phit & pfa should be a proportion in the range {>0..<1} or a percentage in range {1..<100}');
end

return
