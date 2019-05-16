% script_generate_OLTs_for_pRF_maps.m
%
% a simple script to generate BrainVoyager color lookup tables (*.olt)
% for visualizing pRF and the other statistical mapping results
%
%
% Created    : "2018-08-31 09:47:37 ban"
% Last Update: "2018-09-04 17:14:42 ban"

cv_hbtools_BVQX_setup(1);

% constants
nLUT=20; % default #LUT of BrainVoyager

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% colormap for pRF eccentricity representation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lut_pRF_rho=ceil(255.*imresize(generate_colormap_BrainFactory(360,64,-90,1,0,0,0),[nLUT/2,3]));
%lut_pRF_rho=lut_pRF_rho([3:nLUT/2,1:2],:);
lut_pRF_rho(lut_pRF_rho<0)=0; lut_pRF_rho(lut_pRF_rho>255)=255;
lut_pRF_rho=flip(lut_pRF_rho,1);

fid=fopen('pRF_eccentricity_BVQX_hbtools.olt','w');
for ii=1:1:nLUT/2
  fprintf(fid,sprintf('Color%d: % 3d % 3d % 3d\n',ii,lut_pRF_rho(ii,1),lut_pRF_rho(ii,2),lut_pRF_rho(ii,3)));
end
for ii=1:1:nLUT/2
  fprintf(fid,sprintf('Color%d: % 3d % 3d % 3d\n',ii+nLUT/2,lut_pRF_rho(ii,1),lut_pRF_rho(ii,2),lut_pRF_rho(ii,3)));
end
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% colormap for pRF polar-angle representation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lut_pol=ceil(255.*imresize(generate_colormap_BrainFactory(360,64,0,2,0,0,0),[nLUT,3]));
lut_pol(lut_pol<0)=0; lut_pol(lut_pol>255)=255;

fid=fopen('pRF_polar_BVQX_hbtools.olt','w');
for ii=1:1:size(lut_pol,1)
  fprintf(fid,sprintf('Color%d: % 3d % 3d % 3d\n',ii,lut_pol(ii,1),lut_pol(ii,2),lut_pol(ii,3)));
end
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% colormap for amplitude etc (hot_cool)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lut_hot=zeros(nLUT,3);
lut_hot(1:1:nLUT/2,1)=255;
lut_hot(1:1:nLUT/2,2)=ceil(linspace(0,255,nLUT/2));
lut_hot(1:1:nLUT/2,3)=0;
lut_hot(nLUT/2+1:1:nLUT,1)=0;
lut_hot(nLUT/2+1:1:nLUT,2)=ceil(linspace(0,255,nLUT/2));
lut_hot(nLUT/2+1:1:nLUT,3)=255;

fid=fopen('pRF_hot_cool_BVQX_hbtools.olt','w');
for ii=1:1:size(lut_hot,1)
  fprintf(fid,sprintf('Color%d: % 3d % 3d % 3d\n',ii,lut_hot(ii,1),lut_hot(ii,2),lut_hot(ii,3)));
end
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% colormap for correlation etc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%lut_corr=load(fullfile(fileparts(mfilename('fullpath')),'..','lut','corr.lut'));
%lut_corr=ceil(255.*imresize(lut_corr(:,1:3),[nLUT,3]));
%lut_corr(lut_corr<0)=0; lut_corr(lut_corr>255)=255;

lut_corr(1:1:nLUT/2,1:3)=ceil([255*ones(nLUT/2,1),linspace(0,255,nLUT/2)',zeros(nLUT/2,1)]);
lut_corr(nLUT/2+1:1:nLUT,1:3)=ceil([linspace(255,0,nLUT/2)',zeros(nLUT/2,1),255*ones(nLUT/2,1)]);
lut_corr(lut_corr<0)=0; lut_corr(lut_corr>255)=255;

fid=fopen('pRF_corr_BVQX_hbtools.olt','w');
for ii=1:1:size(lut_corr,1)
  fprintf(fid,sprintf('Color%d: % 3d % 3d % 3d\n',ii,lut_corr(ii,1),lut_corr(ii,2),lut_corr(ii,3)));
end
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% colormap for sigma
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lut_sigma=load(fullfile(fileparts(mfilename('fullpath')),'..','lut','sigma.lut'));
lut_sigma=ceil(255.*imresize(lut_sigma(:,1:3),[nLUT/2,3]));
lut_sigma(lut_sigma<0)=0; lut_sigma(lut_sigma>255)=255;
%lut_sigma(nLUT/2+1:nLUT,:)=lut_sigma(nLUT/2:-1:1,:);
lut_sigma=[lut_sigma;lut_sigma];

fid=fopen('pRF_sigma_BVQX_hbtools.olt','w');
for ii=1:1:size(lut_sigma,1)
  fprintf(fid,sprintf('Color%d: % 3d % 3d % 3d\n',ii,lut_sigma(ii,1),lut_sigma(ii,2),lut_sigma(ii,3)));
end
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% colormap for standard maps (BrainVoyager default)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lut_standard=[
255 75 0;
255 95 0;
255 115 0;
255 135 0;
255 155 0;
255 175 0;
255 195 0;
255 215 0;
255 235 0;
255 255 0;
0 75 255;
0 95 235;
0 115 215;
0 135 195;
0 155 175;
0 175 155;
0 195 135;
0 215 115;
0 235 95;
0 255 75];

fid=fopen('pRF_standard_BVQX_hbtools.olt','w');
for ii=1:1:size(lut_standard,1)
  fprintf(fid,sprintf('Color%d: % 3d % 3d % 3d\n',ii,lut_standard(ii,1),lut_standard(ii,2),lut_standard(ii,3)));
end
fclose(fid);

cv_hbtools_BVQX_setup(0);
