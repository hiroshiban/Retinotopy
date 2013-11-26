function [vmask,vbmask,vx,vy,x,y]=GenerateVoronoiMaskPatterns(fieldSize,dense,jitterratio,mode,nimages,pix_per_deg,display_flg,save_flg)

% Generates Voronoi texture mask patterns.
% function [vmask,vbmask,vx,vy,x,y]=GenerateVoronoiMaskPatterns(fieldSize,dense,jitterwidth,mode,nimages,pix_per_deg,display_flg,save_flg)
%
% [input]
% fieldSize        : the size of the field in degrees, [row,col]
% dense            : percentage of the dot in the space, 0.05 by default.
% jitterratio      : a jitter ratio of each dot position in the grid array.
%                    jitter is added as [x_jitter,y_jitter]=[x,y]+jitterratio*unifrnd(-1,1,[1,2]).
%                    0.4 by default.
% mode             : 0=cartesian coord, 1=polar coord. 0 by default.
% nimages          : the number of images to be generated. 1 by default.
% pix_per_deg      : pixels per degree, [pixels]. 40 by default.
% display_flag     : if 1, the generated images are displayed. [1/0]
% save_flag        : if 1, the generated images are saved. [1/0]
%
% [output]
% vmask            : Voronoi tessellation mask, cell structure, vmask{nimages}
% vbmask           : Voronoi tessellation's border mask, cell structure, vbmask{2,nimages}
%                    1: no gaussian smoothing, 2: gaussian smoothed
% vx               : x positions of the vertices of Voronoi tessellation, cell structure, vx{nimages}
% vy               : y positions of the vertices of Voronoi tessellation, cell structure, vy{nimages}
% x                : x positions of the centroids of Voronoi tessellation, cell structure, x{nimages}
% y                : y positions of the centroids of Voronoi tessellation, cell structure, y{nimages}
%
%
% Created    : "2013-08-29 11:45:39 ban"
% Last Update: "2013-11-26 11:18:38 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(fieldSize), fieldSize=8; end
if nargin<2 || isempty(dense), dense=0.05; end
if nargin<3 || isempty(jitterratio), jitterratio=0.4; end
if nargin<4 || isempty(mode), mode=0; end
if nargin<5 || isempty(nimages), nimages=1; end
if nargin<6 || isempty(pix_per_deg), pix_per_deg=40; end
if nargin<7 || isempty(display_flg), display_flg=0; end
if nargin<8 || isempty(save_flg), save_flg=0; end

% geberating Voronoi diagram texture mask
ranges=[-fieldSize/2,fieldSize/2;-fieldSize/2,fieldSize/2];
%ranges=[0,fieldSize/2-0.2;0,360];
[img,point_idx]=GenerateGridDotImage(fieldSize,ranges,dense,jitterratio,mode,nimages,pix_per_deg,0,0);

% generating Voronoi cells
vmask=cell(nimages,1); vbmask=cell(2,nimages);
vx=cell(nimages,1); vy=cell(nimages,1);
x=cell(nimages,1); y=cell(nimages,1);
h=fspecial('gaussian',size(img{1}),2);
for nn=1:1:nimages
  fprintf('generating Voronoi tessellation image #%02d...',nn);
  vcheck=0;
  while vcheck==0 % to avoid wrong assignment of textures
    [vmask{nn},vbmask{1,nn},vx{nn},vy{nn},x{nn},y{nn}]=voronoi2mask(point_idx{nn}(1,:)',point_idx{nn}(2,:)',size(img{nn}));
    if numel(unique(vmask{nn}(:)))-1==size(point_idx{nn},2)
      vcheck=1;
    else
      [dummy,update_idx]=GenerateGridDotImage(fieldSize,ranges,dense,jitterratio,mode,1,pix_per_deg,0,0);
      point_idx{nn}=update_idx{1};
    end
  end
  vbmask{2,nn}=imfilter(255*double(vbmask{1,nn}),h,'replicate');
  vbmask{2,nn}(vbmask{2,nn}>45)=45;
  vbmask{2,nn}=( vbmask{2,nn}-min(vbmask{2,nn}(:)) )./( max(vbmask{2,nn}(:))-min(vbmask{2,nn}(:)) );
  disp('done.');
end

% display the generated image(s)
if display_flg
  fprintf('displaying images...');
  scrsz=get(0,'ScreenSize');
  for nn=1:1:nimages
    figure('Name',sprintf('Voronoi texture #%02d',nn),'NumberTitle','off','Position',[scrsz(3)/6,scrsz(4)/4,4*scrsz(3)/6,2*scrsz(4)/4]);

    subplot(1,2,1);
    %imshow(vmask{nn},[0,max(vmask{nn}(:))]);
    imshow(vmask{nn}.*(1-vbmask{nn}),[0,max(vmask{nn}(:))]);
    axis equal; axis off; hold on;
    colormap(Shuffle(rainbow(round(max(vmask{nn}(:))))));
    title('voronoi texture');

    subplot(1,2,2);
    imshow(vbmask{nn},[0,1]);
    axis equal; axis off; hold on;
    title('voronoi border mask');
  end
  disp('done.');
end

% save generated masks
if save_flg
  save VoronoiMasks.mat vmask vbmask vx vy x y;
end

return
