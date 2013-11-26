function rc=corrrand(nvals,C)

% Generates normally distributed random numbers for N variables with the C correlation matrix.
% function rc=corrrand(nvals,C)
%
% This function generates normally distributed random numbers for N variables
% with the C correlation matrix. The correlation between variables are estimated
% using Cholesky decomposition.
%
% [example]
% >> C=[1.0 0.6 0.3;0.6 1.0 0.5;0.3 0.5 1.0];
% >> rc=corrrand([3,1000],C);
% >> corr(rc(:,1),rc(:,2))
% >> corr(rc(:,1),rc(:,3))
% >> figure;
% >> plot(rc(:,1),rc(:,2),'ro');
% >> hold on;
% >> plot(rc(:,1),rc(:,3),'bo');
%
% [input]
% nvals : the number of random variables to be generated, [nvals,nums]
%         e.g. if you want to generate 3 of random 100 variables, nvals=[3,100]
% C     : correlation matrix between nvals
%         e.g. if you want to generate 3 random normal numbers with correlatoins,
%         1 vs 2 = 0.6, 1 vs 3 = 0.3, 2 vs 3 = 0.5, then C should be like
%         C= [ 1.0 0.6 0.3;   0.6 1.0 0.5;   0.3 0.5 1.0]
%
% [output]
% rc    : generated random numbers, [nvals x n_nums]
%
%
% Created    : "2013-08-31 16:19:16 ban"
% Last Update: "2013-11-22 18:37:49 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<2, help(mfilename()); return; end
if numel(nvals)==1, error('nvals should be [nvals,nums]. check input variable.'); end
if size(C,1)~=size(C,2), error('C should be a square matrix. check input variable.'); end
if nvals(1)~=size(C,1), error('size(C,1) should be same with nvals. check input variable.'); end

% Cholesky decomposition
U=chol(C);

% generate random numbers
rc=randn(nvals(2),nvals(1))*U;

return
