function oimg=mkWiggleStereoscopy(img1,img2,option,display_flg,save_flg)

% Generates a wiggle stereoscopy movie (e.g. for stereo viewing).
% function oimg=mkWiggleStereoscopy(img1,img2,option,display_flg,save_flg)
%
% This function generates wiggle-stereoscopy image from img1 & img2
%
% [input]
% img1   : input image 1 with relative path, e.g. '/imgs/scene_left.bmp'
% img2   : input image 2 with relative path, e.g. '/imgs/scene_right.bmp'
% option : option parameters for an output wiggle stereoscopy movie.
%          structure with the elements below
%          .duration  : image presentation duration in msec for each image
%                       100 by default.
%          .nrepeat   : the number of repetitions of presenting a pair of images.
%          .type      : type of wiggle stereoscopy image, "gif", "avi", or "mp4"
%                       "gif" by default. effective only when the save_flg is set to 1.
%          .name      : output movie file name, "wigglestereopsis" by default.
%                       effective only when the save_flg is set to 1.
%          .framerate : frame rate of the generated wiggle streoscopy movie. 30 by default.
% display_flg : whether displaying the generated image, [0|1]
%               0 (not displaying) by default
% save_flg    : whether saving the generated image, [0|1]
%               0 (not displaying) by default
%
% [output]
% oimg : generated wiggle stereoscopy iamge data
%
%
% Created    : "2024-03-22 15:44:21 ban"
% Last Update: "2024-03-25 14:09:07 ban"

cv_hbtools_StimCommon_setup(1);

% check input variables
if nargin<2, help(mfilename()); return; end
if nargin<3 || isempty(option)
  option.duration=100;
  option.nrepeat=10;
  option.type='avi';
  option.name='wigglestereopsis';
  option.framerate=30;
end
if nargin<4 || isempty(display_flg), display_flg=0; end
if nargin<5 || isempty(save_flg), save_flg=0; end

if ~isstructmember(option,'duration'), option.duration=100; end
if ~isstructmember(option,'nrepeat'), option.nrepeat=10; end
if ~isstructmember(option,'type'), option.type='gif'; end
if ~isstructmember(option,'name'), option.name='wigglestereopsis'; end
if ~isstructmember(option,'framerate'), option.framerate=30; end

% loading input images
fprintf('input 1: %s\n',fullfile(pwd,img1));
fprintf('input 2: %s\n',fullfile(pwd,img2));
im1=imread(fullfile(pwd,img1));
im2=imread(fullfile(pwd,img2));

% displaying the wiggle stereoscopy
if display_flg
  fprintf('displaying generated wiggle stereoscopy image...');
  fig=figure('Name','Wiggle Stereoscopy','MenuBar','none');
  h1=imshow(im1); set(h1,'Visible',0);
  hold on;
  h2=imshow(im2); set(h2,'Visible',0);

  for ii=1:1:option.nrepeat
    set(h1,'Visible',mod(ii,2));
    set(h2,'Visible',1-mod(ii,2));
    pause(option.duration/1000);
  end
  close(fig);
  fprintf('done.\n');
end % if display_flg

% making movie
if save_flg
  fig=figure('Name','Wiggle Stereoscopy','MenuBar','none');
  h1=imshow(im1); set(h1,'Visible',0);
  hold on;
  h2=imshow(im2); set(h2,'Visible',0);

  fprintf('saving generated wiggle stereoscopy image...');
  if ~strcmp(option.type,'gif')
    if strcmp(option.type,'mp4')
      mv=VideoWriter('wigglestereoscopy.mp4','MPEG-4');
    elseif strcmp(option.type,'avi')
      mv=VideoWriter('wigglestereoscopy.avi','Motion JPEG AVI');
    end

    mv.FrameRate=option.framerate;
    open(mv);
    for ii=1:1:round(option.framerate*option.duration/1000)
      set(h1,'Visible',1);
      set(h2,'Visible',0);
      mvf=getframe(gcf);
      writeVideo(mv,mvf);
    end
    for ii=round(option.framerate*option.duration/1000)+1:1:round(2*option.framerate*option.duration/1000)
      set(h1,'Visible',0);
      set(h2,'Visible',1);
      mvf=getframe(gcf);
      writeVideo(mv,mvf);
    end
    mvf=getframe(gcf);
    writeVideo(mv,mvf);
    close(mv);
  else % if ~strcmp(option.type,'gif')
    set(h1,'Visible',1);
    set(h2,'Visible',0);
    [A,map]=rgb2ind(frame2im(getframe(gcf)),256);
    imwrite(A,map,'wigglestereoscopy.gif','gif','LoopCount',Inf,'DelayTime',round(option.duration/1000));

    set(h1,'Visible',0);
    set(h2,'Visible',1);
    [A,map]=rgb2ind(frame2im(getframe(gcf)),256);
    imwrite(A,map,'wigglestereoscopy.gif','gif','WriteMode','append','DelayTime',round(option.duration/1000));
  end

  close(fig);
  fprintf('done.\n');
end

cv_hbtools_StimCommon_setup(0);

return
