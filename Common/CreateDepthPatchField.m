function imgs=CreateDepthPatchField(fieldSize,npatches,ipd,vdist,pix_per_cm,basedisp,jitterdisp,nimg,fine_coefficient,rgb_flg,bgcolor)

% Creates a plane of lattice depth patches
% function imgs=CreateDepthPatchField(fieldSize,npatches,ipd,vdist,pix_per_cm,:basedisp,:jitterdisp,:nimg,:fine_coefficient,:rgb_flg,:bgcolor)
% (: is optional)
%
% This function creates a lattice consisted of small patch palnes with randomly assigned disparities.
% Each patch size of the lattice is defined as [x,y] = 0.8*[fieldSize(1)/nrows, fieldSize(2)/ncols]
%
% [input]
% fieldSize        : the size of the field in degrees, [row,col] (deg)
%                    from the fixational plane
% npatches         : the number of patches in the lattice, [num_row, num_col]
% ipd              : inter-pupil distance
% vdist            : viewing distance (cm)
% pix_per_cm       : pixels per cm, [pixels]
% basedisp         : (optional) the base binocular disparity (image shift along z-axis)
%                    of the lattice, negative is near, 0 by default
% jitterdisp       : (optional) disparity jitter to be added on each of patches, [min,max]
%                    [-3,+3] by default
% nimg             : (optional) the number of images to be generated, 1 by default
% fine_coefficient : (optional) if larger, the generated oval become finer,
%                    but comsumes much CPU power. [val] (default=1, as is, no tuning)
% rgb_flg          : (optional) whether presenting the patch with RGB color or not, [0|1]
%                    1 by default. when 0, grayscale image will be generated (faster)
% bgcolor          : (optional) background RGB color, 128 or [128,128,128] by default.
%
% [output]
% imgs             : output images, a cell structure, {nimg,2}, 2 = left/right images
%
%
% Created
% Last Update: "2017-12-29 14:03:41 ban"

% check input variables
if nargin<5, help(mfilename()); imgs=[]; return; end
if nargin<6 || isempty(basedisp), basedisp=0; end
if nargin<7 || isempty(jitterdisp), jitterdisp=[-3,3]; end
if nargin<8 || isempty(nimg), nimg=1; end
if nargin<9 || isempty(fine_coefficient), fine_coefficient=1; end
if nargin<10 || isempty(rgb_flg), rgb_flg=1; end
if nargin<11 || isempty(bgcolor)
  if rgb_flg
    bgcolor=[128,128,128];
  else
    bgcolor=128;
  end
end

if numel(fieldSize)==1, fieldSize=[fieldSize,fieldSize]; end
if numel(npatches)==1, npatches=[npatches,npatches]; end
if rgb_flg & numel(bgcolor)==1, bgcolor=repmat(bgcolor,[1,3]); end

% initialize random seed
InitializeRandomSeed();

% unit conversions
cm_per_pix=1/pix_per_cm;
pix_per_deg=round( 1/( 180*atan(cm_per_pix/vdist)/pi ) );

% convert from degrees to pixels
wdims=fieldSize.*pix_per_deg;
wdims(2)=wdims(2)*fine_coefficient;

% calculate centers (X,Y) of each patch
p_edgeY=mod(wdims(1),npatches(1))+10; % delete exceeded region, 10 is a margin
p_intervalY=round((wdims(1)-p_edgeY)/npatches(1)); % intervals between patches
p_Y=repmat((p_intervalY/2+p_edgeY/2:p_intervalY:wdims(1)-p_edgeY/2)',[1,npatches(2)]);

p_edgeX=mod(wdims(2),npatches(2))+10; % delete exceeded region, 10 is a margin
p_intervalX=round((wdims(2)-p_edgeX)/npatches(2)); % intervals between patches
p_X=repmat(p_intervalX/2+p_edgeX/2:p_intervalX:wdims(2)-p_edgeX/2,[npatches(1),1]);

% set the base disparity shifts
basedist=CalcDistFromDisparity(ipd,basedisp,vdist);
baseshift(1)=ceil(RayTrace_ScreenPos_X(-1*basedist,ipd,vdist,1,pix_per_cm,0));
baseshift(2)=ceil(RayTrace_ScreenPos_X(-1*basedist,ipd,vdist,2,pix_per_cm,0));

% set colors
if rgb_flg
  colors=ceil(RandLim([nimg,npatches(1),npatches(2),3],64,255));
else
  colors=ceil(RandLim([nimg,npatches(1),npatches(2)],64,255));
end

% generating images
imgs=cell(nimg,2);
if rgb_flg
  baseimg=repmat(reshape(bgcolor,[1,1,3]),[wdims,1]);
else
  baseimg=bgcolor.*ones(wdims);
end

for ii=1:1:nimg
  imgs{ii,1}=baseimg;
  imgs{ii,2}=baseimg;

  pdims_Y=ceil(RandLim(npatches,0.5*p_intervalY,0.9*p_intervalY));
  pdims_X=ceil(RandLim(npatches,0.5*p_intervalX,0.9*p_intervalX));

  % set jitters of the patch centers
  centershift_Y=RandLim(npatches,-wdims(1)/30,wdims(1)/30);
  centershift_X=RandLim(npatches,-wdims(2)/30,wdims(2)/30);

  % calculate X & Y start point
  p_Ys=int32(p_Y-pdims_Y./2+centershift_Y); p_Ys(p_Ys<=0)=1;
  p_Xs=int32(p_X-pdims_X./2+centershift_X); p_Xs(p_Xs<=0)=1;

  % calculate X & Y end point
  p_Ye=int32(p_Y+pdims_Y./2+centershift_Y); p_Ye(p_Ye>wdims(1))=wdims(1);
  p_Xe=int32(p_X+pdims_X./2+centershift_X); p_Xe(p_Xe>wdims(2))=wdims(2);

  % set jitter disparities to be added to patches
  jitters=RandLim([npatches(1),npatches(2)],jitterdisp(1),jitterdisp(2));
  dist=CalcDistFromDisparity(ipd,jitters,vdist);
  xshifts(1,:,:)=ceil(RayTrace_ScreenPos_X(-1*dist,ipd,vdist,1,pix_per_cm,0));
  xshifts(2,:,:)=ceil(RayTrace_ScreenPos_X(-1*dist,ipd,vdist,2,pix_per_cm,0));

  % order the patches by the added disparity to prevent occlusion problem
  valx=squeeze(xshifts(1,:,:));
  valx=valx(:);
  [dummy,idx]=sort(valx,'descend'); %#ok
  [yy,xx]=ind2sub(size(p_Ys),idx);

  for pp=1:1:numel(idx)
    for nn=1:1:2 % left and right
      for cc=1:1:size(colors,4) % RGB
        imgs{ii,nn}(max(p_Ys(idx(pp))+1,1):min(p_Ye(idx(pp)),size(imgs{ii,nn},1)),...
                    max(p_Xs(idx(pp))+1+xshifts(nn,idx(pp))+baseshift(nn),1):...
                    min(p_Xe(idx(pp))+xshifts(nn,idx(pp))+baseshift(nn),...
                    size(imgs{ii,nn},2)),cc)=colors(ii,yy(pp),xx(pp),cc);
      end
    end
  end
  imgs{ii,nn}=uint8(imgs{ii,nn});
end % for ii=1:1:nimg

return
