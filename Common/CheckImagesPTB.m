function imgfiles=CheckImagesPTB(img_dir,img_ext,auto_msec,img_size)

% Reads images in the target directory and presents them onto the PTB screen
% function imgfiles=CheckImagesPTB(img_dir,:img_ext,:auto_msec,:img_size)
% (: is optional)
%
% This function reads all the images in the target directory and display
% them successively by detecting button press or automatically.
% The key manipulations are done by pressing
% left  arrow : displaying the previous image
% rigth arrow : displaying the next image
% When auto_msec is set to non-zero value, the images will be presented
% successively automatically with the auto_msec intervals.
%
% [input]
% img_dir   : target directory in which images are included.
%             a relative path format in which the directory where this
%             function is called is the origin. e.g. img_dir='../imgs';
% img_ext   : (optional) file extension of the target image files.
%             e.g. img_ext='.jpg';, empty by default.
% auto_msec : (optional) an interval in msec to present images automatically
%             if 0, the image change will be done by the key pressing.
%             0 by default.
% img_size  : (optional) display image size, [row, col] (pixels)
%             when this values are empty, the image size will be automatically
%             adjusted. empty by default
%
% [output]
% imgfiles : a list of the images in the img_dir, a cell structure
%
% [note]
% a log file will be saved in the directory where this function is called.
%
% [dependencies]
% 1. Hiroshi's Common tools
% 2. Psychtoolbox ver 3 or above
%
%
% Created    : "2015-07-18 16:14:34 ban"
% Last Update: "2015-07-29 15:08:37 ban"

% check the input variables
if nargin<1 || isempty(img_dir), help(mfilename()); return; end
if nargin<2 || isempty(img_ext), img_ext=''; end
if nargin<3 || isempty(auto_msec), auto_msec=0; end
if nargin<4 || isempty(img_size), img_size=[]; end

img_dir=fullfile(pwd,img_dir);
if ~exist(img_dir,'dir'), error('can not find img_dir. check input variable.'); end

% log file
diary(fullfile(fileparts(mfilename('fullpath')),strcat(mfilename(),'_',datestr(date,'yymmdd'),'.log')));

% PTB setup
DisableJISkeyTrouble();
KbName('UnifyKeyNames');

Screen('Preference','VisualDebuglevel', 3);

if strcmpi(img_ext,'MPO')
  [winPtr,winRect,nScr,fps,ifi,initDisplay_OK]=InitializePTBDisplays('shutter',[127,127,127],0); %#ok
else
  [winPtr,winRect,nScr,fps,ifi,initDisplay_OK]=InitializePTBDisplays('mono',[127,127,127],0); %#ok
end

if ~initDisplay_OK, error('Display initialization error. Please check your exp_run parameter.'); end
HideCursor();

priorityLevel=MaxPriority(winPtr,'WaitBlanking');
Priority(priorityLevel);

InitializeMatlabOpenGL();
AssertOpenGL();

Screen('BlendFunction',winPtr,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

% processing
fprintf('\n');
imgfiles=wildcardsearch(img_dir,['*',img_ext]);

ii=1; % image ID
end_flg=0;
while 1

  % generate image textures for left/right eyes and displaying
  imgfile=relativepath(imgfiles{ii}); imgfile=imgfile(1:end-1); % remove the final '/'
  [dummy,imgfname,imgext]=fileparts(imgfile); %#ok
  fprintf('Target image %05d: %s%s\n',ii,imgfname,imgext)

  if strcmpi(img_ext,'mpo')
    imgs=imreadmpo(imgfile,0);
    img=zeros(1,2); for pp=1:1:2, img(pp)=Screen('MakeTexture',winPtr,imgs{pp}); end

    % display size adjustment
    if isempty(img_size)
      sz=size(imgs{pp});
      sz=sz(1:2);
      disp_size=sz;
      if size(imgs{pp},1)>winRect(2) || size(imgs{pp},2)>winRect(1) % the image exceeds the screen size
        scale_not=1;
        weight=0.95;
        while scale_not
          disp_size=weight.*disp_size;
          if disp_size(2)<=winRect(3) && disp_size(1)<=winRect(4), scale_not=0; end
        end
      end
    else
      disp_size=img_size;
    end

    for nn=1:1:nScr
      Screen('SelectStereoDrawBuffer',winPtr,nn-1);
      Screen('DrawTexture',winPtr,img(nn),[0,0,sz(2),sz(1)],CenterRect([0,0,disp_size(2),disp_size(1)],winRect));
    end
  else
    imgs=imread(imgfile);
    img=Screen('MakeTexture',winPtr,imgs);

    % display size adjustment
    if isempty(img_size)
      sz=size(imgs);
      sz=sz(1:2);
      disp_size=sz;
      if size(imgs,1)>winRect(2) || size(imgs,2)>winRect(1) % the image exceeds the screen size
        scale_not=1;
        weight=0.95;
        while scale_not
          disp_size=weight.*disp_size;
          if disp_size(2)<=winRect(3) && disp_size(1)<=winRect(4), scale_not=0; end
        end
      end
    else
      disp_size=img_size;
    end

    Screen('SelectStereoDrawBuffer',winPtr,0);
    Screen('DrawTexture',winPtr,img,[0,0,sz(2),sz(1)],CenterRect([0,0,disp_size(2),disp_size(1)],winRect));
  end

  Screen('DrawingFinished',winPtr);
  Screen('Flip',winPtr);

  if ~auto_msec

    % check button and classify the images
    key_check=1;
    while key_check
      [keyIsDown,keysecs,keyCode]=KbCheck(); %#ok
      if keyIsDown
        if (keyCode(KbName('q'))==1 || keyCode(KbName('escape'))==1)
          Screen('CloseAll');
          end_flg=1;
          break;
        elseif keyCode(37)==1 % left arrow --- back to the previous image
          ii=max(ii-1,1);
          if ii==1
            fprintf('the first image in the directory');
          end
          key_check=0;
        elseif keyCode(39)==1 % right arrow --- go to the next image
          ii=min(ii+1,length(imgfiles));
          if ii==length(imgfiles)
            fprintf('the final image in the directory');
          end
          key_check=0;
        end
      end
    end

  else % if ~auto_msec

    % wait for auto_msec and proceed to the next
    ii=ii+1;
    if ii>length(imgfiles)
      Screen('CloseAll');
      end_flg=1; %#ok
      break
    end
    WaitSecs(auto_msec/1000);

    [keyIsDown,keysecs,keyCode]=KbCheck(); %#ok
    if keyIsDown
      if (keyCode(KbName('q'))==1 || keyCode(KbName('escape'))==1)
        Screen('CloseAll');
        end_flg=1; %#ok
        break
      end
    end

  end % if ~auto_msec

  % clean up
  clear imgs;
  if end_flg~=1
    for nn=1:1:nScr
      Screen('SelectStereoDrawBuffer',winPtr,nn-1);
      Screen('FillRect',winPtr,[127,127,127]);
    end
    Screen('DrawingFinished',winPtr);
    Screen('Flip',winPtr);

    if strcmpi(img_ext,'mpo')
      for pp=1:1:2, Screen('Close',img(pp)); end
    else
      Screen('Close',img);
    end
    pause(0.1);
  else
    break;
  end


end % while 1

ShowCursor();
diary off;

return
