function H = generate_gabor_nonlin_orientation_filter(d_center,d_range,num_detectors,y_size,theta,lambda,psi,display_flg)

% Generates nonlinear 2D Gabor orientation filter(s).
% function H = generate_gabor_nonlin_orientation_filter(d_center,d_range,num_detectors,y_size,theta,lambda,psi,display_flg)
%
% This function generates nonlinear 2D Gabor orientation filter(s)
%
% [input]
% d_center : filter center, disparity, -2<=d_center<=2, 1 shifts the filter to 1 radius
% d_range  : range of filter, 'radius' in disparity
% num_detectors : the number of detectors in d_range
% y_size   : size in pixels along y-axis of the generated detectors
% theta    : orientation(s) of carrier, multiple values are acceptable
% lambda   : frequency of the carrier
% psi      : phase offset of the carrier
% display_flg   : whether displaying the generated response patterns, [0|1], 0 by default
%
% [output]
% H        : output filter bank(s), 3D matrix, [size(x,1) x size(x,2) x numel(theta)]
%
% [example]
% >> H=generate_gabor_nonlin_orientation_filter(0,4,17,[],1.8,[],1);
%
% [note & reference]
% all the equations were from Lehky and Sejnowski, JNS, 1990
%
%
% Created    : "2011-07-18 10:17:48 banh"
% Last Update: "2013-11-22 18:49:52 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<3, help generate_gabor_nonlin_orientation_filter; return; end
if nargin<4 || isempty(y_size)
  %scaling_factor=10; % constant variable
  %y_size=(3*num_detectors*scaling_factor-1)/2+1;
  y_size=3*456/2; % actual stimulus size used at BUIC, temporal setting
end
if nargin<5 || isempty(theta), theta=[0,15,30,45,60,75,90,105,120,135,150,165]; end
if nargin<6 || isempty(lambda), lambda=1.5; end
if nargin<7 || isempty(psi), psi=0; end
if nargin<8 || isempty(display_flg), display_flg=0; end

if d_center<-2 || 2<d_center
  error('d_center should be -2<=d_center<=2. check input variable.');
end

% nonlinear transformations, considering center shift
d_max=3*abs(d_range);
xmaxval=calc_range(d_max);
disparity_ids=linspace(1,xmaxval,y_size);

d_peak=calc_disparity(disparity_ids);
d_peak=[-d_peak(end:-1:2),0,d_peak(2:end)];

d_sigma=calc_sigma(disparity_ids);
d_sigma=[d_sigma(end:-1:2),d_sigma(1),d_sigma(2:end)];

% store the center positions of the filter
tgt_ids_x=(ceil(2*numel(d_peak)/6)+1:ceil(4*numel(d_peak)/6))-ceil(d_center*numel(d_peak)/6);
tgt_ids_y=ceil(2*numel(d_peak)/6)+1:ceil(4*numel(d_peak)/6);

% generte nonlinear filter field parameters
x=repmat(d_peak,size(d_peak,2),1);
y=(1:1:size(x,1))'; y=y-mean(y); y=repmat(y,1,size(y,1)); y=y./max(y(:))*max(abs(x(:)));
sigma=repmat(d_sigma,size(d_sigma,2),1)./4;
sigma_x_cor_factor=1;
sigma_y_cor_factor=3;
sigma_x=sigma_x_cor_factor*sigma;
sigma_y=sigma_y_cor_factor*sigma;

% processing
H=zeros(numel(tgt_ids_y),numel(tgt_ids_x),numel(theta));
rtheta=theta*pi/180;
for ii=1:1:numel(theta)

  % rotate filter fileds
  x_theta=x*cos(rtheta(ii))+y*sin(rtheta(ii));
  y_theta=-x*sin(rtheta(ii))+y*cos(rtheta(ii));

  % generate Gabor orientation filter
  %H(:,:,ii) = 1./(2*pi.*sigma_x.*sigma_y).*...
  %    exp(-0.5*(x_theta.^2./sigma_x.^2+y_theta.^2./sigma_y.^2)).*cos(2*pi/lambda.*x_theta+psi);
  tmp = 1./(2*pi.*sigma_x.*sigma_y).*...
        exp(-0.5*(x_theta.^2./sigma_x.^2+y_theta.^2./sigma_y.^2)).*cos(2*pi/lambda.*x_theta+psi);
  H(:,:,ii)=tmp(tgt_ids_y,tgt_ids_x);

  % scaling the filter
  H(:,:,ii)=H(:,:,ii)./max(max(abs(H(:,:,ii))));

end

% adjust the filter size and scaling to the final one
Hc=zeros([size(H,1),num_detectors]);
for ii=1:1:numel(theta)
  Hc(:,:,ii)=imresize(H(:,:,ii),[size(H,1),num_detectors]);
  %Hc(:,:,ii)=Hc(:,:,ii)./max(max(abs(Hc(:,:,ii))));
end
H=Hc;

% % for masking the filters
% [x,y]=meshgrid((1:size(H,2))-mean(1:size(H,2)),(1:size(H,2))-mean(1:size(H,1)));
% r=sqrt(x.*x+y.*y);
% mask=zeros(size(r));
% mask(r<=size(x,1)/2)=1;
% mask(r>size(x,1)/2)=0;

% visualizing
if display_flg
  figure;
  for ii=1:1:size(H,3)
    subplot(3,ceil(size(H,3)/3),ii);
    %imagesc(H(:,:,ii),'AlphaData',mask);
    imagesc(H(:,:,ii));
    %set(gca,'CLim',[-1,1]);
    colormap(generate_RWB_colormap);
    %colormap(jet);
    axis square;
    axis off;
    title_str=sprintf('orient: %.2f',theta(ii));
    title(title_str);
  end
end

return


%% subfunctions
function max_id=calc_range(d_max)
max_id=0.0002*d_max.^3-0.0203*d_max.^2+0.6541*d_max+0.7822;

function disparity_peak=calc_disparity(disparity_ids)
disparity_peak=0.0965*disparity_ids.^3-0.9331*disparity_ids.^2+4.609*disparity_ids-3.7943;

function disparity_sigma=calc_sigma(disparity_ids)
%disparity_sigma=0.0437*disparity_ids.^3+0.4372*disparity_ids.^2-2.0937*disparity_ids+5.5352;
disparity_sigma=1.8637*exp(0.3718*disparity_ids);
