function cseed=InitializeRandomSeed

% Initializes MATLAB internal state of a random seed.
% function InitializeRandomSeed
%
% This function initializes MATLAB internal state of random seed
%
% [no input]
%
% [output]
% cseed  : struct, the current rand settings & seed
%
% Created : Jan 29 2010 Hiroshi Ban
% Last Update: "2013-11-22 23:18:35 ban (ban.hiroshi@gmail.com)"

if ~exist('RandStream','file')

  % run old method
  rand('twister',sum(100*clock)); %#ok
  cseed='';

else

  % new method
  cseed = RandStream.create('mt19937ar','seed',sum(100*clock));

  % after MATLAB R2013
  if ismethod('RandStream','setGlobalStream')
    RandStream.setGlobalStream(cseed);
  else
    RandStream.setDefaultStream(cseed);
  end

end
