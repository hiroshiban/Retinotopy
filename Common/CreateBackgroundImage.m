function [Bimg,parameters] = CreateBackgroundImage(wdims,stdims,pdims,bgcolor,...
                                 color1,color2,fixcolor,patchnum,fix_flag,save_flag,show_flag)

% Creates background image that can be used as a background of your stimulus displays.
% function [Bimg,parameters] = CreateBackgroundImage(wdims,stdims,pdims,bgcolor,...
%                                  color1,color2,fixcolor,patchnum,fix_flag,save_flag,show_flag)
%
% Generate Background Images for left/right eyes (both are the same)
%
% <example>
% bimg=CreateBackgroundImage([1024,1280],[600,800],[40,40],...
%                            [128,128,128],[255,255,255],[0,0,0],[128,128,128],[20,20],16,0,1);
%
% <input>
% wdims       : window resolutions [row,col]
% stdims      : stimulus to-be-presented resolutions [row,col]
% pdims       : background patch size [row,col]
% bgcolor     : background color [r,g,b]
% color1      : background patch color 1 [r,g,b]
% color2      : background patch color 2 [r,g,b]
% fixcolor    : fixation color [r,g,b]
% patchnum    : number of patches along x and y axis [val,val]
% fix_flag    : whether the central fixation is added to each image
%               if 0, images are generated without the central fixation point.
%               if above 0, images are generated with the central fixation
%               whose radius is [fix_flag](in pix).
% save_flag   : if 1, the created checkerboard patterns
%               will be saved as BMP files.
% show_flag   : if 1, the created checkerboard patterns
%               are showed in the figure windows.
%
% * NOTICE mod(imgsize,sdims) & mod(tgtsize,sdims) should be 0
%          mod(mdims,2) should be 0, here mdims is defined as imgsize./tgtsize
%
% <output>
% Bimg       : Background images, cell arrays, {2}
%              (here 2 means left/right eye images, 1 is left)
%
% !!! NOTICE !!!
% for speeding up image generation process,
% I will not put codes for nargin checks.
% Please be careful.
%
% Created     : July 17 2009 Hiroshi Ban
% Last Update : Sep  01 2009 Hiroshi Ban


parameters=[];
if save_flag
  % save parameters
  parameters.name=mfilename();
  parameters.wdims=wdims;
  parameters.stdims=stdims;
  parameters.pdims=pdims;
  parameters.color1=color1;
  parameters.color2=color2;
  parameters.bgcolor=bgcolor;
  parameters.patchnum=patchnum;
  parameters.fix_rad=fix_rad;
  parameters.fixcolor=fixcolor;
  parameters.save_flag=save_flag;
  parameters.show_flag=show_flag;
end % save_flag

% matrix dimension check
if mod(wdims(1),2) || mod(wdims(2),2)
    error('Window resolutions should be divided by 2! Please check the input parameters');
end

% patch dimension check
if mod(pdims(1),2) || mod(pdims(2),2)
    error('Background patch resolutions should be divided by 2! Please check the input parameters');
end

% background patch size check
if round(wdims(1)/patchnum(1))<pdims(1) || round(wdims(2)/patchnum(2))<pdims(2)
    error('Background patch sizes are too big for the current window resolutions! Please check the input parameters');
end


%%% start creating stimulus images

% initializing cell arrays
Bimg=cell(2,1);

% calculate centers (X,Y) of each patch
p_edgeY=mod(wdims(1),patchnum(1)); % delete exceeded region
p_intervalY=round((wdims(1)-p_edgeY)/patchnum(1)); % intervals between patches
p_Y=p_intervalY/2+p_edgeY/2:p_intervalY:wdims(1)-p_edgeY/2;
clear p_edgeY p_intervalY;

p_edgeX=mod(wdims(2),patchnum(2)); % delete exceeded region
p_intervalX=round((wdims(2)-p_edgeX)/patchnum(2)); % intervals between patches
p_X=p_intervalX/2+p_edgeX/2:p_intervalX:wdims(2)-p_edgeX/2;
clear p_edgeX p_intervalX;

% calculate X & Y start point
p_Ys=int32(p_Y-pdims(1)/2);
p_Xs=int32(p_X-pdims(2)/2);
% calculate X & Y end point
p_Ye=int32(p_Y+pdims(1)/2);
p_Xe=int32(p_X+pdims(2)/2);

%%% create background images

% fill the background with bgcolor
for cc=1:1:3 % RGB
  Bimg{1}(:,:,cc)=bgcolor(cc)*ones(wdims);
end

% creating patches
for xx=1:1:length(p_Xs)
  for yy=1:1:length(p_Ys)

    ss=randi(3,[1,1]);
    % create a patch with color1
    if ss==1
      for cc=1:1:3
        Bimg{1}(p_Ys(yy)+1:p_Ye(yy),p_Xs(xx)+1:p_Xe(xx),cc)=color1(cc);
      end
    % create a patch with color2
    elseif ss==2
      for cc=1:1:3
        Bimg{1}(p_Ys(yy)+1:p_Ye(yy),p_Xs(xx)+1:p_Xe(xx),cc)=color2(cc);
      end
    % do nothing
    else
      % empty
    end % if ss

  end % for yy
end % for xx

% fill the target region with bgcolor
for cc=1:1:3
  Bimg{1}( (wdims(1)-stdims(1))/2:(wdims(1)-stdims(1))/2+stdims(1),(wdims(2)-stdims(2))/2:(wdims(2)-stdims(2))/2+stdims(2),cc )=bgcolor(cc);
end

% left/right images are same
if fix_flag>0
  Bimg{1}=AddFixationToImage(Bimg{1},fix_flag,fixcolor);
end

Bimg{1}=uint8(Bimg{1});
Bimg{2}=Bimg{1};

%fprintf('\n');
%disp('Stimulus Generation Completed.');

if save_flag
  fprintf('Saving images...');
  save Background.mat Bimg parameters;
  fprintf('Done.\n');
end

if show_flag

  disp('Showing Created Stimuli.')
  figure;

    %subplot(1,2,1); hold on;
    imshow(Bimg{1},[0 255]);
    axis off;
    title('Background Left');

%    subplot(1,2,2); hold on;
%    imshow(Bimg{2},[0 255]);
%    axis off;
%    title('Background Right');

    drawnow; pause(0.5);

end % if show_flag

return
