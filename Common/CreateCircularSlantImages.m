function [imgL,imgR]=CreateCircularSlantImages(fieldSize,theta_deg,orient_deg,...
                                               aperture_deg,tgt_val,outer_val,...
                                               pix_per_deg,fine_coefficient,ipd,vdist)

% Creates an image(s) on whose 2D plane a ciruclar slant surface is projected.
% function [imgL,imgR]=CreateCircularSlantImages(fieldSize,theta_deg,orient_deg,...
%                                                aperture_deg,tgt_val,outer_val,...
%                                                pix_per_deg,fine_coefficient,ipd,vdist)
%
% Creates oriented slant with ciruclar aperture
% This function is different from CreateApertureSlantField in that
% the shape of the generated slant is adjusted as to look a perfect circle.
% 
% [input]
% fieldSize   : the size of the field in degrees, [row,col]
% theta_deg   : an angle measured fromh the vertical, [deg]
% orient_deg  : an angle (orientation) of slant,
%               from horizontal meridian, clockwise [deg]
% aperture_deg: the size of circular aperture in degrees, [deg]
% tgt_val     : target gray-scale value, [val]
% outer_val   : value to fill the outer region of slant field, [val]
% pix_per_deg : pixels per degree, [pixels]
% fine_coefficient : (optional) if larger, the generated oval become finer,
%                    but comsumes much CPU power. [val]
%                    (default=1, as is, no tuning)
% ipd         : inter pupile distance, [cm]
% vdist       : viewing distance, [cm]
%
% 
% [output]
% field       : grating image, double format, [row,col]
% 
% Created    : "2010-06-11 12:32:41 ban"
% Last Update: "2013-11-22 18:34:27 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(fieldSize), fieldSize=8; end
if nargin<2 || isempty(theta_deg), theta_deg=45; end
if nargin<3 || isempty(orient_deg), orient_deg=90; end
if nargin<4 || isempty(aperture_deg), aperture_deg=6; end
if nargin<5 || isempty(tgt_val), tgt_val=128; end
if nargin<6 || isempty(outer_val), outer_val=0; end
if nargin<7 || isempty(pix_per_deg), pix_per_deg=40; end
if nargin<8 || isempty(fine_coefficient), fine_coefficient=1.5; end
if nargin<9 || isempty(ipd), ipd=6.4; end
if nargin<10 || isempty(vdist), vdist=65; end

if numel(fieldSize)==1, fieldSize=[fieldSize,fieldSize]; end

% convert to pixels
fieldSize=round(fieldSize.*pix_per_deg*fine_coefficient);
aperture_pix=round(aperture_deg/2*fine_coefficient*pix_per_deg)^2; 

% generate base-distance matrix
[x,y]=meshgrid(0:1:fieldSize(2),0:1:fieldSize(1));
x=x-fieldSize(2)/2; y=y-fieldSize(1)/2;
if mod(size(x,1),2), x=x(1:end-1,:); y=y(1:end-1,:); end
if mod(size(x,2),2), x=x(:,1:end-1); y=y(:,1:end-1); end

%% calculate transformation matrix
% *NOTE*
% these values are calculated by hand by solving the formula below
%
% [origin_x,origin_y,origin_z]*rot_y(theta)*rot_z(delta)*rot_y(phi(L/R))=[dest_x,dest_y,dest_z]
%
% here,
% [origin_x,origin_y,origin_z] : xyz coordinate of the origin
%                                the point is on the circumference of the
%                                circle layed along XY-plane
% theta                        : degree of slant
% delta                        : degree of tilt
% phi                          : degree of eye angle (left/right)
% rot_y(*)                     : affine transformation matrix, along y-axis rotation
%                                [cos(*) 0 sin(*); 0 1 0; -sin(*) 0 cos(*)]
% rot_z(*)                     : affine transformation matrix, along z-axis rotation
%                                [cos(*) -sin(*) 0; sin(*) cos(*) 0; 0 0 1]
% [dest_x,dest_y,dest_z]       : xyz coordinate of the destination point
%                                the point is on the circumference of the
%                                slanted circle

% calculate radians
theta=theta_deg*pi/180;
delta=orient_deg*pi/180;
phiL=atan(ipd/2/vdist);
phiR=-atan(ipd/2/vdist);

% for left eye image
AL=cos(theta)*sin(phiL)+sin(theta)*cos(delta)*cos(phiL);
BL=sin(theta)*sin(delta);
CL=cos(theta)*cos(phiL)-sin(theta)*cos(delta)*sin(phiL);

% for right eye image
AR=cos(theta)*sin(phiR)+sin(theta)*cos(delta)*cos(phiR);
BR=sin(theta)*sin(delta);
CR=cos(theta)*cos(phiR)-sin(theta)*cos(delta)*sin(phiR);

% calculate distance of the orientad circular field
% the locus is ellipse
R2_L = ( (AL^2+CL^2)*(x.^2) + (2*AL*BL)*(x.*y) + (BL^2+CL^2).*(y.^2) )/(CL^2);
R2_R = ( (AR^2+CR^2)*(x.^2) + (2*AR*BR)*(x.*y) + (BR^2+CR^2).*(y.^2) )/(CR^2);

%% generate left/right images projected onto XY-plane
imgL=outer_val*ones(size(x));
imgR=outer_val*ones(size(x));

imgL(R2_L<=aperture_pix)=tgt_val;
imgR(R2_R<=aperture_pix)=tgt_val;

% adjust the size
if fine_coefficient~=1
  imgL=imresize(imgL,1/fine_coefficient,'bicubic');
  imgR=imresize(imgR,1/fine_coefficient,'bicubic');
end

return
