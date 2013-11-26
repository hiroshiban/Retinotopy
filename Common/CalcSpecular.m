function amount = CalcSpecular(nv,lv,vv,shininess,model_id)

% Calculates a specular value at a point on the surface using Blinn's phong method.
% function amount = CalcSpecular(nv,lv,vv,shininess,model_id)
%
% Calculate a specular value at a point on the surface using Blinn's phong
% shading method etc.
%
% [input]
% nv          : coordinates of a point on the surface, [X;Y;Height]
% lv          : light source, 1x3 vector [x,y,z]
% vv          : viewpoint vector, [x,y,z]([0,0,1] by default)
% shininess   : shininess factor, [val](16.^0.25 by default)
% model_id    : ID of phong shading model, one of 1-12 (5 by default)
%                1 = Simple Phong method
%                Lyon main methods, with several K values for this D vector and x value
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
%
% [output]
% amount      : specular values at the point on the surface
%
% [related function]
% CreateSpecularMap
% Generate Blinn's Phong Shading map from heightfield input
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
% Created    : "2010-06-29 13:15:25 ban" 
% Last Update: "2013-11-22 18:18:19 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1, help CalcSpecular; return; end
if nargin<2 || isempty(lv), lv=[1,-1,1]; end
if nargin<3 || isempty(vv), vv=[0,0,1]; end
if nargin<4 || isempty(shininess), shininess=16.^0.25; end
if nargin<5 || isempty(model_id), model_id=5; end

if norm(lv)~=1, lv=lv*1/sqrt(sum(lv.*lv)); end
if norm(vv)~=1, vv=vv*1/sqrt(sum(vv.*vv)); end
  
% calculate specular value using phong-shading method

amount=zeros(size(nv,2),1);

% 1. Phong method
if model_id==1
  rv = 2*nv.*repmat((vv*nv),3,1)-repmat(vv',1,size(nv,2)); % reflected view vectors
  dot = rv'*lv';
  idx=find(dot>0);
  amount(idx) = dot(idx).^shininess;

% Lyon main methods, several k values for this D vector and x value

% 2. Lyon k=0
elseif model_id==2
  rv = 2*nv.*repmat((vv*nv),3,1)-repmat(vv',1,size(nv,2));
  dv = repmat(lv',1,size(rv,2)) - rv; % difference vector;
  xs = (sum(dv.*dv,1)*shininess/2)';
  idx=find(xs<=1);
  amount(idx) = 1-xs(idx);
  
% 3. Lyon k=1
elseif model_id==3
  rv = 2*nv.*repmat((vv*nv),3,1)-repmat(vv',1,size(nv,2));
  dv = repmat(lv',1,size(rv,2)) - rv; % difference vector;
  xs = (sum(dv.*dv,1)*shininess/2)';
  idx=find(xs<=2);
  amount(idx) = 1 - xs(idx)/2;
  amount(idx) = amount(idx).*amount(idx); % -- square k=1 times
  
% 4. Lyon k=2
elseif model_id==4
  rv = 2*nv.*repmat((vv*nv),3,1)-repmat(vv',1,size(nv,2));
  dv = repmat(lv',1,size(rv,2)) - rv; % difference vector;
  xs = (sum(dv.*dv,1)*shininess/2)';
  idx=find(xs<=4);
  amount(idx) = 1 - xs(idx)/4;
  amount(idx) = amount(idx).*amount(idx);
  amount(idx) = amount(idx).*amount(idx); % -- square k=2 times
    
% use n4 (4*n) in all the h-vector methods
% 5. Blinn method
elseif model_id==5
  hv = (lv+vv)/2;
  hl = hv*hv'; % hv length^2;
  hv2 = 1/sqrt(hl)*hv; % normalized halfway vector;
  n4 = 4*shininess; % "shininess" for halfway vector method
  dot = (hv2*nv)';
  idx=find(dot>0);
  amount(idx) = dot(idx).^n4;
  
% 6. Lyon/Blinn halfway method, normalized hv2, k=2
elseif model_id==6
  hv = (lv+vv)/2;
  hl = hv*hv'; % hv length^2;
  hv2 = 1/sqrt(hl)*hv; % normalized halfway vector;
  n4 = 4*shininess; % "shininess" for halfway vector method
  dv = repmat(hv2',1,size(nv,2)) - nv; % difference vector
  xs = (sum(dv.*dv,1)*n4/2)';
  idx=find(xs<=4);
  amount(idx) = 1 - xs(idx)/4;
  amount(idx) = amount(idx).*amount(idx);
  amount(idx) = amount(idx).*amount(idx); % -- square k=2 times
  
% 7. Lyon halfway method, no norm of h, k=2
elseif model_id==7
  hv = (lv+vv)/2;
  n4 = 4*shininess; % "shininess" for halfway vector method
  dv = repmat(hv',1,size(nv,2)) - nv.*repmat(hv*nv,3,1); % difference vector to projection
  xs = sum(dv.*dv,1)*n4/2;
  idx=find(xs<=4);
  amount(idx) = 1 - xs(idx)/4;
  amount(idx) = amount(idx).*amount(idx);
  amount(idx) = amount(idx).*amount(idx); % -- square k=2 times
    
% 8. Lyon halfway method 2, projecting hv1, k=2
elseif model_id==8
  hv = (lv+vv)/2;
  hl = hv*hv'; % hv length^2
  dl = 1-hl; % length error z
  hv1 = (1+0.5*(dl+dl*dl))*hv; % approx. normalized halfway vector
  n4 = 4*shininess; % "shininess" for halfway vector method
  dv = repmat(hv1',1,size(nv,2)) - nv.*repmat(hv1*nv,3,1); % difference vector
  xs = sum(dv.*dv,1)*n4/2;
  idx=find(xs<=4);
  amount(idx) = 1 - xs(idx)/4;
  amount(idx) = amount(idx).*amount(idx);
  amount(idx) = amount(idx).*amount(idx); % -- square k=2 times
  
% 9. Lyon halfway method 2, projecting hv1, k=1
% same xs from above
elseif model_id==9
  rv = 2*nv.*repmat((vv*nv),3,1)-repmat(vv',1,size(nv,2));
  dv = repmat(lv',1,size(rv,2)) - rv; % difference vector;
  xs = (sum(dv.*dv,1)*shininess/2)';
  idx=find(xs<=2);
  amount(idx) = 1 - xs(idx)/2;
  amount(idx) = amount(idx).*amount(idx); % -- square k=1 times
  
% 10. Lyon halfway method 3, hv1 no projection, k=2
elseif model_id==10
  hv = (lv+vv)/2;
  hl = hv*hv'; % hv length^2
  dl = 1-hl; % length error z
  hv1 = (1+0.5*(dl+dl*dl))*hv; % approx. normalized halfway vector
  n4 = 4*shininess; % "shininess" for halfway vector method
  dv = repmat(hv1',1,size(nv,2)) - nv; % difference vector --
  xs = (sum(dv.*dv,1)*n4/2)';
  idx=find(xs<=4);
  amount(idx) = 1 - xs(idx)/4;
  amount(idx) = amount(idx).*amount(idx);
  amount(idx) = amount(idx).*amount(idx); % -- square k=2 times
  
% 11. Blinn method D2 (Torrance and Sparrow)
% using some algebra and angular standard dev. of 1/sqrt(n4)
elseif model_id==11
  hv = (lv+vv)/2;
  hl = hv*hv'; % hv length^2;
  hv2 = 1/sqrt(hl)*hv; % normalized halfway vector;
  n4 = 4*shininess; % "shininess" for halfway vector method
  dot = (hv2*nv)';
  alpha = acos(dot);
  amount = exp(-(n4/2)*alpha.*alpha);
  
% 12. Blinn method D3 (Trowbridge and Reitz)
% using some algebra and n in place of (1/c2^2 - 1)
elseif model_id==12
  rv = 2*nv.*repmat((vv*nv),3,1)-repmat(vv',1,size(nv,2));
  dot = rv'*lv';
  idx=find(dot>0);
  amount(idx) = (1/(1+(1-dot(idx).*dot(idx))*shininess)).^2;
  amount(dot<=0) = (1/(1+shininess))^2; % as low as it gets!

% error
else
  error('model_id should be one of 1-12. Check input variables');

end

return
