function H = generate_gabor_orientation_filter(x,y,sigma,theta,lambda,psi,display_flg)

% Generates 2D Gabor orientation filter(s).
% function H = generate_gabor_orientation_filter(x,y,sigma,theta,lambda,psi,display_flg)
%
% This function generates 2D Gabor orientation filter(s)
%
% [input]
% x      : filter field coordinates in column
% y      : filter field coordinates in row
%          !!!NOTE!!! x & y should be generated like [x,y]=meshgrid(-5:0.01:5);
% sigma  : SD of the Gaussian envelope in x and y directions, [sigma_x, sigma_y]
% theta  : orientation(s) of carrier, multiple values are acceptable
% lambda : frequency of the carrier
% psi    : phase offset of the carrier
% display_flg   : whether displaying the generated response patterns, [0|1], 0 by default
%
% [output]
% H      : output filter bank(s), 3D matrix, [size(x,1) x size(x,2) x numel(theta)]
%
% [example]
% [x,y]=meshgrid(-5:0.01:5);
% gab = generate_gabor_orientation_filter(x,y,1,2,pi/4,1.5,0);
% imagesc(gab)
%
%
% Created    : "2011-07-15 13:53:29 banh"
% Last Update: "2013-11-22 18:49:31 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<2, help generate_gabor_orientation_filter; return; end
if nargin<3 || isempty(sigma), sigma=[1,2]; end
if nargin<4 || isempty(theta), theta=[0,15,30,45,60,75,90,105,120,135,150,165]; end
if nargin<5 || isempty(lambda), lambda=1.5; end
if nargin<6 || isempty(psi), psi=0; end
if nargin<7 || isempty(display_flg), display_flg=0; end

if numel(sigma)==1, sigma=[sigma,sigma]; end

% processing
H=zeros(size(x,1),size(x,2),numel(theta));
rtheta=theta*pi/180;
for ii=1:1:numel(theta)

  % rotate filter fileds
  x_theta=x*cos(rtheta(ii))+y*sin(rtheta(ii));
  y_theta=-x*sin(rtheta(ii))+y*cos(rtheta(ii));

  % generate Gabor orientation filter
  H(:,:,ii) = 1/(2*pi*sigma(1)*sigma(2))*...
      exp(-0.5*(x_theta.^2/sigma(1)^2+y_theta.^2/sigma(2)^2)).*cos(2*pi/lambda*x_theta+psi);

end

% for masking the filters
[x,y]=meshgrid((1:size(x,2))-mean(1:size(x,2)),(1:size(x,2))-mean(1:size(x,1)));
r=sqrt(x.*x+y.*y);
mask=zeros(size(r));
mask(r<=size(x,1)/2)=1;
mask(r>size(x,1)/2)=0;

% visualizing
if display_flg
  figure;
  for ii=1:1:size(H,3)
    subplot(3,ceil(size(H,3)/3),ii);
    imagesc(H(:,:,ii),'AlphaData',mask);
    colormap(generate_RWB_colormap);
    %colormap(jet);
    axis square;
    axis off;
    title_str=sprintf('orient: %.2f',theta(ii));
    title(title_str);
  end
end

return
