function cleanpport

% Sets most pins of the parallel port to zero
% function cleanpport

parport = digitalio('parallel','LPT1');
addline(parport,0:7,'out');

putvalue(parport.Line(1:8),0)
%putvalue(par.Line,[1 1 1 1 1 1 1 1 ])

delete(parport);