function pmap=CreateSpecularMap(heightfield,model_id,vv,lvs,shininess,diffuse,...
                                ambient,pix_per_cm,display_flag,save_flag)

% Generates a specular map from the input height field (using Blinn's Phong shading method).
% function smap=CreateSpecularMap(heightfield,model_id,vv,lvs,shininess,diffuse,...
%                                 ambient,pix_per_cm,display_flag,save_flag)
%
% This function generates Blinn's Phong Shading map from heightfield input
%
% [input]
% heightfield : height field to generate Blinn's phong-map, [row,col]
%               *NOTICE* the unit of the height should be cm
% model_id    : ID of phong shading model, one of 1-12 (5 by default)
%                1 = Simple Phong method
%                Lyon main methods, with several K values for the D vector and X value
%                2 = Lyon K=0 method
%                3 = Lyon K=1 method
%                4 = Kyon K=2 method
%                5 = Blinn method
%                6 = Lyon/Blinn halfway method, normalized hv2, K=2
%                7 = Lyon/Blinn halfway method, no norm of hv1, K=2
%                8 = Lyon/Blinn halfway method 2, projecting hv1, K=2
%                9 = Lyon/Blinn halfway method 2, projecting hv2, K=1
%               10 = Lyon/Blinn halfway method, normalized hv2, K=2
%               11 = Blinn method D2 (Torrance and Sparrow)
%               12 = Blinn method D3 (Trowbridge and Reitz)
% vv          : view point vector
% lvs         : light sources, Nx3 vectors,
%               N is the number of light sources projected to the heightfield.
%               2 light sources by default, one is from back(shininess)
%               and another is from front, ([x1,y1,z1;x2,y2,z2]=[1 1 -1;1 -1 1])
% shininess   : shininess factor, [val](16 by default)
% diffuse     : diffuse factor, [val](35 by default)
% ambient     : ambient light factor, [val](0 by default)
% display_flag: if 1, the generated images will be displayed, [0/1]
% save_flag   : if 1, the generated images will be saved as RDS_imgs.mat, [0/1]
%
% [output]
% pmap        : Blinn's Phong Shading map [row,col]
%               The size of pmap is same with heightfield
%
% [requirement]
% CalcSpecular
% Calculate specular value at a point on the surface using Blinn's phong
% shading method etc.
% 
% [example]
% heightfield=CreateCylinderField();
% pix_per_cm=57;
% heightfield=heightfield/pix_per_cm;
%  
% model_id=5;
% vv=[0 0 1].*10;
% lvs=[0 1 1;0 -1 1];
% shininess=6.^0.25;
% diffuse=35;
% ambient=0;
% baseval=0;
% display_flag=1;
% save_flag=0;
%  
% pmap=CreateSpecularMap(heightfield,model_id,vv,lvs,shininess,...
%              diffuse,ambient,'',display_flag,save_flag);
%  
% figure;
% subplot(1,3,1); hold on; surf(heightfield); shading interp; colormap gray;
% subplot(1,3,2); hold on; surf(double(pmap)); shading interp; colormap gray;
% subplot(1,3,3); hold on; imshow(uint8(pmap)); shading interp; colormap gray;
%
% [reference]
% Phong Shading Reformulation for Hardware Renderer Simplification
% Apple Technical Report #43, 1993
% Richard F. Lyon
% http://www.dicklyon.com/tech/Graphics/Phong_TR-Lyon.pdf
%
%
% Created    : "2010-06-29 11:42:29 ban"
% Last Update: "2013-11-22 23:03:52 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1, help CreateSpecularMap; return; end
if nargin<2 || isempty(model_id), model_id=5; end
if nargin<3 || isempty(vv), vv=[0 0 1]; end
if nargin<4 || isempty(lvs), lvs=[1 1 -1;1 -1 1]; end
if nargin<5 || isempty(shininess), shininess=16; end
if nargin<6 || isempty(diffuse), diffuse=35; end
if nargin<7 || isempty(ambient), ambient=0; end
if nargin<8 || isempty(pix_per_cm), 
  % cm per pix
  % 1 inch = 2.54 cm, my PC's display is 1920x1200, 15.4 inch.
  % So, 15.4(inch)*2.54(cm) / sqrt(1920^2+1200^2) (pix) = XXX cm/pixel
  cm_per_pix=15.4*2.54/sqrt(1920^2+1200^2);
  pix_per_cm=1/cm_per_pix;
end
if nargin<9 || isempty(display_flag), display_flag=0; end
if nargin<10 || isempty(save_flag), save_flag=0; end

if size(vv,2)~=3, error('the size of vv shoud be 1x3. Check input variables.'); end
if size(lvs,2)~=3, error('the size of lvs shoud be Nx3. Check input variables.'); end

% convert light source vectors to unit vectors
for ii=1:1:size(lvs,1)
  if norm(lvs(ii,:))~=1
    lvs(ii,:)=lvs(ii,:)*1/sqrt(sum(lvs(ii,:).*lvs(ii,:)));
  end
end

% calculate specular amounts
specf=shininess.^0.25;
%specf=400/max(specf)*specf; % set max specular amount to 400

% set xy coordinates as the origin is the center of the heightfield
% note, mod(size(heightfield,{1|2}),2) is always 0 in this function
X=repmat( ( (1:1:size(heightfield,2)) -0.5-size(heightfield,2)/2 )./pix_per_cm, size(heightfield,1), 1 );
Y=repmat( ( (1:1:size(heightfield,1))'-0.5-size(heightfield,1)/2 )./pix_per_cm, 1, size(heightfield,2) );

% generate phong shading map
totals = ambient*ones(size(heightfield,1)*size(heightfield,2),1); % ambient light
nv = [X(:) Y(:) heightfield(:)]'; % nv=[X;Y;Z] are now coordinates of normal to the heightfield surface
for ii=1:1:size(lvs,1)
  difs = (lvs(ii,:)*nv)'; idx=find(difs>0); totals(idx) = totals(idx) + diffuse*difs(idx); % diffuse light
  totals=totals+specf*CalcSpecular(nv,lvs(ii,:),vv,shininess,model_id); % Blinn phong shading
end
pmap=reshape(totals,size(heightfield));

% --- plot the results
if display_flag
  figure; hold on;
  imshow(uint8(pmap),[0 255]);
  colormap(gray);
  shg;
end

% --- save the results
if save_flag
  save Phong_imgs.mat pmap heightfield;
end

return
