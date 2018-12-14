function resp=generate_RF(x,mu,sigma,amp1,amp2)

% Generates 1D/2D 2-diff of gaussian response pulse.
% function generate_RF(x,mu,sigma,amp1,amp2)
%
% This function generates 1D/2D 2-diff of gaussian response pulse
%
% [input]
% x     : input response field,
%         e.g. x=-5:5; (for 1D gaussian), x=[-5:5;-5:5]; (for 2D)
% mu    : center of the response field, e.g. mu=0;
% sigma : sigma of gaussians
% amp1  : positive amplitude
% amp2  : amplitude of the undershoot component
%
% [output]
% resp  : output gaussian response
%
%
% Created    : "2011-07-14 13:22:03 banh"
% Last Update: "2013-11-22 18:49:21 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(x), x=-5:5; end

% generate gaussian response
if size(x,1)==1 % 1D gaussian response
  if nargin<2 || isempty(mu), mu=0; end
  if nargin<3 || isempty(sigma), sigma=2; end
  if nargin<4 || isempty(amp1), amp1=1.0; end
  if nargin<5 || isempty(amp2), amp2=0.5; end

  resp=amp1.*exp(-(x-mu(1)).^2/(sigma(1)^2))-(amp2.*exp(-(x-mu(1)).^2/(2*sigma(1)^2)));

else % 2D gaussian response
  [xx,yy]=meshgrid(x(1,:),x(2,:));
  if nargin<2 || isempty(mu), mu=[0,0]; end
  if nargin<3 || isempty(sigma), sigma=[2,2]; end
  if nargin<4 || isempty(amp1), amp1=1.0; end
  if nargin<5 || isempty(amp2), amp2=0.5; end

  resp=amp1.*exp( -( (xx-mu(1)).^2/(sigma(1)^2) + (yy-mu(1)).^2/(sigma(1)^2) ) )-...
       amp2.*exp( -( (xx-mu(2)).^2/(2*sigma(2)^2) + (yy-mu(2)).^2/(2*sigma(2)^2) ) );
end

return
