function xyz=mkTorus(aL,bL,center_xyz,rad,steps,display_flg)

% Returns [x,y,z] coordinate of a torus object.
% function xyz=mkTorus(aL,bL,center_xyz,rad,steps,display_flg)
%
% This function generates (x,y,z) coordinates of a torus object
%
% [input]
% aL         : torus major radius along x-axis, [val]
% bL         : torus major radius along y-axis, [val]
% center_xyz : center position of the torus, [x,y,z]
% rad        : torus minor radius, [val]
% steps      : division steps along u and v angles, [num_u,num_v]
% display_flg: whether displaying the generated torus object.
%              if 1, the object will be displayed on MATLAB window
%
% [output]
% xyz        : xyz coords of the generated torus object
%              [num_steps(1),num_steps(2),3(xyz)]
%
%
% Created    : "2012-01-12 13:42:04 banh"
% Last Update: "2013-11-22 23:37:19 ban (ban.hiroshi@gmail.com)"

%% check input variables
if nargin<1 || isempty(aL), aL=4; end
if nargin<2 || isempty(bL), bL=2; end
if nargin<3 || isempty(center_xyz), center_xyz=[0,0,0]; end
if nargin<4 || isempty(rad), rad=1; end
if nargin<5 || isempty(steps), steps=[50,20]; end
if nargin<6 || isempty(display_flg), display_flg=1; end

%% generate torus coordinates

% division of the space
theta=linspace(0,2*pi,steps(1));
phi=linspace(0,2*pi,steps(2));

% bese ellipse
xe=center_xyz(1)+aL*cos(theta');
ye=center_xyz(2)+bL*sin(theta');
ze=center_xyz(3)+zeros(numel(theta),1);

% torus
xt=zeros(numel(theta),numel(phi));
yt=zeros(numel(theta),numel(phi));
zt=zeros(numel(theta),numel(phi));
for pp=1:1:numel(phi)
  xt(:,pp)=xe+rad*cos(phi(pp))*cos(theta');
  yt(:,pp)=ye+rad*cos(phi(pp))*sin(theta');
  zt(:,pp)=ze+rad*sin(phi(pp));
end
xyz(:,:,1)=xt;
xyz(:,:,2)=yt;
xyz(:,:,3)=zt;

%% display the generated torus objcect
if display_flg
  figure; hold on;
  set(gcf,'Color',[1,1,1]);
  plot3(xyz(:,:,1),xyz(:,:,2),xyz(:,:,3));
  for tt=1:2:numel(theta)
    plot3(xyz(tt,:,1),xyz(tt,:,2),xyz(tt,:,3),'k-','LineWidth',1.5);
  end
  axis equal;
  axis off;
  drawnow;
end


return
